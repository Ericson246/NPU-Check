enum ModelType {
  tinyStories,    // Embebido - 7.7 MB
  tinyLlama,      // Descargable - 637 MB
  phi2,           // Descargable - 1.6 GB
}

extension ModelTypeExtension on ModelType {
  String get displayName {
    switch (this) {
      case ModelType.tinyStories:
        return 'TinyStories (Nano)';
      case ModelType.tinyLlama:
        return 'TinyLlama (Pequeño)';
      case ModelType.phi2:
        return 'Phi-2 (Estándar)';
    }
  }
  
  String get description {
    switch (this) {
      case ModelType.tinyStories:
        return 'Demo rápida - Listo para usar';
      case ModelType.tinyLlama:
        return 'Mejor calidad - Requiere 637 MB';
      case ModelType.phi2:
        return 'Máxima calidad - Requiere 1.6 GB';
    }
  }
  
  double get sizeMB {
    switch (this) {
      case ModelType.tinyStories:
        return 7.7;
      case ModelType.tinyLlama:
        return 637.0;
      case ModelType.phi2:
        return 1600.0;
    }
  }
  
  bool get isEmbedded {
    return this == ModelType.tinyStories;
  }
  
  String get downloadUrl {
    switch (this) {
      case ModelType.tinyStories:
        return ''; // Embebido, no necesita URL
      case ModelType.tinyLlama:
        return 'https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf';
      case ModelType.phi2:
        return 'https://huggingface.co/TheBloke/phi-2-GGUF/resolve/main/phi-2.Q4_K_M.gguf';
    }
  }
  
  String get fileName {
    switch (this) {
      case ModelType.tinyStories:
        return 'tinystories-3m-q2_k.gguf';
      case ModelType.tinyLlama:
        return 'tinyllama-1.1b-q4_k_m.gguf';
      case ModelType.phi2:
        return 'phi-2-q4_k_m.gguf';
    }
  }
}
