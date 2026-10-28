import 'package:dio/dio.dart';

import '../../error/failure.dart';
import '../../storage/secure_storage.dart';
import '../token_refresher.dart';
import '../device_session.dart';

class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor(
    this._storage, {
    required this._refresher,
    this.onUnauthorized,
    this.deviceSession,
    Dio? retryDio,
  }) : _retryDio = retryDio ?? Dio();

  static const _retriedKey = 'auth_retried';

  final SecureStorage _storage;
  final DeviceSession? deviceSession;

  final Dio _retryDio;

  final TokenRefresher Function() _refresher;

  final void Function(Failure failure)? onUnauthorized;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      await deviceSession?.ensure();
    } on Object catch (e) {
      return handler.reject(
        DioException(
          requestOptions: options,
          error: e,
          type: DioExceptionType.connectionError,
        ),
      );
    }
    final token =
        await _storage.readAccessToken() ?? await _storage.readDeviceToken();
    if (deviceSession != null) {
      options.headers['X-App-Version'] = deviceSession!.appVersion;
      final id = await _storage.readDeviceId();
      if (id != null) options.headers['X-Device-Id'] = id;
    }

    final ownHost = options.uri.host == Uri.tryParse(options.baseUrl)?.host;
    if (ownHost && token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    final data = err.response?.data;
    final code = data is Map && data['code'] is String
        ? data['code'] as String
        : null;

    if (status == 403 &&
        (code == ApiCodes.userBlocked || code == 'account_disabled')) {
      await _storage.clearSession();
      onUnauthorized?.call(
        const ApiFailure(code: ApiCodes.userBlocked, statusCode: 403),
      );
      return handler.next(err);
    }

    final options = err.requestOptions;
    final hadToken = options.headers.containsKey('Authorization');
    if (status != 401 || !hadToken || options.extra[_retriedKey] == true) {
      return handler.next(err);
    }

    if (code != null && code != 'token_expired') {
      await _storage.clearSession();
      onUnauthorized?.call(
        code == 'session_revoked'
            ? const ApiFailure(code: 'session_revoked', statusCode: 401)
            : const UnauthorizedFailure(),
      );
      return handler.next(err);
    }
    final current = await _storage.readAccessToken();
    if (current == null) {
      if (deviceSession == null) return handler.next(err);
      try {
        deviceSession!.invalidate();
        await deviceSession!.ensure();
        options.headers['Authorization'] =
            'Bearer ${await _storage.readDeviceToken()}';
        options.extra[_retriedKey] = true;
        return handler.resolve(await _retryDio.fetch<dynamic>(options));
      } on DioException catch (e) {
        return handler.next(e);
      } on Object {
        return handler.next(err);
      }
    }
    final alreadyRenewed =
        options.headers['Authorization'] != 'Bearer $current';
    switch (alreadyRenewed
        ? RefreshOutcome.renewed
        : await _refresher().refresh()) {
      case RefreshOutcome.renewed:
        break;
      case RefreshOutcome.rejected:
        await _storage.clearSession();
        onUnauthorized?.call(const UnauthorizedFailure());
        return handler.next(err);
      case RefreshOutcome.revoked:
        await _storage.clearSession();
        onUnauthorized?.call(
          const ApiFailure(code: 'session_revoked', statusCode: 401),
        );
        return handler.next(err);
      case RefreshOutcome.unavailable:
        return handler.next(err);
    }

    try {
      final token = await _storage.readAccessToken();
      options
        ..headers['Authorization'] = 'Bearer $token'
        ..extra[_retriedKey] = true;
      handler.resolve(await _retryDio.fetch<dynamic>(options));
    } on DioException catch (retryError) {
      if (retryError.response?.statusCode == 401) {
        await _storage.clearSession();
        final body = retryError.response?.data;
        onUnauthorized?.call(
          body is Map && body['code'] == 'session_revoked'
              ? const ApiFailure(code: 'session_revoked', statusCode: 401)
              : const UnauthorizedFailure(),
        );
      }
      handler.next(retryError);
    }
  }
}
