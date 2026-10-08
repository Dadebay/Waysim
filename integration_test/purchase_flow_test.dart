import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:waysim/main.dart' as app;

/// The key scenario on a real device or emulator, on the mock backend:
/// search → plan → sign in with an e-mail code → pay → eSIM ready.
///
///   flutter test integration_test --dart-define=USE_MOCK_API=true
///
/// The widget test in test/features/purchase_flow_test.dart covers the same
/// path without a device; this one also exercises the real plugins (secure
/// storage, preferences, fonts, SVG flags, platform channels).
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

    // Signed out: the sign-in screen first.
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
