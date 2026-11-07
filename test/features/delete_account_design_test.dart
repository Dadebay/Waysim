import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/app/app.dart';
import 'package:waysim/app/cubit/locale_cubit.dart';
import 'package:waysim/app/session_coordinator.dart';
import 'package:waysim/core/di/injector.dart';
import 'package:waysim/core/utils/result.dart';
import 'package:waysim/features/auth/domain/repositories/auth_repository.dart';
import 'package:waysim/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:waysim/features/catalog/presentation/cubit/catalog_cubit.dart';
import 'package:waysim/mock/mock_backend.dart';

import '../helpers/load_fonts.dart';
import '../helpers/test_dependencies.dart';

void main() {
  setUpAll(loadAppFonts);
  setUp(() async {
    await setUpTestDependencies(backend: MockBackend(latency: Duration.zero));
    await getIt<CatalogCubit>().load();
    final result = await getIt<AuthRepository>().verifyCode(
      email: 'anna@example.com',
      code: '123456',
    );
    getIt<AuthCubit>().signedIn((result as Success).data.user);
    getIt<SessionCoordinator>().start();
    getIt<LocaleCubit>().setLocale(const Locale('ru'));
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });

  testWidgets('delete warning shows consequences, support and code step', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Профиль').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Удалить аккаунт'));
    await tester.pumpAndSettle();

    expect(find.text('Удаление аккаунта'), findsOneWidget);
    expect(find.text('Это действие нельзя отменить'), findsOneWidget);
    expect(find.byKey(const ValueKey('delete-support-note')), findsOneWidget);
    expect(find.text('Продолжить'), findsOneWidget);
    expect(find.text('Отмена'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('delete-support-note')));
    await tester.pumpAndSettle();
    expect(find.text('Чем помочь?'), findsOneWidget);
    await tester.tap(find.text('Закрыть'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Продолжить'));
    await tester.pumpAndSettle();
    expect(find.text('Введите код'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}
