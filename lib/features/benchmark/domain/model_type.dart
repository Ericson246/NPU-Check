enum ModelType {
  tinyStories,    // Embebido - 7.7 MB
  tinyLlama,      // Descargable - 637 MB
  phi2,           // Descargable - 1.6 GB -> Liquid LFM 2.6B
}

extension ModelTypeExtension on ModelType {
  String get displayName {
    switch (this) {
      case ModelType.tinyStories:
        return 'TinyStories (Nano)';
      case ModelType.tinyLlama:
        return 'TinyLlama (Small)';
      case ModelType.phi2:
        return 'Gemma 2 2B (Standard)';
    }
  }
  
  String get description {
    switch (this) {
      case ModelType.tinyStories:
        return 'Demo - Instant';
      case ModelType.tinyLlama:
        return 'Balanced - 637 MB';
      case ModelType.phi2:
        return 'High Performance - 1.7 GB';
    }
  }
  
  double get sizeMB {
    switch (this) {
      case ModelType.tinyStories:
        return 7.7;
      case ModelType.tinyLlama:
        return 637.0;
      case ModelType.phi2:
        return 1750.0; // ~1.71 GB
    }
  }
  
  bool get isEmbedded {
    return this == ModelType.tinyStories;
  }
  
  String get downloadUrl {
    switch (this) {
      case ModelType.tinyStories:
        return '';
      case ModelType.tinyLlama:
        return 'https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf';
      case ModelType.phi2:
        return 'https://huggingface.co/bartowski/gemma-2-2b-it-GGUF/resolve/main/gemma-2-2b-it-Q4_K_M.gguf';
    }
  }
  
  String get fileName {
    switch (this) {
      case ModelType.tinyStories:
        return 'tinystories-3m-q2_k.gguf';
      case ModelType.tinyLlama:
        return 'tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf';
      case ModelType.phi2:
        return 'gemma-2-2b-it-Q4_K_M.gguf';
    }
  }
}
