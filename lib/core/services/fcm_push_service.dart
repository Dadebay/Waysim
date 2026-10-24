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
  String? _apnsToken;
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
      if (kDebugMode) await messaging.requestPermission();
      await _logPermission(messaging);

      // Registered before the streams: a terminated-app delivery reaches the
      // isolate below, which has no Firebase of its own.
      FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
      FirebaseMessaging.onMessage.listen(_onForeground);
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        unawaited(_onOpened(message));
      });

      // A rotated token is useless to the backend until it is sent again.
      // Registered before the first request too: on iOS the FCM token can
      // appear only after APNs answered late, and arrives through here.
      messaging.onTokenRefresh.listen((token) {
        _token = token;
        _logTokens(source: 'refreshed');
        unawaited(syncToken());
      });

      // The notification that launched the app from a cold start; it never
      // reaches `onMessageOpenedApp`.
      final initial = await messaging.getInitialMessage();
      if (initial != null) await _onOpened(initial);

      // On iOS the FCM token is derived from the APNs one: asking for the
      // token or subscribing to a topic before APNs answered throws
      // `apns-token-not-set`, so APNs goes first.
      _apnsToken = await _awaitApns();
      _logApns();
      try {
        _token = await messaging.getToken();
      } on Object catch (e) {
        AppLogger.group(
          'FCM token request failed',
          level: Level.error,
          lines: [
            '$e',
            if (Platform.isIOS && _apnsToken == null)
              'No APNs token yet — see the APNs line above.',
          ],
        );
      }
      _logTokens();
      unawaited(syncToken());
      try {
        await _applyTopic(messaging);
      } on Object catch (e) {
        AppLogger.w('Topic subscription failed: $e');
      }
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

  /// Waits for APNs to hand iOS its device token. Returns `null` on Android
  /// and on the simulator, which never gets one, and when APNs stays silent —
  /// the app carries on without push, and a late token arrives through
  /// `onTokenRefresh`.
  Future<String?> _awaitApns() async {
    if (!Platform.isIOS) return null;
    final deadline = DateTime.now().add(const Duration(seconds: 20));
    while (DateTime.now().isBefore(deadline)) {
      final token = await FirebaseMessaging.instance.getAPNSToken();
      if (token != null) return token;
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    return null;
  }

  /// What the phone allows, in colour: green is fine, red says where to go.
  Future<void> _logPermission(FirebaseMessaging messaging) async {
    final settings = await messaging.getNotificationSettings();
    final status = settings.authorizationStatus;
    final allowed =
        status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
    AppLogger.group(
      'Push permission: ${status.name}',
      level: allowed
          ? Level.info
          : (status == AuthorizationStatus.notDetermined
                ? Level.warning
                : Level.error),
      lines: [
        'alert=${settings.alert.name} badge=${settings.badge.name} '
            'sound=${settings.sound.name}',
        if (status == AuthorizationStatus.denied)
          'Denied: iPhone Settings → Waysim → Notifications → Allow.',
        if (status == AuthorizationStatus.notDetermined)
          'Not asked yet (release builds ask after the first purchase).',
      ],
    );
  }

  void _logApns() {
    if (!Platform.isIOS) return;
    final token = _apnsToken;
    if (token != null) {
      AppLogger.group(
        'APNs token received',
        level: Level.info,
        lines: [AnsiColor.paint(token, AnsiColor.cyan)],
      );
      return;
    }
    AppLogger.group(
      'APNs token NOT received (waited 20 s)',
      level: Level.error,
      lines: [
        'Push cannot work until Apple hands the phone a device token. Check:',
        '1. A real device — the simulator never gets one.',
        '2. Notification permission is Allow (line above).',
        '3. Xcode → Runner → Signing & Capabilities has Push Notifications '
            'and a profile that includes aps-environment.',
        '4. Bundle id com.waysim.app has Push enabled in the Apple Developer '
            'portal; the phone has internet.',
      ],
    );
  }

  /// Full tokens, in debug builds only (AppLogger is silent in release), so a
  /// test push can be addressed to this exact phone from the Firebase console.
  void _logTokens({String source = 'received'}) {
    final token = _token;
    AppLogger.group(
      token == null ? 'FCM token NOT available' : 'FCM token $source',
      level: token == null ? Level.error : Level.info,
      lines: [
        token == null
            ? (Platform.isIOS && _apnsToken == null
                  ? 'Waiting for APNs; the token will be logged here when it '
                        'arrives.'
                  : 'Firebase returned no token.')
            : AnsiColor.paint(token, AnsiColor.magenta),
      ],
    );
  }

  /// Every delivery, in colour, so "the push never arrived" and "it arrived
  /// but nothing was drawn" can be told apart from the console.
  static void _logMessage(String where, RemoteMessage message) {
    final n = message.notification;
    AppLogger.group(
      'PUSH $where',
      level: Level.info,
      lines: [
        'id=${message.messageId} from=${message.from}',
        if (n != null)
          AnsiColor.paint(
            'notification: "${n.title}" / "${n.body}"',
            AnsiColor.magenta,
          )
        else
          AnsiColor.paint(
            'data-only (no notification block)',
            AnsiColor.yellow,
          ),
        'data=${message.data}',
      ],
    );
  }

  void _onForeground(RemoteMessage message) {
    _logMessage('received while the app is open', message);
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
    _logMessage('tapped', message);
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
  FcmPushService._logMessage('received in the background', message);
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
