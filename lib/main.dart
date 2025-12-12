import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/benchmark/presentation/screens/home_screen.dart';
import 'features/benchmark/data/repositories/benchmark_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  final repository = BenchmarkRepository();
  await repository.initialize();
  
  runApp(
    const ProviderScope(
      child: NeuralGaugeApp(),
    ),
  );
}

class NeuralGaugeApp extends StatelessWidget {
  const NeuralGaugeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeuralGauge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const HomeScreen(),
    );
  }
}
