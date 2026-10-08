import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../utils/app_logger.dart';
import 'analytics_service.dart';
import 'app_attestation.dart';
import 'crash_reporter.dart';

/// Crash reports to Firebase Crashlytics. Collection is off in debug builds,
/// so a developer's own crashes do not pollute the dashboard.
class CrashlyticsReporter implements CrashReporter {
  CrashlyticsReporter() {
    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
  }

  @override
  void recordError(Object error, StackTrace? stack, {bool fatal = false}) {
    AppLogger.e(fatal ? 'FATAL' : 'ERROR', error, stack);
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: fatal);
  }

  /// Only the public id (`A0123`) — never an e-mail address.
  @override
  void setUserId(String? publicId) =>
      FirebaseCrashlytics.instance.setUserIdentifier(publicId ?? '');
}

/// App Check: App Attest / DeviceCheck on iOS, Play Integrity on Android. The
/// debug providers are used in debug builds; their token has to be registered
/// once in the Firebase console (App Check → Apps → Manage debug tokens).
class FirebaseAppAttestation implements AppAttestation {
  bool _activated = false;

  Future<void> _activate() async {
    if (_activated) return;
    _activated = true;
    try {
      await FirebaseAppCheck.instance.activate(
        providerAndroid: kDebugMode
            ? const AndroidDebugProvider()
            : const AndroidPlayIntegrityProvider(),
        providerApple: kDebugMode
            ? const AppleDebugProvider()
            : const AppleAppAttestWithDeviceCheckFallbackProvider(),
      );
    } on Object catch (e) {
      AppLogger.w('App Check did not activate: $e');
    }
  }

  @override
  Future<String?> token() async {
    await _activate();
    try {
      return await FirebaseAppCheck.instance.getToken();
    } on Object catch (e) {
      AppLogger.w('App Check token unavailable: $e');
      return null;
    }
  }
}

/// Firebase Analytics. Collection is on in every build, but debug builds
/// mark their events so they can be filtered out of the dashboards
/// (`flutter run` sessions, tests by the team).
class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService() {
    _analytics.setAnalyticsCollectionEnabled(true);
    if (kDebugMode) _analytics.setUserProperty(name: 'build', value: 'debug');
  }

  final _analytics = FirebaseAnalytics.instance;

  @override
  void logEvent(String name, [Map<String, Object> parameters = const {}]) {
    _analytics
        .logEvent(
          name: name,
          parameters: parameters.isEmpty ? null : parameters,
        )
        .catchError((Object e) => AppLogger.w('Analytics event failed: $e'));
  }

  @override
  void logScreen(String name) {
    _analytics
        .logScreenView(screenName: name)
        .catchError((Object e) => AppLogger.w('Analytics screen failed: $e'));
  }

  @override
  void setUserId(String? publicId) => _analytics.setUserId(id: publicId);

  @override
  void setUserProperty(String name, String? value) =>
      _analytics.setUserProperty(name: name, value: value);
}
