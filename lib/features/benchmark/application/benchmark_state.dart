import 'package:freezed_annotation/freezed_annotation.dart';
import '../domain/model_type.dart';

part 'benchmark_state.freezed.dart';

@freezed
class BenchmarkState with _$BenchmarkState {
  const factory BenchmarkState({
    @Default(0.0) double currentSpeed, // tokens per second
    @Default(0.0) double averageSpeed, // average tokens per second
    @Default('') String generatedText,
    @Default(0.0) double progress, // 0.0 to 1.0
    @Default(false) bool isOfflineMode,
    @Default(0.0) double ramUsageMB,
    @Default(0.0) double ramPeakMB,
    @Default(BenchmarkStatus.idle) BenchmarkStatus status,
    @Default(ModelType.tinyStories) ModelType selectedModel,
    @Default(false) bool showTerminal,
    String? errorMessage,
    String? modelName,
    @Default(BenchmarkWorkload.standard) BenchmarkWorkload workload,
    @Default([]) List<ModelType> downloadedModels,
  }) = _BenchmarkState;
}

enum BenchmarkStatus {
  idle,
  loadingModel,
  downloading,
  running,
  completed,
  error,
}

enum BenchmarkWorkload {
  quick(50, Duration.zero, 'Quick Scan'),
  standard(256, Duration(seconds: 15), 'Standard'),
  stress(1024, Duration(seconds: 60), 'Stress Test');

  final int tokens;
  final Duration minDuration;
  final String label;
  
  const BenchmarkWorkload(this.tokens, this.minDuration, this.label);
  
  bool get isTimeBased => minDuration > Duration.zero;
}
