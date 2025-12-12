import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../../core/services/llama_service.dart';
import '../domain/model_manager.dart';
import '../domain/model_strategy.dart';
import '../domain/model_type.dart';
import '../data/repositories/benchmark_repository.dart';
import '../data/models/benchmark_result.dart';
import 'benchmark_state.dart';

part 'benchmark_controller.g.dart';

@riverpod
@riverpod
class BenchmarkController extends _$BenchmarkController {
  LlamaService? _llamaService;
  late final ModelManager _modelManager;
  late final BenchmarkRepository _repository;
  StreamSubscription? _tokenSubscription;
  StreamSubscription? _statusSubscription;
  
  int _tokensGenerated = 0;
  DateTime? _startTime;

  @override
  BenchmarkState build() {
    _modelManager = ModelManager();
    _repository = ref.watch(benchmarkRepositoryProvider);
    
    ref.onDispose(() {
      _disposeService();
    });

    return const BenchmarkState();
  }

  Future<void> _initService() async {
    if (_llamaService != null) return;
    
    _llamaService = LlamaService();
    
    _tokenSubscription = _llamaService!.tokenStream.listen(_onTokenReceived);
    _statusSubscription = _llamaService!.statusStream.listen(_onStatusUpdate);
    
    await _llamaService!.initialize();
  }

  Future<void> _disposeService() async {
    await _tokenSubscription?.cancel();
    await _statusSubscription?.cancel();
    _tokenSubscription = null;
    _statusSubscription = null;
    
    await _llamaService?.dispose();
    _llamaService = null;
  }

  /// Select a model
  void selectModel(ModelType modelType) {
    state = state.copyWith(selectedModel: modelType);
  }

  /// Select a workload
  void selectWorkload(BenchmarkWorkload workload) {
    state = state.copyWith(workload: workload);
  }

