import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:waysim/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> settle(WidgetTester tester) => tester.pumpAndSettle(
    const Duration(milliseconds: 100),
    EnginePhase.sendSemanticsUpdate,
    const Duration(seconds: 20),
  );

  testWidgets('a guest buys a plan and gets an eSIM', (tester) async {
    app.main();
    await settle(tester);

    await tester.tap(find.text('Where do you need an eSIM?'));
    await settle(tester);
    await tester.enterText(find.byType(TextField), 'tur');
    await settle(tester);
    await tester.tap(find.text('Türkiye'));
    await settle(tester);

    await tester.tap(find.textContaining('Buy for'));
    await settle(tester);

    await tester.enterText(find.byType(TextField).first, 'it@example.com');
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await settle(tester);
    await tester.enterText(find.byType(TextField), '123456');
    await settle(tester);
    await tester.tap(find.text('Skip'));
    await settle(tester);

    await tester.tap(find.textContaining('Pay '));
    await settle(tester);

    expect(find.text('eSIM is ready!'), findsOneWidget);
    await binding.takeScreenshot('esim-ready');
  });
}
