import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waysim/app/view/force_update_gate.dart';
import 'package:waysim/core/network/interceptors/app_check_interceptor.dart';
import 'package:waysim/core/services/app_attestation.dart';
import 'package:waysim/core/services/push_router.dart';
import 'package:waysim/core/services/push_service.dart';
import 'package:waysim/core/storage/local_storage.dart';
import 'package:waysim/core/theme/app_theme.dart';
import 'package:waysim/core/utils/app_version.dart';
import 'package:waysim/features/config/domain/entities/app_config.dart';
import 'package:waysim/features/config/domain/repositories/config_repository.dart';
import 'package:waysim/features/config/presentation/cubit/config_cubit.dart';
import 'package:waysim/core/utils/result.dart';
import 'package:waysim/l10n/app_localizations.dart';

class _CountingPush extends NoopPushService {
  var asked = 0;

  @override
  Future<bool> requestPermission() async {
    asked++;
    return true;
  }
}

class _FakeAttestation implements AppAttestation {
  @override
  Future<String?> token() async => 'tok';
}

class _FixedConfig implements ConfigRepository {
  _FixedConfig(this.config);

  final AppConfig config;

  @override
  Future<Result<AppConfig>> load() async => Success(config);
}

void main() {
  group('PushRouter', () {
    test('opens the eSIM a notification is about', () {
      expect(
        PushRouter.routeFor({'type': 'esim_ready', 'esimId': 'esim_12'}),
        '/esim/esim_12',
      );
      expect(
        PushRouter.routeFor({'type': 'data_low', 'esimId': 'abc-9'}),
        '/esim/abc-9',
      );
    });

    test('a hostile id falls back to the eSIM list', () {
      expect(
        PushRouter.routeFor({'type': 'esim_ready', 'esimId': '../../login'}),
        '/my-esim',
      );
    });

    test('maps the other events and ignores unknown ones', () {
      expect(PushRouter.routeFor({'type': 'order_failed'}), '/orders');
      expect(PushRouter.routeFor({'type': 'balance_topped_up'}), '/profile');
      expect(PushRouter.routeFor({'type': 'referral_bonus'}), '/referral');
      expect(PushRouter.routeFor({'type': 'whatever'}), isNull);
      expect(PushRouter.routeFor({}), isNull);
    });

    test('a broadcast opens only known in-app paths', () {
      expect(
        PushRouter.routeFor({'type': 'broadcast', 'path': '/referral'}),
        '/referral',
      );
      for (final bad in ['https://evil.example', '//evil', '/delete-account']) {
        expect(PushRouter.routeFor({'type': 'broadcast', 'path': bad}), isNull);
      }
    });
  });

  test('notification permission is requested once, after a purchase', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageImpl(await SharedPreferences.getInstance());
    final push = _CountingPush();
    final gate = PushPermissionGate(push, storage);

    expect(push.asked, 0);
    await gate.afterPurchase();
    await gate.afterPurchase();
    expect(push.asked, 1);
  });

  test('versions compare numerically, not as text', () {
    expect(AppVersion.isOlder('1.0.0', '1.0.1'), isTrue);
    expect(AppVersion.isOlder('1.9.0', '1.10.0'), isTrue);
    expect(AppVersion.isOlder('2.0', '1.9.9'), isFalse);
    expect(AppVersion.isOlder('1.4', '1.4.0'), isFalse);
    expect(AppVersion.isOlder('1.4.0+7', '1.4.0'), isFalse);
    expect(AppVersion.isOlder('1.x', '1.0.0'), isFalse);
  });

  group('App Check', () {
    test('only protected endpoints carry the token', () async {
      final interceptor = AppCheckInterceptor(_FakeAttestation());
      for (final entry in {
        '/v1/auth/otp': true,
        '/v1/orders': true,
        '/v1/referral': true,
        '/v1/catalog': false,
        '/v1/config': false,
      }.entries) {
        final options = RequestOptions(path: entry.key);
        final handler = _Capture();
        await interceptor.onRequest(options, handler);
        expect(
          options.headers.containsKey(AppCheckInterceptor.header),
          entry.value,
          reason: entry.key,
        );
      }
    });
  });

  group('ForceUpdateGate', () {
    Widget app(AppConfig config, String version) => BlocProvider(
      create: (_) => ConfigCubit(_FixedConfig(config))..refresh(),
      child: MaterialApp(
        theme: AppTheme.light,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: ForceUpdateGate(
          currentVersion: version,
          child: const Scaffold(body: Text('the app')),
        ),
      ),
    );

    testWidgets('an old version sees the update screen', (tester) async {
      await tester.pumpWidget(
        app(const AppConfig(minSupportedVersion: '2.0.0'), '1.0.0'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Please update the app'), findsOneWidget);
      expect(find.text('the app'), findsNothing);
    });

    testWidgets('a current version, or no limit, sees the app', (tester) async {
      await tester.pumpWidget(
        app(const AppConfig(minSupportedVersion: '1.0.0'), '1.0.0'),
      );
      await tester.pumpAndSettle();
      expect(find.text('the app'), findsOneWidget);

      await tester.pumpWidget(app(const AppConfig(), '0.0.1'));
      await tester.pumpAndSettle();
      expect(find.text('the app'), findsOneWidget);
    });
  });
}

class _Capture extends RequestInterceptorHandler {
  @override
  void next(RequestOptions requestOptions) {}
}
