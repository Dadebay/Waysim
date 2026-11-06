import 'package:dio/dio.dart';

import '../../error/failure.dart';
import '../../services/analytics_service.dart';
import '../../services/app_attestation.dart';
import '../../utils/app_logger.dart';

/// Attaches the Firebase App Check token to the endpoints the backend checks.
///
/// While the server only counts bad tokens, this also reports every request
/// that went out without one and every `403 app_check_failed`, so the
/// rollout can be watched before the server is switched to enforce.
class AppCheckInterceptor extends Interceptor {
  AppCheckInterceptor(this._attestation, {this._analytics});

  static const header = 'X-Firebase-AppCheck';

  /// `POST` routes the backend checks (docs/api/client-api.md, 2026-11-05).
  static final _protected = <RegExp>[
    RegExp(r'^/v1/devices$'),
    RegExp(r'^/v1/auth/otp/request$'),
    RegExp(r'^/v1/auth/otp/verify$'),
    RegExp(r'^/v1/auth/refresh$'),
    RegExp(r'^/v1/orders$'),
    RegExp(r'^/v1/esims/[^/]+/topups$'),
    RegExp(r'^/v1/payments$'),
  ];

  final AppAttestation _attestation;
  final AnalyticsService? _analytics;

  static bool isProtected(String path, {String method = 'POST'}) =>
      method.toUpperCase() == 'POST' && _protected.any((r) => r.hasMatch(path));

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (isProtected(options.path, method: options.method)) {
      final started = DateTime.now();
      final token = await _attestation.token();
      final ms = DateTime.now().difference(started).inMilliseconds;
      if (token != null) {
        options.headers[header] = token;
        AppLogger.d(
          '[APPCHECK] token attached to ${options.path} '
          '(${token.length} chars, ${ms}ms)',
        );
      } else {
        AppLogger.w(
          '[APPCHECK] no token for ${options.path} (${ms}ms) — '
          'the server may refuse or quietly drop this request',
        );
        _analytics?.appCheckIssue('token_missing', options.path);
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final body = err.response?.data;
    if (err.response?.statusCode == 403 &&
        body is Map &&
        body['code'] == ApiCodes.appCheckFailed) {
      AppLogger.w(
        '[APPCHECK] rejected ${err.requestOptions.path} '
        'requestId=${err.response?.headers.value('x-request-id') ?? '-'}',
      );
      _analytics?.appCheckIssue('rejected', err.requestOptions.path);
    }
    handler.next(err);
  }
}
