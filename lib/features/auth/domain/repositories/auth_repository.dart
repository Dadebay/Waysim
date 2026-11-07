import '../../../../core/utils/result.dart';
import '../entities/user.dart';

abstract interface class AuthRepository {
  int get resendAfterSeconds;

  Future<Result<User?>> restore();

  Future<Result<String>> guestId();

  Future<Result<void>> requestCode({required String email, String? inviteCode});

  Future<Result<SignInResult>> verifyCode({
    required String email,
    required String code,
  });

  Future<Result<User>> updateName(String name);

  Future<Result<void>> registerPushToken(String token);

  Future<Result<void>> updatePreferences({
    String? locale,
    bool? esim,
    bool? marketing,
  });

  Future<void> signOut();
  Future<Result<void>> removePushToken();
  Future<Result<void>> revokeDevice(String id);

  Future<Result<List<DeviceInfo>>> devices();

  Future<Result<void>> requestDeletionCode();

  Future<Result<void>> deleteAccount({required String code});
}
