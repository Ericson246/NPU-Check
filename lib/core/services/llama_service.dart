import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:isolate';
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

  /// Initialize the service and spawn the Isolate
  Future<void> initialize() async {
    if (_isInitialized) return;

    _receivePort.listen((message) {
      if (message is SendPort) {
        _sendPort = message;
        _statusController.add('Isolate ready');
      } else if (message is TokenEvent) {
        _tokenController.add(message);
      } else if (message is String) {
        _statusController.add(message);
      }
    });

    _isolate = await Isolate.spawn(
      _isolateEntry,
      _receivePort.sendPort,
      debugName: 'LlamaInferenceIsolate',
    );

    // Wait for Isolate to be ready
    await _statusController.stream.firstWhere((msg) => msg == 'Isolate ready');
    _isInitialized = true;
  }

  /// Load a model from the given path
  Future<void> loadModel(String modelPath) async {
    if (!_isInitialized) {
      throw StateError('Service not initialized. Call initialize() first.');
    }
    _sendPort?.send(LoadModelMessage(modelPath));
  }

  /// Run inference with the loaded model
  Future<void> runInference(String prompt, {int maxTokens = 100}) async {
    if (!_isInitialized) {
      throw StateError('Service not initialized. Call initialize() first.');
    }
    _sendPort?.send(RunInferenceMessage(prompt, maxTokens));
  }

  /// Get current RAM usage in MB
  double getRamUsage() {
    // This is called from main thread, not Isolate
    // For real implementation, you'd need to send a message and wait for response
    // For now, return 0 as placeholder
    return 0.0;
  }

  /// Dispose the model and clean up resources
  Future<void> dispose() async {
    _sendPort?.send(DisposeMessage());
    await Future.delayed(const Duration(milliseconds: 100));
    
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _sendPort = null;
    _isInitialized = false;
    
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

    // Token callback - sends tokens back to main thread
    void tokenCallback(ffi.Pointer<Utf8> tokenPtr, int timeMs) {
      final token = tokenPtr.toDartString();
      mainSendPort.send(TokenEvent(token, timeMs));
    }

    // Set up the native callback
    final callbackPointer = ffi.Pointer.fromFunction<TokenCallbackNative>(
      _nativeTokenCallback,
    );
    bindings.setTokenCallback(callbackPointer);

    // Listen for messages from main thread
    isolateReceivePort.listen((message) {
      try {
        if (message is LoadModelMessage) {
          mainSendPort.send('Loading model: ${message.modelPath}');
          final pathPtr = Utf8Pointer.fromString(message.modelPath);
          final result = bindings.loadModel(pathPtr);
          ffi.malloc.free(pathPtr);

          if (result == 0) {
            mainSendPort.send('Model loaded successfully');
          } else {
            mainSendPort.send('Error: Failed to load model');
          }
        } else if (message is RunInferenceMessage) {
          mainSendPort.send('Starting inference...');
          final promptPtr = Utf8Pointer.fromString(message.prompt);
          final tokensGenerated = bindings.runInference(
            promptPtr,
            message.maxTokens,
          );
          ffi.malloc.free(promptPtr);

          mainSendPort.send('Inference complete: $tokensGenerated tokens');
        } else if (message is DisposeMessage) {
          bindings.disposeModel();
          mainSendPort.send('Model disposed');
          isolateReceivePort.close();
        }
      } catch (e) {
        mainSendPort.send('Error: $e');
      }
    });
  }

  /// Native callback wrapper (must be top-level or static)
  static void _nativeTokenCallback(ffi.Pointer<Utf8> token, int timeMs) {
    // This gets called from C++, but we need to route it through the Isolate
    // In practice, you'd use a more sophisticated mechanism
    // For now, this is a placeholder
  }
}
