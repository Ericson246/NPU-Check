import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'model_strategy.dart';
import 'model_type.dart';

/// Manages model selection and downloading
class ModelManager {
  final Connectivity _connectivity = Connectivity();
  
  /// Stream of download progress (0.0 to 1.0)
  Stream<double>? _downloadProgress;
  Stream<double>? get downloadProgress => _downloadProgress;

  http.Client? _activeClient;
  bool _isCancelled = false;

  /// Check if device has internet connectivity
  Future<bool> hasConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    return result == ConnectivityResult.mobile ||
           result == ConnectivityResult.wifi ||
           result == ConnectivityResult.ethernet;
  }

  Future<ModelStrategy> selectStrategy({
    ModelType modelType = ModelType.tinyStories,
  }) async {
    if (modelType.isEmbedded) {
      return EmbeddedModelStrategy();
    }

    final cachedPath = await _getCachedModelPath(modelType.fileName);
    if (cachedPath != null && await _isModelFullyDownloaded(cachedPath, modelType.sizeMB)) {
      return _CachedModelStrategy(
        cachedPath,
        modelType.displayName,
        modelType.sizeMB,
      );
    }

    return OnlineModelStrategy(
      downloadUrl: modelType.downloadUrl,
      modelName: modelType.displayName,
      sizeMB: modelType.sizeMB,
    );
  }

  Future<bool> _isModelFullyDownloaded(String path, double expectedSizeMB) async {
    final file = File(path);
    if (!await file.exists()) return false;
    
    final size = await file.length();
    final expectedSize = (expectedSizeMB * 1024 * 1024).toInt();
    final tolerance = (expectedSize * 0.05).toInt(); // 5% tolerance
    
    // Check if size is within 5% of expected size
    return (size - expectedSize).abs() < tolerance;
  }

  /// Download and cache a model from OnlineModelStrategy
  Future<String> downloadModel(OnlineModelStrategy strategy) async {
    try {
      final fileName = strategy.downloadUrl.split('/').last;
      final cacheDir = await getApplicationDocumentsDirectory();
      final modelFile = File('${cacheDir.path}/models/$fileName');

      // Create directory if it doesn't exist
      await modelFile.parent.create(recursive: true);

      int existingBytes = 0;
      if (await modelFile.exists()) {
        existingBytes = await modelFile.length();
      }

      final expectedSize = (strategy.expectedSizeMB * 1024 * 1024).toInt();
      final tolerance = (expectedSize * 0.05).toInt(); // 5% tolerance
      
      print('DEBUG Download: File=${modelFile.path}');
      print('DEBUG Download: Existing=${existingBytes} bytes (${(existingBytes / 1024 / 1024).toStringAsFixed(1)} MB)');
      print('DEBUG Download: Expected=${expectedSize} bytes (${strategy.expectedSizeMB.toStringAsFixed(1)} MB)');
      print('DEBUG Download: Tolerance=±${tolerance} bytes (±${(tolerance / 1024 / 1024).toStringAsFixed(1)} MB)');
      print('DEBUG Download: Range=${expectedSize - tolerance} to ${expectedSize + tolerance}');
      
      // If already fully downloaded
      if (existingBytes >= expectedSize - tolerance && existingBytes <= expectedSize + tolerance) {
        print('DEBUG Download: File is complete, skipping download');
        return modelFile.path;
      }
      
      print('DEBUG Download: File incomplete or corrupt, starting/resuming download');

      _isCancelled = false;
      _activeClient = http.Client();

      // Prepare request with Range header if partial file exists
      final request = http.Request('GET', Uri.parse(strategy.downloadUrl));
      if (existingBytes > 0) {
        request.headers['Range'] = 'bytes=$existingBytes-';
      }

      final response = await _activeClient!.send(request);
      
      print('DEBUG Download: HTTP Status=${response.statusCode}');
      print('DEBUG Download: Content-Length=${response.contentLength}');

      // Handle 416 Range Not Satisfiable - file is already complete
      if (response.statusCode == 416) {
        print('DEBUG Download: Got 416 Range Not Satisfiable');
        _cleanupClient();
        // Verify the file is actually complete
        if (existingBytes >= expectedSize - tolerance && existingBytes <= expectedSize + tolerance) {
          print('DEBUG Download: File size valid, accepting as complete');
          return modelFile.path;
        } else {
          print('DEBUG Download: File size invalid, deleting corrupt file');
          // File is corrupt, delete and restart
          await modelFile.delete();
          throw Exception('File corrupted. Please restart download.');
        }
      }

      // Handle 206 Partial Content or 200 OK
      if (response.statusCode != 200 && response.statusCode != 206) {
        print('DEBUG Download: Unexpected status code: ${response.statusCode}');
        _cleanupClient();
        throw Exception('Failed to download model: ${response.statusCode}');
      }
      
      print('DEBUG Download: Starting stream download (status ${response.statusCode})');

      final bool isResuming = response.statusCode == 206;
      int downloadedBytes = isResuming ? existingBytes : 0;
      final totalBytes = (response.contentLength ?? 0) + downloadedBytes;

      final sink = modelFile.openWrite(mode: isResuming ? FileMode.append : FileMode.write);
      
      try {
        await for (final chunk in response.stream) {
          if (_isCancelled) {
            throw Exception('DOWNLOAD_CANCELLED');
          }
          sink.add(chunk);
          downloadedBytes += chunk.length;
          
          if (totalBytes > 0) {
            final progress = downloadedBytes / totalBytes;
            strategy.onProgress?.call(progress);
          }
        }
      } finally {
        await sink.close();
        _cleanupClient();
      }

      return modelFile.path;
      
    } catch (e) {
      if (e.toString().contains('DOWNLOAD_CANCELLED')) {
         throw Exception('STOPPED BY USER');
      }
      final errorStr = e.toString();
      if (errorStr.contains('Connection closed') || errorStr.contains('SocketException')) {
        throw Exception('Connection lost. Keep the screen on during download.');
      }
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

  /// Copy embedded model from assets to writable location
  Future<String> extractEmbeddedModel(EmbeddedModelStrategy strategy) async {
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

  void cancelActiveDownload() {
    _isCancelled = true;
    _cleanupClient();
  }

  void _cleanupClient() {
    _activeClient?.close();
    _activeClient = null;
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
