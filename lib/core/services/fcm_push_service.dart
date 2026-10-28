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

class FcmPushService implements PushService {
  FcmPushService(
    this._local, {
    required this.tokenSink,
    this.onSignedOut,
    this.onSupportReply,
  });

  static const topic = 'waysim';

  final LocalNotificationsService _local;
  final Future<void> Function(String token) tokenSink;
  final Future<void> Function()? onSignedOut;
  final Future<void> Function()? onSupportReply;

  final _taps = StreamController<PushTap>();

  String? _token;
  String? _apnsToken;
  bool _newsEnabled = true;

  @override
  Stream<PushTap> get taps => _taps.stream;

  @override
  Future<void> init() async {
    try {
      await _local.init(onTap: _onLocalTap);
      final messaging = FirebaseMessaging.instance;

      if (Platform.isIOS) {
        await messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      if (kDebugMode) await messaging.requestPermission();
      await _logPermission(messaging);

      FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
      FirebaseMessaging.onMessage.listen(_onForeground);
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        unawaited(_onOpened(message));
      });

      messaging.onTokenRefresh.listen((token) {
        _token = token;
        _logTokens(source: 'refreshed');
        unawaited(syncToken());
      });

      final initial = await messaging.getInitialMessage();
      if (initial != null) await _onOpened(initial);

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

  Future<void> _onLocalTap(String? payload) async {
    if (payload == null) return;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map) {
        final data = _strings(decoded);
        await _handleAccountEvent(data);
        _taps.add(PushTap(data));
      }
      // ignore: empty_catches
    } on FormatException {}
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

@pragma('vm:entry-point')
Future<void> _backgroundHandler(RemoteMessage message) async {
  FcmPushService._logMessage('received in the background', message);
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