  /// Start a benchmark
  Future<void> startBenchmark() async {
    try {
      state = state.copyWith(
        status: BenchmarkStatus.loadingModel,
        errorMessage: null,
        generatedText: '',
        currentSpeed: 0.0,
      );

      // Initialize service
      await _initService();

      // Select model strategy based on selected model
      final strategy = await _modelManager.selectStrategy(
        modelType: state.selectedModel,
      );

      state = state.copyWith(
        modelName: strategy.modelName,
      );

      // Get model path
      String modelPath;
      if (strategy is OnlineModelStrategy) {
        state = state.copyWith(status: BenchmarkStatus.downloading);
        
        // Set up progress tracking
        final strategyWithProgress = OnlineModelStrategy(
          downloadUrl: strategy.downloadUrl,
          modelName: strategy.modelName,
          sizeMB: strategy.expectedSizeMB,
          onProgress: (progress) {
            state = state.copyWith(progress: progress);
          },
        );

        try {
          modelPath = await _modelManager.downloadModel(strategyWithProgress);
        } catch (e) {
          // Download failed
          state = state.copyWith(
            status: BenchmarkStatus.error,
            errorMessage: 'Failed to download model: $e',
          );
          return;
        }
      } else if (strategy is OfflineModelStrategy) {
        // This shouldn't happen anymore, but keep for backwards compatibility
        try {
          modelPath = await _modelManager.extractAssetModel(strategy);
        } catch (e) {
          state = state.copyWith(
            status: BenchmarkStatus.error,
            errorMessage: 'Model not found. Please connect to internet to download.',
          );
          return;
        }
      } else if (strategy is EmbeddedModelStrategy) {
        // Extract embedded model from assets
        modelPath = await _modelManager.extractEmbeddedModel(strategy);
      } else {
        modelPath = await strategy.getModelPath();
      }

      // Load model
      await _llamaService!.loadModel(modelPath);

      // Start inference
      state = state.copyWith(
        status: BenchmarkStatus.running,
        progress: 0.0,
      );

      _tokensGenerated = 0;
      _startTime = DateTime.now();
      
      final workload = state.workload;
      
      if (workload.isTimeBased) {
        // Time-based loop
        while (DateTime.now().difference(_startTime!) < workload.minDuration) {
          // Verify if we should stop (user cancelled)
          if (state.status != BenchmarkStatus.running) break;
          
          await _runOnePass(maxTokens: 1024); // Use large max tokens to fill time
        }
      } else {
        // Token-based (single pass)
        await _runOnePass(maxTokens: workload.tokens);
      }

      // Check if we were cancelled during the loop
      if (state.status == BenchmarkStatus.running) {
        // Save result
        await _saveResult();
        state = state.copyWith(status: BenchmarkStatus.completed);
      }
      
    } catch (e) {
      await _disposeService();
      state = state.copyWith(
        status: BenchmarkStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _runOnePass({required int maxTokens}) async {
    // Start inference
    await _llamaService!.runInference(
      'Write a short story about artificial intelligence:',
      maxTokens: maxTokens,
    );
    
    // Wait for completion
    // We listen to the status stream for "Inference complete"
    await _llamaService!.statusStream.firstWhere(
      (msg) => msg.startsWith('Inference complete') || msg.startsWith('Error'),
    );
  }

  /// Handle incoming tokens
  void _onTokenReceived(TokenEvent event) {
    // 1. Update the displayed text
    state = state.copyWith(generatedText: event.token);

    // 2. Estimate token count
    // This is a rough approximation. For accurate token counting, a proper
    // tokenizer would be needed. Here, we assume ~4 chars per token.
    final estimatedTokens = (event.token.length / 4).round();
    _tokensGenerated = estimatedTokens;

    // 3. Calculate speed & progress
    if (_startTime != null && _tokensGenerated > 0) {
      final now = DateTime.now();
      final elapsed = now.difference(_startTime!);
      
      if (elapsed.inMilliseconds > 0) {
        final tokensPerSecond = _tokensGenerated / elapsed.inMilliseconds * 1000;
        
        double progress;
        if (state.workload.isTimeBased) {
          // Progress based on time
          progress = elapsed.inMilliseconds / state.workload.minDuration.inMilliseconds;
        } else {
          // Progress based on tokens
          progress = _tokensGenerated / state.workload.tokens;
        }
        
        state = state.copyWith(
          currentSpeed: tokensPerSecond,
          progress: progress.clamp(0.0, 1.0),
        );
      }
    }

    // 4. Update RAM usage (placeholder)
    final ramUsage = _llamaService?.getRamUsage() ?? 0.0;
    state = state.copyWith(ramUsageMB: ramUsage);
  }


  /// Handle status updates
  void _onStatusUpdate(String status) {
    // Log status updates (could be displayed in UI)
    print('Benchmark status: $status');
  }

  /// Save benchmark result to Hive
  Future<void> _saveResult() async {
    final deviceInfo = DeviceInfoPlugin();
    String deviceModel = 'Unknown';

    try {
      final androidInfo = await deviceInfo.androidInfo;
      deviceModel = '${androidInfo.manufacturer} ${androidInfo.model}';
    } catch (e) {
      // iOS or other platform
      try {
        final iosInfo = await deviceInfo.iosInfo;
        deviceModel = iosInfo.model;
      } catch (_) {}
    }

    final result = BenchmarkResult(
      timestamp: DateTime.now(),
      deviceModel: deviceModel,
      aiModelName: state.modelName ?? 'Unknown',
      tokensPerSecond: state.currentSpeed,
      ramUsageMB: state.ramUsageMB,
    );

    await _repository.saveBenchmark(result);
  }

  /// Stop the benchmark
  Future<void> stopBenchmark() async {
    await _disposeService();
    state = state.copyWith(status: BenchmarkStatus.idle);
  }
}

// Provider for benchmark repository
@riverpod
BenchmarkRepository benchmarkRepository(BenchmarkRepositoryRef ref) {
  return BenchmarkRepository();
}
