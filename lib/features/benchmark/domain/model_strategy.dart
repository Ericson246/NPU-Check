/// Abstract strategy for loading AI models
abstract class ModelStrategy {
  /// Get the file path to the model
  /// May involve downloading, extracting from assets, etc.
  Future<String> getModelPath();
  
  /// Get a human-readable name for this model
  String get modelName;
  
  /// Get the expected size in MB (for UI display)
  double get expectedSizeMB;
}

/// Strategy for loading a bundled offline model from assets
class OfflineModelStrategy implements ModelStrategy {
  @override
  String get modelName => 'TinyLlama-1.1B (Nano)';
  
  @override
  double get expectedSizeMB => 80.0;
  
  @override
  Future<String> getModelPath() async {
    // In Flutter, assets are bundled in the APK/IPA
    // We need to copy it to a writable location first
    // For now, return the asset path (you'll need to implement asset copying)
    return 'assets/models/tinyllama-1.1b-q4_k_m.gguf';
  }
}

/// Strategy for downloading a model from a URL
class OnlineModelStrategy implements ModelStrategy {
  final String downloadUrl;
  final String _modelName;
  final double _sizeMB;
  
  /// Callback for download progress (0.0 to 1.0)
  final void Function(double progress)? onProgress;

  OnlineModelStrategy({
    required this.downloadUrl,
    required String modelName,
    required double sizeMB,
    this.onProgress,
  })  : _modelName = modelName,
        _sizeMB = sizeMB;

  @override
  String get modelName => _modelName;
  
  @override
  double get expectedSizeMB => _sizeMB;
  
  @override
  Future<String> getModelPath() async {
    // Implementation will download the model and cache it
    // This is a placeholder - actual implementation in model_manager.dart
    throw UnimplementedError('Use ModelManager to handle downloads');
  }
}
