import 'dart:async';

import '../core/services/analytics_service.dart';
import '../core/services/crash_reporter.dart';
import '../core/services/slow_frame_reporter.dart';
import '../core/services/push_service.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/notification/presentation/cubit/notification_prefs_cubit.dart';
import 'cubit/locale_cubit.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/catalog/presentation/cubit/catalog_cubit.dart';
import '../features/config/presentation/cubit/config_cubit.dart';
import 'cubit/theme_cubit.dart';

class TelemetryCoordinator {
  TelemetryCoordinator({
    required this._auth,
    required this._locale,
    required this._theme,
    required this._notifications,
    required this._analytics,
    required this._crashes,
    this.slowFrames,
    required this._push,
    this._preferences,
    this._catalog,
    this._config,
  });

  final AuthCubit _auth;
  final LocaleCubit _locale;
  final ThemeCubit _theme;
  final NotificationPrefsCubit _notifications;
  final AnalyticsService _analytics;
  final CrashReporter _crashes;
  final SlowFrameReporter? slowFrames;
  final PushService _push;
  final AuthRepository? _preferences;
  final CatalogCubit? _catalog;
  final ConfigCubit? _config;
  Future<void> _sync = Future.value();
  NotificationPrefs? _hydratedPrefs;
  void _save({String? locale, bool? esim, bool? marketing}) {
    _sync = _sync.then((_) async {
      await _preferences?.updatePreferences(
        locale: locale,
        esim: esim,
        marketing: marketing,
      );
    });
  }

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
          _save(locale: locale.languageCode);
          unawaited(_catalog?.load());
          unawaited(_config?.refresh());
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
    slowFrames?.setUserId(id);

    if (state.status == AuthStatus.signedIn && _lastStatus != state.status) {
      final user = state.user;
      if (user != null &&
          (user.notifyEsim != null || user.notifyMarketing != null)) {
        final news = _notifications.state.news;
        _hydratedPrefs = NotificationPrefs(
          esim: user.notifyEsim ?? true,
          news: news,
        );
        _notifications.applyServerPreferences(_hydratedPrefs!);
        if (news && user.notifyMarketing == false) _save(marketing: true);
      }
      unawaited(_config?.refresh());
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
