import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:waysim/app/app.dart';
import 'package:waysim/app/router/app_routes.dart';
import 'package:waysim/app/cubit/locale_cubit.dart';
import 'package:waysim/app/cubit/theme_cubit.dart';
import 'package:waysim/app/telemetry_coordinator.dart';
import 'package:waysim/core/services/analytics_service.dart';
import 'package:waysim/core/services/crash_report.dart';
import 'package:waysim/core/services/crash_reporter.dart';
import 'package:waysim/core/services/firestore_crash_reporter.dart';
import 'package:waysim/core/services/push_service.dart';
import 'package:waysim/core/services/slow_frame_reporter.dart';
import 'package:waysim/core/di/injector.dart';
import 'package:waysim/features/catalog/presentation/cubit/catalog_cubit.dart';
import 'package:waysim/features/home/presentation/view/home_page.dart';
import 'package:waysim/core/storage/local_storage.dart';
import 'package:waysim/core/utils/formatters/money.dart';
import 'package:waysim/features/auth/domain/entities/user.dart';
import 'package:waysim/features/auth/domain/repositories/auth_repository.dart';
import 'package:waysim/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:waysim/features/notification/presentation/cubit/notification_prefs_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_dependencies.dart';

class _MemoryStore implements CrashReportStore {
  final saved = <CrashReport>[];

  @override
  Future<void> save(CrashReport report) async => saved.add(report);
}

class _FailingStore implements CrashReportStore {
  @override
  Future<void> save(CrashReport report) async => throw StateError('offline');
}

class _MemorySlowFrameStore implements SlowFrameReportStore {
  final saved = <SlowFrameReport>[];

  @override
  Future<void> save(SlowFrameReport report) async => saved.add(report);
}

class _FailingSlowFrameStore implements SlowFrameReportStore {
  @override
  Future<void> save(SlowFrameReport report) => throw StateError('offline');
}

class _RecordingCrashes implements CrashReporter {
  final errors = <Object>[];
  String? userId;

  @override
  void recordError(Object error, StackTrace? stack, {bool fatal = false}) =>
      errors.add(error);

  @override
  void setUserId(String? publicId) => userId = publicId;
}

class _RecordingPush extends NoopPushService {
  bool? news;
  var synced = 0;

  @override
  Future<void> setNewsEnabled({required bool enabled}) async => news = enabled;

  @override
  Future<void> syncToken() async => synced++;
}

const _device = DeviceContext(
  platform: 'ios',
  osVersion: 'iOS 18.2',
  model: 'iPhone16,2',
  appVersion: '1.0.0',
  buildNumber: '7',
  locale: 'en-US',
  flavor: 'prod',
);

