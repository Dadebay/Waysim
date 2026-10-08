import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/app/app.dart';
import 'package:waysim/app/cubit/locale_cubit.dart';
import 'package:waysim/app/session_coordinator.dart';
import 'package:waysim/core/di/injector.dart';
import 'package:waysim/core/theme/app_color_tokens.dart';
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
    getIt<LocaleCubit>().setLocale(const Locale('ru'));
  });

  testWidgets('guest profile has blue card and bordered white menu', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Профиль').last);
    await tester.pumpAndSettle();

    final background = tester.widget<ColoredBox>(
      find.byKey(const ValueKey('profile-background')),
    );
    expect(
      background.color,
      Color.lerp(
        AppColorTokens.light.background,
        AppColorTokens.light.textPrimary,
        0.04,
      ),
    );
    final hero = tester.widget<Container>(
      find.byKey(const ValueKey('profile-guest-hero')),
    );
    final menu = tester.widget<Container>(
      find.byKey(const ValueKey('profile-guest-menu')),
    );
    expect(
      (hero.decoration! as BoxDecoration).color,
      AppColorTokens.light.primary,
    );
    final menuDecoration = menu.decoration! as BoxDecoration;
    expect(menuDecoration.color, AppColorTokens.light.background);
    expect(menuDecoration.border, isNotNull);
    expect(find.text('Зарегистрироваться'), findsOneWidget);
    expect(find.text('Настройки'), findsOneWidget);
    expect(find.text('Подробнее'), findsOneWidget);
    for (final label in ['Настройки', 'Подробнее']) {
      final row = find
          .ancestor(of: find.text(label), matching: find.byType(InkWell))
          .first;
      expect(tester.getSize(row).height, greaterThanOrEqualTo(62));
    }
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Зарегистрироваться'));
    await tester.pumpAndSettle();
    expect(find.text('Вход или регистрация'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}
