import 'package:freezed_annotation/freezed_annotation.dart';

part 'benchmark_state.freezed.dart';

@freezed
class BenchmarkState with _$BenchmarkState {
  const factory BenchmarkState({
    @Default(0.0) double currentSpeed, // tokens per second
    @Default('') String generatedText,
    @Default(0.0) double progress, // 0.0 to 1.0
    @Default(false) bool isOfflineMode,
    @Default(0.0) double ramUsageMB,
    @Default(BenchmarkStatus.idle) BenchmarkStatus status,
    String? errorMessage,
    String? modelName,
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
