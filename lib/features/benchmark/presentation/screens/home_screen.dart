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
    // We use a different name to avoid shadowing the context in showDialog
    final benchmarkState = ref.watch(benchmarkControllerProvider);

    // Listen for completion to show dialog
    ref.listen(benchmarkControllerProvider.select((s) => s.status), (previous, next) {
      if (next == BenchmarkStatus.completed) {
        _showResultsDialog(context, ref);
      }
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with connectivity indicator
                  _buildHeader(benchmarkState),
                  
                  const SizedBox(height: 10),
                  
                  // Model Selector
                  ModelSelectorWidget(
                    selectedModel: benchmarkState.selectedModel,
                    downloadedModels: benchmarkState.downloadedModels,
                    onModelSelected: (model) {
                      ref.read(benchmarkControllerProvider.notifier).selectModel(model);
                    },
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Workload Selector
                  _buildWorkloadSelector(ref, benchmarkState),

                  // Speedometer with fixed height since Spacer won't work inside scroll
                  SizedBox(
                    height: 250,
                    child: SpeedometerWidget(
                      tokensPerSecond: benchmarkState.currentSpeed,
                      maxSpeed: 100.0,
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // RAM Usage
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildMetricCard(
                        'RAM USAGE',
                        '${benchmarkState.ramUsageMB.toStringAsFixed(1)} MB',
                        AppTheme.neonMagenta,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Progress Bar
                  if (benchmarkState.status == BenchmarkStatus.running || 
                      benchmarkState.status == BenchmarkStatus.downloading)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              benchmarkState.status == BenchmarkStatus.downloading
                                  ? 'DOWNLOADING MODEL...'
                                  : 'BENCHMARK PROGRESS',
                              style: const TextStyle(
                                fontFamily: 'RobotoMono',
                                fontSize: 10,
                                color: AppTheme.neonCyan,
                                letterSpacing: 1,
                              ),
                            ),
                            Text(
                              '${(benchmarkState.progress * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontFamily: 'RobotoMono',
                                fontSize: 10,
                                color: AppTheme.neonCyan,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: benchmarkState.progress,
                            backgroundColor: AppTheme.darkBgTertiary,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.neonCyan),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 15),
                      ],
                    ),

                  // Collapsible Terminal
                  _buildTerminal(ref, benchmarkState),
                  
                  const SizedBox(height: 15),
                  
                  // Status message
                  if (benchmarkState.status != BenchmarkStatus.idle && 
                      benchmarkState.status != BenchmarkStatus.completed)
                     Padding(
                       padding: const EdgeInsets.only(bottom: 10),
                       child: _buildStatusMessage(benchmarkState),
                     ),
                  
                  // Control buttons
                  _buildControls(context, ref, benchmarkState),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BenchmarkState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App title
          const Text(
            'NEURAL GAUGE',
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.neonCyan,
              letterSpacing: 2,
              shadows: [
                Shadow(
                  color: AppTheme.neonCyan,
                  blurRadius: 10,
                ),
              ],
            ),
          ),
          
          // Connectivity indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.darkBgSecondary,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: state.isOfflineMode
                    ? AppTheme.neonOrange
                    : AppTheme.neonGreen,
                width: 1.5,
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
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  state.isOfflineMode ? 'OFFLINE' : 'ONLINE',
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 10,
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
        message = 'BENCHMARK COMPLETE';
        color = AppTheme.neonGreen;
        break;
      case BenchmarkStatus.error:
        final rawError = state.errorMessage ?? "Unknown error";
        final cleanError = rawError.replaceAll('Exception: ', '').replaceAll('Failed to prepare model: ', '');
        
        if (state.errorMessage == 'STOPPED BY USER') {
          message = 'BENCHMARK STOPPED BY USER';
          color = AppTheme.neonOrange;
        } else {
          message = 'ERROR: $cleanError';
          color = AppTheme.neonOrange;
        }
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
    final isDownloading = state.status == BenchmarkStatus.downloading;
    final isRunningOrLoading = state.status == BenchmarkStatus.running || 
                               state.status == BenchmarkStatus.loadingModel;
    final isActive = isDownloading || isRunningOrLoading;

    String buttonText = 'START BENCHMARK';
    if (isDownloading) {
      buttonText = 'CANCEL DOWNLOAD';
    } else if (isRunningOrLoading) {
      buttonText = 'STOP BENCHMARK';
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (isActive) {
            controller.stopBenchmark();
          } else {
            controller.startBenchmark();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? AppTheme.neonOrange : AppTheme.neonCyan,
          disabledBackgroundColor: AppTheme.darkBgTertiary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadowColor: isActive ? AppTheme.neonOrange : AppTheme.neonCyan,
          elevation: 8,
        ),
        child: Text(
          buttonText,
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

  Widget _buildTerminal(WidgetRef ref, BenchmarkState state) {
    final isVisible = state.showTerminal;
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkBgSecondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.neonCyan.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          // Terminal Header
          GestureDetector(
            onTap: () => ref.read(benchmarkControllerProvider.notifier).toggleTerminal(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.darkBgTertiary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.terminal, size: 14, color: AppTheme.neonCyan),
                      SizedBox(width: 8),
                      Text(
                        'INFERENCE CONSOLE',
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.neonCyan,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    isVisible ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                    size: 16,
                    color: AppTheme.neonCyan,
                  ),
                ],
              ),
            ),
          ),
          
          // Terminal Content
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: isVisible ? 80 : 0,
            padding: EdgeInsets.all(isVisible ? 8 : 0),
            child: SingleChildScrollView(
              reverse: true,
              child: Text(
                state.generatedText.isEmpty ? '> Waiting for input...' : state.generatedText,
                style: const TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 9,
                  color: AppTheme.neonGreen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResultsDialog(BuildContext context, WidgetRef ref) {
    final state = ref.read(benchmarkControllerProvider);
    
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.8),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: ScaleTransition(
            scale: animation,
            child: FadeTransition(
              opacity: animation,
              child: Material(
                color: Colors.transparent,
                child: _buildFinalResults(context, ref, state),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFinalResults(BuildContext context, WidgetRef ref, BenchmarkState state) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.darkBgSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neonGreen, width: 2),
        boxShadow: AppTheme.neonGlow(AppTheme.neonGreen),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline, color: AppTheme.neonGreen, size: 64),
          const SizedBox(height: 16),
          const Text(
            'BENCHMARK COMPLETE',
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.neonGreen,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLargeResultMetric(
                'AVERAGE SPEED',
                state.averageSpeed.toStringAsFixed(1),
                't/s',
                AppTheme.neonCyan,
              ),
              _buildLargeResultMetric(
                'RAM PEAK',
                state.ramPeakMB.toStringAsFixed(0),
                'MB',
                AppTheme.neonMagenta,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.darkBgTertiary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Hardware: Pixel 7 Pro\nModel: ${state.modelName}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 12,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(benchmarkControllerProvider.notifier).stopBenchmark();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonGreen,
                foregroundColor: AppTheme.darkBg,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'DISMISS & RESET',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeResultMetric(String label, String value, String unit, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 10,
            color: AppTheme.textSecondary,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
                shadows: [Shadow(color: color, blurRadius: 10)],
              ),
            ),
            const SizedBox(width: 4),
            Text(
              unit,
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 12,
                color: color.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkloadSelector(WidgetRef ref, BenchmarkState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.darkBgSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.neonPurple.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'WORKLOAD INTENSITY',
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 10,
                color: AppTheme.textSecondary,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: BenchmarkWorkload.values.map((workload) {
                final isSelected = state.workload == workload;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (state.status == BenchmarkStatus.idle || 
                          state.status == BenchmarkStatus.completed || 
                          state.status == BenchmarkStatus.error) {
                        ref.read(benchmarkControllerProvider.notifier).selectWorkload(workload);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppTheme.neonPurple.withOpacity(0.2) 
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected 
                              ? AppTheme.neonPurple 
                              : AppTheme.darkBgTertiary,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            workload.label.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected 
                                  ? AppTheme.neonPurple 
                                  : AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            workload.isTimeBased 
                                ? '${workload.minDuration.inSeconds}s' 
                                : '${workload.tokens} TOKENS',
                            style: TextStyle(
                              fontFamily: 'RobotoMono',
                              fontSize: 10,
                              color: isSelected 
                                  ? AppTheme.white 
                                  : AppTheme.textSecondary.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

