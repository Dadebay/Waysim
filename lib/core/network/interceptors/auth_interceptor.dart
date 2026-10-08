import 'package:dio/dio.dart';

import '../../error/failure.dart';
import '../../storage/secure_storage.dart';
import '../token_refresher.dart';

/// Attaches the bearer token, renews it on a 401 and clears the session when
/// renewing fails.
///
/// A [QueuedInterceptor]: while one request is refreshing the token, errors
/// from other in-flight requests wait their turn instead of firing a second
/// refresh with the already-rotated refresh token.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor(
    this._storage, {
    required TokenRefresher Function() refresher,
    this.onUnauthorized,
    Dio? retryDio,
  }) : _refresher = refresher,
       _retryDio = retryDio ?? Dio();

  static const _retriedKey = 'auth_retried';

  final SecureStorage _storage;

  /// Replays the failed request. Deliberately a bare [Dio]: the retry must not
  /// re-enter this interceptor's error queue, which is still busy with the
  /// request that is waiting on it.
  final Dio _retryDio;

  final TokenRefresher Function() _refresher;

  /// Called after the session is cleared, so the app can show the sign-in.
  final void Function(Failure failure)? onUnauthorized;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.readAccessToken();
    if (token != null && token.isNotEmpty) {
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

    if (status == 403 && code == ApiCodes.userBlocked) {
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

    switch (await _refresher().refresh()) {
      case RefreshOutcome.renewed:
        break;
      case RefreshOutcome.rejected:
        await _storage.clearSession();
        onUnauthorized?.call(const UnauthorizedFailure());
        return handler.next(err);
      case RefreshOutcome.unavailable:
        // Offline mid-refresh is not a reason to sign the customer out.
        return handler.next(err);
    }

    try {
      final token = await _storage.readAccessToken();
      options
        ..headers['Authorization'] = 'Bearer $token'
        ..extra[_retriedKey] = true;
      handler.resolve(await _retryDio.fetch<dynamic>(options));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }
}
