import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/core/error/failure.dart';
import 'package:waysim/core/network/interceptors/auth_interceptor.dart';
import 'package:waysim/core/network/token_refresher.dart';
import 'package:waysim/features/auth/data/auth_token_refresher.dart';

import '../helpers/test_dependencies.dart';

class ScriptedAdapter implements HttpClientAdapter {
  ScriptedAdapter(this._respond);

  final ResponseBody Function(RequestOptions options, int callNumber) _respond;
  final seenAuth = <String?>[];
  var calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    seenAuth.add(options.headers['Authorization'] as String?);
    return _respond(options, ++calls);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody json(int status, Map<String, dynamic> body) =>
    ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

class FakeRefresher implements TokenRefresher {
  FakeRefresher(this.outcome, this.storage);

  final RefreshOutcome outcome;
  final MemorySecureStorage storage;
  var calls = 0;

  @override
  Future<RefreshOutcome> refresh() async {
    calls++;
    if (outcome == RefreshOutcome.renewed) {
      await storage.saveTokens(accessToken: 'new', refreshToken: 'new-r');
    }
    return outcome;
  }
}

void main() {
  late MemorySecureStorage storage;
  late List<Failure> unauthorized;

  setUp(() async {
    storage = MemorySecureStorage();
    await storage.saveTokens(accessToken: 'old', refreshToken: 'old-r');
    unauthorized = [];
  });

  Dio dioFor(
    ScriptedAdapter adapter,
    FakeRefresher refresher, {
    ScriptedAdapter? retryAdapter,
  }) {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;
    dio.interceptors.add(
      AuthInterceptor(
        storage,
        refresher: () => refresher,
        onUnauthorized: unauthorized.add,
        retryDio: Dio()..httpClientAdapter = retryAdapter ?? adapter,
      ),
    );
    return dio;
  }

  test('a 401 renews the token once and replays the request', () async {
    final adapter = ScriptedAdapter(
      (_, n) => n == 1 ? json(401, {}) : json(200, {'ok': true}),
    );
    final refresher = FakeRefresher(RefreshOutcome.renewed, storage);

    final response = await dioFor(adapter, refresher).get<dynamic>('/v1/esims');

    expect(response.statusCode, 200);
    expect(refresher.calls, 1);
    expect(adapter.seenAuth, ['Bearer old', 'Bearer new']);
    expect(unauthorized, isEmpty);
  });

  test('concurrent expired requests share the rotated token', () async {
    final adapter = ScriptedAdapter(
      (options, _) => options.headers['Authorization'] == 'Bearer old'
          ? json(401, {'code': 'token_expired'})
          : json(200, {'ok': true}),
    );
    final refresher = FakeRefresher(RefreshOutcome.renewed, storage);
    final dio = dioFor(adapter, refresher);
    final results = await Future.wait([
      dio.get<dynamic>('/one'),
      dio.get<dynamic>('/two'),
    ]);
    expect(results.every((r) => r.statusCode == 200), true);
    expect(refresher.calls, 1);
    expect(unauthorized, isEmpty);
  });

  test('a refused refresh token ends the session', () async {
    final adapter = ScriptedAdapter((_, _) => json(401, {}));
    final refresher = FakeRefresher(RefreshOutcome.rejected, storage);

    await expectLater(
      dioFor(adapter, refresher).get<dynamic>('/v1/esims'),
      throwsA(isA<DioException>()),
    );

    expect(await storage.readAccessToken(), isNull);
    expect(await storage.readRefreshToken(), isNull);
    expect(unauthorized.single, isA<UnauthorizedFailure>());
  });

  test(
    'session_revoked preserves its reason and keeps the guest token',
    () async {
      await storage.saveDeviceToken('guest');
      final adapter = ScriptedAdapter(
        (_, _) => json(401, {'code': 'session_revoked'}),
      );
      final refresher = FakeRefresher(RefreshOutcome.renewed, storage);

      await expectLater(
        dioFor(adapter, refresher).get<dynamic>('/v1/me'),
        throwsA(isA<DioException>()),
      );

      expect(refresher.calls, 0);
      expect(await storage.readAccessToken(), isNull);
      expect(await storage.readRefreshToken(), isNull);
      expect(await storage.readDeviceToken(), 'guest');
      expect((unauthorized.single as ApiFailure).code, 'session_revoked');
    },
  );

  test('being offline during a refresh keeps the session', () async {
    final adapter = ScriptedAdapter((_, _) => json(401, {}));
    final refresher = FakeRefresher(RefreshOutcome.unavailable, storage);

    await expectLater(
      dioFor(adapter, refresher).get<dynamic>('/v1/esims'),
      throwsA(isA<DioException>()),
    );

    expect(await storage.readRefreshToken(), 'old-r');
    expect(unauthorized, isEmpty);
  });

  test('a replay that fails again is not refreshed twice', () async {
    final adapter = ScriptedAdapter((_, _) => json(401, {}));
    final refresher = FakeRefresher(RefreshOutcome.renewed, storage);

    await expectLater(
      dioFor(adapter, refresher).get<dynamic>('/v1/esims'),
      throwsA(isA<DioException>()),
    );

    expect(refresher.calls, 1);
  });

  test('a blocked account ends the session at once', () async {
    final adapter = ScriptedAdapter(
      (_, _) => json(403, {'code': ApiCodes.userBlocked}),
    );
    final refresher = FakeRefresher(RefreshOutcome.renewed, storage);

    await expectLater(
      dioFor(adapter, refresher).get<dynamic>('/v1/esims'),
      throwsA(isA<DioException>()),
    );

    expect(refresher.calls, 0);
    expect(await storage.readAccessToken(), isNull);
    expect((unauthorized.single as ApiFailure).code, ApiCodes.userBlocked);
  });

  group('AuthTokenRefresher', () {
    AuthTokenRefresher refresherFor(ScriptedAdapter adapter) =>
        AuthTokenRefresher(
          storage,
          dio: Dio(BaseOptions(baseUrl: 'https://api.test'))
            ..httpClientAdapter = adapter,
        );

    test('stores both new tokens', () async {
      final adapter = ScriptedAdapter(
        (_, _) => json(200, {
          'data': {'accessToken': 'a2', 'refreshToken': 'r2'},
        }),
      );

      expect(await refresherFor(adapter).refresh(), RefreshOutcome.renewed);
      expect(await storage.readAccessToken(), 'a2');
      expect(await storage.readRefreshToken(), 'r2');
    });

    test('a 401 from the server means the session is over', () async {
      final adapter = ScriptedAdapter((_, _) => json(401, {}));
      expect(await refresherFor(adapter).refresh(), RefreshOutcome.rejected);
    });

    test('a revoked refresh token keeps the signed-out reason', () async {
      final adapter = ScriptedAdapter(
        (_, _) => json(401, {'code': 'session_revoked'}),
      );
      expect(await refresherFor(adapter).refresh(), RefreshOutcome.revoked);
    });

    test('a 500 is "try later", not "signed out"', () async {
      final adapter = ScriptedAdapter((_, _) => json(500, {}));
      expect(await refresherFor(adapter).refresh(), RefreshOutcome.unavailable);
    });

    test('no stored refresh token is a rejection', () async {
      await storage.clearSession();
      final adapter = ScriptedAdapter((_, _) => json(200, {}));
      expect(await refresherFor(adapter).refresh(), RefreshOutcome.rejected);
      expect(adapter.calls, 0);
    });
  });
}
