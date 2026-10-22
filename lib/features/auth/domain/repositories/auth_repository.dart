import '../../../../core/utils/result.dart';
import '../entities/user.dart';

abstract interface class AuthRepository {
  int get resendAfterSeconds;

  /// Restores a stored session; `Success(null)` for a guest.
  Future<Result<User?>> restore();

  /// The public guest id (`A0000`) issued on first launch.
  Future<Result<String>> guestId();

  /// Sends a 6-digit code to [email]. The server answers the same for new and
  /// existing addresses.
  Future<Result<void>> requestCode({required String email, String? inviteCode});

  /// Failures: `otp-invalid`, `otp-expired`, `otp-too-many-attempts`.
  Future<Result<SignInResult>> verifyCode({
    required String email,
    required String code,
  });

  Future<Result<User>> updateName(String name);

  /// Tells the backend which device token reaches this customer's phone, so
  /// personal pushes ("your eSIM is ready") can be sent. A no-op for a guest.
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

  /// Sends the confirmation code needed to delete the account.
  Future<Result<void>> requestDeletionCode();

  Future<Result<void>> deleteAccount({required String code});
}
