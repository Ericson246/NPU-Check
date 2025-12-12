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

/// Strategy for loading an embedded model from assets
class EmbeddedModelStrategy implements ModelStrategy {
  @override
  String get modelName => 'TinyStories (Nano)';
  
  @override
  double get expectedSizeMB => 7.7;
  
  @override
  Future<String> getModelPath() async {
    // Return asset path - will be copied by ModelManager
    return 'assets/models/tinystories-3m-q2_k.gguf';
  }
}

/// Strategy for loading a bundled offline model from assets (legacy)
class OfflineModelStrategy implements ModelStrategy {
  @override
  String get modelName => 'TinyLlama-1.1B (Nano)';
  
  @override
  double get expectedSizeMB => 80.0;
  
  @override
  Future<String> getModelPath() async {
    // Legacy - not used anymore
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
