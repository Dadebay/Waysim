import 'package:flutter/foundation.dart' show kReleaseMode;

/// Build-time configuration. Pass values with `--dart-define`:
///
/// ```sh
/// flutter run --dart-define=FLAVOR=dev --dart-define=USE_MOCK_API=true
/// flutter build ipa --dart-define=FLAVOR=prod --dart-define=API_BASE_URL=https://api.waysim.co
/// ```
enum Flavor { dev, staging, prod }

abstract final class AppEnvironment {
  static const _flavorName = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'dev',
  );

  static Flavor get flavor => switch (_flavorName) {
    'prod' => Flavor.prod,
    'staging' => Flavor.staging,
    _ => Flavor.dev,
  };

  /// Waysim API root; every path is relative to it and carries the `/v1`
  /// version itself. The app never talks to the eSIM supplier directly.
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.waysim.co',
  );

  /// Serves repositories from in-memory fixtures instead of the network, so
  /// screens can also be exercised without a backend. Explicitly opt in for tests.
  static const _useMockApi = String.fromEnvironment(
    'USE_MOCK_API',
    defaultValue: 'auto',
  );

  /// Never true in a release build: the in-memory backend accepts a fixed
  /// demo code, so a store build must always talk to the real API.
  static bool get useMockApi => !kReleaseMode && _useMockApi == 'true';

  /// Where the router starts. `--dart-define=INITIAL_ROUTE=/gallery` opens the
  /// design gallery straight away (debug builds).
  static const initialRoute = String.fromEnvironment(
    'INITIAL_ROUTE',
    defaultValue: '/home',
  );

  /// `--dart-define=FIREBASE=false` skips Firebase entirely (push, crash
  /// reports, App Check) — for a build without the generated config files.
  static const firebaseEnabled = bool.fromEnvironment(
    'FIREBASE',
    defaultValue: true,
  );

  static bool get isProd => flavor == Flavor.prod;

  /// Console logging (requests, bloc states). Off in every release build
  /// whatever the flavor says: a release built without `FLAVOR=prod` would
  /// otherwise print e-mails and eSIM state to the device log.
  static bool get enableLogging => !isProd && !kReleaseMode;

  /// A release build never talks to the API over plain HTTP: the bearer
  /// token and the OTP code would travel in clear text.
  static void ensureSecureApiBaseUrl() {
    if (kReleaseMode && !apiBaseUrl.startsWith('https://')) {
      throw StateError(
        'API_BASE_URL must be an https:// URL in a release build',
      );
    }
  }
}
