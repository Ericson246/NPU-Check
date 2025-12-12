import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../../core/services/llama_service.dart';
import '../domain/model_manager.dart';
import '../domain/model_strategy.dart';
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
    
    return const BenchmarkState();
  }

  /// Start a benchmark
  Future<void> startBenchmark({bool forceOffline = false}) async {
    try {
      state = state.copyWith(
        status: BenchmarkStatus.loadingModel,
        errorMessage: null,
        generatedText: '',
        currentSpeed: 0.0,
      );

      // Initialize service
      await _llamaService.initialize();

      // Select model strategy
      final strategy = await _modelManager.selectStrategy(
        forceOffline: forceOffline,
      );

      state = state.copyWith(
        isOfflineMode: strategy is OfflineModelStrategy,
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
          // Fallback to offline
          state = state.copyWith(
            isOfflineMode: true,
            status: BenchmarkStatus.loadingModel,
          );
          final offlineStrategy = OfflineModelStrategy();
          modelPath = await _modelManager.extractAssetModel(offlineStrategy);
          state = state.copyWith(modelName: offlineStrategy.modelName);
        }
      } else if (strategy is OfflineModelStrategy) {
        modelPath = await _modelManager.extractAssetModel(strategy);
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
        maxTokens: 100,
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
    _tokensGenerated++;
    
    // Update generated text
    final newText = state.generatedText + event.token;
    state = state.copyWith(generatedText: newText);

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

  @override
  void dispose() {
    _llamaService.dispose();
    super.dispose();
  }
}

// Provider for benchmark repository
@riverpod
BenchmarkRepository benchmarkRepository(BenchmarkRepositoryRef ref) {
  return BenchmarkRepository();
}
