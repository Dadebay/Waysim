import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:waysim/core/error/failure.dart';
import 'package:waysim/core/utils/result.dart';
import 'package:waysim/core/services/push_router.dart';
import 'package:waysim/features/notification/presentation/cubit/notification_prefs_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waysim/core/network/api_client.dart';
import 'package:waysim/core/network/device_session.dart';
import 'package:waysim/core/network/interceptors/auth_interceptor.dart';
import 'package:waysim/core/network/api_helpers.dart';
import 'package:waysim/core/services/crash_report.dart';
import 'package:waysim/core/storage/local_storage.dart';
import 'package:waysim/core/storage/storage_keys.dart';
import 'package:waysim/core/utils/formatters/money.dart';
import 'package:waysim/features/auth/data/api_auth_repository.dart';
import 'package:waysim/features/auth/data/auth_token_refresher.dart';
import 'package:waysim/features/catalog/data/api_catalog_repository.dart';
import 'package:waysim/features/catalog/domain/entities/esim_package.dart';
import 'package:waysim/features/config/data/api_config_repository.dart';
import 'package:waysim/features/esim/data/api_esim_repository.dart';
import 'package:waysim/features/esim/domain/entities/esim.dart';
import 'package:waysim/features/legal/data/api_legal_repository.dart';
import 'package:waysim/features/purchase/data/api_purchase_repository.dart';
import 'package:waysim/features/referral/data/api_referral_repository.dart';
import 'package:waysim/features/support/data/api_support_repository.dart';
import 'package:waysim/features/support/presentation/cubit/chat_cubit.dart';
import 'package:waysim/features/wallet/data/api_wallet_repository.dart';
import 'package:waysim/features/wallet/domain/entities/wallet_entities.dart';
import 'package:waysim/features/wallet/presentation/cubit/top_up_cubit.dart';
import 'package:waysim/features/wallet/presentation/cubit/wallet_cubit.dart';

import '../helpers/test_dependencies.dart';

