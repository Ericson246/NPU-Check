import 'package:hive/hive.dart';

part 'benchmark_result.g.dart';

@HiveType(typeId: 0)
class BenchmarkResult extends HiveObject {
  @HiveField(0)
  final DateTime timestamp;

  @HiveField(1)
  final String deviceModel;

  @HiveField(2)
  final String aiModelName;

  @HiveField(3)
  final double tokensPerSecond;

  @HiveField(4)
  final double ramUsageMB;

  BenchmarkResult({
    required this.timestamp,
    required this.deviceModel,
    required this.aiModelName,
    required this.tokensPerSecond,
    required this.ramUsageMB,
  });

  @override
  String toString() {
    return 'BenchmarkResult('
        'timestamp: $timestamp, '
        'device: $deviceModel, '
        'model: $aiModelName, '
        'speed: ${tokensPerSecond.toStringAsFixed(2)} t/s, '
        'ram: ${ramUsageMB.toStringAsFixed(1)} MB'
        ')';
  }
}
