import '../storage/local_storage.dart';
import '../storage/storage_keys.dart';
import 'push_service.dart';
import 'tracking_permission.dart';

class StartupPermissions {
  StartupPermissions(this._push, this._tracking, this._storage);

  final PushService _push;
  final TrackingPermission _tracking;
  final LocalStorage _storage;

  Future<void> run({
    required Future<bool> Function() confirmNotifications,
  }) async {
    if (_push is NoopPushService) return;
    if (_storage.getBool(StorageKeys.startupPermissionsShown) ?? false) return;

    await _storage.setBool(StorageKeys.startupPermissionsShown, value: true);

    if (await confirmNotifications()) {
      await _storage.setBool(StorageKeys.pushPromptShown, value: true);
      await _push.requestPermission();
    }
    await _tracking.request();
  }
}
