import 'dart:convert';

import '../../../core/error/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_helpers.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/device_session.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/result.dart';
import '../domain/entities/user.dart';
import '../domain/repositories/auth_repository.dart';

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this.api, this.secure, this.device);
  final ApiClient api;
  final SecureStorage secure;
  final DeviceSession device;
  String? _email;
  @override
  int resendAfterSeconds = 60;

  LocalStorage get _local => device.local;

  /// `/v1/me`, kept so a signed-in user is not demoted to guest when the app
  /// starts offline or the backend is briefly failing.
  Future<User> _fetchMe() async {
    final json = asMap(await api.get('/v1/me'));
    await _local.setString(StorageKeys.cachedUser, jsonEncode(json));
    return _user(json);
  }

  User? _cachedUser() {
    final raw = _local.getString(StorageKeys.cachedUser);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw);
      return json is Map<String, dynamic> ? _user(json) : null;
    } on Object {
      return null;
    }
  }

  User _user(Map<String, dynamic> j) {
    _email = j.str('email');
    final notifications = j.mapOrNull('notifications');
    return User(
      publicId: j.str('id'),
      email: j.str('email'),
      name: j.strOrNull('name'),
      notifyEsim: notifications?['esim'] as bool?,
      notifyMarketing: notifications?['marketing'] as bool?,
      supportUnread: j.mapOrNull('support')?.intVal('unread') ?? 0,
    );
  }

  @override
  Future<Result<String>> guestId() => apiResult(() async {
    try {
      await device.ensure();
    } on AppException catch (e) {
      if (!e.isTransient) rethrow;
    }
    return await secure.readDeviceId() ?? '';
  });

  @override
  Future<Result<User?>> restore() => apiResult(() async {
    try {
      await device.ensure();
      if (await secure.readAccessToken() == null) {
        await _local.remove(StorageKeys.cachedUser);
        return null;
      }
      return await _fetchMe();
    } on AppException catch (e) {
      if (!e.isTransient || await secure.readAccessToken() == null) rethrow;
      final cached = _cachedUser();
      if (cached == null) rethrow;
      AppLogger.w(
        '[AUTH] restore failed (${e.runtimeType}); using saved profile',
      );
      return cached;
    }
  });

  @override
  Future<Result<void>> requestCode({
    required String email,
    String? inviteCode,
  }) => apiResult(() async {
    final started = DateTime.now();
    AppLogger.group(
      '[AUTH] OTP request → sending',
      lines: [
        'email=${_maskEmail(email)} invite=${inviteCode ?? 'none'}',
        'deviceId=${await secure.readDeviceId() == null ? 'missing' : 'present'}',
      ],
    );
    try {
      if (inviteCode != null && inviteCode.isNotEmpty) {
        final validation = asMap(
          await api.get(
            '/v1/referral/codes/${Uri.encodeComponent(inviteCode)}',
          ),
        );
        AppLogger.d(
          '[AUTH] invite $inviteCode valid=${validation.boolVal('valid')}',
        );
        if (!validation.boolVal('valid')) {
          throw const ServerException(
            'Invalid invite code',
            statusCode: 422,
            code: 'invite_code_invalid',
          );
        }
      }
      final j = asMap(
        await api.post(
          '/v1/auth/otp/request',
          data: {
            'email': email,
            'adultConsent': true,
            'inviteCode': ?inviteCode,
          },
        ),
      );
      resendAfterSeconds = j.intVal('resendAfterSeconds', 60);
      AppLogger.group(
        '[AUTH] OTP request ✓ accepted by server — e-mail is now up to the '
        'server/mail provider',
        level: Level.info,
        lines: [
          'email=${_maskEmail(email)} took=${_since(started)}',
          'resendAfterSeconds=$resendAfterSeconds '
              'ttlSeconds=${j.intOrNull('ttlSeconds') ?? 'missing'}',
          'response keys=${j.keys.join(', ')}',
        ],
      );
    } on AppException catch (e) {
      _logFailure('OTP request', email, started, e);
      rethrow;
    }
  });

  @override
  Future<Result<SignInResult>> verifyCode({
    required String email,
    required String code,
  }) => apiResult(() async {
    final started = DateTime.now();
    AppLogger.d('[AUTH] OTP verify → sending for ${_maskEmail(email)}');
    final Map<String, dynamic> j;
    try {
      j = asMap(
        await api.post(
          '/v1/auth/otp/verify',
          data: {'email': email, 'code': code},
        ),
      );
    } on AppException catch (e) {
      _logFailure('OTP verify', email, started, e);
      rethrow;
    }
    AppLogger.group(
      '[AUTH] OTP verify ✓ signed in',
      level: Level.info,
      lines: [
        'email=${_maskEmail(email)} took=${_since(started)}',
        'isNewUser=${j.boolVal('isNewUser')} '
            'userId=${j.mapOrNull('user')?.str('id') ?? 'missing'}',
      ],
    );
    final tokens = asMap(j['tokens']);
    await secure.saveTokens(
      accessToken: tokens.str('accessToken'),
      refreshToken: tokens.str('refreshToken'),
    );
    return SignInResult(
      user: _user(asMap(j['user'])),
      isNewUser: j.boolVal('isNewUser'),
    );
  });

  @override
  Future<Result<User>> updateName(String name) => apiResult(
    () async => _user(asMap(await api.patch('/v1/me', data: {'name': name}))),
  );

  @override
  Future<Result<void>> updatePreferences({
    String? locale,
    bool? esim,
    bool? marketing,
  }) => apiResult(() async {
    try {
      await device.update(api);
    } on Object catch (_) {}
    if (await secure.readAccessToken() != null) {
      await api.patch(
        '/v1/me',
        data: {
          'locale': ?locale,
          if (esim != null || marketing != null)
            'notifications': {'esim': ?esim, 'marketing': ?marketing},
        },
      );
    }
  });

  @override
  Future<Result<void>> registerPushToken(String token) => apiResult(() async {
    await api.put('/v1/devices/me/push-token', data: {'token': token});
  });

  @override
  Future<void> signOut() async {
    final refresh = await secure.readRefreshToken();
    try {
      final j = asMap(
        await api.post('/v1/auth/logout', data: {'refreshToken': ?refresh}),
      );
      await secure.saveDeviceToken(j.str('deviceToken'));
    } on AppException catch (e) {
      // Offline or the server is failing: still sign out on this phone. The
      // server session expires by itself and the device re-registers on the
      // next request.
      AppLogger.w('[AUTH] logout request failed, signing out locally: $e');
      device.invalidate();
    }
    await secure.clearSession();
    await _local.remove(StorageKeys.cachedUser);
    _email = null;
  }

  @override
  Future<Result<List<DeviceInfo>>> devices() => apiResult(() async {
    final response = await api.get('/v1/me/devices');

    final currentId = await secure.readDeviceId();
    return parseList(
      response,
      (j) => DeviceInfo(
        id: j.str('id'),
        model: j.str('model'),
        os: j.str('osVersion'),
        isCurrent: j['current'] is bool
            ? j.boolVal('current')
            : j.boolVal('isCurrent') ||
                  (currentId != null && j.str('id') == currentId),
        lastSeen: j.dateOrNull('lastSeenAt'),
      ),
    );
  });

  @override
  Future<Result<void>> revokeDevice(String id) => apiResult(() async {
    await api.delete('/v1/me/devices/${Uri.encodeComponent(id)}');
  });
  @override
  Future<Result<void>> removePushToken() => apiResult(() async {
    await api.delete('/v1/devices/me/push-token');
  });

  @override
  Future<Result<void>> requestDeletionCode() async {
    if (_email == null) {
      final result = await apiResult(
        () async => _user(asMap(await api.get('/v1/me'))),
      );
      if (result case Error(:final failure)) return Error(failure);
    }
    return requestCode(email: _email!);
  }

  @override
  Future<Result<void>> deleteAccount({required String code}) =>
      apiResult(() async {
        if (_email == null) throw const UnauthorizedException();

        final verification = await verifyCode(email: _email!, code: code);
        if (verification case Error(:final failure)) {
          throw ServerException(
            failure.message ?? 'Verification failed',
            code: failure.code,
            statusCode: failure.statusCode,
          );
        }

        await api.delete('/v1/devices/me/push-token');
        await api.post('/v1/me/delete', data: {'confirm': true});
        await secure.clearSession();
        await _local.remove(StorageKeys.cachedUser);
        device.invalidate();
        _email = null;
      });

  static String _maskEmail(String email) {
    final at = email.indexOf('@');
    if (at < 1) return '***';
    final name = email.substring(0, at);
    return '${name.substring(0, name.length < 2 ? 1 : 2)}***'
        '${email.substring(at)}';
  }

  static String _since(DateTime started) =>
      '${DateTime.now().difference(started).inMilliseconds}ms';

  static void _logFailure(
    String step,
    String email,
    DateTime started,
    AppException e,
  ) => AppLogger.group(
    '[AUTH] $step ✗ ${e.runtimeType}',
    level: Level.error,
    lines: [
      'email=${_maskEmail(email)} took=${_since(started)}',
      'status=${e.statusCode ?? 'none'} code=${e.code ?? 'none'}',
      'message=${e.message}',
      if (e.details != null) 'details=${e.details}',
    ],
  );
}
