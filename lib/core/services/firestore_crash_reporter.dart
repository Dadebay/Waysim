import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/app_logger.dart';
import 'analytics_service.dart';
import 'crash_report.dart';
import 'crash_reporter.dart';

/// Writes each crash to Firestore (`crash_reports`): the customer's public
/// id, the phone, the app version, the screen and the error — so a report can
/// be opened, understood and fixed without any other tool.
///
/// Guards against flooding: the same crash is written once per run, and a run
/// writes at most [maxPerRun] reports. Firestore queues writes made offline
/// and sends them when the network returns.
class FirestoreCrashReporter implements CrashReporter {
  FirestoreCrashReporter({
    required CrashReportStore store,
    required DeviceContext device,
    this.maxPerRun = 20,
    String Function()? currentScreen,
  }) : _store = store,
       _device = device,
       _currentScreen =
           currentScreen ?? (() => AnalyticsRouteObserver.currentScreen);

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
      error: _clip('$error', 1500),
      stack: _clip(stack?.toString() ?? '', 4000),
      fatal: fatal,
      screen: _currentScreen(),
      publicId: _publicId,
      device: _device,
    );
    if (!_seen.add(report.signature)) return;

    // Fire and forget: reporting a crash must never cause another one.
    _store.save(report).catchError((Object e) {
      AppLogger.w('Crash report not saved: $e');
    });
  }

  static String _clip(String text, int max) =>
      text.length <= max ? text : '${text.substring(0, max)}…';
}

/// The real store.
class FirestoreCrashReportStore implements CrashReportStore {
  FirestoreCrashReportStore([FirebaseFirestore? firestore])
    : _firestore = firestore ?? FirebaseFirestore.instance;

  static const collection = 'crash_reports';

  final FirebaseFirestore _firestore;

  @override
  Future<void> save(CrashReport report) =>
      _firestore.collection(collection).add({
        ...report.toMap(),
        // The server's clock, not the phone's.
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'new',
      });
}

/// Sends every crash to all of [reporters].
class CompositeCrashReporter implements CrashReporter {
  CompositeCrashReporter(this._reporters);

  final List<CrashReporter> _reporters;

  @override
  void recordError(Object error, StackTrace? stack, {bool fatal = false}) {
    for (final r in _reporters) {
      try {
        r.recordError(error, stack, fatal: fatal);
      } on Object {
        // One reporter failing must not stop the others.
      }
    }
  }

  @override
  void setUserId(String? publicId) {
    for (final r in _reporters) {
      try {
        r.setUserId(publicId);
      } on Object {
        // Same rule as recordError.
      }
    }
  }
}
