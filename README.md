# NeuralGauge 🚀

A cyberpunk-themed AI benchmarking application for Android/iOS built with Flutter. Test your device's AI inference performance with real-time metrics and stunning neon aesthetics.

![Cyberpunk Theme](https://img.shields.io/badge/Theme-Cyberpunk-00FFFF?style=for-the-badge)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green?style=for-the-badge)

## ✨ Features

- **Hybrid Model Loading**: Automatic fallback between online (downloaded) and offline (bundled) AI models
- **Real-time Metrics**: Live tokens/second speedometer with 60fps animations
- **Non-blocking Inference**: Isolate-based architecture prevents UI freezing
- **Cyberpunk UI**: Neon glow effects, dark gradients, and futuristic typography
- **Persistent History**: Local benchmark results saved with Hive
- **Memory Monitoring**: Real-time RAM usage tracking

## 🏗️ Architecture

### Stack
- **UI Layer**: Flutter with Riverpod 2.0 state management
- **Inference Engine**: llama.cpp (C++) via Dart FFI
- **Persistence**: Hive (NoSQL)
- **Connectivity**: Automatic online/offline detection

### Key Components

```
lib/
├── core/
│   ├── ffi/                    # FFI bindings
│   ├── services/               # LlamaService with Isolate
│   └── theme/                  # Cyberpunk theme
├── features/benchmark/
│   ├── application/            # Riverpod controllers & state
│   ├── domain/                 # Model strategies
│   ├── data/                   # Hive models & repositories
│   └── presentation/           # UI widgets & screens
```

## 🚀 Setup Instructions

### Prerequisites

1. **Flutter SDK** (3.2.0 or higher)
2. **Android NDK** (for native C++ compilation)
3. **llama.cpp library**

### Step 1: Clone llama.cpp

```bash
cd android/app/src/main/cpp/
git clone https://github.com/ggerganov/llama.cpp.git
```

### Step 2: Add Model Files

**Offline Model** (bundled):
- Place a small .gguf model (~50-100MB) in `assets/models/`
- Example: `tinyllama-1.1b-q4_k_m.gguf`

**Online Model** (optional):
- Update the URL in `lib/features/benchmark/domain/model_manager.dart`
- Default: Phi-2 from HuggingFace

### Step 3: Install Dependencies

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Step 4: Run the App

```bash
# Android
flutter run

# Release build
flutter build apk --release
```

## 🎨 Cyberpunk Theme

The app features a custom cyberpunk industrial aesthetic:

- **Colors**: Neon cyan (#00FFFF), magenta (#FF00FF), electric blue
- **Typography**: Orbitron (headers), Roboto Mono (body)
- **Effects**: Glow shadows, gradient backgrounds, animated transitions

## 🧠 How It Works

### Model Loading Strategy

1. **Check Connectivity**: Uses `connectivity_plus` to detect internet
2. **Select Strategy**:
   - **Online**: Download model from URL with progress tracking
   - **Offline**: Extract bundled model from assets
3. **Automatic Fallback**: If download fails, falls back to offline mode

### Inference Pipeline

1. **Isolate Spawn**: Creates separate thread for C++ inference
2. **Token Streaming**: Real-time token callbacks via `SendPort`/`ReceivePort`
3. **UI Updates**: Riverpod state updates trigger UI redraws
4. **Memory Management**: Automatic model disposal on completion

## 📊 Benchmark Results

Results are saved locally with:
- Timestamp
- Device model (from `device_info_plus`)
- AI model name
- Tokens/second performance
- RAM usage

## 🛠️ Development

### Code Generation

Run this after modifying Riverpod providers or Freezed classes:

```bash
dart run build_runner watch
```

### Adding New Models

Edit `model_manager.dart`:

```dart
return OnlineModelStrategy(
  downloadUrl: 'https://your-model-url.gguf',
  modelName: 'Your Model Name',
  sizeMB: 500.0,
);
```

## 🐛 Troubleshooting

### CMake Build Fails
- Ensure Android NDK is installed via Android Studio
- Check `android/local.properties` has correct NDK path

### Model Loading Errors
- Verify .gguf file is valid and compatible with llama.cpp version
- Check file permissions in app storage

### UI Freezing
- Ensure Isolate is properly spawned in `LlamaService`
- Check for blocking operations on main thread

## 📝 License

MIT License - See LICENSE file for details

## 🙏 Acknowledgments

- [llama.cpp](https://github.com/ggerganov/llama.cpp) - Fast LLM inference
- [Flutter](https://flutter.dev) - UI framework
- [Riverpod](https://riverpod.dev) - State management

---

**Built with ⚡ by a cyberpunk enthusiast**
