import '../../../core/storage/secure_storage.dart';
import '../../../core/utils/result.dart';
import '../../../mock/mock_backend.dart';
import '../domain/entities/user.dart';
import '../domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  MockAuthRepository(this._backend, this._secure);

  final MockBackend _backend;
  final SecureStorage _secure;

  static const _mockToken = 'mock-session';

  @override
  Future<Result<User?>> restore() async {
    // The mock server forgets everything on restart, so a stored token has
    // nothing to restore; clear it so the guest state is consistent.
    if (await _secure.readAccessToken() != null && _backend.user == null) {
      await _secure.clearSession();
    }
    return Success(_backend.user);
  }

  @override
  Future<Result<String>> guestId() async {
    final stored = await _secure.readDeviceId();
    if (stored != null) return Success(stored);
    await _secure.saveDeviceId(MockBackend.guestPublicId);
    return const Success(MockBackend.guestPublicId);
  }

  @override
  Future<Result<void>> requestCode({
    required String email,
    String? inviteCode,
  }) => _backend.requestCode(email);

  @override
  Future<Result<SignInResult>> verifyCode({
    required String email,
    required String code,
  }) async {
    final result = await _backend.verifyCode(email, code);
    if (result.isSuccess) {
      await _secure.saveTokens(
        accessToken: _mockToken,
        refreshToken: _mockToken,
      );
    }
    return result;
  }

  @override
  Future<Result<User>> updateName(String name) => _backend.updateName(name);

  @override
  Future<Result<void>> registerPushToken(String token) async =>
      const Success(null);

  @override
  Future<void> signOut() async {
    _backend.signOut();
    await _secure.clearSession();
  }

  @override
  Future<Result<List<DeviceInfo>>> devices() async => Success([
    DeviceInfo(
      id: 'd1',
      model: 'iPhone 15',
      os: 'iOS 18.2',
      isCurrent: true,
      lastSeen: DateTime.now(),
    ),
    DeviceInfo(
      id: 'd2',
      model: 'Pixel 8',
      os: 'Android 15',
      isCurrent: false,
      lastSeen: DateTime.now().subtract(const Duration(days: 23)),
    ),
  ]);

  @override
  Future<Result<void>> requestDeletionCode() async => const Success(null);

  @override
  Future<Result<void>> deleteAccount({required String code}) async {
    final result = await _backend.deleteAccount(code);
    if (result.isSuccess) await _secure.clearSession();
    return result;
  }
}
