# NPU Check 🚀

A professional AI benchmarking application for Android/iOS built with Flutter. Test your device's AI inference performance with real-time metrics, resumable downloads, and a stunning cyberpunk-themed interface.

![Cyberpunk Theme](https://img.shields.io/badge/Theme-Cyberpunk-00FFFF?style=for-the-badge)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green?style=for-the-badge)

## ✨ Key Features

### 🤖 Multiple AI Models
- **TinyStories (7.7 MB)** - Bundled, instant access, perfect for quick tests
- **TinyLlama (637 MB)** - Balanced performance, downloadable
- **Gemma 2 2B (1.7 GB)** - High performance, modern architecture by Google

### 📊 Flexible Benchmark Modes
- **Quick Scan** (50 tokens) - Fast device check
- **Standard** (15 seconds) - Comprehensive performance test
- **Stress Test** (60 seconds) - Extended load testing

### 💾 Robust Download System
- **Resumable Downloads** - Pause and continue from where you left off
- **Progress Tracking** - Real-time download percentage
- **File Validation** - Automatic integrity checking
- **Smart Recovery** - Handles network interruptions gracefully
- **Duplicate Prevention** - Avoids re-downloading existing models

### 📈 Real-Time Performance Metrics
- **Live Speedometer** - Tokens per second with smooth animations
- **Accurate Timing** - Benchmark starts when first token is generated
- **RAM Monitoring** - Current and peak memory usage
- **Progress Tracking** - Visual progress bar for time-based tests

### 🎨 Polished User Interface
- **Cyberpunk Aesthetics** - Neon colors, dark gradients, futuristic typography
- **Collapsible Console** - View generated text without cluttering the screen
- **Status Indicators** - Clear visual feedback for downloads and benchmarks
- **Responsive Design** - Adapts to different screen sizes

## 🏗️ Technical Architecture

### Technology Stack
- **UI Framework**: Flutter 3.x with Material Design
- **State Management**: Riverpod 2.0 with code generation
- **AI Engine**: llama.cpp (C++) via Dart FFI
- **Persistence**: Hive (NoSQL local database)
- **Networking**: HTTP with Range header support for resumable downloads
- **Concurrency**: Dart Isolates for non-blocking inference

### Project Structure

```
lib/
├── core/
│   ├── ffi/                    # FFI bindings to llama.cpp
│   ├── services/               # LlamaService with Isolate management
│   └── theme/                  # Cyberpunk theme configuration
├── features/benchmark/
│   ├── application/            # Riverpod controllers & state
│   │   ├── benchmark_controller.dart
│   │   └── benchmark_state.dart
│   ├── domain/                 # Business logic
│   │   ├── model_manager.dart  # Download & caching
│   │   ├── model_type.dart     # Model definitions
│   │   └── model_strategy.dart # Loading strategies
│   ├── data/                   # Persistence layer
│   │   ├── models/             # Hive data models
│   │   └── repositories/       # Benchmark history
│   └── presentation/           # UI components
│       ├── screens/            # Main screens
│       └── widgets/            # Reusable widgets
```

### Key Technical Improvements

#### 1. Resumable Download System
- Uses HTTP `Range` headers for partial content requests
- Saves progress to disk incrementally
- Validates file size before marking as complete
- Handles connection drops gracefully

#### 2. Accurate Benchmark Timing
- Timer starts when **first token is generated**, not when button is pressed
- Excludes model loading time from performance metrics
- Ensures fair comparison across different devices

#### 3. Download Validation
- Checks file size matches expected size (±1MB tolerance)
- Prevents loading corrupt or incomplete models
- Automatically resumes incomplete downloads

#### 4. Non-Blocking Inference
- Runs AI inference in a separate Dart Isolate
- Token streaming via `SendPort`/`ReceivePort`
- UI remains responsive during heavy computation

#### 5. Smart State Management
- Tracks downloaded models to show appropriate UI indicators
- Prevents duplicate downloads with active download tracking
- Refreshes model list on app startup

## 🚀 Setup Instructions

### Prerequisites

1. **Flutter SDK** (3.2.0 or higher)
   ```bash
   flutter --version
   ```

2. **Android NDK** (for native C++ compilation)
   - Install via Android Studio SDK Manager
   - Required for llama.cpp compilation

3. **Git** (for cloning llama.cpp)

### Installation Steps

#### Step 1: Clone the Repository
```bash
git clone <your-repo-url>
cd npu-benchmark
```

#### Step 2: Clone llama.cpp Library
```bash
cd android/app/src/main/cpp/
git clone https://github.com/ggerganov/llama.cpp.git
cd ../../../../..
```

#### Step 3: Add Bundled Model
Place the TinyStories model in the assets folder:
- Download: `tinystories-3m-q2_k.gguf` (7.7 MB)
- Location: `assets/models/tinystories-3m-q2_k.gguf`

#### Step 4: Install Dependencies
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

#### Step 5: Run/Build the App
```bash
# Debug mode
flutter run

# Create Signed Release Bundle (For Google Play)
flutter build appbundle
# Output: build/app/outputs/bundle/release/app-release.aab

# Create Signed Release APK (For manual install)
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

## 📖 User Guide

### Selecting a Model

1. **TinyStories (Nano)** - Already installed, ready to use
2. **TinyLlama (Pequeño)** - Tap to download 637 MB
3. **Phi-2 (Estándar)** - Tap to download 1.6 GB

**Download Tips:**
- Keep screen on during download to prevent connection loss
- Downloads resume automatically if interrupted
- Downloaded models show a checkmark icon

### Choosing a Benchmark Mode

- **Quick Scan** - Generates 50 tokens, fastest test
- **Standard** - Runs for 15 seconds, balanced test
- **Stress Test** - Runs for 60 seconds, intensive load test

### Running a Benchmark

1. Select your desired model
2. Choose a benchmark mode
3. Tap **START BENCHMARK**
4. Watch real-time metrics:
   - **Current Speed** - Instantaneous tokens/second
   - **Average Speed** - Overall performance
   - **RAM Usage** - Memory consumption
   - **Progress** - Completion percentage

### Understanding Results

- **Tokens/Second (TPS)** - Higher is better
  - 10-30 TPS: Entry-level performance
  - 30-60 TPS: Good performance
  - 60+ TPS: Excellent performance

- **RAM Usage** - Lower is better
  - Varies by model size
  - Peak RAM shows maximum usage during test

## 🎨 Cyberpunk Theme

### Design Philosophy
Industrial cyberpunk aesthetic with functional clarity

### Color Palette
- **Neon Cyan** (#00FFFF) - Primary actions, highlights
- **Neon Magenta** (#FF00FF) - Warnings, downloads
- **Neon Green** (#39FF14) - Success, active inference
- **Neon Orange** (#FF6600) - Errors, stop actions
- **Dark Background** (#0A0E27) - Main background

### Typography
- **Orbitron** - Headers and titles (futuristic)
- **Roboto Mono** - Body text and metrics (technical)

### Visual Effects
- Glow shadows on interactive elements
- Gradient backgrounds for depth
- Smooth animations (60 FPS target)
- Pulsing indicators for active states

## 🛠️ Development

### Code Generation

After modifying Riverpod providers or Freezed classes:
```bash
# One-time build
dart run build_runner build --delete-conflicting-outputs

# Watch mode (auto-rebuild on changes)
dart run build_runner watch
```

### Adding New Models

Edit `lib/features/benchmark/domain/model_type.dart`:

```dart
enum ModelType {
  tinyStories,
  tinyLlama,
  phi2,
  yourNewModel,  // Add here
}

extension ModelTypeExtension on ModelType {
  String get downloadUrl {
    switch (this) {
      case ModelType.yourNewModel:
        return 'https://huggingface.co/path/to/model.gguf';
      // ...
    }
  }
  
  double get sizeMB {
    switch (this) {
      case ModelType.yourNewModel:
        return 800.0;  // Size in MB
      // ...
    }
  }
}
```

### Modifying Benchmark Workloads

Edit `lib/features/benchmark/application/benchmark_state.dart`:

```dart
enum BenchmarkWorkload {
  quick(50, Duration.zero, 'Quick Scan'),
  standard(256, Duration(seconds: 15), 'Standard'),
  stress(1024, Duration(seconds: 60), 'Stress Test'),
  custom(500, Duration(seconds: 30), 'Custom Test'),  // Add here
}
```

## 🐛 Troubleshooting

### Download Issues

**Problem**: Download fails with "Connection lost"
- **Solution**: Keep screen on during download
- **Why**: Android may suspend network activity when screen is off

**Problem**: Download shows as incomplete after finishing
- **Solution**: File size validation failed, restart download
- **Why**: Network interruption corrupted the file

**Problem**: Can't resume download after canceling
- **Solution**: Fixed in latest version, download continues from last byte

### Model Loading Issues

**Problem**: "Failed to load model" error
- **Check**: File integrity (size should match expected size ±1MB)
- **Solution**: Delete partial file and re-download

**Problem**: App crashes when loading large model
- **Check**: Available RAM (Phi-2 needs ~2GB free)
- **Solution**: Close other apps before benchmarking

### Benchmark Issues

**Problem**: "Download failed" or Corrupt file loop
- **Solution**: Fixed in v1.0. App now automatically deletes corrupt files and validates headers (no more 416 errors).
- **Action**: Just retry the download.

**Problem**: Benchmark stays at "PREPARING INFERENCE ENGINE"
- **Solution**: Fixed in latest version
- **Cause**: State transition bug, now resolved

**Problem**: Benchmark duration is inaccurate
- **Solution**: Timer now starts when first token is generated
- **Note**: Model loading time is excluded from benchmark

**Problem**: UI freezes during inference
- **Check**: Isolate is properly initialized
- **Solution**: Ensure `LlamaService.initialize()` completed successfully

### Build Issues

**Problem**: CMake build fails
- **Check**: Android NDK is installed
- **Location**: Android Studio → SDK Manager → SDK Tools → NDK
- **Verify**: `android/local.properties` has correct `ndk.dir`

**Problem**: "llama.cpp not found" error
- **Solution**: Clone llama.cpp into `android/app/src/main/cpp/`
- **Command**: See Step 2 in Setup Instructions

**Problem**: Code generation fails
- **Solution**: Delete generated files and rebuild
  ```bash
  flutter clean
  flutter pub get
  dart run build_runner build --delete-conflicting-outputs
  ```

## 📊 Performance Tips

### For Accurate Benchmarks

1. **Use Release Build**
   ```bash
   flutter build apk --release
   ```
   Debug builds are 2-3x slower

2. **Close Background Apps**
   - Free up RAM
   - Reduce CPU contention

3. **Charge Your Device**
   - Some devices throttle when battery is low

4. **Cool Down Between Tests**
   - Thermal throttling affects results
   - Wait 2-3 minutes between stress tests

5. **Use Standard Mode**
   - 15-second duration provides reliable averages
   - Quick mode may not reach steady state

## 🔒 Privacy & Data

- **No Internet Required** - TinyStories model works offline
- **No Data Collection** - All benchmarks stored locally
- **No Analytics** - Your performance data stays on your device

## 📝 License

MIT License - See LICENSE file for details

## 🙏 Acknowledgments

- [llama.cpp](https://github.com/ggerganov/llama.cpp) - Fast LLM inference engine
- [Flutter](https://flutter.dev) - Cross-platform UI framework
- [Riverpod](https://riverpod.dev) - Reactive state management
- [TheBloke](https://huggingface.co/TheBloke) - Quantized model repository

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Workflow

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 🚀 Google Play Release Guide

To generate the `.aab` file for Google Play:

1. **Verify Permissions**: `android/app/src/main/AndroidManifest.xml` checked.
2. **Signing**: `upload-keystore.jks` and `key.properties` configured.
3. **Build Command**:
   ```bash
   flutter build appbundle
   ```
4. **Locate File**: `build/app/outputs/bundle/release/app-release.aab`
5. **Upload**: Drag this file to Google Play Console.

---

**Built with ⚡ by cyberpunk enthusiasts, for performance enthusiasts**
