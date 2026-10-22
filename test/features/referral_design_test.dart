import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/app/app.dart';
import 'package:waysim/app/cubit/locale_cubit.dart';
import 'package:waysim/app/cubit/theme_cubit.dart';
import 'package:waysim/app/session_coordinator.dart';
import 'package:waysim/core/di/injector.dart';
import 'package:waysim/core/theme/app_color_tokens.dart';
import 'package:waysim/core/utils/result.dart';
import 'package:waysim/features/auth/domain/repositories/auth_repository.dart';
import 'package:waysim/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:waysim/features/catalog/presentation/cubit/catalog_cubit.dart';
import 'package:waysim/features/referral/presentation/view/referral_page.dart';
import 'package:waysim/features/referral/domain/entities/referral.dart';
import 'package:waysim/features/referral/domain/repositories/referral_repository.dart';
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

  testWidgets('referral page groups the PDF design sections on cards', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Профиль').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Пригласить друзей'));
    await tester.pumpAndSettle();

    final hero = tester.widget<Container>(
      find.byKey(const ValueKey('referral-hero')),
    );
    expect(
      (hero.decoration! as BoxDecoration).color,
      AppColorTokens.light.primary,
    );
    expect(find.text('WAY7K2Q'), findsOneWidget);
    expect(find.text('Поделиться приглашением'), findsOneWidget);
    expect(find.textContaining('waysim.co/r/'), findsNothing);
    expect(find.byKey(const ValueKey('referral-rules-card')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('referral-invites-card')),
      250,
      scrollable: find
          .descendant(
            of: find.byType(ReferralPage),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.byKey(const ValueKey('referral-invites-card')), findsOneWidget);
    expect(find.text('a***@gmail.com'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('empty invites card uses the matching light and dark artwork', (
    tester,
  ) async {
    getIt
      ..unregister<ReferralRepository>()
      ..registerSingleton<ReferralRepository>(
        _EmptyInvitesRepository(getIt<MockBackend>()),
      );

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Профиль').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Пригласить друзей'));
    await tester.pumpAndSettle();

    final card = find.byKey(const ValueKey('referral-invites-empty-card'));
    await tester.scrollUntilVisible(
      card,
      250,
      scrollable: find
          .descendant(
            of: find.byType(ReferralPage),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(card, findsOneWidget);
    expect(find.byKey(const ValueKey('referral-invites-card')), findsNothing);

    String artwork() =>
        (tester
                    .widget<Image>(
                      find.descendant(of: card, matching: find.byType(Image)),
                    )
                    .image
                as AssetImage)
            .assetName;
    expect(artwork(), endsWith('referral_invites_empty_light.png'));

    getIt<ThemeCubit>().setThemeMode(ThemeMode.dark);
    await tester.pumpAndSettle();
    expect(artwork(), endsWith('referral_invites_empty_dark.png'));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('copying the invite code shows no second toast on Android', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Профиль').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Пригласить друзей'));
    await tester.pumpAndSettle();

    String? copiedCode;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            copiedCode =
                (call.arguments as Map<Object?, Object?>)['text'] as String;
          }
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );

    await tester.tap(find.byKey(const ValueKey('referral-copy-code-button')));
    await tester.pump();

    expect(copiedCode, 'WAY7K2Q');
    expect(find.byType(SnackBar), findsNothing);
    expect(tester.takeException(), isNull);

    debugDefaultTargetPlatformOverride = null;
    await tester.pumpWidget(const SizedBox());
  });
}

class _EmptyInvitesRepository implements ReferralRepository {
  _EmptyInvitesRepository(this.backend);

  final MockBackend backend;

  @override
  Future<Result<ReferralInfo>> load() async {
    final data = (await backend.referral()).dataOrNull!;
    return Success(
      ReferralInfo(
        code: data.code,
        link: data.link,
        reward: data.reward,
        invited: 0,
        credited: data.credited,
        pending: 0,
        rejected: 0,
        invites: const [],
        rulesText: data.rulesText,
      ),
    );
  }
}
