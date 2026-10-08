import 'package:shared_preferences/shared_preferences.dart';

/// Plain key/value preferences — settings, flags, small caches.
abstract interface class LocalStorage {
  String? getString(String key);
  Future<void> setString(String key, String value);
  bool? getBool(String key);
  Future<void> setBool(String key, {required bool value});
  List<String>? getStringList(String key);
  Future<void> setStringList(String key, List<String> value);
  Future<void> remove(String key);
}

class LocalStorageImpl implements LocalStorage {
  LocalStorageImpl(this._prefs);

  final SharedPreferences _prefs;

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  @override
  bool? getBool(String key) => _prefs.getBool(key);

  @override
  Future<void> setBool(String key, {required bool value}) =>
      _prefs.setBool(key, value);

  @override
  List<String>? getStringList(String key) => _prefs.getStringList(key);

  @override
  Future<void> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  @override
  Future<void> remove(String key) => _prefs.remove(key);
}
