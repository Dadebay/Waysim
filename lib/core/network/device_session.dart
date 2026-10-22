import 'package:uuid/uuid.dart';

import '../services/crash_report.dart';
import '../storage/local_storage.dart';
import '../storage/secure_storage.dart';
import '../storage/storage_keys.dart';
import 'api_client.dart';
import 'api_response.dart';

/// Uses a public client so registration never recurses through auth interceptors.
class DeviceSession {
  DeviceSession(this.api, this.secure, this.local, this.context);
  final ApiClient api;
  final SecureStorage secure;
  final LocalStorage local;
  final DeviceContext context;
  Future<Map<String, dynamic>>? _registration;

  String get language => local.getString(StorageKeys.contentLanguage) ?? 'en';
  String get appVersion => '${context.appVersion} (${context.buildNumber})';

  void invalidate() => _registration = null;

  Future<Map<String, dynamic>> ensure() =>
      _registration ??= _register().catchError((Object e) {
        _registration = null;
        throw e;
      });

  Future<Map<String, dynamic>> _register() async {
    var id = local.getString(StorageKeys.installId);
    if (id == null) {
      id = const Uuid().v4();
      await local.setString(StorageKeys.installId, id);
    }
    final json = asMap(
      await api.post(
        '/v1/devices',
        data: {
          'installId': id,
          'platform': context.platform,
          'model': context.model,
          'osVersion': context.osVersion,
          'appVersion': appVersion,
          'locale': language,
          'timezone': context.timezone,
          'isEmulator': context.isEmulator,
          'isRooted': context.isRooted,
        },
      ),
    );
    await secure.saveDeviceId(asMap(json['device']).str('id'));
    await secure.saveDeviceToken(json.str('deviceToken'));
    // Never forward a token left by the in-memory backend to the real API.
    if (json['user'] == null ||
        await secure.readAccessToken() == 'mock-session') {
      await secure.clearSession();
    }
    return json;
  }

  Future<void> update(ApiClient authenticatedApi) async {
    await ensure();
    await authenticatedApi.put(
      '/v1/devices/me',
      data: {
        'locale': language,
        'appVersion': appVersion,
        'osVersion': context.osVersion,
        'model': context.model,
        'timezone': context.timezone,
      },
    );
  }
}
