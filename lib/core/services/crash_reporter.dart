import '../utils/app_logger.dart';

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
