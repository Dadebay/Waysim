import 'package:equatable/equatable.dart';

/// Everything needed to find and fix a crash: who, on which phone, doing what.
/// Deliberately free of personal data — the public id (`A0123`) identifies the
/// customer to support; there is no e-mail, name, token or payment detail.
class CrashReport extends Equatable {
  const CrashReport({
    required this.error,
    required this.stack,
    required this.fatal,
    required this.screen,
    required this.device,
    this.publicId,
  });

  /// `error.toString()`, trimmed.
  final String error;

  /// First lines of the stack trace.
  final String stack;
  final bool fatal;

  /// The route the customer was on.
  final String screen;
  final String? publicId;
  final DeviceContext device;

  /// What the same crash looks like twice: used to avoid writing it ten
  /// thousand times from a build loop.
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

/// The phone and the build.
class DeviceContext extends Equatable {
  const DeviceContext({
    required this.platform,
    required this.osVersion,
    required this.model,
    required this.appVersion,
    required this.buildNumber,
    required this.locale,
    required this.flavor,
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
  ];
}

/// Where reports are kept.
abstract interface class CrashReportStore {
  Future<void> save(CrashReport report);
}
