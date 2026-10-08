import 'dart:async';

import 'package:equatable/equatable.dart';

import '../storage/local_storage.dart';
import '../storage/storage_keys.dart';

/// A notification the customer tapped, reduced to what the app routes on.
class PushTap extends Equatable {
  const PushTap(this.data);

  /// The `data` payload of the message (strings only, as FCM delivers it).
  final Map<String, String> data;

  @override
  List<Object?> get props => [data];
}

/// Push notifications (FCM; APNs on iOS). Only the contract lives here: the
/// Firebase implementation arrives with the customer's Firebase project
/// (docs/06-roadmap.md T5.4) and replaces [NoopPushService] in the injector.
abstract interface class PushService {
  /// Registers the device token with our backend once the customer is signed
  /// in, and starts listening.
  Future<void> init();

  /// Shows the system permission dialog. Returns whether it was granted.
  Future<bool> requestPermission();

  /// Fires when a notification is tapped, from any app state.
  Stream<PushTap> get taps;

  /// Sends the device token to the backend (called again after sign-in).
  Future<void> syncToken();

  /// The "News & offers" switch: joins or leaves the broadcast topic.
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

/// Asks for notification permission exactly once, after the customer's first
/// purchase — never at launch, when there is no reason to say yes yet.
class PushPermissionGate {
  PushPermissionGate(this._push, this._storage);

  final PushService _push;
  final LocalStorage _storage;

  Future<void> afterPurchase() async {
    if (_storage.getBool(StorageKeys.pushPromptShown) ?? false) return;
    // Marked before asking: an app killed behind the dialog must not ask again.
    await _storage.setBool(StorageKeys.pushPromptShown, value: true);
    await _push.requestPermission();
  }
}
