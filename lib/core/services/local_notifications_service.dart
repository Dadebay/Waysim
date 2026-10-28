import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationsService {
  LocalNotificationsService();

  static const channelId = 'waysim_default';
  static const _channelName = 'Waysim';
  static const channels = {
    'orders': 'Orders',
    'esim': 'eSIM',
    'support': 'Support',
    'wallet': 'Wallet',
    'marketing': 'News and offers',
    'account': 'Account',
  };
  static const _channelDescription = 'eSIM status, balance, usage and news';

  final _plugin = FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  int _nextId = 0;

  Future<void> init({void Function(String? payload)? onTap}) async {
    if (_initialized) return;

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_stat_waysim'),

        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) =>
          onTap?.call(response.payload),
    );

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

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    for (final entry in channels.entries) {
      await android?.createNotificationChannel(
        AndroidNotificationChannel(
          entry.key,
          entry.value,
          importance: Importance.max,
        ),
      );
    }
    _initialized = true;
  }

  Future<void> show(
    String? title,
    String? body, {
    String? payload,
    String? channel,
  }) => _plugin.show(
    id: _nextId++,
    title: title,
    body: body,
    payload: payload,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        channels.containsKey(channel) ? channel! : channelId,
        channels[channel] ?? _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@drawable/ic_stat_waysim',
      ),
      iOS: const DarwinNotificationDetails(),
    ),
  );
}
