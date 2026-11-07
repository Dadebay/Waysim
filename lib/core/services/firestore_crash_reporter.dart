import '../utils/app_logger.dart';
import '../utils/scrub.dart';
import 'analytics_service.dart';
import 'crash_report.dart';
import 'crash_reporter.dart';

class FirestoreCrashReporter implements CrashReporter {
  FirestoreCrashReporter({
    required this._store,
    required this._device,
    this.maxPerRun = 20,
    String Function()? currentScreen,
  }) : _currentScreen =
           currentScreen ?? (() => AnalyticsScreenTracker.currentScreen);

  final CrashReportStore _store;
  final DeviceContext _device;
  final String Function() _currentScreen;
  final int maxPerRun;

  final _seen = <String>{};
  String? _publicId;

  @override
  void setUserId(String? publicId) => _publicId = publicId;

  @override
  void recordError(Object error, StackTrace? stack, {bool fatal = false}) {
    if (_seen.length >= maxPerRun) return;
    final report = CrashReport(
      error: _clip(scrubSensitive('$error'), 1500),
      stack: _clip(scrubSensitive(stack?.toString() ?? ''), 4000),
      fatal: fatal,
      screen: _currentScreen(),
      publicId: _publicId,
      device: _device,
    );
    if (!_seen.add(report.signature)) return;

    _store.save(report).catchError((Object e) {
      AppLogger.w('Crash report not saved: $e');
    });
  }

  static String _clip(String text, int max) =>
      text.length <= max ? text : '${text.substring(0, max)}…';
}

class CompositeCrashReporter implements CrashReporter {
  CompositeCrashReporter(this._reporters);

  final List<CrashReporter> _reporters;

  @override
  void recordError(Object error, StackTrace? stack, {bool fatal = false}) {
    for (final r in _reporters) {
      try {
        r.recordError(error, stack, fatal: fatal);
        // ignore: empty_catches
      } on Object {}
    }
  }

  @override
  void setUserId(String? publicId) {
    for (final r in _reporters) {
      try {
        r.setUserId(publicId);
        // ignore: empty_catches
      } on Object {}
    }
  }
}
