import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:waysim/app/app.dart';
import 'package:waysim/core/di/injector.dart';
import 'package:waysim/core/storage/local_storage.dart';
import 'package:waysim/core/storage/storage_keys.dart';
import 'package:waysim/features/catalog/presentation/cubit/catalog_cubit.dart';
import 'package:waysim/features/auth/presentation/cubit/auth_cubit.dart';

import '../helpers/load_fonts.dart';
import '../helpers/test_dependencies.dart';

/// `https://waysim.co/...` and `waysim://...` links. A link never acts on its
/// own: it can remember an invite code and open the app, nothing more.
void main() {
  setUpAll(loadAppFonts);

  setUp(() async {
    await setUpTestDependencies();
    await getIt<CatalogCubit>().load();
    await getIt<AuthCubit>().restore();
  });

  Future<GoRouter> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    return GoRouter.of(tester.element(find.text('Hi!')));
  }

  testWidgets('an invite link keeps the code for sign-up and opens Home', (
    tester,
  ) async {
    final router = await open(tester);

    router.go('/r/way7k2q');
    await tester.pumpAndSettle();

    expect(
      getIt<LocalStorage>().getString(StorageKeys.pendingInvite),
      'WAY7K2Q',
    );
    expect(find.text('Hi!'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a malformed invite code is ignored', (tester) async {
    final router = await open(tester);

    router.go('/r/x%20y;drop');
    await tester.pumpAndSettle();

    expect(getIt<LocalStorage>().getString(StorageKeys.pendingInvite), isNull);
    expect(find.text('Hi!'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('returning from PayPal lands on Home', (tester) async {
    final router = await open(tester);

    router.go('/pay/return?token=abc');
    await tester.pumpAndSettle();

    expect(find.text('Hi!'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the sign-up form is prefilled with a remembered invite', (
    tester,
  ) async {
    final router = await open(tester);
    router.go('/r/WAY7K2Q');
    await tester.pumpAndSettle();

    unawaited(router.push('/login'));
    await tester.pumpAndSettle();

    expect(find.text('WAY7K2Q'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
