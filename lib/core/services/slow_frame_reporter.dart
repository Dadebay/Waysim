import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/scheduler.dart';

import '../utils/app_logger.dart';
import 'analytics_service.dart';
import 'crash_report.dart';

abstract interface class SlowFrameReporter {
  void start();
  void stop();
  void setUserId(String? publicId);
}

class NoopSlowFrameReporter implements SlowFrameReporter {
  @override
  void start() {}

  @override
  void stop() {}

  @override
  void setUserId(String? publicId) {}
}

class SlowFrameReport {
  const SlowFrameReport({
    required this.screen,
    required this.device,
    required this.buildMs,
    required this.rasterMs,
    this.publicId,
  });

  final String screen;
  final DeviceContext device;
  final int buildMs;
  final int rasterMs;
  final String? publicId;

  Map<String, Object?> toMap() => {
    'screen': screen,
    'publicId': publicId,
    'buildMs': buildMs,
    'rasterMs': rasterMs,
    'frameMs': buildMs + rasterMs,
    ...device.toMap(),
  };
}

abstract interface class SlowFrameReportStore {
  Future<void> save(SlowFrameReport report);
}

class FirestoreSlowFrameReportStore implements SlowFrameReportStore {
  FirestoreSlowFrameReportStore([FirebaseFirestore? firestore])
    : _firestore = firestore ?? FirebaseFirestore.instance;

  static const collection = 'performance_reports';
  final FirebaseFirestore _firestore;

  @override
  Future<void> save(SlowFrameReport report) =>
      _firestore.collection(collection).add({
        ...report.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'new',
      });
}

/// Reports severe UI/GPU stalls. One report per screen per minute and at most
/// twenty per app run keeps Firestore writes bounded even on a slow phone.
class FirestoreSlowFrameReporter implements SlowFrameReporter {
  FirestoreSlowFrameReporter({
    required this._store,
    required this._device,
    String Function()? currentScreen,
    DateTime Function()? now,
    this.threshold = const Duration(milliseconds: 150),
    this.minimumInterval = const Duration(minutes: 1),
    this.maxPerRun = 20,
  }) : _currentScreen =
           currentScreen ?? (() => AnalyticsScreenTracker.currentScreen),
       _now = now ?? DateTime.now;

  final SlowFrameReportStore _store;
  final DeviceContext _device;
  final String Function() _currentScreen;
  final DateTime Function() _now;
  final Duration threshold;
  final Duration minimumInterval;
  final int maxPerRun;
  final _lastSaved = <String, DateTime>{};
  int _saved = 0;
  String? _publicId;
  bool _started = false;

  @override
  void start() {
    if (_started) return;
    _started = true;
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
  }

  @override
  void stop() {
    if (!_started) return;
    _started = false;
    SchedulerBinding.instance.removeTimingsCallback(_onTimings);
  }

  @override
  void setUserId(String? publicId) => _publicId = publicId;

  void _onTimings(List<FrameTiming> timings) {
    if (timings.isEmpty) return;
    final slowest = timings.reduce((a, b) => _work(a) >= _work(b) ? a : b);
    recordFrame(slowest.buildDuration, slowest.rasterDuration);
  }

  static int _work(FrameTiming timing) =>
      timing.buildDuration.inMicroseconds +
      timing.rasterDuration.inMicroseconds;

  /// Exposed for deterministic tests; the scheduler callback uses this path.
  void recordFrame(Duration build, Duration raster) {
    if (build + raster < threshold || _saved >= maxPerRun) return;
    final screen = _currentScreen();
    final now = _now();
    final last = _lastSaved[screen];
    if (last != null && now.difference(last) < minimumInterval) return;
    _lastSaved[screen] = now;
    _saved++;

    final report = SlowFrameReport(
      screen: screen,
      device: _device,
      buildMs: (build.inMicroseconds / 1000).round(),
      rasterMs: (raster.inMicroseconds / 1000).round(),
      publicId: _publicId,
    );
    try {
      _store.save(report).catchError((Object error) {
        AppLogger.w('Slow frame report not saved: $error');
      });
    } on Object catch (error) {
      AppLogger.w('Slow frame report not saved: $error');
    }
  }
}
