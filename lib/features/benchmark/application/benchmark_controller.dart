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
class BenchmarkController extends _$BenchmarkController {
  late final LlamaService _llamaService;
  late final ModelManager _modelManager;
  late final BenchmarkRepository _repository;
  
  int _tokensGenerated = 0;
  DateTime? _startTime;

  @override
  BenchmarkState build() {
    _llamaService = LlamaService();
    _modelManager = ModelManager();
    _repository = ref.watch(benchmarkRepositoryProvider);
    
    // Listen to token stream
    _llamaService.tokenStream.listen(_onTokenReceived);
    _llamaService.statusStream.listen(_onStatusUpdate);
    
    ref.onDispose(() {
      _llamaService.dispose();
    });

    return const BenchmarkState();
  }

  /// Select a model
  void selectModel(ModelType modelType) {
    state = state.copyWith(selectedModel: modelType);
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
      await _llamaService.initialize();

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
      await _llamaService.loadModel(modelPath);

      // Start inference
      state = state.copyWith(
        status: BenchmarkStatus.running,
        progress: 0.0,
      );

      _tokensGenerated = 0;
      _startTime = DateTime.now();

      await _llamaService.runInference(
        'Write a short story about artificial intelligence:',
        maxTokens: 50,
      );

      // Save result
      await _saveResult();

      state = state.copyWith(status: BenchmarkStatus.completed);
      
    } catch (e) {
      state = state.copyWith(
        status: BenchmarkStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Handle incoming tokens
  void _onTokenReceived(TokenEvent event) {
    // The event.token contains all generated text
    // We need to estimate token count or get it from the event
    // For now, estimate based on words (rough approximation)
    final words = event.token.trim().split(RegExp(r'\s+'));
    _tokensGenerated = words.length;
    
    // Update generated text
    state = state.copyWith(generatedText: event.token);

    // Calculate speed
    if (_startTime != null) {
      final elapsed = DateTime.now().difference(_startTime!);
      final tokensPerSecond = _tokensGenerated / elapsed.inMilliseconds * 1000;
      state = state.copyWith(currentSpeed: tokensPerSecond);
    }

    // Update RAM usage
    final ramUsage = _llamaService.getRamUsage();
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
    await _llamaService.dispose();
    state = state.copyWith(status: BenchmarkStatus.idle);
  }
}

// Provider for benchmark repository
@riverpod
BenchmarkRepository benchmarkRepository(BenchmarkRepositoryRef ref) {
  return BenchmarkRepository();
}
