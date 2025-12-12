import 'package:hive_flutter/hive_flutter.dart';
import '../models/benchmark_result.dart';

class BenchmarkRepository {
  static const String _boxName = 'benchmarks';
  Box<BenchmarkResult>? _box;

  /// Initialize Hive and open the box
  Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Only register adapter if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(BenchmarkResultAdapter());
    }
    
    _box = await Hive.openBox<BenchmarkResult>(_boxName);
  }

  /// Save a benchmark result
  Future<void> saveBenchmark(BenchmarkResult result) async {
    await _ensureInitialized();
    await _box!.add(result);
  }

  /// Get all benchmarks, sorted by date (newest first)
  Future<List<BenchmarkResult>> getAllBenchmarks() async {
    await _ensureInitialized();
    final results = _box!.values.toList();
    results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return results;
  }

  /// Get benchmarks for a specific device
  Future<List<BenchmarkResult>> getBenchmarksByDevice(String deviceModel) async {
    await _ensureInitialized();
    return _box!.values
        .where((result) => result.deviceModel == deviceModel)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Clear all benchmark history
  Future<void> clearHistory() async {
    await _ensureInitialized();
    await _box!.clear();
  }

  /// Get the best (fastest) benchmark result
  Future<BenchmarkResult?> getBestResult() async {
    await _ensureInitialized();
    if (_box!.isEmpty) return null;
    
    return _box!.values.reduce((a, b) =>
        a.tokensPerSecond > b.tokensPerSecond ? a : b);
  }

  /// Ensure box is initialized
  Future<void> _ensureInitialized() async {
    if (_box == null || !_box!.isOpen) {
      await initialize();
    }
  }

  /// Close the box
  Future<void> close() async {
    await _box?.close();
  }
}
