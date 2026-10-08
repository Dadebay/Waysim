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
  /// every screen runs before the backend exists. On by default outside
  /// production until the real API lands (docs/06-roadmap.md T7.1).
  static const _useMockApi = String.fromEnvironment(
    'USE_MOCK_API',
    defaultValue: 'auto',
  );

  static bool get useMockApi => switch (_useMockApi) {
    'true' => true,
    'false' => false,
    _ => !isProd,
  };

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
  static bool get enableLogging => !isProd;
}
