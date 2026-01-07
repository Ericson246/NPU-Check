import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npu_check/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Simple smoke test to ensure the app widget tree can be built.
    // Note: Full integration testing requires mocking Hive and native bindings.
    await tester.pumpWidget(
      const ProviderScope(
        child: NeuralGaugeApp(),
      ),
    );
  });
}