void main() {
  group('router analytics', () {
    late RecordingAnalytics analytics;

    setUp(() async {
      analytics = RecordingAnalytics();
      await setUpTestDependencies(analytics: analytics);
      await getIt<AuthCubit>().restore();
      await getIt<CatalogCubit>().load();
    });

    testWidgets('reports tab changes and pushed screens once', (tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      expect(analytics.screens, ['home']);

      final router = GoRouter.of(tester.element(find.byType(HomePage)));
      router.go(AppRoute.profile.path);
      await tester.pumpAndSettle();
      expect(analytics.screens.last, 'profile');

      final settings = router.push<void>(AppRoute.settings.path);
      await tester.pumpAndSettle();
      expect(analytics.screens.last, 'settings');

      router.pop();
      await tester.pumpAndSettle();
      await settings;
      expect(analytics.screens, ['home', 'profile', 'settings', 'profile']);
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('slow frames in Firestore', () {
    test('records severe frames with screen and device, then rate limits', () {
      var now = DateTime.utc(2026);
      var screen = 'home';
      final store = _MemorySlowFrameStore();
      final reporter = FirestoreSlowFrameReporter(
        store: store,
        device: _device,
        now: () => now,
        currentScreen: () => screen,
        maxPerRun: 2,
      )..setUserId('A0123');

      reporter.recordFrame(
        const Duration(milliseconds: 50),
        const Duration(milliseconds: 40),
      );
      expect(store.saved, isEmpty);

      reporter.recordFrame(
        const Duration(milliseconds: 160),
        const Duration(milliseconds: 30),
      );
      reporter.recordFrame(
        const Duration(milliseconds: 200),
        const Duration(milliseconds: 30),
      );
      expect(store.saved, hasLength(1));
      expect(store.saved.single.toMap(), containsPair('frameMs', 190));
      expect(store.saved.single.toMap(), containsPair('screen', 'home'));
      expect(
        store.saved.single.toMap(),
        containsPair('deviceModel', 'iPhone16,2'),
      );
      expect(store.saved.single.toMap(), containsPair('publicId', 'A0123'));

      now = now.add(const Duration(minutes: 1));
      screen = 'destination';
      reporter.recordFrame(const Duration(milliseconds: 170), Duration.zero);
      reporter.recordFrame(const Duration(milliseconds: 200), Duration.zero);
      expect(store.saved, hasLength(2));
    });

    test('a report write failure never breaks frame rendering', () {
      final reporter = FirestoreSlowFrameReporter(
        store: _FailingSlowFrameStore(),
        device: _device,
      );
      expect(
        () => reporter.recordFrame(
          const Duration(milliseconds: 200),
          Duration.zero,
        ),
        returnsNormally,
      );
    });
  });

  group('crash reports in Firestore', () {
    test('say who, on which phone, on which screen — and nothing personal', () {
      final store = _MemoryStore();
      final reporter = FirestoreCrashReporter(
        store: store,
        device: _device,
        currentScreen: () => 'destination',
      )..setUserId('A0123');

      reporter.recordError(StateError('boom'), StackTrace.current, fatal: true);

      final report = store.saved.single;
      expect(report.publicId, 'A0123');
      expect(report.screen, 'destination');
      expect(report.fatal, isTrue);
      expect(report.error, contains('boom'));
      expect(report.device.model, 'iPhone16,2');

      final map = report.toMap();
      expect(map['deviceModel'], 'iPhone16,2');
      expect(map['osVersion'], 'iOS 18.2');
      expect(map['appVersion'], '1.0.0');
      for (final key in map.keys) {
        expect(key.toLowerCase(), isNot(contains('email')));
        expect(key.toLowerCase(), isNot(contains('token')));
      }
    });

    test('the same crash is written once, however often it repeats', () {
      final store = _MemoryStore();
      final reporter = FirestoreCrashReporter(store: store, device: _device);
      final stack = StackTrace.fromString('#0 a\n#1 b\n#2 c');

      for (var i = 0; i < 50; i++) {
        reporter.recordError(StateError('same'), stack);
      }

      expect(store.saved, hasLength(1));
    });

    test('a run writes at most maxPerRun different crashes', () {
      final store = _MemoryStore();
      final reporter = FirestoreCrashReporter(
        store: store,
        device: _device,
        maxPerRun: 3,
      );

      for (var i = 0; i < 10; i++) {
        reporter.recordError(StateError('crash $i'), null);
      }

      expect(store.saved, hasLength(3));
    });

    test('long errors and stacks are clipped', () {
      final store = _MemoryStore();
      FirestoreCrashReporter(
        store: store,
        device: _device,
      ).recordError('x' * 10000, StackTrace.fromString('y' * 20000));
      expect(store.saved.single.error.length, lessThan(1600));
      expect(store.saved.single.stack.length, lessThan(4100));
    });

    test('a store that fails does not throw into the app', () async {
      final reporter = FirestoreCrashReporter(
        store: _FailingStore(),
        device: _device,
      );
      expect(
        () => reporter.recordError(StateError('x'), null),
        returnsNormally,
      );
      await Future<void>.delayed(Duration.zero);
    });

    test('the composite keeps going when one reporter throws', () {
      final good = _RecordingCrashes();
      final bad = _ThrowingReporter();
      final composite = CompositeCrashReporter([bad, good]);

      composite.recordError(StateError('x'), null);
      composite.setUserId('A1');

      expect(good.errors, hasLength(1));
      expect(good.userId, 'A1');
    });
  });

  group('analytics', () {
    test('money goes out in dollars, as a number', () {
      final a = RecordingAnalytics()
        ..purchased(
          transactionId: 'esim_1',
          packageId: 'TR_5_30',
          destination: 'TR',
          price: const Money(599),
          addOn: false,
        );
      final event = a.named('purchase').single;
      expect(event['value'], 5.99);
      expect(event['currency'], 'USD');
      expect(event['transaction_id'], 'esim_1');
      expect(event['item_id'], 'TR_5_30');
      expect(event['destination_code'], 'TR');
    });

    test('selected search result carries the destination code', () {
      final a = RecordingAnalytics()
        ..searched('tur', results: 3, destinationCode: 'TR');
      expect(a.named('search').single['destination_code'], 'TR');
      expect(a.named('search').single['destination_type'], 'country');
    });

    test('tracks active time across navigation and backgrounding', () {
      var now = DateTime.utc(2026);
      final a = RecordingAnalytics();
      final tracker = AnalyticsScreenTracker(a, now: () => now);

      tracker.enter('home', routeKey: 1);
      now = now.add(const Duration(seconds: 5));
      tracker.enter('destination', routeKey: 2);
      expect(AnalyticsScreenTracker.currentScreen, 'destination');
      tracker.pause(); // App moved to the background.
      now = now.add(const Duration(minutes: 1));
      tracker.resume();
      now = now.add(const Duration(seconds: 3));
      tracker.enter('home', routeKey: 1);

      expect(a.screens, ['home', 'destination', 'home']);
      expect(a.named('screen_time').map((e) => e['duration_ms']), [5000, 3000]);
      expect(a.named('screen_time').map((e) => e['screen_name']), [
        'home',
        'destination',
      ]);
    });

    test('a route change in the background adds no background time', () {
      var now = DateTime.utc(2026);
      final a = RecordingAnalytics();
      final tracker = AnalyticsScreenTracker(a, now: () => now);
      tracker.enter('home', routeKey: 1);
      tracker.pause();
      now = now.add(const Duration(minutes: 30));
      tracker.enter('settings', routeKey: 2);
      tracker.resume();
      now = now.add(const Duration(seconds: 2));
      tracker.pause();
      expect(a.named('screen_time').single['duration_ms'], 2000);
    });
  });

  group('TelemetryCoordinator', () {
    late RecordingAnalytics analytics;
    late _RecordingCrashes crashes;
    late _RecordingPush push;
    late AuthCubit auth;
    late LocaleCubit locale;
    late ThemeCubit theme;
    late NotificationPrefsCubit prefs;

    setUp(() async {
      await setUpTestDependencies();
      SharedPreferences.setMockInitialValues({});
      analytics = RecordingAnalytics();
      crashes = _RecordingCrashes();
      push = _RecordingPush();
      auth = AuthCubit(getIt<AuthRepository>());
      locale = LocaleCubit(
        LocalStorageImpl(await SharedPreferences.getInstance()),
      );
      theme = ThemeCubit();
      prefs = NotificationPrefsCubit();
      TelemetryCoordinator(
        auth: auth,
        locale: locale,
        theme: theme,
        notifications: prefs,
        analytics: analytics,
        crashes: crashes,
        push: push,
      ).start();
    });

    test('knows the language and theme from the start', () {
      expect(analytics.properties['language'], 'en');
      expect(analytics.properties['theme'], 'light');
      expect(push.news, isTrue);
    });

    test(
      'signing in sets the user everywhere and registers the push token',
      () async {
        auth.signedIn(const User(publicId: 'A0123', email: 'a@b.co'));
        await Future<void>.delayed(Duration.zero);

        expect(analytics.userId, 'A0123');
        expect(crashes.userId, 'A0123');
        expect(analytics.properties['account'], 'signed_in');
        expect(push.synced, 1);
        // The e-mail address never reaches analytics.
        expect(analytics.properties.values, isNot(contains('a@b.co')));
      },
    );

    test(
      'language, theme and the news switch are reported when they change',
      () async {
        locale.setLocale(const Locale('ru'));
        theme.setThemeMode(ThemeMode.dark);
        prefs.setNews(false);
        await Future<void>.delayed(Duration.zero);

        expect(analytics.properties['language'], 'ru');
        expect(analytics.properties['theme'], 'dark');
        expect(push.news, isFalse);
        expect(
          analytics.named('setting_changed').map((e) => e['setting']),
          containsAll(['language', 'theme', 'news_push']),
        );
      },
    );
  });
}

class _ThrowingReporter implements CrashReporter {
  @override
  void recordError(Object error, StackTrace? stack, {bool fatal = false}) =>
      throw StateError('reporter down');

  @override
  void setUserId(String? publicId) => throw StateError('reporter down');
}
