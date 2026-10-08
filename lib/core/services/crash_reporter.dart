import '../utils/app_logger.dart';

/// Where uncaught errors go. [LogCrashReporter] only logs; the Crashlytics
/// (or Sentry) implementation replaces it once the customer's Firebase
/// project exists (docs/06-roadmap.md T6.3). Never pass personal data: the
/// public id (`A0123`) is the only identifier allowed.
abstract interface class CrashReporter {
  void recordError(Object error, StackTrace? stack, {bool fatal = false});

  void setUserId(String? publicId);
}

class LogCrashReporter implements CrashReporter {
  @override
  void recordError(Object error, StackTrace? stack, {bool fatal = false}) =>
      AppLogger.e(fatal ? 'FATAL' : 'ERROR', error, stack);

  @override
  void setUserId(String? publicId) {}
}
