import 'dart:async';

import 'package:equatable/equatable.dart';

import '../storage/local_storage.dart';
import '../storage/storage_keys.dart';
import 'tracking_permission.dart';

class PushTap extends Equatable {
  const PushTap(this.data);

  final Map<String, String> data;

  @override
  List<Object?> get props => [data];
}

abstract interface class PushService {
  Future<void> init();

  Future<bool> requestPermission();

  Stream<PushTap> get taps;

  Future<void> syncToken();

  Future<void> setNewsEnabled({required bool enabled});
}

class NoopPushService implements PushService {
  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermission() async => false;

  @override
  Stream<PushTap> get taps => const Stream.empty();

  @override
  Future<void> syncToken() async {}

  @override
  Future<void> setNewsEnabled({required bool enabled}) async {}
}

/// Asks for notifications and tracking once, right after the first purchase,
/// when the reason to allow them (eSIM updates) is obvious. Never at launch.
class PushPermissionGate {
  PushPermissionGate(this._push, this._storage, this._tracking);

  final PushService _push;
  final LocalStorage _storage;
  final TrackingPermission _tracking;

  Future<void> afterPurchase() async {
    if (_storage.getBool(StorageKeys.pushPromptShown) ?? false) return;

    await _storage.setBool(StorageKeys.pushPromptShown, value: true);
    await _push.requestPermission();
    await _tracking.request();
  }
}
