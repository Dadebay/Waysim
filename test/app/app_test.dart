import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/app/app.dart';
import 'package:waysim/app/cubit/locale_cubit.dart';
import 'package:waysim/app/cubit/theme_cubit.dart';
import 'package:waysim/core/di/injector.dart';
import 'package:waysim/core/network/api_client.dart';
import 'package:waysim/core/services/push_service.dart';
import 'package:waysim/core/storage/secure_storage.dart';
import 'package:waysim/core/widgets/support_fab.dart';
import 'package:waysim/core/storage/local_storage.dart';
import 'package:waysim/core/theme/app_theme.dart';
import 'package:waysim/core/widgets/app_crossfade.dart';
import 'package:waysim/core/widgets/app_hero.dart';
import 'package:waysim/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:waysim/features/auth/domain/entities/user.dart';
import 'package:waysim/features/auth/presentation/view/login_page.dart';
import 'package:waysim/mock/mock_backend.dart';
import 'package:waysim/features/catalog/presentation/cubit/catalog_cubit.dart';
import 'package:waysim/features/config/domain/entities/app_config.dart';
import 'package:waysim/features/config/presentation/cubit/config_cubit.dart';
import 'package:waysim/features/catalog/presentation/view/destination_page.dart';
import 'package:waysim/features/home/presentation/view/home_page.dart';
import 'package:waysim/features/home/presentation/widgets/destination_list.dart';
import 'package:waysim/features/legal/presentation/view/legal_pages.dart';
import 'package:waysim/features/notification/presentation/cubit/notification_prefs_cubit.dart';
import 'package:waysim/features/profile/presentation/view/settings_page.dart';
import 'package:waysim/l10n/app_localizations.dart';

import '../helpers/load_fonts.dart';
import '../helpers/test_dependencies.dart';

