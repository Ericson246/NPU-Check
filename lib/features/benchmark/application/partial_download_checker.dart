import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../domain/model_type.dart';

/// Helper to check if a model has a partial download
class PartialDownloadChecker {
  /// Check if the selected model has a partial download
  static Future<bool> hasPartialDownload(ModelType modelType) async {
    if (modelType.isEmbedded) return false;
    
    try {
      final cacheDir = await getApplicationDocumentsDirectory();
      final filePath = '${cacheDir.path}/models/${modelType.fileName}';
      final file = File(filePath);
      
      if (!await file.exists()) return false;
      
      final existingSize = await file.length();
      final expectedSize = (modelType.sizeMB * 1024 * 1024).toInt();
      final tolerance = (expectedSize * 0.05).toInt();
      
      // If file exists but is not complete, it's a partial download
      return existingSize > 0 && existingSize < (expectedSize - tolerance);
    } catch (e) {
      return false;
    }
  }
}
