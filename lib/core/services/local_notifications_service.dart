import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Draws a push as a native banner while the app is in the **foreground**.
///
/// `FirebaseMessaging.onMessage` fires in that case but — unlike a background
/// or terminated delivery, which the system draws itself — shows nothing on
/// Android. iOS is handled by the presentation options in [FcmPushService].
class LocalNotificationsService {
  LocalNotificationsService();

  /// Must match `default_notification_channel_id` in AndroidManifest.xml, so
  /// a push drawn by the system while the app is closed uses the same
  /// channel (and so the same sound, importance and customer-facing name).
  static const channelId = 'waysim_default';
  static const _channelName = 'Waysim';
  static const _channelDescription = 'eSIM status, balance, usage and news';

  final _plugin = FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Ids only have to be distinct; the counter restarts with the process.
  int _nextId = 0;

  /// [onTap] receives the payload of a banner this class drew, when it is
  /// tapped.
  Future<void> init({void Function(String? payload)? onTap}) async {
    if (_initialized) return;

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_stat_waysim'),
        // All three false: permission is asked once, after the first
        // purchase, by PushPermissionGate — not as a side effect of startup.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) =>
          onTap?.call(response.payload),
    );

    // Android needs the channel to exist before the first banner; its
    // importance decides whether one appears as a heads-up at all.
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            channelId,
            _channelName,
            description: _channelDescription,
            importance: Importance.max,
          ),
        );

    _initialized = true;
  }

  Future<void> show(String? title, String? body, {String? payload}) =>
      _plugin.show(
        id: _nextId++,
        title: title,
        body: body,
        payload: payload,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.max,
            priority: Priority.high,
            icon: '@drawable/ic_stat_waysim',
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
}