void main() {
  setUpAll(loadAppFonts);

  setUp(() async {
    await setUpTestDependencies();
    await getIt<CatalogCubit>().load();
    await getIt<AuthCubit>().restore();
  });

  testWidgets('boots in English, light, on the Home tab', (tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.text('Hi!'), findsOneWidget);
    expect(find.text('Where do you need an eSIM?'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('My eSIM'), findsWidgets);
    expect(find.text('Profile'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.text('Hi!'))).brightness,
      Brightness.light,
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('reports a tapped push with its delivery id', (tester) async {
    final push = _TestPushService();
    getIt
      ..unregister<PushService>()
      ..registerSingleton<PushService>(push);

    final requests = <RequestOptions>[];
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: {'ok': true},
            ),
          );
        },
      ),
    );
    getIt
      ..unregister<ApiClient>()
      ..registerSingleton<ApiClient>(ApiClient(dio));

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    push.emit(const PushTap({'type': 'unknown', 'deliveryId': 'delivery-1'}));
    await tester.pumpAndSettle();
    expect(requests, hasLength(1));
    expect(requests.single.method, 'POST');
    expect(requests.single.path, '/v1/notifications/opened');
    expect(requests.single.data, {'deliveryId': 'delivery-1'});

    push.emit(const PushTap({'type': 'unknown', 'broadcastId': 'broadcast-1'}));
    await tester.pumpAndSettle();
    expect(requests, hasLength(2));
    expect(requests.last.data, {'broadcastId': 'broadcast-1'});

    push.emit(const PushTap({'type': 'unknown'}));
    await tester.pumpAndSettle();
    expect(requests, hasLength(3));
    expect(requests.last.data, <String, String>{});

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('sign-up offers the invite field before the referral flag is '
      'known', (tester) async {
    // Signed out, the real API reports the programme as off: `/v1/referral`
    // needs a session.
    getIt<MockBackend>().config = const AppConfig(referralEnabled: false);
    await getIt<ConfigCubit>().refresh();
    final auth = getIt<AuthCubit>();
    final login = await getIt<MockBackend>().verifyCode(
      'person@example.com',
      '123456',
    );
    auth.signedIn(login.dataOrNull!.user);
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    auth.sessionExpired(revoked: true);
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Invite code (optional)'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('remote sign-out opens sign-in with an explanation', (
    tester,
  ) async {
    final backend = getIt<MockBackend>();
    final login = await backend.verifyCode('person@example.com', '123456');
    final auth = getIt<AuthCubit>();
    auth.signedIn(login.dataOrNull!.user);
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    auth.sessionExpired(revoked: true);
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(
      find.text('You were signed out on this device. Please sign in again.'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('signed_out push drops user tokens and keeps the guest device', (
    tester,
  ) async {
    final push = _TestPushService();
    getIt
      ..unregister<PushService>()
      ..registerSingleton<PushService>(push);
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) => handler.resolve(
          Response<dynamic>(
            requestOptions: options,
            statusCode: 200,
            data: {'ok': true},
          ),
        ),
      ),
    );
    getIt
      ..unregister<ApiClient>()
      ..registerSingleton<ApiClient>(ApiClient(dio));
    final storage = getIt<SecureStorage>();
    await storage.saveDeviceToken('guest-token');
    await storage.saveTokens(
      accessToken: 'user-token',
      refreshToken: 'refresh',
    );
    getIt<AuthCubit>().signedIn(
      const User(publicId: 'A123', email: 'person@example.com'),
    );

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    push.emit(
      const PushTap({'type': 'signed_out', 'deepLink': 'waysim://home'}),
    );
    await tester.pumpAndSettle();

    expect(await storage.readAccessToken(), isNull);
    expect(await storage.readRefreshToken(), isNull);
    expect(await storage.readDeviceToken(), 'guest-token');
    expect(find.byType(LoginPage), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('support unread badge clears after replies are read', (
    tester,
  ) async {
    final auth = getIt<AuthCubit>();
    auth.signedIn(
      const User(
        publicId: 'A123',
        email: 'person@example.com',
        supportUnread: 2,
      ),
    );
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    final badge = find.descendant(
      of: find.byType(SupportFab),
      matching: find.text('2'),
    );
    expect(badge, findsOneWidget);
    auth.clearSupportUnread();
    await tester.pumpAndSettle();
    expect(badge, findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('tab pages get the screen above the tab bar', (tester) async {
    // Regression: a max-sized Column in the tab bar once took the whole
    // height and left every tab page 0 px tall.
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(HomePage)).height, greaterThan(400));

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Sign in to buy eSIMs').hitTestable(), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  for (final resume in [false, true]) {
    testWidgets(
      'checks removed session on ${resume ? 'resume' : 'tab change'}',
      (tester) async {
        final backend = getIt<MockBackend>();
        final login = await backend.verifyCode('person@example.com', '123456');
        final auth = getIt<AuthCubit>();
        auth.signedIn(login.dataOrNull!.user);
        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();
        await tester.tap(find.text('Profile').last);
        await tester.pumpAndSettle();
        expect(auth.state.isSignedIn, isTrue);

        // Simulate the server revoking this phone while its cached UI is open.
        backend.signOut();
        expect(auth.state.isSignedIn, isTrue);
        if (resume) {
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.paused,
          );
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.resumed,
          );
        } else {
          await tester.tap(find.text('Home'));
        }
        await tester.pumpAndSettle();
        expect(auth.state.status, AuthStatus.guest);
        await tester.tap(find.text('Profile').last);
        await tester.pumpAndSettle();
        expect(find.text('Sign in to buy eSIMs').hitTestable(), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

  testWidgets('destination flag has a matching Hero on its detail page', (
    tester,
  ) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -700));
    await tester.pumpAndSettle();
    final row = find.byType(DestinationRow).first;
    final destination = tester.widget<DestinationRow>(row).destination;
    await tester.ensureVisible(row);
    await tester.pumpAndSettle();
    await tester.tap(row);
    await tester.pumpAndSettle();

    expect(find.byType(DestinationPage), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(DestinationPage),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Hero &&
              widget.tag == AppHeroTags.destinationFlag(destination.code),
        ),
      ),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Profile, More, and document titles navigate with Heroes', (
    tester,
  ) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    expect(find.byType(LegalListPage), findsOneWidget);

    await tester.tap(find.text('Terms of use'));
    await tester.pumpAndSettle();
    expect(find.byType(LegalDocumentPage), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Terms of use'),
      ),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Settings: language and theme apply immediately', (tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>.value(value: getIt<ThemeCubit>()),
          BlocProvider<LocaleCubit>.value(value: getIt<LocaleCubit>()),
          BlocProvider<ConfigCubit>.value(value: getIt<ConfigCubit>()),
          BlocProvider.value(value: getIt<NotificationPrefsCubit>()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) => BlocBuilder<LocaleCubit, Locale>(
            builder: (context, locale) => MaterialApp(
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeMode,
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              home: const SettingsPage(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    final title = tester.widget<Text>(find.text('Settings'));
    expect(title.style?.fontSize, 20);
    expect(title.style?.fontWeight, FontWeight.w700);

    await tester.tap(find.text('Русский'));
    await tester.pumpAndSettle();
    expect(find.text('Настройки'), findsOneWidget);
    expect(getIt<LocaleCubit>().state, const Locale('ru'));

    // The language cards push the theme section below the fold.
    await tester.scrollUntilVisible(
      find.text('Тёмная'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    // Built is not the same as on screen: bring it inside the viewport.
    await tester.ensureVisible(find.text('Тёмная'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Тёмная'));
    await tester.pumpAndSettle();
    expect(getIt<ThemeCubit>().state, ThemeMode.dark);
    expect(
      Theme.of(tester.element(find.text('Настройки'))).brightness,
      Brightness.dark,
    );

    // The choice reaches plain preferences, where the Dio interceptor reads it.
    expect(getIt<LocalStorage>().getString('content_language'), 'ru');
  });

  testWidgets(
    'Settings follows server languages and replaces a removed choice',
    (tester) async {
      final backend = getIt<MockBackend>();
      backend.config = const AppConfig(
        supportedLocales: ['en', 'ru'],
        defaultLocale: 'ru',
      );
      await getIt<ConfigCubit>().refresh();
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Profile').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.text('English'), findsOneWidget);
      expect(find.text('Русский'), findsOneWidget);
      expect(find.text('中文'), findsNothing);

      getIt<LocaleCubit>().setLocale(const Locale('ru'));
      await tester.pumpAndSettle();
      backend.config = const AppConfig(supportedLocales: ['en']);
      await getIt<ConfigCubit>().refresh();
      await tester.pumpAndSettle();
      expect(getIt<LocaleCubit>().state, const Locale('en'));
      expect(find.text('Русский'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'app fades the theme over Settings without moving its scroll position',
    (tester) async {
      final photo = (await tester.runAsync(
        () => createTestImage(width: 8, height: 8),
      ))!;
      AppCrossfadeState.debugCapture = () async => photo;
      addTearDown(() => AppCrossfadeState.debugCapture = null);

      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Profile').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Dark'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.text('Dark'));
      await tester.pumpAndSettle();

      final scrollState = tester.state<ScrollableState>(
        find.byType(Scrollable).first,
      );
      final scrollOffset = scrollState.position.pixels;
      final cardPosition = tester.getTopLeft(find.text('Dark'));

      await tester.tap(find.text('Dark'));
      await tester.pump();
      await tester.pump();
      expect(getIt<ThemeCubit>().state, ThemeMode.dark);
      expect(find.byType(RawImage), findsOneWidget);
      final fade = tester.widget<FadeTransition>(
        find
            .ancestor(
              of: find.byType(RawImage),
              matching: find.byType(FadeTransition),
            )
            .first,
      );
      expect(fade.opacity.value, 1);

      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      expect(find.byType(RawImage), findsNothing);
      // Allow subpixel rounding as the scroll simulation settles.
      expect(scrollState.position.pixels, closeTo(scrollOffset, 0.1));
      expect(
        (tester.getTopLeft(find.text('Dark')) - cardPosition).distance,
        lessThan(0.1),
      );
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('theme still changes smoothly when no screenshot is available', (
    tester,
  ) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    final title = find.text('Hi!');
    final light = Theme.of(tester.element(title)).colorScheme.surface;

    getIt<ThemeCubit>().setThemeMode(ThemeMode.dark);
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final midway = Theme.of(tester.element(title)).colorScheme.surface;
    expect(midway, isNot(light));
    expect(midway, isNot(AppTheme.dark.colorScheme.surface));

    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(title)).colorScheme.surface,
      AppTheme.dark.colorScheme.surface,
    );
    await tester.pumpWidget(const SizedBox());
  });

  test('every supported locale is one of the five app languages', () {
    expect(LocaleCubit.supported.map((l) => l.languageCode).toSet(), {
      'en',
      'zh',
      'ru',
      'es',
      'fr',
    });
  });
}

class _TestPushService implements PushService {
  final _taps = StreamController<PushTap>();

  void emit(PushTap tap) => _taps.add(tap);

  @override
  Stream<PushTap> get taps => _taps.stream;

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> setNewsEnabled({required bool enabled}) async {}

  @override
  Future<void> syncToken() async {}
}
