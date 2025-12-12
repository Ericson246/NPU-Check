import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/benchmark_controller.dart';
import '../../application/benchmark_state.dart';
import '../widgets/speedometer_widget.dart';
import '../widgets/typewriter_text.dart';
import '../widgets/model_selector_widget.dart';
import '../../../../core/theme/app_theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final benchmarkState = ref.watch(benchmarkControllerProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header with connectivity indicator
                _buildHeader(benchmarkState),
                
                const SizedBox(height: 20),
                
                // Model Selector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ModelSelectorWidget(
                    selectedModel: benchmarkState.selectedModel,
                    onModelSelected: (model) {
                      ref.read(benchmarkControllerProvider.notifier).selectModel(model);
                    },
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Speedometer
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SpeedometerWidget(
                        tokensPerSecond: benchmarkState.currentSpeed,
                        maxSpeed: 100.0,
                      ),
                      const SizedBox(height: 20),
                      
                      // RAM Usage
                      _buildMetricCard(
                        'RAM USAGE',
                        '${benchmarkState.ramUsageMB.toStringAsFixed(1)} MB',
                        AppTheme.neonMagenta,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Generated text display
                if (benchmarkState.generatedText.isNotEmpty)
                  Container(
                    constraints: const BoxConstraints(maxHeight: 150),
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: AppTheme.darkBgSecondary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.neonCyan.withOpacity(0.3),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: TypewriterText(
                        text: benchmarkState.generatedText,
                      ),
                    ),
                  ),
                
                const SizedBox(height: 12),
                
                // Status message
                if (benchmarkState.status != BenchmarkStatus.idle)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildStatusMessage(benchmarkState),
                  ),
                
                const SizedBox(height: 20),
                
                // Control buttons
                _buildControls(context, ref, benchmarkState),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BenchmarkState state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App title
          Text(
            'NEURAL GAUGE',
            style: const TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.neonCyan,
              letterSpacing: 3,
              shadows: [
                Shadow(
                  color: AppTheme.neonCyan,
                  blurRadius: 15,
                ),
              ],
            ),
          ),
          
          // Connectivity indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.darkBgSecondary,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: state.isOfflineMode
                    ? AppTheme.neonOrange
                    : AppTheme.neonGreen,
                width: 2,
              ),
              boxShadow: AppTheme.neonGlow(
                state.isOfflineMode ? AppTheme.neonOrange : AppTheme.neonGreen,
                intensity: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  state.isOfflineMode ? Icons.wifi_off : Icons.wifi,
                  color: state.isOfflineMode
                      ? AppTheme.neonOrange
                      : AppTheme.neonGreen,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  state.isOfflineMode ? 'OFFLINE' : 'ONLINE',
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: state.isOfflineMode
                        ? AppTheme.neonOrange
                        : AppTheme.neonGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.darkBgSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
        boxShadow: AppTheme.neonGlow(color, intensity: 0.3),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'RobotoMono',
              fontSize: 10,
              color: AppTheme.textSecondary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
              shadows: [
                Shadow(color: color, blurRadius: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusMessage(BenchmarkState state) {
    String message = '';
    Color color = AppTheme.neonCyan;

    switch (state.status) {
      case BenchmarkStatus.loadingModel:
        message = 'LOADING MODEL: ${state.modelName ?? "..."}';
        break;
      case BenchmarkStatus.downloading:
        message = 'DOWNLOADING: ${(state.progress * 100).toStringAsFixed(0)}%';
        break;
      case BenchmarkStatus.running:
        message = 'INFERENCE IN PROGRESS...';
        color = AppTheme.neonGreen;
        break;
      case BenchmarkStatus.completed:
        message = 'BENCHMARK COMPLETE - ${state.currentSpeed.toStringAsFixed(1)} TOKENS/SEC';
        color = AppTheme.neonGreen;
        break;
      case BenchmarkStatus.error:
        message = 'ERROR: ${state.errorMessage ?? "Unknown error"}';
        color = AppTheme.neonOrange;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.darkBgSecondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          if (state.status == BenchmarkStatus.running ||
              state.status == BenchmarkStatus.downloading)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          if (state.status == BenchmarkStatus.running ||
              state.status == BenchmarkStatus.downloading)
            const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(
    BuildContext context,
    WidgetRef ref,
    BenchmarkState state,
  ) {
    final controller = ref.read(benchmarkControllerProvider.notifier);
    final isRunning = state.status == BenchmarkStatus.running ||
        state.status == BenchmarkStatus.downloading ||
        state.status == BenchmarkStatus.loadingModel;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ElevatedButton(
        onPressed: isRunning
            ? null
            : () => controller.startBenchmark(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.neonCyan,
          disabledBackgroundColor: AppTheme.darkBgTertiary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          isRunning ? 'RUNNING...' : 'START BENCHMARK',
          style: const TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: AppTheme.darkBg,
          ),
        ),
      ),
    );
  }
}
