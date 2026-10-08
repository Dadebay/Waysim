import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/app/app.dart';
import 'package:waysim/app/session_coordinator.dart';
import 'package:waysim/core/di/injector.dart';
import 'package:waysim/core/utils/result.dart';
import 'package:waysim/features/auth/domain/repositories/auth_repository.dart';
import 'package:waysim/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:waysim/features/catalog/presentation/cubit/catalog_cubit.dart';
import 'package:waysim/mock/mock_backend.dart';

import '../helpers/load_fonts.dart';
import '../helpers/test_dependencies.dart';

/// Tap targets of at least 44 pt (iOS) / 48 dp (Android) and a spoken label
/// on everything tappable, on the screens a customer uses most.
void main() {
  setUpAll(loadAppFonts);

  Future<void> boot(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      await setUpTestDependencies(
        backend: MockBackend(
          now: () => tester.binding.clock.now(),
          latency: Duration.zero,
          purchaseLatency: Duration.zero,
        ),
      );
      await getIt<CatalogCubit>().load();
      final result = await getIt<AuthRepository>().verifyCode(
        email: 'anna@example.com',
        code: '123456',
      );
      getIt<AuthCubit>().signedIn((result as Success).data.user);
      getIt<SessionCoordinator>().start();
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
  }

  Future<void> check(WidgetTester tester) async {
    final handle = tester.ensureSemantics();
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  }

  testWidgets('Home', (tester) async {
    await boot(tester);
    await check(tester);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('My eSIM', (tester) async {
    await boot(tester);
    await tester.tap(find.text('My eSIM').last);
    await tester.pumpAndSettle();
    await check(tester);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Profile', (tester) async {
    await boot(tester);
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await check(tester);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Destination', (tester) async {
    await boot(tester);
    await tester.tap(find.text('Where do you need an eSIM?'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'tur');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Türkiye'));
    await tester.pumpAndSettle();
    await check(tester);
    await tester.pumpWidget(const SizedBox());
  });
}
