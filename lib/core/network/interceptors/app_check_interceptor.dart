import 'package:dio/dio.dart';

import '../../services/app_attestation.dart';
import '../../utils/app_logger.dart';

/// Adds the App Check token to the requests the TZ protects: sign-up and
/// sign-in, referrals, purchases and top-ups. Every other call stays light.
class AppCheckInterceptor extends Interceptor {
  AppCheckInterceptor(this._attestation);

  static const header = 'X-Firebase-AppCheck';

  /// Path fragments of the protected endpoints.
  static const protectedPaths = [
    '/auth/',
    '/referral',
    '/orders',
    '/purchases',
    '/topups',
    '/wallet/top-up',
  ];

  final AppAttestation _attestation;

  static bool isProtected(String path) =>
      protectedPaths.any((fragment) => path.contains(fragment));

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (isProtected(options.path)) {
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
      }
    }
    handler.next(options);
  }
}
