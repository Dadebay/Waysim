import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/core/error/failure.dart';
import 'package:waysim/core/network/api_client.dart';
import 'package:waysim/core/network/api_helpers.dart';
import 'package:waysim/core/network/interceptors/upgrade_required_interceptor.dart';
import 'package:waysim/core/network/token_refresher.dart';
import 'package:waysim/core/storage/local_storage.dart';
import 'package:waysim/core/utils/result.dart';
import 'package:waysim/features/auth/data/auth_token_refresher.dart';
import 'package:waysim/features/auth/domain/entities/user.dart';
import 'package:waysim/features/auth/domain/repositories/auth_repository.dart';
import 'package:waysim/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:waysim/features/esim/data/api_esim_repository.dart';
import 'package:waysim/features/wallet/data/api_wallet_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_dependencies.dart';
import 'client_api_test.dart'
    show ContractAdapter, esim, package, reply, transport;

DioException _offline(RequestOptions o) =>
    DioException.connectionError(requestOptions: o, reason: 'offline');

class _Auth implements AuthRepository {
  Result<User?> restored = const Success(null);
  bool signOutThrows = false;

  @override
  Future<Result<String>> guestId() async => const Success('guest-1');

  @override
  Future<Result<User?>> restore() async => restored;

  @override
  Future<void> signOut() async {
    if (signOutThrows) throw StateError('offline');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _anna = User(publicId: 'u1', email: 'anna@example.com');

void main() {
  group('token refresh', () {
    Future<RefreshOutcome> refreshWith(int status) async {
      final storage = MemorySecureStorage();
      await storage.saveTokens(accessToken: 'a', refreshToken: 'r');
      final adapter = ContractAdapter((_) => reply({'code': 'x'}, status));
      return AuthTokenRefresher(storage, dio: transport(adapter)).refresh();
    }

    test('429 and 408 only mean "try later", never a logout', () async {
      expect(await refreshWith(429), RefreshOutcome.unavailable);
      expect(await refreshWith(408), RefreshOutcome.unavailable);
      expect(await refreshWith(500), RefreshOutcome.unavailable);
    });

    test('a refused token is still rejected', () async {
      expect(await refreshWith(401), RefreshOutcome.rejected);
    });
  });

  group('session', () {
    test('starting offline keeps a saved profile as signed in', () async {
      final auth = _Auth()..restored = const Success(_anna);
      final cubit = AuthCubit(auth);
      await cubit.restore();
      expect(cubit.state.isSignedIn, isTrue);
      expect(cubit.state.user, _anna);
    });

    test(
      'an unreachable backend with no profile is retried, not final',
      () async {
        final auth = _Auth()..restored = const Error(NetworkFailure());
        final cubit = AuthCubit(auth);
        await cubit.restore();
        expect(cubit.state.status, AuthStatus.guest);

        auth.restored = const Success(_anna);
        await cubit.revalidate();
        expect(cubit.state.isSignedIn, isTrue);
      },
    );

    test('a refused session ends as guest and is not retried', () async {
      final auth = _Auth()..restored = const Error(UnauthorizedFailure());
      final cubit = AuthCubit(auth);
      await cubit.restore();

      auth.restored = const Success(_anna);
      await cubit.revalidate();
      expect(cubit.state.status, AuthStatus.guest);
    });

    test('sign-out works even when the request fails', () async {
      final auth = _Auth()..restored = const Success(_anna);
      final cubit = AuthCubit(auth);
      await cubit.restore();

      auth.signOutThrows = true;
      await cubit.signOut();
      expect(cubit.state.status, AuthStatus.guest);
    });
  });

  group('API errors', () {
    test('426 asks for an update and keeps the request id', () async {
      final notifier = UpdateRequiredNotifier();
      final adapter = ContractAdapter(
        (_) => ResponseBody.fromString(
          '{"code":"upgrade_required","message":"old"}',
          426,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
            'x-request-id': ['req-42'],
          },
        ),
      );
      final dio = transport(adapter)
        ..interceptors.add(UpgradeRequiredInterceptor(notifier));
      final result = await apiResult(() => ApiClient(dio).get('/v1/me'));

      expect(notifier.value, isTrue);
      final failure = (result as Error).failure;
      expect(failure.statusCode, 426);
      expect(failure.requestId, 'req-42');
    });

    test('a missing balance is an error, not zero', () async {
      final adapter = ContractAdapter((_) => <String, Object?>{});
      final repo = ApiWalletRepository(ApiClient(transport(adapter)));
      expect((await repo.balance()).isSuccess, isFalse);
    });
  });

  group('eSIMs offline', () {
    test('a saved copy opens when the phone has no connection', () async {
      SharedPreferences.setMockInitialValues({});
      final local = LocalStorageImpl(await SharedPreferences.getInstance());
      final secure = MemorySecureStorage();
      var online = true;
      final adapter = ContractAdapter((o) {
        if (!online) throw _offline(o);
        return switch (o.path) {
          '/v1/esims' => {
            'items': o.queryParameters['tab'] == 'current' ? [esim()] : [],
            'nextCursor': null,
          },
          '/v1/catalog/packages/pkg-1' => package,
          '/v1/esims/esim-1' => esim(detail: true),
          _ => throw StateError('Unexpected ${o.path}'),
        };
      });
      final repo = ApiEsimRepository(
        ApiClient(transport(adapter)),
        local,
        secure,
      );

      expect((await repo.list()).dataOrNull, hasLength(1));
      await repo.get('esim-1');

      online = false;
      final list = (await repo.list()).dataOrNull!;
      expect(list.single.id, 'esim-1');
      final detail = (await repo.get('esim-1')).dataOrNull!;
      expect(detail.lpa, 'LPA:1\$smdp.test\$activation');
      expect((await repo.get('unknown')).isSuccess, isFalse);
    });

    test(
      'a purchased eSIM installation code is available offline without opening its detail first',
      () async {
        SharedPreferences.setMockInitialValues({});
        final local = LocalStorageImpl(await SharedPreferences.getInstance());
        final secure = MemorySecureStorage();
        var online = true;
        final adapter = ContractAdapter((o) {
          if (!online) throw _offline(o);
          return switch (o.path) {
            '/v1/esims' => {
              'items': o.queryParameters['tab'] == 'current' ? [esim()] : [],
              'nextCursor': null,
            },
            '/v1/catalog/packages/pkg-1' => package,
            '/v1/esims/esim-1' => esim(detail: true),
            _ => throw StateError('Unexpected ${o.path}'),
          };
        });
        final repo = ApiEsimRepository(
          ApiClient(transport(adapter)),
          local,
          secure,
        );

        expect((await repo.list()).dataOrNull, hasLength(1));
        online = false;
        expect(
          (await repo.get('esim-1')).dataOrNull?.lpa,
          'LPA:1\$smdp.test\$activation',
        );
      },
    );

    test('a list refresh does not discard a saved installation code', () async {
      SharedPreferences.setMockInitialValues({});
      final local = LocalStorageImpl(await SharedPreferences.getInstance());
      final secure = MemorySecureStorage();
      var online = true;
      var detailOnline = true;
      final adapter = ContractAdapter((o) {
        if (!online) throw _offline(o);
        return switch (o.path) {
          '/v1/esims' => {
            'items': o.queryParameters['tab'] == 'current' ? [esim()] : [],
            'nextCursor': null,
          },
          '/v1/catalog/packages/pkg-1' => package,
          '/v1/esims/esim-1' when detailOnline => esim(detail: true),
          '/v1/esims/esim-1' => throw _offline(o),
          _ => throw StateError('Unexpected ${o.path}'),
        };
      });
      final repo = ApiEsimRepository(
        ApiClient(transport(adapter)),
        local,
        secure,
      );

      expect(
        (await repo.get('esim-1')).dataOrNull?.activationCode,
        'activation',
      );
      detailOnline = false;
      expect((await repo.list()).dataOrNull, hasLength(1));
      online = false;
      expect(
        (await repo.get('esim-1')).dataOrNull?.activationCode,
        'activation',
      );
    });

    test('signing out wipes the saved codes', () async {
      final secure = MemorySecureStorage();
      await secure.saveEsimCache('[]');
      await secure.clearSession();
      expect(await secure.readEsimCache(), isNull);
    });
  });
}
