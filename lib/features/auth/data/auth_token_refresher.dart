import 'package:dio/dio.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_environment.dart';
import '../../../core/network/token_refresher.dart';
import '../../../core/storage/secure_storage.dart';

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

      if (await _storage.readRefreshToken() != current) {
        return RefreshOutcome.rejected;
      }
      await _storage.saveTokens(accessToken: access, refreshToken: refresh);
      return RefreshOutcome.renewed;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data;
      if (status == 401 && body is Map && body['code'] == 'session_revoked') {
        return RefreshOutcome.revoked;
      }
      return status != null && status >= 400 && status < 500
          ? RefreshOutcome.rejected
          : RefreshOutcome.unavailable;
    }
  }
}
