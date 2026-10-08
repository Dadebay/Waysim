import 'package:dio/dio.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_environment.dart';
import '../../../core/network/token_refresher.dart';
import '../../../core/storage/secure_storage.dart';

/// Renews the session: `POST /v1/auth/refresh { refreshToken }` answers with a
/// new access token (~15 min) and a **new** refresh token — each one works
/// once. The session ends only after 180 days without opening the app.
///
/// Uses its own bare [Dio]: the refresh call must not pass through the
/// interceptor that is waiting for it.
///
/// The path and field names follow the TZ and are provisional until the
/// backend publishes its OpenAPI (docs/06-roadmap.md T7.1).
class AuthTokenRefresher implements TokenRefresher {
  AuthTokenRefresher(this._storage, {Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: AppEnvironment.apiBaseUrl,
              connectTimeout: AppConstants.connectTimeout,
              receiveTimeout: AppConstants.receiveTimeout,
              headers: const {'Accept': 'application/json'},
            ),
          );

  final SecureStorage _storage;
  final Dio _dio;

  @override
  Future<RefreshOutcome> refresh() async {
    final current = await _storage.readRefreshToken();
    if (current == null || current.isEmpty) return RefreshOutcome.rejected;

    try {
      final response = await _dio.post<dynamic>(
        '/v1/auth/refresh',
        data: {'refreshToken': current},
      );
      final body = response.data;
      final data = body is Map && body['data'] is Map ? body['data'] : body;
      final access = data is Map ? data['accessToken'] : null;
      final refresh = data is Map ? data['refreshToken'] : null;
      if (access is! String || refresh is! String) {
        return RefreshOutcome.rejected;
      }
      // Both tokens are replaced together; keeping an old refresh token
      // would fail the next refresh.
      await _storage.saveTokens(accessToken: access, refreshToken: refresh);
      return RefreshOutcome.renewed;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      return status != null && status >= 400 && status < 500
          ? RefreshOutcome.rejected
          : RefreshOutcome.unavailable;
    }
  }
}
