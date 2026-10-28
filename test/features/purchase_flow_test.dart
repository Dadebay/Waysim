import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/app/app.dart';
import 'package:waysim/app/session_coordinator.dart';
import 'package:waysim/app/telemetry_coordinator.dart';
import 'package:waysim/core/di/injector.dart';
import 'package:waysim/core/services/esim_compatibility.dart';
import 'package:waysim/core/services/esim_support_cubit.dart';
import 'package:waysim/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:waysim/features/catalog/presentation/cubit/catalog_cubit.dart';
import 'package:waysim/features/wallet/presentation/cubit/wallet_cubit.dart';
import 'package:waysim/mock/demo_credentials.dart';

import '../helpers/load_fonts.dart';
import '../helpers/test_dependencies.dart';

/// The whole happy path on the mock backend, through the real screens:
/// find a country → buy as a guest (sign in on the way) → eSIM ready.
void main() {
  setUpAll(loadAppFonts);

  late RecordingAnalytics analytics;

  setUp(() async {
    analytics = RecordingAnalytics();
    await setUpTestDependencies(analytics: analytics);
    await getIt<CatalogCubit>().load();
    await getIt<AuthCubit>().restore();
    await getIt<EsimSupportCubit>().check();
    getIt<SessionCoordinator>().start();
    getIt<TelemetryCoordinator>().start();
  });

  Future<void> phone(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  testWidgets('a guest buys a plan: search, sign in, confirm, eSIM ready', (
    tester,
  ) async {
    await phone(tester);
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 5),
    );

    // Search for Türkiye with a prefix, in any case.
    await tester.tap(find.text('Where do you need an eSIM?'));
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 5),
    );
    await tester.enterText(find.byType(TextField), 'tur');
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 5),
    );
    await tester.tap(find.text('Türkiye'));
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 5),
    );

    // The 5 GB plan is pre-selected.
    expect(find.text(r'Buy for $5.99'), findsOneWidget);
    await tester.tap(find.text(r'Buy for $5.99'));
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 5),
    );

    // Guests are sent to sign in first.
    expect(find.text('Sign in or sign up'), findsOneWidget);
    await tester.enterText(
      find.byType(TextField).first,
      DemoCredentials.newEmail,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller?.text,
      DemoCredentials.newEmail,
    );

    Future<void> openConsentLink(String label, String title) async {
      final paragraph = tester.renderObject<RenderParagraph>(
        find.byKey(const ValueKey('consent-text')),
      );
      final start = paragraph.text.toPlainText().indexOf(label);
      expect(start, greaterThanOrEqualTo(0));
      final box = paragraph
          .getBoxesForSelection(
            TextSelection(
              baseOffset: start,
              extentOffset: start + label.length,
            ),
          )
          .first;
      await tester.tapAt(paragraph.localToGlobal(box.toRect().center));
      await tester.pumpAndSettle();
      expect(find.text(title), findsWidgets);
      await tester.pageBack();
      await tester.pumpAndSettle();
    }

    await openConsentLink('Terms of Use', 'Terms of use');
    await openConsentLink('Privacy Policy', 'Privacy policy');
    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(find.text('Please accept the terms to continue'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('age-checkbox')));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 5),
    );

    // The code step. Six digits, no password.
    expect(find.text('Enter the code'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    await tester.tap(find.text('Change e-mail'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller?.text,
      DemoCredentials.newEmail,
    );
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Enter the code'), findsOneWidget);
    await tester.enterText(find.byType(TextField), DemoCredentials.code);
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 5),
    );

    // New customers are asked for a name, which they can skip.
    expect(find.text('What should we call you?'), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 5),
    );

    // Back where they were: the confirmation, with the demo balance.
    expect(find.text('Confirm purchase'), findsOneWidget);
    expect(find.text(r'$24.50'), findsOneWidget);
    expect(find.text(r'$18.51'), findsOneWidget);
    await tester.tap(find.text(r'Pay $5.99'));
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 5),
    );

    expect(find.text('eSIM is ready!'), findsOneWidget);
    expect(find.text('Install eSIM'), findsOneWidget);
    // The server's balance, as the app now shows it.
    expect(getIt<WalletCubit>().state.balance?.cents, 1851);

    // What the dashboards will see: the funnel, with the price in dollars.
    expect(analytics.named('search').single['search_term'], 'tur');
    expect(analytics.named('sign_up'), hasLength(1));
    final checkout = analytics.named('begin_checkout').single;
    expect(checkout['item_id'], 'TR_5_30');
    expect(checkout['value'], 5.99);
    final purchase = analytics.named('purchase').single;
    expect(
      (purchase['items'] as List<Object?>).single,
      containsPair('item_category', 'TR'),
    );
    expect(purchase['value'], 5.99);
    expect(analytics.userId, 'A0123');

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a supported phone says so and explains the carrier lock', (
    tester,
  ) async {
    await phone(tester);
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Where do you need an eSIM?'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'tur');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Türkiye'));
    await tester.pumpAndSettle();
    expect(find.text('Your device supports eSIMs'), findsOneWidget);

    await tester.tap(find.text('Your device supports eSIMs'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'How to check if your device is locked to a carrier or network',
      ),
      findsOneWidget,
    );
    await tester.ensureVisible(find.text('Got it'));
    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();
    expect(find.text('Your device supports eSIMs'), findsOneWidget);
  });

  testWidgets('an unverified iPhone has no EID confirmation controls', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    (getIt<EsimCompatibility>() as FakeCompatibility).support =
        EsimSupport.likely;
    await getIt<EsimSupportCubit>().check();
    await phone(tester);
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.text('eSIM support not verified'), findsOneWidget);
    expect(find.textContaining('EID'), findsNothing);
    expect(find.text('Got it'), findsNothing);
    expect(find.text('eSIM support not verified'), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('a phone without eSIM warns before buying', (tester) async {
    (getIt<EsimCompatibility>() as FakeCompatibility).support = EsimSupport.no;
    await getIt<EsimSupportCubit>().check();
    await phone(tester);
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Where do you need an eSIM?'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'tur');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Türkiye'));
    await tester.pumpAndSettle();
    expect(find.text("Your device doesn't support eSIMs"), findsOneWidget);
    await tester.tap(find.text(r'Buy for $5.99'));
    await tester.pumpAndSettle();

    expect(find.text('Your phone may not support eSIM'), findsOneWidget);
    expect(find.text('Sign in or sign up'), findsNothing);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text(r'Buy for $5.99'), findsOneWidget);
  });

  testWidgets('an unconfirmed iPhone warns before checkout', (tester) async {
    (getIt<EsimCompatibility>() as FakeCompatibility).support =
        EsimSupport.likely;
    await getIt<EsimSupportCubit>().check();
    await phone(tester);
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Where do you need an eSIM?'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'tur');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Türkiye'));
    await tester.pumpAndSettle();
    expect(find.text('eSIM support not verified'), findsOneWidget);

    await tester.tap(find.text(r'Buy for $5.99'));
    await tester.pumpAndSettle();
    expect(find.text('Your phone may not support eSIM'), findsOneWidget);
    expect(find.text('Sign in or sign up'), findsNothing);
  });
}
