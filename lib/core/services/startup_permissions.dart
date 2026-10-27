import '../storage/local_storage.dart';
import '../storage/storage_keys.dart';
import 'push_service.dart';
import 'tracking_permission.dart';

/// The two permission screens of a first launch, in order: our own
/// notifications card then the system dialog, then the iOS tracking dialog.
/// Runs once; builds without push (tests, no Firebase config) skip it.
class StartupPermissions {
  StartupPermissions(this._push, this._tracking, this._storage);

  final PushService _push;
  final TrackingPermission _tracking;
  final LocalStorage _storage;

  /// [confirmNotifications] shows the pre-permission card and returns whether
  /// the customer chose "Turn on".
  Future<void> run({
    required Future<bool> Function() confirmNotifications,
  }) async {
    if (_push is NoopPushService) return;
    if (_storage.getBool(StorageKeys.startupPermissionsShown) ?? false) return;
    // Marked first: an app killed behind a dialog must not ask again.
    await _storage.setBool(StorageKeys.startupPermissionsShown, value: true);

    if (await confirmNotifications()) {
      await _storage.setBool(StorageKeys.pushPromptShown, value: true);
      await _push.requestPermission();
    }
    await _tracking.request();
  }
}
