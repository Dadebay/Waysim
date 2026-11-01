import 'dart:convert';

import '../../../core/di/injector.dart';
import '../../../core/services/local_notifications_service.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/utils/app_logger.dart';
import '../domain/entities/esim.dart';

/// Remembers when the user started installing an eSIM so the detail page can
/// tell that an install is stuck (the Apple installer gives the app no result).
abstract final class EsimInstallTracker {
  static const stuckAfter = Duration(minutes: 3);

  static String _key(String id) => 'esim_install_started_$id';

  static DateTime? startedAt(String id) {
    try {
      final raw = getIt<LocalStorage>().getString(_key(id));
      return raw == null ? null : DateTime.tryParse(raw);
    } on Object {
      return null;
    }
  }

  static Future<void> start(String id, {required String method}) async {
    try {
      await getIt<LocalStorage>().setString(
        _key(id),
        DateTime.now().toIso8601String(),
      );
      AppLogger.i('[ESIM-INSTALL] started id=$id method=$method');
      await _scheduleReminder(id);
    } on Object catch (e) {
      AppLogger.w('[ESIM-INSTALL] could not save start time: $e');
    }
  }

  static Future<void> clear(String id, {required String reason}) async {
    try {
      if (startedAt(id) == null) return;
      await getIt<LocalStorage>().remove(_key(id));
      await _cancelReminder(id);
      AppLogger.i('[ESIM-INSTALL] cleared id=$id reason=$reason');
    } on Object {
      // best effort
    }
  }

  static bool isDone(EsimStatus status) =>
      status == EsimStatus.installed || status == EsimStatus.active;

  /// Elapsed install time when it passed [stuckAfter] and the eSIM is still
  /// not installed, otherwise null.
  static Duration? stuckFor(Esim esim, DateTime now) {
    if (isDone(esim.status) || esim.status.isArchived) return null;
    final started = startedAt(esim.id);
    if (started == null) return null;
    final elapsed = now.difference(started);
    return elapsed >= stuckAfter ? elapsed : null;
  }

  static int _notificationId(String id) =>
      700000 + (id.hashCode.abs() % 100000);

  static Future<void> _scheduleReminder(String id) async {
    try {
      final context = _reminderText;
      await getIt<LocalNotificationsService>().schedule(
        id: _notificationId(id),
        after: stuckAfter,
        title: context.$1,
        body: context.$2,
        payload: jsonEncode({'type': 'esim_status', 'esimId': id}),
        channel: 'esim',
      );
      AppLogger.i(
        '[ESIM-INSTALL] reminder scheduled id=$id in ${stuckAfter.inMinutes} min',
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
