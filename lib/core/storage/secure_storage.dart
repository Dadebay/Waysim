import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'storage_keys.dart';

/// Keychain / Keystore — tokens and the device id, nothing else.
///
/// The access token lives ~15 minutes; the refresh token is rotated on every
/// refresh and the session ends after 180 days without opening the app.
abstract interface class SecureStorage {
  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  /// Identifies this install to the server across sessions; survives sign-out.
  Future<String?> readDeviceId();
  Future<void> saveDeviceId(String id);

  /// Drops the session tokens but keeps the device id.
  Future<void> clearSession();
}

class SecureStorageImpl implements SecureStorage {
  SecureStorageImpl(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readAccessToken() =>
      _storage.read(key: StorageKeys.accessToken);

  @override
  Future<String?> readRefreshToken() =>
      _storage.read(key: StorageKeys.refreshToken);

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: StorageKeys.accessToken, value: accessToken);
    await _storage.write(key: StorageKeys.refreshToken, value: refreshToken);
  }

  @override
  Future<String?> readDeviceId() => _storage.read(key: StorageKeys.deviceId);

  @override
  Future<void> saveDeviceId(String id) =>
      _storage.write(key: StorageKeys.deviceId, value: id);

  @override
  Future<void> clearSession() async {
    await _storage.delete(key: StorageKeys.accessToken);
    await _storage.delete(key: StorageKeys.refreshToken);
  }
}
