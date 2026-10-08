import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/app/app.dart';
import 'package:waysim/app/cubit/locale_cubit.dart';
import 'package:waysim/app/session_coordinator.dart';
import 'package:waysim/core/di/injector.dart';
import 'package:waysim/core/theme/app_color_tokens.dart';
import 'package:waysim/core/utils/result.dart';
import 'package:waysim/features/auth/domain/repositories/auth_repository.dart';
import 'package:waysim/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:waysim/features/catalog/presentation/cubit/catalog_cubit.dart';
import 'package:waysim/features/profile/presentation/view/profile_page.dart';
import 'package:waysim/mock/mock_backend.dart';

import '../helpers/load_fonts.dart';
import '../helpers/test_dependencies.dart';

void main() {
  setUpAll(loadAppFonts);
  setUp(() async {
    await setUpTestDependencies(
      backend: MockBackend(
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
    getIt<LocaleCubit>().setLocale(const Locale('ru'));
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });

  testWidgets('signed-in profile uses blue balance and grouped white menus', (
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
    final systemBackground = tester.widget<ColoredBox>(
      find.byKey(const ValueKey('profile-system-background')),
    );
    expect(systemBackground.color, background.color);
    final systemStyle = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
      find.descendant(
        of: find.byType(ProfilePage),
        matching: find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
      ),
    );
    expect(systemStyle.value.statusBarColor, background.color);
    final balance = tester.widget<Container>(
      find.byKey(const ValueKey('profile-balance-card')),
    );
    expect(
      (balance.decoration! as BoxDecoration).color,
      AppColorTokens.light.primary,
    );
    expect(find.byKey(const ValueKey('profile-account-menu')), findsOneWidget);
    expect(find.byKey(const ValueKey('profile-danger-menu')), findsOneWidget);
    expect(find.text(r'$24.50'), findsOneWidget);
    expect(find.text('Заказы'), findsOneWidget);
    for (final label in ['Заказы', 'Пригласить друзей']) {
      final row = find
          .ancestor(of: find.text(label), matching: find.byType(InkWell))
          .first;
      expect(tester.getSize(row).height, greaterThanOrEqualTo(54));
    }
    expect(find.text('Настройки'), findsOneWidget);
    expect(find.text('Выйти'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('+ Пополнить'));
    await tester.pumpAndSettle();
    expect(find.text('Пополнить баланс'), findsWidgets);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('copying the profile ID shows no second toast on Android', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Профиль').last);
    await tester.pumpAndSettle();
    String? copiedId;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            copiedId =
                (call.arguments as Map<Object?, Object?>)['text'] as String;
          }
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );
    await tester.tap(find.byKey(const ValueKey('profile-id-chip')));
    await tester.pump();

    expect(copiedId, 'A0123');
    expect(find.byType(SnackBar), findsNothing);
    expect(tester.takeException(), isNull);
    debugDefaultTargetPlatformOverride = null;
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'sign out asks for confirmation and preserves the session on cancel',
    (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Профиль').last);
      await tester.pumpAndSettle();

      final signOutRow = find.descendant(
        of: find.byKey(const ValueKey('profile-danger-menu')),
        matching: find.text('Выйти'),
      );
      await tester.ensureVisible(signOutRow);
      await tester.pumpAndSettle();
      await tester.tap(signOutRow);
      await tester.pumpAndSettle();

      expect(find.text('Выйти из аккаунта?'), findsOneWidget);
      expect(getIt<AuthCubit>().state.isSignedIn, isTrue);
      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle();
      expect(getIt<AuthCubit>().state.isSignedIn, isTrue);

      await tester.tap(signOutRow);
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Выйти'),
        ),
      );
      await tester.pumpAndSettle();
      expect(getIt<AuthCubit>().state.isSignedIn, isFalse);
      expect(find.text('Зарегистрироваться'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
