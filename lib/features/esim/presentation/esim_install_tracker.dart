import 'dart:convert';

import '../../../core/di/injector.dart';
import '../../../core/services/local_notifications_service.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/utils/app_logger.dart';
import '../domain/entities/esim.dart';

/// Remembers when the user started installing an eSIM so the detail page can
/// tell that an install is stuck (the Apple installer gives the app no result).
abstract final class EsimInstallTracker {
  static const oneTapStuckAfter = Duration(minutes: 1);
  static const otherStuckAfter = Duration(minutes: 3);

  static String _key(String id) => 'esim_install_started_$id';
  static String _statusKey(String id) => 'esim_install_status_$id';
  static String _methodKey(String id) => 'esim_install_method_$id';
  static String _guideKey(String id) => 'esim_install_guide_shown_$id';

  static Duration _stuckAfter(String id) =>
      getIt<LocalStorage>().getString(_methodKey(id)) == 'one_tap'
      ? oneTapStuckAfter
      : otherStuckAfter;

  static EsimStatus? _statusAtStart(String id) {
    try {
      final name = getIt<LocalStorage>().getString(_statusKey(id));
      for (final status in EsimStatus.values) {
        if (status.name == name) return status;
      }
      // ignore: empty_catches
    } on Object {}
    return null;
  }

  static DateTime? startedAt(String id) {
    try {
      final raw = getIt<LocalStorage>().getString(_key(id));
      return raw == null ? null : DateTime.tryParse(raw);
    } on Object {
      return null;
    }
  }

  static Future<void> start(
    String id, {
    required String method,
    required EsimStatus statusAtStart,
  }) async {
    try {
      await getIt<LocalStorage>().setString(
        _key(id),
        DateTime.now().toIso8601String(),
      );
      await getIt<LocalStorage>().setString(_statusKey(id), statusAtStart.name);
      await getIt<LocalStorage>().setString(_methodKey(id), method);
      AppLogger.i('[ESIM-INSTALL] started id=$id method=$method');
      await _scheduleReminder(id, after: _stuckAfter(id));
    } on Object catch (e) {
      AppLogger.w('[ESIM-INSTALL] could not save start time: $e');
    }
  }

  static Future<void> clear(String id, {required String reason}) async {
    try {
      if (startedAt(id) == null) return;
      await getIt<LocalStorage>().remove(_key(id));
      await getIt<LocalStorage>().remove(_statusKey(id));
      await getIt<LocalStorage>().remove(_methodKey(id));
      await getIt<LocalStorage>().remove(_guideKey(id));
      await _cancelReminder(id);
      AppLogger.i('[ESIM-INSTALL] cleared id=$id reason=$reason');
    } on Object {
      // best effort
    }
  }

  /// Server status only confirms progress if it changed after this attempt.
  /// An eSIM that was already active before opening Apple's installer can
  /// still fail there with an expired/used code.
  static bool completedSinceStart(String id, EsimStatus status) =>
      startedAt(id) != null &&
      _statusAtStart(id) == EsimStatus.notInstalled &&
      (status == EsimStatus.installed || status == EsimStatus.active);

  /// Elapsed install time when it passed the method's threshold and is still
  /// not installed, otherwise null.
  static Duration? stuckFor(Esim esim, DateTime now) {
    // The provider may cancel a profile while Apple's installer still shows
    // "Connecting". Keep troubleshooting reachable for that attempt.
    if (completedSinceStart(esim.id, esim.status) ||
        (esim.status.isArchived && esim.status != EsimStatus.cancelled)) {
      return null;
    }
    final started = startedAt(esim.id);
    if (started == null) return null;
    final elapsed = now.difference(started);
    return elapsed >= _stuckAfter(esim.id) ? elapsed : null;
  }

  static bool guideWasShown(String id) {
    final started = startedAt(id);
    if (started == null) return false;
    try {
      return getIt<LocalStorage>().getString(_guideKey(id)) ==
          started.toIso8601String();
    } on Object {
      return false;
    }
  }

  static Future<void> markGuideShown(String id) async {
    final started = startedAt(id);
    if (started == null) return;
    await getIt<LocalStorage>().setString(
      _guideKey(id),
      started.toIso8601String(),
    );
  }

  static int _notificationId(String id) =>
      700000 + (id.hashCode.abs() % 100000);

  static Future<void> _scheduleReminder(
    String id, {
    required Duration after,
  }) async {
    try {
      final context = _reminderText;
      await getIt<LocalNotificationsService>().schedule(
        id: _notificationId(id),
        after: after,
        title: context.$1,
        body: context.$2,
        payload: jsonEncode({'type': 'esim_install_stuck', 'esimId': id}),
        channel: 'esim',
      );
      AppLogger.i(
        '[ESIM-INSTALL] reminder scheduled id=$id in ${after.inMinutes} min',
      );
    } on Object catch (e) {
      AppLogger.w('[ESIM-INSTALL] reminder not scheduled: $e');
    }
  }

  static Future<void> _cancelReminder(String id) async {
    try {
      await getIt<LocalNotificationsService>().cancel(_notificationId(id));
      AppLogger.i('[ESIM-INSTALL] reminder cancelled id=$id');
    } on Object {
      // best effort
    }
  }

  /// Set from the UI language before an install starts (no BuildContext here).
  static (String, String) _reminderText = (
    'Waysim eSIM',
    'Is the eSIM installed? If it is stuck, open the app for the fix steps.',
  );

  static void setReminderText(String title, String body) =>
      _reminderText = (title, body);
}
