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
class BenchmarkController extends _$BenchmarkController {
  LlamaService? _llamaService;
  late final ModelManager _modelManager;
  late final BenchmarkRepository _repository;
  StreamSubscription? _tokenSubscription;
  StreamSubscription? _statusSubscription;
  
  int _tokensGenerated = 0;
  DateTime? _startTime;
  final List<DateTime> _tokenWindow = [];
  DateTime? _lastUpdate;
  final StringBuffer _generatedBuffer = StringBuffer();
  final Map<ModelType, Future<String?>> _activeDownloads = {};

  @override
  BenchmarkState build() {
    _modelManager = ModelManager();
    _repository = ref.watch(benchmarkRepositoryProvider);
    
    // Initial check for downloaded models
    Future.microtask(() => _refreshDownloadedModels());

    ref.onDispose(() {
      _disposeService();
    });

    return const BenchmarkState();
  }

  Future<void> _refreshDownloadedModels() async {
    final List<ModelType> downloaded = [];
    for (final model in ModelType.values) {
      if (model.isEmbedded) {
        downloaded.add(model);
        continue;
      }
      
      final strategy = await _modelManager.selectStrategy(modelType: model);
      // If it's not OnlineModelStrategy, it means it's already local/cached
      if (strategy is! OnlineModelStrategy) {
        downloaded.add(model);
      }
    }
    state = state.copyWith(downloadedModels: downloaded);
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
  Future<void> selectModel(ModelType modelType) async {
    state = state.copyWith(
      selectedModel: modelType,
      status: BenchmarkStatus.idle,
      errorMessage: null,
      progress: 0.0,
    );
    
    // Proactively refresh the downloaded models list to be absolutely sure
    await _refreshDownloadedModels();
    
    // Auto-trigger download if needed
    final strategy = await _modelManager.selectStrategy(modelType: modelType);
    if (strategy is OnlineModelStrategy) {
      if (_activeDownloads.containsKey(modelType)) {
        // Already downloading this model, just wait for the existing task
        return;
      }
      await _ensureModelDownloaded(strategy);
    }
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
        averageSpeed: 0.0,
        progress: 0.0,
        ramUsageMB: 0.0,
        ramPeakMB: 0.0,
      );

      _tokensGenerated = 0;
      _tokenWindow.clear();
      _generatedBuffer.clear();
      _lastUpdate = null;

      // Initialize service
      await _initService();

      // Ensure model is ready (downloaded/extracted)
      final strategy = await _modelManager.selectStrategy(modelType: state.selectedModel);
      final modelPath = await _ensureModelDownloaded(strategy);
      
      if (modelPath == null) return; // Error already handled in _ensureModelDownloaded

      state = state.copyWith(
        status: BenchmarkStatus.loadingModel,
        modelName: strategy.modelName,
      );

      // Load model
      await _llamaService!.loadModel(modelPath);

      // Update RAM usage after loading the model
      _updateRamUsage();

      // Start inference
      state = state.copyWith(
        status: BenchmarkStatus.running,
        progress: 0.0,
      );

      _tokensGenerated = 0;
      _startTime = DateTime.now();
      
      final workload = state.workload;
      Timer? durationTimer;

      if (workload.isTimeBased) {
        // For time-based, we run one large pass and stop it when timer fires
        durationTimer = Timer(workload.minDuration, () {
          if (state.status == BenchmarkStatus.running) {
            _llamaService?.stopInference();
          }
        });
        
        // Large token limit for time-based mode
        await _runOnePass(maxTokens: 10000); 
      } else {
        // Token-based (single pass)
        await _runOnePass(maxTokens: workload.tokens);
      }

      durationTimer?.cancel();

      // Check if we were cancelled during the loop
      if (state.status == BenchmarkStatus.running) {
        // Save result
        await _saveResult();
        state = state.copyWith(status: BenchmarkStatus.completed);
      }
      
    } catch (e) {
      // If the status is already idle or error (stopped by user), don't overwrite with a crash error
      if (state.status == BenchmarkStatus.idle || 
          (state.status == BenchmarkStatus.error && state.errorMessage == 'STOPPED BY USER')) {
        return;
      }

      await _disposeService();
      state = state.copyWith(
        status: BenchmarkStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _runOnePass({required int maxTokens}) async {
    if (_llamaService == null) return;

    // Start inference
    await _llamaService!.runInference(
      'Write a short story about artificial intelligence:',
      maxTokens: maxTokens,
    );
    
    try {
      // Wait for completion
      // We listen to the status stream for "Inference complete"
      await _llamaService!.statusStream.firstWhere(
        (msg) => msg.startsWith('Inference complete') || msg.startsWith('Error'),
      );
    } catch (_) {
      // Stream swallowed/closed - likely due to manual stop
      if (state.status != BenchmarkStatus.running) {
        return;
      }
      rethrow;
    }
  }

  /// Handle incoming tokens
  void _onTokenReceived(TokenEvent event) {
    if (state.status != BenchmarkStatus.running) return;

    // 1. Buffer the token efficiently
    _generatedBuffer.write(event.token);
    _tokensGenerated++;
    
    final now = DateTime.now();
    _tokenWindow.add(now);

    // 2. Remove tokens older than 1 second for the "real-time" speed window
    _tokenWindow.removeWhere((t) => now.difference(t) > const Duration(seconds: 1));

    // 3. Throttle state updates to ~15 FPS (66ms) to avoid lagging the UI
    if (_lastUpdate == null || now.difference(_lastUpdate!) > const Duration(milliseconds: 66)) {
      _updateState(now);
      _lastUpdate = now;
    }
  }

  void _updateState(DateTime now) {
    if (_startTime == null) return;
    
    final totalElapsed = now.difference(_startTime!);
    if (totalElapsed.inMilliseconds <= 0) return;

    // Cumulative Average Speed
    final averageSpeed = _tokensGenerated / totalElapsed.inMilliseconds * 1000;
    
    // Real-time Speed (based on the last 1 second window)
    final windowDurationMs = _tokenWindow.isEmpty 
        ? 0 
        : now.difference(_tokenWindow.first).inMilliseconds;
    
    // Avoid division by zero and handle the initial ramp-up
    final currentSpeed = windowDurationMs < 100 
        ? averageSpeed // Fallback to average during the first 100ms
        : (_tokenWindow.length / (windowDurationMs / 1000.0));
    
    double progress;
    if (state.workload.isTimeBased) {
      progress = totalElapsed.inMilliseconds / state.workload.minDuration.inMilliseconds;
    } else {
      progress = _tokensGenerated / state.workload.tokens;
    }

    state = state.copyWith(
      generatedText: _generatedBuffer.toString(),
      currentSpeed: currentSpeed,
      averageSpeed: averageSpeed,
      progress: progress.clamp(0.0, 1.0),
    );
    
    _updateRamUsage();
  }

  void _updateRamUsage() {
    final currentRam = _llamaService?.getRamUsage() ?? 0.0;
    final peakRam = currentRam > state.ramPeakMB ? currentRam : state.ramPeakMB;
    state = state.copyWith(
      ramUsageMB: currentRam,
      ramPeakMB: peakRam,
    );
  }

  Future<String?> _ensureModelDownloaded(ModelStrategy strategy) async {
    // Find model type from strategy (hacky but effective for now)
    final ModelType? modelType = ModelType.values.any((m) => m.displayName == strategy.modelName) 
        ? ModelType.values.firstWhere((m) => m.displayName == strategy.modelName)
        : null;

    if (modelType != null && _activeDownloads.containsKey(modelType)) {
      return _activeDownloads[modelType];
    }

    final downloadFuture = _prepareModel(strategy);
    
    if (modelType != null) {
      _activeDownloads[modelType] = downloadFuture;
    }

    try {
      final result = await downloadFuture;
      if (modelType != null) _activeDownloads.remove(modelType);
      return result;
    } catch (_) {
      if (modelType != null) _activeDownloads.remove(modelType);
      rethrow;
    }
  }

  Future<String?> _prepareModel(ModelStrategy strategy) async {
    try {
      if (strategy is OnlineModelStrategy) {
        state = state.copyWith(
          status: BenchmarkStatus.downloading,
          modelName: strategy.modelName,
        );

        final strategyWithProgress = OnlineModelStrategy(
          downloadUrl: strategy.downloadUrl,
          modelName: strategy.modelName,
          sizeMB: strategy.expectedSizeMB,
          onProgress: (progress) {
            // Only update progress if we are still viewing/downloading THIS model
            if (state.modelName == strategy.modelName) {
              state = state.copyWith(progress: progress);
            }
          },
        );

        final path = await _modelManager.downloadModel(strategyWithProgress);
        
        // Update downloaded models list
        final ModelType? modelType = ModelType.values.any((m) => m.displayName == strategy.modelName) 
            ? ModelType.values.firstWhere((m) => m.displayName == strategy.modelName)
            : null;
            
        if (modelType != null && !state.downloadedModels.contains(modelType)) {
          state = state.copyWith(
            downloadedModels: [...state.downloadedModels, modelType],
          );
        }

        // If we are still looking at this model, set it to idle (ready)
        if (state.modelName == strategy.modelName) {
          state = state.copyWith(status: BenchmarkStatus.idle, progress: 1.0);
        }
        return path;
      } else if (strategy is EmbeddedModelStrategy) {
        return await _modelManager.extractEmbeddedModel(strategy);
      } else {
        return await strategy.getModelPath();
      }
    } catch (e) {
      state = state.copyWith(
        status: BenchmarkStatus.error,
        errorMessage: 'Failed to prepare model: $e',
      );
      return null;
    }
  }

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
      tokensPerSecond: state.averageSpeed,
      ramUsageMB: state.ramPeakMB, // Save peak RAM
    );

    await _repository.saveBenchmark(result);
  }

  /// Toggle terminal visibility
  void toggleTerminal() {
    state = state.copyWith(showTerminal: !state.showTerminal);
  }

  /// Stop the benchmark
  Future<void> stopBenchmark() async {
    final wasRunning = state.status == BenchmarkStatus.running || 
                       state.status == BenchmarkStatus.loadingModel ||
                       state.status == BenchmarkStatus.downloading;

    // Set status immediately to avoid race conditions in the inference loop
    state = state.copyWith(
      status: wasRunning ? BenchmarkStatus.error : BenchmarkStatus.idle,
      errorMessage: wasRunning ? 'STOPPED BY USER' : null,
    );

    await _disposeService();
  }
}

// Provider for benchmark repository
@riverpod
BenchmarkRepository benchmarkRepository(BenchmarkRepositoryRef ref) {
  return BenchmarkRepository();
}
