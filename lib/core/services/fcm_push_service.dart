import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';
import '../utils/app_logger.dart';
import 'local_notifications_service.dart';
import 'push_service.dart';

/// Push notifications over Firebase Cloud Messaging (APNs on iOS), open,
/// backgrounded or closed.
///
/// Three deliveries, three paths — the same recipe the other apps use:
/// * **closed or backgrounded**: the system draws the banner itself from the
///   `notification` block of the message; [_backgroundHandler] runs in its own
///   isolate for data-only pushes;
/// * **open, Android**: [_onForeground] draws it with a local notification;
/// * **open, iOS**: Firebase draws it, once
///   `setForegroundNotificationPresentationOptions` is set.
///
/// Two audiences: everyone (and, when the customer allows news) receives the
/// broadcasts sent to the [topic]; personal events — "your eSIM is ready",
/// "100 MB left" — go to the device token the backend stores through
/// [tokenSink].
class FcmPushService implements PushService {
  FcmPushService(
    this._local, {
    required this.tokenSink,
    this.onSignedOut,
    this.onSupportReply,
  });

  /// Broadcasts from the admin panel are sent to this topic.
  static const topic = 'waysim';

  final LocalNotificationsService _local;
  final Future<void> Function(String token) tokenSink;
  final Future<void> Function()? onSignedOut;
  final Future<void> Function()? onSupportReply;

  /// Single-subscription on purpose: a tap that launched the app arrives
  /// before the UI listens, and a broadcast stream would drop it.
  final _taps = StreamController<PushTap>();

  String? _token;
  bool _newsEnabled = true;

  @override
  Stream<PushTap> get taps => _taps.stream;

  /// Never throws: a phone without Play services, or an iOS simulator with no
  /// APNs, must still open the app.
  @override
  Future<void> init() async {
    try {
      await _local.init(onTap: _onLocalTap);
      final messaging = FirebaseMessaging.instance;

      // iOS hides banners while the app is open unless this is set —
      // independent of the notification permission.
      if (Platform.isIOS) {
        await messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      // Debug builds ask straight away so a test push can be received without
      // buying anything first. Release builds follow the product rule: ask
      // once, after the first purchase (PushPermissionGate).
      if (kDebugMode) {
        final settings = await messaging.requestPermission();
        AppLogger.i('Push permission: ${settings.authorizationStatus.name}');
      }

      // Registered before the streams: a terminated-app delivery reaches the
      // isolate below, which has no Firebase of its own.
      FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
      FirebaseMessaging.onMessage.listen(_onForeground);
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        unawaited(_onOpened(message));
      });

      // The notification that launched the app from a cold start; it never
      // reaches `onMessageOpenedApp`.
      final initial = await messaging.getInitialMessage();
      if (initial != null) await _onOpened(initial);

      await _applyTopic(messaging);

      // On iOS the FCM token is derived from the APNs one; asking too early
      // returns null, with no second attempt.
      await _awaitApns();
      _token = await messaging.getToken();
      _logTokens();
      unawaited(syncToken());

      // A rotated token is useless to the backend until it is sent again.
      messaging.onTokenRefresh.listen((token) {
        _token = token;
        unawaited(syncToken());
      });
    } on Object catch (e, s) {
      AppLogger.e('Push setup failed', e, s);
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } on Object catch (e) {
      AppLogger.w('Push permission request failed: $e');
      return false;
    }
  }

  /// "News & offers" in Settings: the topic is the news channel.
  @override
  Future<void> setNewsEnabled({required bool enabled}) async {
    _newsEnabled = enabled;
    try {
      await _applyTopic(FirebaseMessaging.instance);
    } on Object catch (e) {
      AppLogger.w('Topic change failed: $e');
    }
  }

  Future<void> _applyTopic(FirebaseMessaging messaging) async {
    if (_newsEnabled) {
      await messaging.subscribeToTopic(topic);
      AppLogger.i('Subscribed to topic "$topic"');
    } else {
      await messaging.unsubscribeFromTopic(topic);
      AppLogger.i('Unsubscribed from topic "$topic"');
    }
  }

  /// Sends the current token to the backend. Only meaningful with a session,
  /// so sign-in calls it again; the sink decides (and never throws).
  @override
  Future<void> syncToken() async {
    try {
      final token = _token ??= await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) return;
      await tokenSink(token);
    } on Object catch (e) {
      AppLogger.w('Push token sync failed: $e');
    }
  }

  /// Waits for APNs to hand iOS its device token. A no-op on Android and on
  /// the simulator, which never gets one — the loop runs out and the app
  /// carries on without push, which is right there.
  Future<void> _awaitApns() async {
    if (!Platform.isIOS) return;
    final deadline = DateTime.now().add(const Duration(seconds: 6));
    while (DateTime.now().isBefore(deadline)) {
      if (await FirebaseMessaging.instance.getAPNSToken() != null) return;
      await Future<void>.delayed(const Duration(milliseconds: 400));
    }
    AppLogger.w('APNs did not answer in time');
  }

  /// Full tokens, in debug builds only (AppLogger is silent in release), so a
  /// test push can be addressed to this exact phone from the Firebase console.
  void _logTokens() {
    AppLogger.group('FCM token', lines: [_token ?? 'null — no token yet']);
  }

  void _onForeground(RemoteMessage message) {
    unawaited(_handleAccountEvent(_strings(message.data)));
    final notification = message.notification;
    // iOS presents the remote message itself; a local one on top of it would
    // be a duplicate banner. A data-only message has nothing to draw.
    if (notification == null || Platform.isIOS) return;
    unawaited(
      _local.show(
        notification.title,
        notification.body,
        payload: jsonEncode(message.data),
        channel: notification.android?.channelId,
      ),
    );
  }

  Future<void> _onOpened(RemoteMessage message) async {
    AppLogger.i('Notification opened: ${message.data}');
    final data = _strings(message.data);
    await _handleAccountEvent(data);
    _taps.add(PushTap(data));
  }

  /// A banner drawn by [LocalNotificationsService] was tapped.
  Future<void> _onLocalTap(String? payload) async {
    if (payload == null) return;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map) {
        final data = _strings(decoded);
        await _handleAccountEvent(data);
        _taps.add(PushTap(data));
      }
    } on FormatException {
      // Not ours: ignore.
    }
  }

  Future<void> _handleAccountEvent(Map<String, String> data) async {
    try {
      switch (data['type']) {
        case 'signed_out':
          await onSignedOut?.call();
        case 'support_reply':
          await onSupportReply?.call();
      }
    } on Object catch (e, s) {
      AppLogger.e('Push account update failed', e, s);
    }
  }

  static Map<String, String> _strings(Map<dynamic, dynamic> data) => {
    for (final e in data.entries) '${e.key}': '${e.value}',
  };
}

/// Runs in its own isolate with the app backgrounded or killed, so it shares
/// nothing with [FcmPushService] and has to bring Firebase up itself.
@pragma('vm:entry-point')
Future<void> _backgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
