import 'package:flutter/foundation.dart' show kReleaseMode;

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

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.waysim.co',
  );

  static const _useMockApi = String.fromEnvironment(
    'USE_MOCK_API',
    defaultValue: 'auto',
  );

  static bool get useMockApi => !kReleaseMode && _useMockApi == 'true';

  static const initialRoute = String.fromEnvironment(
    'INITIAL_ROUTE',
    defaultValue: '/home',
  );

  static const firebaseEnabled = bool.fromEnvironment(
    'FIREBASE',
    defaultValue: true,
  );

  static bool get isProd => flavor == Flavor.prod;

  static bool get enableLogging => !isProd && !kReleaseMode;

  static void ensureSecureApiBaseUrl() {
    if (kReleaseMode && !apiBaseUrl.startsWith('https://')) {
      throw StateError(
        'API_BASE_URL must be an https:// URL in a release build',
      );
    }
  }
}