class ContractAdapter implements HttpClientAdapter {
  ContractAdapter(this.respond);
  final FutureOr<Object?> Function(RequestOptions) respond;
  final requests = <RequestOptions>[];
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final value = await respond(options);
    if (value is ResponseBody) return value;
    return reply(value);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody reply(Object? data, [int status = 200]) => ResponseBody.fromString(
  jsonEncode(data),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);
Map<String, dynamic> body(RequestOptions request) => request.data is String
    ? jsonDecode(request.data as String) as Map<String, dynamic>
    : request.data as Map<String, dynamic>;
Dio transport(ContractAdapter adapter) =>
    Dio(BaseOptions(baseUrl: 'https://api.test'))..httpClientAdapter = adapter;
const package = {
  'id': 'pkg-1',
  'slug': 'TR_5_30',
  'name': 'Türkiye 5 GB',
  'dataBytes': 5368709120,
  'unlimited': false,
  'perDay': false,
  'days': 30,
  'priceCents': 599,
  'direction': {'kind': 'country', 'code': 'TR', 'name': 'Türkiye'},
  'topUpAllowed': true,
};
Map<String, dynamic> esim({bool detail = false}) => {
  'id': 'esim-1',
  'title': 'Türkiye · 5 GB · 30 days',
  'status': 'not_installed',
  'usage': {'usedBytes': 0, 'totalBytes': 5368709120},
  'package': {'id': 'pkg-1', 'locationCode': 'TR', 'directionKind': 'country'},
  if (detail)
    'install': {
      'iccid': '890000001',
      'smdpAddress': 'smdp.test',
      'activationCode': 'activation',
      'lpaString': 'LPA:1\$smdp.test\$activation',
      'appleUniversalLink':
          'https://esimsetup.apple.com/esim_qrcode_provisioning?carddata=test',
    },
  if (detail) 'topup': {'allowed': true, 'count': 0, 'max': 9},
};
Map<String, dynamic> payment([String status = 'pending']) => {
  'id': 'payment-1',
  'publicNo': 58012,
  'provider': 'crypto',
  'status': status,
  'amountCents': 2500,
  'creditedCents': status == 'credited' ? 2400 : null,
  'expiresAt': '2027-10-16T12:00:00Z',
  'createdAt': '2026-10-16T11:00:00Z',
  'crypto': {
    'coin': 'USDT',
    'network': 'BEP-20',
    'payCurrency': 'usdtbsc',
    'payAddress': 'public-address',
    'payExtraId': '1234',
    'payAmount': '25.43858644',
    'rateUsd': '0.98275',
    'qrValue': 'qr:public-address',
  },
};

void main() {
  late LocalStorage local;
  late MemorySecureStorage secure;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    local = LocalStorageImpl(await SharedPreferences.getInstance());
    secure = MemorySecureStorage();
  });
  const deviceInfo = DeviceContext(
    platform: 'android',
    osVersion: '16',
    model: 'Test phone',
    appVersion: '1.0.0',
    buildNumber: '1',
    locale: 'en',
    flavor: 'dev',
    timezone: 'Asia/Ashgabat',
    isEmulator: true,
    isRooted: true,
  );

  test('meta supplies the active app languages and support address', () async {
    final adapter = ContractAdapter((o) {
      expect(o.path, '/v1/meta');
      return {
        'supportedLocales': ['ru', 'en', 'it'],
        'defaultLocale': 'ru',
        'supportEmail': 'help@waysim.co',
        'maintenance': false,
      };
    });
    final config = (await ApiConfigRepository(
      ApiClient(transport(adapter)),
    ).load()).dataOrNull!;
    expect(config.supportedLocales, ['ru', 'en']);
    expect(config.defaultLocale, 'ru');
    expect(config.supportEmail, 'help@waysim.co');
  });

  test(
    'server push links map to supported screens and reject external commands',
    () {
      expect(
        PushRouter.routeFor({
          'type': 'broadcast',
          'deepLink': 'waysim://country/TR',
        }),
        '/destination/TR',
      );
      expect(
        PushRouter.routeFor({
          'type': 'broadcast',
          'deepLink': 'waysim://region/eu-42',
        }),
        '/destination/eu-42',
      );
      expect(
        PushRouter.routeFor({'type': 'esim_usage_low', 'esimId': 'esim-1'}),
        '/esim/esim-1',
      );
      expect(PushRouter.routeForLink('waysim://esims/esim-1'), '/esim/esim-1');
      expect(
        PushRouter.routeForLink('waysim://packages/pkg-1'),
        '/package/pkg-1',
      );
      expect(
        PushRouter.routeForLink('waysim://payment/payment-1'),
        '/balance/top-up?paymentId=payment-1',
      );
      expect(PushRouter.routeForLink('https://evil.test/payment/1'), isNull);
      expect(PushRouter.routeForLink('waysim://esims/%2F%2Fevil.test'), isNull);
    },
  );

  test(
    'failed notification preference save rolls back and exposes failure',
    () async {
      HydratedBloc.storage = MemoryStorage();
      final saved = Completer<Result<void>>();
      final cubit = NotificationPrefsCubit(
        save: (esim, marketing) {
          expect(esim, true);
          expect(marketing, false);
          return saved.future;
        },
      );
      addTearDown(cubit.close);
      cubit.setNews(false);
      expect(cubit.state.news, false);
      final rollback = cubit.stream.firstWhere((s) => s.failure != null);
      saved.complete(const Error(NetworkFailure()));
      expect((await rollback).news, true);
    },
  );

  test(
    'parallel first requests register one install and use device bearer/header context',
    () async {
      final registration = ContractAdapter((o) {
        expect(o.path, '/v1/devices');
        expect(body(o)['platform'], 'android');
        expect(body(o)['installId'], matches(RegExp(r'^[0-9a-f-]{36}$')));
        expect(body(o), containsPair('timezone', 'Asia/Ashgabat'));
        expect(body(o), containsPair('isEmulator', true));
        expect(body(o), containsPair('isRooted', true));
        return {
          'device': {'id': 'device-1'},
          'deviceToken': 'guest-token',
          'user': null,
        };
      });
      await secure.saveTokens(accessToken: 'mock-session', refreshToken: 'old');
      final session = DeviceSession(
        ApiClient(transport(registration)),
        secure,
        local,
        deviceInfo,
      );
      final requests = ContractAdapter((o) {
        expect(o.headers['Authorization'], 'Bearer guest-token');
        expect(o.headers['X-Device-Id'], 'device-1');
        expect(o.headers['X-App-Version'], '1.0.0 (1)');
        return {};
      });
      final dio = transport(requests)
        ..interceptors.add(
          AuthInterceptor(
            secure,
            deviceSession: session,
            refresher: () => AuthTokenRefresher(secure),
          ),
        );
      await Future.wait([
        dio.get<dynamic>('/v1/catalog/home'),
        dio.get<dynamic>('/v1/catalog/search'),
      ]);
      expect(registration.requests, hasLength(1));
      final install = local.getString(StorageKeys.installId);
      await DeviceSession(
        ApiClient(transport(registration)),
        secure,
        local,
        deviceInfo,
      ).ensure();
      expect(body(registration.requests.last)['installId'], install);
      expect(await secure.readAccessToken(), isNull);

      final update = ContractAdapter((o) {
        expect(o.path, '/v1/devices/me');
        expect(body(o)['timezone'], 'Asia/Ashgabat');
        return {};
      });
      await session.update(ApiClient(transport(update)));
    },
  );

  test(
    'OTP contract validates invite, sends consent, rotates tokens and logout keeps device identity',
    () async {
      final adapter = ContractAdapter(
        (o) => switch (o.path) {
          '/v1/referral/codes/A001248' => {'valid': true},
          '/v1/auth/otp/request' => {
            'resendAfterSeconds': 90,
            'ttlSeconds': 600,
          },
          '/v1/auth/otp/verify' => {
            'user': {
              'id': 'A001248',
              'email': 'user@example.test',
              'name': 'User',
              'notifications': {'esim': true, 'marketing': false},
              'support': {'unread': 2},
            },
            'isNewUser': false,
            'tokens': {'accessToken': 'access', 'refreshToken': 'refresh'},
          },
          '/v1/auth/logout' => {'deviceToken': 'new-guest'},
          _ => throw StateError('Unexpected ${o.path}'),
        },
      );
      final api = ApiClient(transport(adapter));
      final repository = ApiAuthRepository(
        api,
        secure,
        DeviceSession(api, secure, local, deviceInfo),
      );
      expect(
        (await repository.requestCode(
          email: 'user@example.test',
          inviteCode: 'A001248',
        )).isSuccess,
        true,
      );
      expect(body(adapter.requests[1]), {
        'email': 'user@example.test',
        'adultConsent': true,
        'inviteCode': 'A001248',
      });
      expect(repository.resendAfterSeconds, 90);
      final login = await repository.verifyCode(
        email: 'user@example.test',
        code: '123456',
      );
      expect(login.dataOrNull!.user.notifyMarketing, false);
      expect(login.dataOrNull!.user.supportUnread, 2);
      expect(await secure.readRefreshToken(), 'refresh');
      await repository.signOut();
      expect(body(adapter.requests.last), {'refreshToken': 'refresh'});
      expect(await secure.readAccessToken(), isNull);
      expect(await secure.readDeviceToken(), 'new-guest');
    },
  );

  test('an invalid invite code stops before requesting an OTP', () async {
    final adapter = ContractAdapter((o) {
      expect(o.path, '/v1/referral/codes/INVALID');
      return {'valid': false};
    });
    final api = ApiClient(transport(adapter));
    final repository = ApiAuthRepository(
      api,
      secure,
      DeviceSession(api, secure, local, deviceInfo),
    );

    final result = await repository.requestCode(
      email: 'user@example.test',
      inviteCode: 'INVALID',
    );

    expect(result.failureOrNull, isA<ApiFailure>());
    expect(result.failureOrNull?.code, 'invite_code_invalid');
    expect(adapter.requests, hasLength(1));
  });

  for (final failureAt in [null, 'verification', 'push']) {
    test(
      'account deletion removes push token before deleting ($failureAt)',
      () async {
        var deleting = false;
        final adapter = ContractAdapter((o) {
          switch (o.path) {
            case '/v1/auth/otp/verify':
              if (deleting && failureAt == 'verification') {
                return reply({
                  'code': 'otp_invalid',
                  'message': 'Invalid code',
                }, 400);
              }
              return {
                'user': {'id': 'A001248', 'email': 'user@example.test'},
                'isNewUser': false,
                'tokens': {'accessToken': 'access', 'refreshToken': 'refresh'},
              };
            case '/v1/devices/me/push-token':
              expect(o.method, 'DELETE');
              expect(secure.readAccessToken(), completion('access'));
              return failureAt == 'push'
                  ? reply({'message': 'Unavailable'}, 503)
                  : reply(null, 204);
            case '/v1/me/delete':
              expect(o.method, 'POST');
              expect(body(o), {'confirm': true});
              return reply(null, 204);
            default:
              throw StateError('Unexpected ${o.path}');
          }
        });
        final api = ApiClient(transport(adapter));
        final repository = ApiAuthRepository(
          api,
          secure,
          DeviceSession(api, secure, local, deviceInfo),
        );
        await repository.verifyCode(email: 'user@example.test', code: '123456');
        adapter.requests.clear();
        deleting = true;
        final result = await repository.deleteAccount(code: '123456');
        expect(adapter.requests.map((o) => o.path).toList(), [
          '/v1/auth/otp/verify',
          if (failureAt != 'verification') '/v1/devices/me/push-token',
          if (failureAt == null) '/v1/me/delete',
        ]);
        expect(result.isSuccess, failureAt == null);
        expect(
          await secure.readAccessToken(),
          failureAt == null ? isNull : 'access',
        );
      },
    );
  }

  test(
    'devices use registered identity and revoke the chosen id, not the model',
    () async {
      await secure.saveDeviceId('old-install');
      final adapter = ContractAdapter((o) {
        if (o.method == 'GET') {
          expect(o.path, '/v1/me/devices');
          return [
            {
              'id': 'current',
              'model': 'Samsung SM-A346E',
              'osVersion': 'Android 16',
              'current': true,
            },
            {
              'id': 'old-install',
              'model': 'Samsung SM-A346E',
              'osVersion': 'Android 16',
              'current': false,
            },
            {'id': 'iphone', 'model': 'iPhone11,6', 'osVersion': 'iOS 18.7.10'},
          ];
        }
        expect(o.method, 'DELETE');
        expect(o.path, '/v1/me/devices/old-install');
        return reply(null, 204);
      });
      final api = ApiClient(transport(adapter));
      final repository = ApiAuthRepository(
        api,
        secure,
        DeviceSession(api, secure, local, deviceInfo),
      );
      final devices = (await repository.devices()).dataOrNull!;
      expect(devices, hasLength(3));
      expect(devices.where((d) => d.isCurrent).single.id, 'current');
      expect((await repository.revokeDevice(devices[1].id)).isSuccess, true);
    },
  );

  test(
    'catalog maps home/search, per-day totals and detailed package fields',
    () async {
      final adapter = ContractAdapter(
        (o) => switch (o.path) {
          '/v1/catalog/home' => {
            'banners': [
              {
                'id': 'banner-1',
                'imageUrl': 'https://cdn.test/banner.png',
                'width': 1000,
                'height': 1000,
                'link': 'waysim://country/TR',
              },
            ],
            'local': [
              {'code': 'TR', 'name': 'Türkiye', 'fromCents': 99},
            ],
            'regional': [],
          },
          '/v1/catalog/search' => {
            'countries': [
              {'code': 'TR', 'name': 'Türkiye', 'fromCents': 99},
            ],
            'regions': [],
          },
          '/v1/catalog/locations/TR' => {
            'limited': [package],
            'unlimited': [
              {
                ...package,
                'id': 'daily',
                'unlimited': false,
                'perDay': true,
                'days': null,
                'dataBytes': 524288000,
                'priceCents': 199,
              },
            ],
            'perDay': {'minDays': 2, 'maxDays': 3},
          },
          '/v1/catalog/packages/daily' => {
            ...package,
            'id': 'daily',
            'unlimited': true,
            'perDay': true,
            'priceCents': 199,
            'network': '4G/5G',
            'hotspot': true,
          },
          _ => throw StateError('Unexpected ${o.path}'),
        },
      );
      final repo = ApiCatalogRepository(ApiClient(transport(adapter)), local);
      expect(
        (await repo.destinations()).dataOrNull!.single.nameFor('en'),
        'Türkiye',
      );
      expect(repo.banners!.single.link, 'waysim://country/TR');
      await repo.search('турция');
      expect(adapter.requests.last.queryParameters, {'q': 'турция'});
      final packages = (await repo.packages('TR')).dataOrNull!;
      expect(packages, hasLength(2));
      final daily = packages.singleWhere((p) => p.id == 'daily');
      expect(daily.kind, PackageKind.unlimited);
      expect(daily.price.cents, 398);
      expect(daily.purchaseDays, 2);
      expect(daily.minPurchaseDays, 2);
      expect(daily.maxPurchaseDays, 3);
      final threeDays = daily.withPurchaseDays(3);
      expect(threeDays.price.cents, 597);
      expect(threeDays.selectionKey, isNot(daily.selectionKey));
      final detail = (await repo.detail(threeDays)).dataOrNull!;
      expect(detail.purchaseDays, 3);
      expect(detail.price.cents, 597);
      expect(detail.network, '4G/5G');
    },
  );

  test(
    'location keeps all unlimited and limited API plans as separate cards',
    () async {
      final adapter = ContractAdapter((o) {
        expect(o.path, '/v1/catalog/locations/AL');
        return {
          'location': {'code': 'AL', 'kind': 'country', 'name': 'Albania'},
          'unlimited': [
            for (var i = 0; i < 5; i++)
              {
                ...package,
                'id': 'unlimited-$i',
                'direction': {
                  'kind': 'country',
                  'code': 'AL',
                  'name': 'Albania',
                },
                // The source array determines the group, even when this flag
                // describes a daily allowance rather than unlimited bytes.
                'unlimited': false,
                'perDay': true,
                'days': null,
              },
          ],
          'limited': [
            for (var i = 0; i < 9; i++)
              {
                ...package,
                'id': 'limited-$i',
                'direction': {
                  'kind': 'country',
                  'code': 'AL',
                  'name': 'Albania',
                },
              },
          ],
          'perDay': {'minDays': 1, 'maxDays': 30},
        };
      });
      final repo = ApiCatalogRepository(ApiClient(transport(adapter)), local);
      final plans = (await repo.packages('AL')).dataOrNull!;

      expect(plans, hasLength(14));
      expect(plans.where((p) => p.kind == PackageKind.unlimited), hasLength(5));
      expect(plans.where((p) => p.kind == PackageKind.limited), hasLength(9));
      expect(plans.map((p) => p.id).toSet(), hasLength(14));
      expect(plans.where((p) => p.dailyPrice != null), hasLength(5));
    },
  );

  test(
    'purchase polls to done, gets installation and wallet, retries the same order without another POST',
    () async {
      var polls = 0;
      final adapter = ContractAdapter(
        (o) => switch (o.path) {
          '/v1/orders' => {
            'order': {'id': 'order-1', 'status': 'processing'},
            'pollAfterMs': 1000,
          },
          '/v1/orders/order-1' => {
            'id': 'order-1',
            'status': ++polls < 2 ? 'processing' : 'done',
            'esimId': 'esim-1',
          },
          '/v1/esims/esim-1' => esim(detail: true),
          '/v1/catalog/packages/pkg-1' => package,
          '/v1/wallet' => {'balanceCents': 1851},
          _ => throw StateError('Unexpected ${o.path}'),
        },
      );
      final api = ApiClient(transport(adapter));
      final repo = ApiPurchaseRepository(
        api,
        ApiEsimRepository(api, local),
        delay: (_) async {},
      );
      final result = await repo.buy(
        packageId: 'pkg-1',
        idempotencyKey: 'key-1',
        expectedPrice: const Money(599),
        days: 7,
      );
      expect(result.isSuccess, true);
      expect(result.dataOrNull!.balanceAfter.cents, 1851);
      expect(result.dataOrNull!.esim.lpa, 'LPA:1\$smdp.test\$activation');
      expect(adapter.requests.first.headers['Idempotency-Key'], 'key-1');
      expect(body(adapter.requests.first), {'packageId': 'pkg-1', 'days': 7});
      await repo.buy(
        packageId: 'pkg-1',
        idempotencyKey: 'key-1',
        expectedPrice: const Money(599),
        days: 7,
      );
      expect(adapter.requests.where((o) => o.method == 'POST'), hasLength(1));
    },
  );

  test('refunded order never produces success or a second charge', () async {
    final adapter = ContractAdapter(
      (o) => {
        'order': {
          'id': 'failed',
          'status': 'failed_refunded',
          'failedReason': 'supplier_balance',
        },
      },
    );
    final api = ApiClient(transport(adapter));
    final result =
        await ApiPurchaseRepository(api, ApiEsimRepository(api, local)).buy(
          packageId: 'p',
          idempotencyKey: 'key',
          expectedPrice: const Money(500),
        );
    expect(result.failureOrNull?.code, 'order_failed_refunded');
    expect(adapter.requests, hasLength(1));
  });

  test(
    'crypto options/minimum, exact decimal/memo and credited amount come from server',
    () async {
      final adapter = ContractAdapter(
        (o) => switch (o.path) {
          '/v1/wallet' => {
            'balanceCents': 1000,
            'limits': {'minCents': 500, 'maxCents': 50000},
            'pendingPayment': null,
          },
          '/v1/payments/methods' => [
            {'provider': 'crypto', 'enabled': true},
            {'provider': 'paypal', 'enabled': false},
          ],
          '/v1/payments/crypto/currencies' => {
            'currencies': [
              {
                'code': 'usdtbsc',
                'coin': 'USDT',
                'network': 'BEP-20',
                'minCents': 879,
              },
            ],
          },
          '/v1/payments' => payment(),
          '/v1/payments/payment-1' => payment('credited'),
          _ => throw StateError('Unexpected ${o.path}'),
        },
      );
      final repo = ApiWalletRepository(ApiClient(transport(adapter)));
      final options = (await repo.options()).dataOrNull!;
      expect(options.methods, [TopUpMethod.crypto]);
      expect(options.currencies.single.minCents, 879);
      final invoice = (await repo.createTopUp(
        amount: const Money(2500),
        method: TopUpMethod.crypto,
        idempotencyKey: 'payment-key',
        payCurrency: 'usdtbsc',
      )).dataOrNull!;
      expect(body(adapter.requests.last), {
        'amountCents': 2500,
        'provider': 'crypto',
        'payCurrency': 'usdtbsc',
      });
      expect(adapter.requests.last.headers['Idempotency-Key'], 'payment-key');
      expect(invoice.crypto!.amountText, '25.43858644');
      expect(invoice.crypto!.memo, '1234');
      expect(invoice.crypto!.qrValue, 'qr:public-address');
      final progress = (await repo.topUpProgress(invoice.id)).dataOrNull!;
      expect(progress.status, TopUpStatus.credited);
      expect(progress.creditedAmount!.cents, 2400);
      for (final status in [
        'review_underpaid',
        'review_overpaid',
        'review_late',
      ]) {
        expect(paymentStatus(status), TopUpStatus.review);
      }
      expect(paymentStatus('disputed'), TopUpStatus.failed);
    },
  );

  test(
    'top-up cubit blocks below currency minimum and resumes a pending invoice without POST',
    () async {
      var pending = false;
      final adapter = ContractAdapter(
        (o) => switch (o.path) {
          '/v1/wallet' => {
            'balanceCents': 0,
            'limits': {'minCents': 500, 'maxCents': 50000},
            'pendingPayment': pending ? {'id': 'payment-1'} : null,
          },
          '/v1/payments/methods' => [
            {'provider': 'crypto', 'enabled': true},
          ],
          '/v1/payments/crypto/currencies' => {
            'currencies': [
              {
                'code': 'usdtbsc',
                'coin': 'USDT',
                'network': 'BEP-20',
                'minCents': 879,
              },
            ],
          },
          '/v1/payments/payment-1' => payment('confirming'),
          _ => throw StateError('Unexpected ${o.path}'),
        },
      );
      final repo = ApiWalletRepository(ApiClient(transport(adapter)));
      final wallet = WalletCubit(repo);
      final cubit = TopUpCubit(
        repository: repo,
        wallet: wallet,
        analytics: RecordingAnalytics(),
      );
      addTearDown(cubit.close);
      addTearDown(wallet.close);
      await cubit.initialize();
      cubit.setAmount(const Money(200));
      await cubit.submit();
      expect(cubit.state.minCents, 879);
      expect(adapter.requests.where((o) => o.method == 'POST'), isEmpty);
      pending = true;
      await cubit.initialize();
      expect(cubit.state.session!.id, 'payment-1');
      expect(cubit.state.progress.status, TopUpStatus.confirming);
      cubit.setVisible(false);
    },
  );

  test(
    'payment details load by public number with received amount and fee',
    () async {
      final adapter = ContractAdapter(
        (request) => switch (request.path) {
          '/v1/payments/58008' => {
            ...payment('review_overpaid'),
            'publicNo': 58008,
            'amountCents': 100,
            'creditedCents': null,
            'creditedAt': null,
            'crypto': {
              ...payment()['crypto'] as Map<String, dynamic>,
              'payAmount': '1.02803431',
              'paidAmount': '4.99',
              'providerStatus': 'finished',
              'feeCents': 3,
              'totalCents': 103,
            },
          },
          _ => throw StateError('Unexpected ${request.path}'),
        },
      );
      final repo = ApiWalletRepository(ApiClient(transport(adapter)));
      final details = (await repo.payment('58008')).dataOrNull!;

      expect(adapter.requests.single.path, '/v1/payments/58008');
      expect(details.publicNo, 58008);
      expect(details.status, TopUpStatus.review);
      expect(details.rawStatus, 'review_overpaid');
      expect(details.amount.cents, 100);
      expect(details.creditedAmount, isNull);
      expect(details.crypto!.amountText, '1.02803431');
      expect(details.crypto!.paidAmountText, '4.99');
      expect(details.crypto!.providerStatus, 'finished');
      expect(details.crypto!.feeCents, 3);
      expect(details.crypto!.totalCents, 103);
      expect(details.toString(), isNot(contains('public-address')));
    },
  );

  test('purchase order details load by UUID', () async {
    final adapter = ContractAdapter(
      (request) => switch (request.path) {
        '/v1/orders/order-uuid' => {
          'id': 'order-uuid',
          'publicNo': 10234,
          'kind': 'purchase',
          'status': 'done',
          'title': 'Türkiye 5 GB',
          'slug': 'TR_5_30',
          'amountCents': 599,
          'esimId': 'esim-uuid',
          'createdAt': '2026-10-22T10:00:00Z',
          'doneAt': '2026-10-22T10:00:30Z',
        },
        _ => throw StateError('Unexpected ${request.path}'),
      },
    );
    final repo = ApiWalletRepository(ApiClient(transport(adapter)));
    final order = (await repo.order('order-uuid')).dataOrNull!;

    expect(adapter.requests.single.path, '/v1/orders/order-uuid');
    expect(order.number, '10234');
    expect(order.outcome, OrderOutcome.completed);
    expect(order.slug, 'TR_5_30');
    expect(order.esimId, 'esim-uuid');
    expect(order.doneAt, DateTime.utc(2026, 10, 22, 10, 0, 30));
  });

  test('purchase history reads order list and maps its status', () async {
    final adapter = ContractAdapter(
      (request) => switch (request.path) {
        '/v1/orders' => {
          'items': [
            {
              'id': 'order-uuid',
              'publicNo': 10234,
              'kind': 'purchase',
              'status': 'processing',
              'title': 'Türkiye 5 GB',
              'amountCents': 599,
              'createdAt': '2026-10-22T10:00:00Z',
            },
          ],
          'nextCursor': null,
        },
        _ => throw StateError('Unexpected ${request.path}'),
      },
    );
    final result = await ApiWalletRepository(
      ApiClient(transport(adapter)),
    ).orders(OrderType.purchase);

    expect(adapter.requests.single.path, '/v1/orders');
    expect(result.dataOrNull, hasLength(1));
    expect(result.dataOrNull!.single.id, 'order-uuid');
    expect(result.dataOrNull!.single.outcome, OrderOutcome.pending);
  });

  test(
    'a late poll cannot reopen an invoice after choosing another amount',
    () async {
      final pendingProgress = Completer<Object?>();
      final adapter = ContractAdapter(
        (o) => switch (o.path) {
          '/v1/wallet' => {
            'balanceCents': 0,
            'limits': {'minCents': 500, 'maxCents': 50000},
            'pendingPayment': null,
          },
          '/v1/payments/methods' => [
            {'provider': 'crypto', 'enabled': true},
          ],
          '/v1/payments/crypto/currencies' => {
            'currencies': [
              {'code': 'usdtbsc', 'coin': 'USDT', 'network': 'BEP-20'},
            ],
          },
          '/v1/payments' => payment(),
          '/v1/payments/payment-1' => pendingProgress.future,
          _ => throw StateError('Unexpected ${o.path}'),
        },
      );
      final repo = ApiWalletRepository(ApiClient(transport(adapter)));
      final wallet = WalletCubit(repo);
      final cubit = TopUpCubit(
        repository: repo,
        wallet: wallet,
        analytics: RecordingAnalytics(),
        initialAmount: const Money(2500),
      );
      addTearDown(cubit.close);
      addTearDown(wallet.close);

      await cubit.initialize();
      await cubit.submit();
      expect(cubit.state.phase, TopUpPhase.paying);
      final checking = cubit.checkNow();
      cubit.chooseAnotherAmount();
      expect(cubit.state.phase, TopUpPhase.form);
      expect(cubit.state.session, isNull);

      pendingProgress.complete(payment('credited'));
      await checking;
      expect(cubit.state.phase, TopUpPhase.form);
      expect(cubit.state.session, isNull);
    },
  );

  test(
    'changing coin or network creates a new payment with its API code',
    () async {
      var created = 0;
      final payments = <String, Map<String, dynamic>>{};
      const currencies = [
        {
          'code': 'usdttrc20',
          'coin': 'USDT',
          'network': 'TRC-20',
          'minCents': 1454,
        },
        {
          'code': 'usdtbsc',
          'coin': 'USDT',
          'network': 'BEP-20',
          'minCents': 896,
        },
        {
          'code': 'usdceth',
          'coin': 'USDC',
          'network': 'ERC-20',
          'minCents': 4000,
        },
        {
          'code': 'usdcbsc',
          'coin': 'USDC',
          'network': 'BEP-20',
          'minCents': 900,
        },
      ];
      final adapter = ContractAdapter((request) {
        switch (request.path) {
          case '/v1/wallet':
            return {
              'balanceCents': 0,
              'limits': {'minCents': 500, 'maxCents': 50000},
              'pendingPayment': null,
            };
          case '/v1/payments/methods':
            return [
              {'provider': 'crypto', 'enabled': true},
            ];
          case '/v1/payments/crypto/currencies':
            return {'currencies': currencies};
          case '/v1/payments' when request.method == 'POST':
            final code = body(request)['payCurrency'];
            final currency = currencies.singleWhere(
              (item) => item['code'] == code,
            );
            final id = 'payment-${++created}';
            final result = {
              ...payment(),
              'id': id,
              'crypto': {
                ...payment()['crypto'] as Map<String, dynamic>,
                'payCurrency': code,
                'coin': currency['coin'],
                'network': currency['network'],
                'payAddress': 'address-$code',
                'qrValue': 'qr:$code',
              },
            };
            payments[id] = result;
            return result;
          default:
            return payments[request.path.split('/').last] ??
                (throw StateError('Unexpected ${request.path}'));
        }
      });
      final repo = ApiWalletRepository(ApiClient(transport(adapter)));
      final wallet = WalletCubit(repo);
      final cubit = TopUpCubit(
        repository: repo,
        wallet: wallet,
        analytics: RecordingAnalytics(),
        initialAmount: const Money(2500),
      );
      addTearDown(cubit.close);
      addTearDown(wallet.close);

      await cubit.initialize();
      expect(cubit.state.options!.methods, [TopUpMethod.crypto]);
      final options = cubit.state.options!.currencies;
      expect(
        options.map((option) => option.code),
        currencies.map((item) => item['code']),
      );
      expect(cubit.state.crypto.code, 'usdtbsc');
      expect(cubit.state.minCents, 896);

      await cubit.submit();
      expect(cubit.state.session!.crypto!.network, 'BEP-20');
      expect(cubit.state.toString(), isNot(contains('address-usdtbsc')));
      expect(cubit.state.toString(), isNot(contains('qr:usdtbsc')));
      final firstId = cubit.state.session!.id;
      await cubit.changeCryptoInvoice(options[0]);
      expect(cubit.state.session!.id, isNot(firstId));
      expect(cubit.state.session!.crypto!.address, 'address-usdttrc20');
      expect(cubit.state.session!.crypto!.qrValue, 'qr:usdttrc20');
      expect(body(adapter.requests.last)['payCurrency'], 'usdttrc20');

      await cubit.changeCryptoInvoice(options[2]);
      expect(created, 2); // This network requires more than the chosen $25.

      await cubit.changeCryptoInvoice(options[3]);
      expect(created, 3);
      expect(cubit.state.session!.crypto!.coin, 'USDC');
      expect(body(adapter.requests.last)['payCurrency'], 'usdcbsc');
      final keys = adapter.requests
          .where((request) => request.method == 'POST')
          .map((request) => request.headers['Idempotency-Key'])
          .toSet();
      expect(keys, hasLength(3));

      final resumed = TopUpCubit(
        repository: repo,
        wallet: wallet,
        analytics: RecordingAnalytics(),
      );
      addTearDown(resumed.close);
      await resumed.initialize(paymentId: cubit.state.session!.id);
      expect(resumed.state.crypto.code, 'usdcbsc');
      expect(resumed.state.amount?.cents, 2500);
    },
  );

  test(
    'cursor APIs aggregate pages; loops fail instead of running forever',
    () async {
      final adapter = ContractAdapter(
        (o) => {
          'items': [
            {'id': o.queryParameters['cursor'] ?? 'first'},
          ],
          'nextCursor': o.queryParameters['cursor'] == null ? 'next' : null,
        },
      );
      expect(
        await apiPages(ApiClient(transport(adapter)), '/list'),
        hasLength(2),
      );
      final repeated = ContractAdapter(
        (o) => {'items': [], 'nextCursor': 'same'},
      );
      expect(
        apiPages(ApiClient(transport(repeated)), '/list'),
        throwsA(isA<Exception>()),
      );
    },
  );

  test(
    'eSIM list gets both tabs and refresh does not fabricate an installation',
    () async {
      final adapter = ContractAdapter(
        (o) => switch (o.path) {
          '/v1/esims' => {
            'items': o.queryParameters['tab'] == 'current' ? [esim()] : [],
            'nextCursor': null,
          },
          '/v1/catalog/packages/pkg-1' => package,
          '/v1/esims/esim-1' ||
          '/v1/esims/esim-1/refresh' => esim(detail: true),
          _ => throw StateError('Unexpected ${o.path}'),
        },
      );
      final repo = ApiEsimRepository(ApiClient(transport(adapter)), local);
      expect((await repo.list()).dataOrNull, hasLength(1));
      expect(
        (await repo.bindToDevice(
          'esim-1',
          deviceName: 'phone',
        )).dataOrNull!.status,
        EsimStatus.notInstalled,
      );
      await repo.refresh('esim-1');
      expect(adapter.requests.last.method, 'POST');
      expect(adapter.requests.last.path, '/v1/esims/esim-1/refresh');
    },
  );

  test(
    'legal and referral use server content including enabled flag and masked invitations',
    () async {
      final adapter = ContractAdapter(
        (o) => switch (o.path) {
          '/v1/legal' => {
            'documents': [
              {'key': 'acceptable_use'},
            ],
          },
          '/v1/legal/acceptable_use' => {
            'key': 'acceptable_use',
            'title': 'Fair use',
            'body': '# Rules\n\n**Read** these rules.',
          },
          '/v1/referral' => {
            'code': 'A001248',
            'link': 'https://waysim.co/r/A001248',
            'enabled': false,
            'bonusCents': 250,
            'rulesText': 'After first purchase',
            'stats': {'invited': 1, 'pending': 1, 'earnedCents': 0},
          },
          '/v1/referral/invitations' => {
            'items': [
              {
                'id': 'i1',
                'email': 'u***@test',
                'status': 'pending',
                'registeredAt': '2026-10-16T00:00:00Z',
              },
            ],
            'nextCursor': null,
          },
          _ => throw StateError('Unexpected ${o.path}'),
        },
      );
      final api = ApiClient(transport(adapter));
      final doc = (await ApiLegalRepository(
        api,
      ).documents('en')).dataOrNull!.single;
      expect(
        adapter.requests
            .where((r) => r.path.startsWith('/v1/legal'))
            .every((r) => r.queryParameters['locale'] == 'en'),
        isTrue,
      );
      expect(doc.id, 'acceptable-use');
      expect(doc.markdown, true);
      expect(doc.body, contains('**Read**'));
      final referral = (await ApiReferralRepository(api).load()).dataOrNull!;
      expect(referral.enabled, false);
      expect(referral.reward.cents, 250);
      expect(referral.invites.single.maskedEmail, 'u***@test');
    },
  );

  test(
    'support reads real messages and keeps replies sent before the user message',
    () async {
      final adapter = ContractAdapter((o) {
        if (o.path == '/v1/support/thread') {
          return {
            'messages': [
              {'id': '01', 'sender': 'user', 'text': 'first'},
            ],
          };
        }
        if (o.path == '/v1/support/read') return {'unread': 0};
        if (o.method == 'POST') {
          return {'id': '03', 'sender': 'user', 'text': 'follow up'};
        }
        expect(o.queryParameters['after'], '01');
        return {
          'items': [
            {'id': '02', 'sender': 'staff', 'text': 'reply'},
            {'id': '03', 'sender': 'user', 'text': 'follow up'},
          ],
          'nextAfter': '03',
        };
      });
      final cubit = ChatCubit(
        ApiSupportRepository(ApiClient(transport(adapter))),
      );
      addTearDown(cubit.close);
      await cubit.load();
      await cubit.send('follow up', language: 'en');
      await cubit.load();
      expect(cubit.state.messages.map((m) => m.id), ['01', '02', '03']);
      expect(cubit.state.messages.map((m) => m.text), [
        'first',
        'reply',
        'follow up',
      ]);
    },
  );

  test('support polls new replies after opening an empty thread', () async {
    final adapter = ContractAdapter((o) {
      if (o.path == '/v1/support/thread') return {'messages': <Object>[]};
      if (o.path == '/v1/support/messages') {
        expect(o.queryParameters['after'], '');
        return {
          'items': [
            {'id': '01', 'sender': 'staff', 'text': 'Hello'},
          ],
          'nextAfter': '01',
        };
      }
      if (o.path == '/v1/support/read') return {'unread': 0};
      throw StateError('Unexpected request: ${o.path}');
    });
    final cubit = ChatCubit(
      ApiSupportRepository(ApiClient(transport(adapter))),
    );
    addTearDown(cubit.close);

    await cubit.load();
    expect(cubit.state.messages, isEmpty);
    await cubit.load();

    expect(cubit.state.messages.single.text, 'Hello');
    expect(adapter.requests.map((request) => request.path), [
      '/v1/support/thread',
      '/v1/support/messages',
      '/v1/support/read',
    ]);
  });
}
