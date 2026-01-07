import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:isolate';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'llama_bindings.dart';

/// Token event sent from Isolate to main thread
class TokenEvent {
  final String token;
  final int timeMs;

  const TokenEvent(this.token, this.timeMs);
}

/// Message types for Isolate communication
sealed class IsolateMessage {}

class LoadModelMessage extends IsolateMessage {
  final String modelPath;
  LoadModelMessage(this.modelPath);
}

class RunInferenceMessage extends IsolateMessage {
  final String prompt;
  final int maxTokens;
  RunInferenceMessage(this.prompt, this.maxTokens);
}

class DisposeMessage extends IsolateMessage {}

/// High-level service for llama.cpp inference
/// Runs inference in a separate Isolate to prevent UI blocking
class LlamaService {
  Isolate? _isolate;
  SendPort? _sendPort;
  final _receivePort = ReceivePort();
  final _tokenController = StreamController<TokenEvent>.broadcast();
  final _statusController = StreamController<String>.broadcast();

  Stream<TokenEvent> get tokenStream => _tokenController.stream;
  Stream<String> get statusStream => _statusController.stream;

  bool _isInitialized = false;
  final _bindingsForMain = LlamaBindings();
  String? _lastLoadedModelPath;

  /// Initialize the service and spawn the Isolate
  Future<void> initialize() async {
    if (_isInitialized) return;

    _receivePort.listen((message) {
      if (message is SendPort) {
        _sendPort = message;
        _statusController.add('Isolate ready');
      } else if (message is TokenEvent) {
        _tokenController.add(message);
      } else if (message is List<TokenEvent>) {
        for (final event in message) {
          _tokenController.add(event);
        }
      } else if (message is String) {
        _statusController.add(message);
      }
    });

    _isolate = await Isolate.spawn(
      _isolateEntry,
      _receivePort.sendPort,
      debugName: 'NPUCheckInferenceIsolate',
    );

    // Wait for Isolate to be ready
    await _statusController.stream.firstWhere((msg) => msg == 'Isolate ready');
    _isInitialized = true;
  }

  /// Load a model from GGUF file
  Future<void> loadModel(String modelPath) async {
    if (_lastLoadedModelPath == modelPath) {
      _statusController.add('Model already loaded: $modelPath');
      return;
    }

    if (!_isInitialized) await initialize();
    _sendPort?.send(LoadModelMessage(modelPath));
    _lastLoadedModelPath = modelPath;
    
    // Wait for the status controller to receive "Model loaded successfully" or Error
    final result = await _statusController.stream.firstWhere(
      (msg) => msg.startsWith('Model loaded successfully') || msg.startsWith('Error'),
    );

    if (result.startsWith('Error')) {
      _lastLoadedModelPath = null;
      throw Exception(result);
    }
  }

  /// Run inference with the loaded model
  Future<void> runInference(String prompt, {int maxTokens = 100}) async {
    if (!_isInitialized) {
      throw StateError('Service not initialized. Call initialize() first.');
    }
    _sendPort?.send(RunInferenceMessage(prompt, maxTokens));
  }

  /// Stop ongoing inference
  void stopInference() {
    _bindingsForMain.stopInference();
  }

  /// Get current RAM usage in MB
  double getRamUsage() {
    try {
      // ProcessInfo.currentRss returns the Resident Set Size in bytes.
      // This includes memory used by the entire process (all Isolates and native code).
      return ProcessInfo.currentRss / (1024 * 1024);
    } catch (e) {
      return 0.0;
    }
  }

  /// Dispose the model and clean up resources
  Future<void> dispose() async {
    // 1. Tell native code to stop any ongoing inference
    // This affects the global state in the C++ library shared by isolates
    _bindingsForMain.stopInference();

    // 2. Try to signal the isolate to dispose gracefully
    _sendPort?.send(DisposeMessage());
    
    // 3. Give it time to break the inference loop and process the message
    await Future.delayed(const Duration(milliseconds: 300));
    
    // 4. Kill it if it's still alive
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _sendPort = null;
    _isInitialized = false;
    _lastLoadedModelPath = null;
    
    await _tokenController.close();
    await _statusController.close();
    _receivePort.close();
  }

  /// Isolate entry point - runs in separate thread
  static void _isolateEntry(SendPort mainSendPort) {
    final isolateReceivePort = ReceivePort();
    final bindings = LlamaBindings();

    // Send our SendPort back to main thread
    mainSendPort.send(isolateReceivePort.sendPort);

    // Set up the native callback
    _isolateSendPort = mainSendPort;
    final callbackPointer = ffi.Pointer.fromFunction<TokenCallbackNative>(
      _nativeTokenCallback,
    );
    bindings.setTokenCallback?.call(callbackPointer);

    // Listen for messages from main thread
    isolateReceivePort.listen((message) {
      try {
        if (message is LoadModelMessage) {
          mainSendPort.send('Loading model: ${message.modelPath}');
          final pathPtr = message.modelPath.toNativeUtf8();
          final result = bindings.loadModel(pathPtr.cast());
          malloc.free(pathPtr);

          if (result == 0) {
            mainSendPort.send('Model loaded successfully');
          } else {
            mainSendPort.send('Error: Failed to load model (code: $result)');
          }
        } else if (message is RunInferenceMessage) {
          mainSendPort.send('Starting inference...');
          
          // Start the batching timer
          _batchTimer?.cancel();
          _batchTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
            if (_tokenBatch.isNotEmpty) {
              mainSendPort.send(List<TokenEvent>.of(_tokenBatch));
              _tokenBatch.clear();
            }
          });

          final promptPtr = message.prompt.toNativeUtf8();
          final tokensGenerated = bindings.runInference(
            promptPtr.cast(),
            message.maxTokens,
          );
          malloc.free(promptPtr);

          // Stop timer and send any remaining tokens
          _batchTimer?.cancel();
          if (_tokenBatch.isNotEmpty) {
            mainSendPort.send(List<TokenEvent>.of(_tokenBatch));
            _tokenBatch.clear();
          }
          
          // Get the generated text
          final textPtr = bindings.getGeneratedText();
          final generatedText = textPtr.cast<Utf8>().toDartString();
          
          print('DEBUG: Generated text length: ${generatedText.length}');
          print('DEBUG: Generated text: $generatedText');
          
          // Send both token count and generated text
          mainSendPort.send('Inference complete: $tokensGenerated tokens');
          mainSendPort.send(TokenEvent(generatedText, DateTime.now().millisecondsSinceEpoch));
        } else if (message is DisposeMessage) {
          _batchTimer?.cancel();
          bindings.disposeModel();
          mainSendPort.send('Model disposed');
          isolateReceivePort.close();
        }
      } catch (e) {
        mainSendPort.send('Error: $e');
      }
    });
  }

  static SendPort? _isolateSendPort;
  static final List<TokenEvent> _tokenBatch = [];
  static Timer? _batchTimer;

  /// Native callback wrapper (must be top-level or static)
  static void _nativeTokenCallback(ffi.Pointer<ffi.Char> token, int timeMs) {
    if (_isolateSendPort != null) {
      final tokenStr = token.cast<Utf8>().toDartString();
      _tokenBatch.add(TokenEvent(tokenStr, timeMs));
    }
  }
}
