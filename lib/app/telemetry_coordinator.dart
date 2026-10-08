import 'dart:async';

import '../core/services/analytics_service.dart';
import '../core/services/crash_reporter.dart';
import '../core/services/push_service.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/notification/presentation/cubit/notification_prefs_cubit.dart';
import 'cubit/locale_cubit.dart';
import 'cubit/theme_cubit.dart';

/// Connects the app's state to the services that report on it:
/// * who is using the app (public id) → analytics and crash reports;
/// * language and theme → user properties, plus an event when they change;
/// * the "News & offers" switch → the push topic;
/// * a fresh sign-in → the push token goes to the backend.
class TelemetryCoordinator {
  TelemetryCoordinator({
    required AuthCubit auth,
    required LocaleCubit locale,
    required ThemeCubit theme,
    required NotificationPrefsCubit notifications,
    required AnalyticsService analytics,
    required CrashReporter crashes,
    required PushService push,
  }) : _auth = auth,
       _locale = locale,
       _theme = theme,
       _notifications = notifications,
       _analytics = analytics,
       _crashes = crashes,
       _push = push;

  final AuthCubit _auth;
  final LocaleCubit _locale;
  final ThemeCubit _theme;
  final NotificationPrefsCubit _notifications;
  final AnalyticsService _analytics;
  final CrashReporter _crashes;
  final PushService _push;

  final _subscriptions = <StreamSubscription<Object?>>[];
  AuthStatus? _lastStatus;

  void start() {
    _applyUser(_auth.state);
    _analytics
      ..setUserProperty('language', _locale.state.languageCode)
      ..setUserProperty('theme', _theme.state.name);
    unawaited(_push.setNewsEnabled(enabled: _notifications.state.news));

    _subscriptions
      ..add(_auth.stream.listen(_applyUser))
      ..add(
        _locale.stream.listen((locale) {
          _analytics
            ..setUserProperty('language', locale.languageCode)
            ..changedSetting('language', locale.languageCode);
        }),
      )
      ..add(
        _theme.stream.listen((mode) {
          _analytics
            ..setUserProperty('theme', mode.name)
            ..changedSetting('theme', mode.name);
        }),
      )
      ..add(
        _notifications.stream.listen((prefs) {
          _analytics
            ..setUserProperty('news_push', prefs.news ? 'on' : 'off')
            ..changedSetting('news_push', prefs.news ? 'on' : 'off');
          unawaited(_push.setNewsEnabled(enabled: prefs.news));
        }),
      );
  }

  void _applyUser(AuthState state) {
    final id = state.publicId;
    _analytics
      ..setUserId(id)
      ..setUserProperty('account', switch (state.status) {
        AuthStatus.signedIn => 'signed_in',
        AuthStatus.guest => 'guest',
        AuthStatus.unknown => null,
      });
    _crashes.setUserId(id);

    // The first moment a customer is signed in: the backend learns which
    // device token reaches them.
    if (state.status == AuthStatus.signedIn && _lastStatus != state.status) {
      unawaited(_push.syncToken());
    }
    _lastStatus = state.status;
  }

  Future<void> dispose() async {
    for (final s in _subscriptions) {
      await s.cancel();
    }
  }
}
