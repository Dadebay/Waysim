import '../../../core/services/crash_report.dart';

/// Keeps the customer's message first and diagnostic data at the very end.
String buildSupportMailBody({
  required String message,
  required String localizedTemplate,
  required DeviceContext device,
  required String osBuild,
  String? deviceId,
  String? installId,
  String? appLanguage,
  DateTime? createdAt,
}) {
  final separator = localizedTemplate.indexOf('\n\n');
  final technicalDetails = separator < 0
      ? localizedTemplate
      : localizedTemplate.substring(separator + 2);
  final details = [
    technicalDetails,
    'Device ID: ${deviceId ?? '—'}',
    'Install ID: ${installId ?? '—'}',
    'Platform: ${device.platform}',
    'Model: ${device.model}',
    'OS build: $osBuild',
    'Device locale: ${device.locale}',
    'App language: ${appLanguage ?? '—'}',
    'Time zone: ${device.timezone}',
    'Emulator: ${device.isEmulator}',
    'Rooted / jailbroken: ${device.isRooted}',
    'Environment: ${device.flavor}',
    'Created (UTC): ${(createdAt ?? DateTime.now()).toUtc().toIso8601String()}',
  ];
  return '${message.trim()}\n\n\n\n\n\n${details.join('\n')}';
}
