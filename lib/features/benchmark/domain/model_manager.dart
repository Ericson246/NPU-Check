import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'model_strategy.dart';

/// Manages model selection and downloading
class ModelManager {
  final Connectivity _connectivity = Connectivity();
  
  /// Stream of download progress (0.0 to 1.0)
  Stream<double>? _downloadProgress;
  Stream<double>? get downloadProgress => _downloadProgress;

  /// Check if device has internet connectivity
  Future<bool> hasConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    return result == ConnectivityResult.mobile ||
           result == ConnectivityResult.wifi ||
           result == ConnectivityResult.ethernet;
  }

  /// Select the appropriate model strategy based on connectivity
  Future<ModelStrategy> selectStrategy({
    bool forceOffline = false,
  }) async {
    if (forceOffline) {
      // For offline mode, check if TinyLlama is cached, otherwise download it
      final cachedPath = await _getCachedModelPath('tinyllama-1.1b-q4_k_m.gguf');
      if (cachedPath != null && await File(cachedPath).exists()) {
        return _CachedModelStrategy(cachedPath, 'TinyLlama-1.1B (Nano)', 637.0);
      }
      
      // Return strategy to download TinyLlama
      return OnlineModelStrategy(
        downloadUrl: 'https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf',
        modelName: 'TinyLlama-1.1B (Nano)',
        sizeMB: 637.0,
      );
    }

    final hasInternet = await hasConnectivity();
    
    if (hasInternet) {
      // Check if online model is already cached
      final cachedPath = await _getCachedModelPath('phi-2-q4_k_m.gguf');
      if (cachedPath != null && await File(cachedPath).exists()) {
        // Model already downloaded, use it
        return _CachedModelStrategy(cachedPath, 'Phi-2 (Standard)', 1600.0);
      }
      
      // Return online strategy for download
      return OnlineModelStrategy(
        downloadUrl: 'https://huggingface.co/TheBloke/phi-2-GGUF/resolve/main/phi-2.Q4_K_M.gguf',
        modelName: 'Phi-2 (Standard)',
        sizeMB: 1600.0,
      );
    }

    // No internet, try to use cached TinyLlama
    final cachedPath = await _getCachedModelPath('tinyllama-1.1b-q4_k_m.gguf');
    if (cachedPath != null && await File(cachedPath).exists()) {
      return _CachedModelStrategy(cachedPath, 'TinyLlama-1.1B (Nano)', 637.0);
    }
    
    // No internet and no cached model - this will fail, but we return offline strategy
    return OfflineModelStrategy();
  }

  /// Download and cache a model from OnlineModelStrategy
  Future<String> downloadModel(OnlineModelStrategy strategy) async {
    try {
      final fileName = strategy.downloadUrl.split('/').last;
      final cacheDir = await getApplicationDocumentsDirectory();
      final modelFile = File('${cacheDir.path}/models/$fileName');

      // Create directory if it doesn't exist
      await modelFile.parent.create(recursive: true);

      // Check if already downloaded
      if (await modelFile.exists()) {
        final size = await modelFile.length();
        final expectedSize = (strategy.expectedSizeMB * 1024 * 1024).toInt();
        
        // If file size matches, return cached path
        if ((size - expectedSize).abs() < 1024 * 1024) {
          return modelFile.path;
        }
      }

      // Download the model
      final request = http.Request('GET', Uri.parse(strategy.downloadUrl));
      final response = await request.send();

      if (response.statusCode != 200) {
        throw Exception('Failed to download model: ${response.statusCode}');
      }

      final totalBytes = response.contentLength ?? 0;
      int downloadedBytes = 0;

      final sink = modelFile.openWrite();
      
      await for (final chunk in response.stream) {
        sink.add(chunk);
        downloadedBytes += chunk.length;
        
        if (totalBytes > 0) {
          final progress = downloadedBytes / totalBytes;
          strategy.onProgress?.call(progress);
        }
      }

      await sink.close();
      return modelFile.path;
      
    } catch (e) {
      // Download failed, fallback to offline model
      throw Exception('Download failed: $e');
    }
  }

  /// Copy bundled asset model to writable location
  Future<String> extractAssetModel(OfflineModelStrategy strategy) async {
    final assetPath = await strategy.getModelPath();
    final cacheDir = await getApplicationDocumentsDirectory();
    final fileName = assetPath.split('/').last;
    final targetFile = File('${cacheDir.path}/models/$fileName');

    // Check if already extracted
    if (await targetFile.exists()) {
      return targetFile.path;
    }

    // Create directory
    await targetFile.parent.create(recursive: true);

    // Copy from assets
    final byteData = await rootBundle.load(assetPath);
    final buffer = byteData.buffer;
    await targetFile.writeAsBytes(
      buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
    );

    return targetFile.path;
  }

  /// Get cached model path if it exists
  Future<String?> _getCachedModelPath(String fileName) async {
    final cacheDir = await getApplicationDocumentsDirectory();
    final path = '${cacheDir.path}/models/$fileName';
    return path;
  }
}

/// Internal strategy for already-cached models
class _CachedModelStrategy implements ModelStrategy {
  final String _path;
  final String _name;
  final double _sizeMB;

  _CachedModelStrategy(this._path, this._name, this._sizeMB);

  @override
  String get modelName => _name;

  @override
  double get expectedSizeMB => _sizeMB;

  @override
  Future<String> getModelPath() async => _path;
}
