import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'storage_keys.dart';

abstract interface class SecureStorage {
  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<String?> readDeviceToken();
  Future<void> saveDeviceToken(String token);

  Future<String?> readDeviceId();
  Future<void> saveDeviceId(String id);

  /// The signed-in user's eSIMs (activation codes included), so a traveller
  /// can still install them offline. Wiped with the session.
  Future<String?> readEsimCache();
  Future<void> saveEsimCache(String json);

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
  Future<String?> readDeviceToken() =>
      _storage.read(key: StorageKeys.deviceToken);

  @override
  Future<void> saveDeviceToken(String token) =>
      _storage.write(key: StorageKeys.deviceToken, value: token);

  @override
  Future<String?> readDeviceId() => _storage.read(key: StorageKeys.deviceId);

  @override
  Future<void> saveDeviceId(String id) =>
      _storage.write(key: StorageKeys.deviceId, value: id);

  @override
  Future<String?> readEsimCache() => _storage.read(key: StorageKeys.esimCache);

  @override
  Future<void> saveEsimCache(String json) =>
      _storage.write(key: StorageKeys.esimCache, value: json);

  @override
  Future<void> clearSession() async {
    await _storage.delete(key: StorageKeys.esimCache);
    await _storage.delete(key: StorageKeys.accessToken);
    await _storage.delete(key: StorageKeys.refreshToken);
  }
}
