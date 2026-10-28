import 'package:equatable/equatable.dart';

class CrashReport extends Equatable {
  const CrashReport({
    required this.error,
    required this.stack,
    required this.fatal,
    required this.screen,
    required this.device,
    this.publicId,
  });

  final String error;

  final String stack;
  final bool fatal;

  final String screen;
  final String? publicId;
  final DeviceContext device;

  String get signature => '$error|${stack.split('\n').take(3).join('|')}';

  Map<String, Object?> toMap() => {
    'error': error,
    'stack': stack,
    'fatal': fatal,
    'screen': screen,
    'publicId': publicId,
    ...device.toMap(),
  };

  @override
  List<Object?> get props => [error, stack, fatal, screen, publicId, device];
}

class DeviceContext extends Equatable {
  const DeviceContext({
    required this.platform,
    required this.osVersion,
    required this.model,
    required this.appVersion,
    required this.buildNumber,
    required this.locale,
    required this.flavor,
    this.timezone = 'UTC',
    this.isEmulator = false,
    this.isRooted = false,
  });

  static const unknown = DeviceContext(
    platform: 'unknown',
    osVersion: '',
    model: '',
    appVersion: '',
    buildNumber: '',
    locale: '',
    flavor: '',
  );

  final String platform;
  final String osVersion;
  final String model;
  final String appVersion;
  final String buildNumber;
  final String locale;
  final String flavor;
  final String timezone;
  final bool isEmulator;
  final bool isRooted;

  Map<String, Object?> toMap() => {
    'platform': platform,
    'osVersion': osVersion,
    'deviceModel': model,
    'appVersion': appVersion,
    'buildNumber': buildNumber,
    'locale': locale,
    'flavor': flavor,
  };

  @override
  List<Object?> get props => [
    platform,
    osVersion,
    model,
    appVersion,
    buildNumber,
    locale,
    flavor,
    timezone,
    isEmulator,
    isRooted,
  ];
}

abstract interface class CrashReportStore {
  Future<void> save(CrashReport report);
}
