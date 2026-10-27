import '../../../core/error/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_helpers.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/device_session.dart';
import '../../../core/storage/secure_storage.dart';
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
    await device.ensure();
    return await secure.readDeviceId() ?? '';
  });

  @override
  Future<Result<User?>> restore() => apiResult(() async {
    await device.ensure();
    if (await secure.readAccessToken() == null) return null;
    return _user(asMap(await api.get('/v1/me')));
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
    // Housekeeping: a rejected device update must not undo the customer's
    // choice, so the preferences below are saved either way.
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
    // Keep local identity if logout fails: do not present a successful logout
    // while the backend still associates this device with the account.
    final refresh = await secure.readRefreshToken();
    final j = asMap(
      await api.post('/v1/auth/logout', data: {'refreshToken': ?refresh}),
    );
    await secure.saveDeviceToken(j.str('deviceToken'));
    await secure.clearSession();
    _email = null;
  }

  @override
  Future<Result<List<DeviceInfo>>> devices() => apiResult(() async {
    final response = await api.get('/v1/me/devices');
    // Some responses omit isCurrent; registration still gives us the exact
    // device id. Never infer identity from model names (two phones can match).
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
  Future<Result<void>> deleteAccount({
    required String code,
  }) => apiResult(() async {
    if (_email == null) throw const UnauthorizedException();
    // Preserve the existing confirmation-code screen with the supported OTP
    // endpoint, then perform deletion only after successful re-authentication.
    final verification = await verifyCode(email: _email!, code: code);
    if (verification case Error(:final failure)) {
      throw ServerException(
        failure.message ?? 'Verification failed',
        code: failure.code,
        statusCode: failure.statusCode,
      );
    }
    // Detach push delivery while the verified session is still valid;
    // deleting the account revokes its credentials.
    await api.delete('/v1/devices/me/push-token');
    await api.post('/v1/me/delete', data: {'confirm': true});
    await secure.clearSession();
    device.invalidate();
    _email = null;
  });

  /// `an***@gmail.com` — enough to tell two addresses apart in a log, not
  /// enough to read one off a shared screenshot.
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
