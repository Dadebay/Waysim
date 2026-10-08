import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/app/app.dart';
import 'package:waysim/app/session_coordinator.dart';
import 'package:waysim/core/di/injector.dart';
import 'package:waysim/core/widgets/support_fab.dart';
import 'package:waysim/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:waysim/features/catalog/presentation/cubit/catalog_cubit.dart';

import '../helpers/load_fonts.dart';
import '../helpers/test_dependencies.dart';

void main() {
  setUpAll(loadAppFonts);
  setUp(() async {
    await setUpTestDependencies();
    await getIt<CatalogCubit>().load();
    await getIt<AuthCubit>().restore();
    getIt<SessionCoordinator>().start();
  });

  testWidgets('empty My eSIM screen offers buying and usage guidance', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    await tester.tap(find.text('My eSIM').last);
    await tester.pumpAndSettle();

    expect(find.text('No eSIMs yet'), findsOneWidget);
    expect(find.text('Get an eSIM'), findsOneWidget);
    expect(find.byKey(const ValueKey('how-esim-works')), findsOneWidget);
    expect(
      tester
          .getRect(find.byKey(const ValueKey('how-esim-works')))
          .overlaps(tester.getRect(find.byType(SupportFab))),
      isFalse,
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('how-esim-works')));
    await tester.pumpAndSettle();
    expect(find.text('How eSIM works'), findsWidgets);
    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Get an eSIM'));
    await tester.pumpAndSettle();
    expect(find.text('Where do you need an eSIM?'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}
