import 'package:equatable/equatable.dart';

import '../../../catalog/domain/entities/esim_package.dart';

/// Where an eSIM stands, in the customer's terms. The backend maps the
/// supplier's statuses onto this (docs/01-product-spec.md §5).
enum EsimStatus {
  /// The order is placed; the profile is not ready yet.
  provisioning,

  /// Ready but not on a phone yet.
  notInstalled,

  /// On the phone, no data used yet.
  installed,

  /// Using data.
  active,
  usedUp,
  expired,
  suspended,
  cancelled,
  revoked,
  failed,
}

extension EsimStatusX on EsimStatus {
  /// Spent or expired eSIMs live under "Archive".
  bool get isArchived =>
      this == EsimStatus.usedUp ||
      this == EsimStatus.expired ||
      this == EsimStatus.cancelled ||
      this == EsimStatus.revoked ||
      this == EsimStatus.failed;
}

class Esim extends Equatable {
  const Esim({
    required this.id,
    required this.destinationCode,
    required this.destinationNames,
    required this.kind,
    required this.days,
    required this.status,
    required this.smdpAddress,
    required this.activationCode,
    required this.iccid,
    this.countryCount,
    this.volumeBytes,
    this.dailyBytes,
    this.usedBytes = 0,
    this.expiresAt,
    this.installBy,
    this.deviceName,
    this.updatedAt,
    this.topUpSupported = true,
    this.lpaString,
    this.appleUniversalLink,
  });

  final String id;
  final String destinationCode;
  final Map<String, String> destinationNames;

  /// Regions: number of countries ("Europe (35 countries)").
  final int? countryCount;
  final PackageKind kind;
  final int days;
  final int? volumeBytes;
  final int? dailyBytes;
  final int usedBytes;
  final EsimStatus status;

  /// When the package runs out; null until the first connection starts it.
  final DateTime? expiresAt;

  /// Last day the eSIM can still be installed.
  final DateTime? installBy;

  /// The phone it is bound to once installation was started.
  final String? deviceName;
  final DateTime? updatedAt;

  final String smdpAddress;
  final String activationCode;
  final String iccid;
  final bool topUpSupported;
  final String? lpaString;
  final String? appleUniversalLink;

  bool get isUnlimited => kind == PackageKind.unlimited;
  bool get isRegion => countryCount != null;

  String nameFor(String language) =>
      destinationNames[language] ?? destinationNames['en'] ?? destinationCode;

  int? get remainingBytes => volumeBytes == null
      ? null
      : (volumeBytes! - usedBytes).clamp(0, volumeBytes!);

  /// 0–1 of the data left; 1 for an unlimited plan.
  double get remainingFraction => volumeBytes == null || volumeBytes == 0
      ? 1
      : (remainingBytes! / volumeBytes!).clamp(0.0, 1.0);

  /// Whole days until [expiresAt], never negative; null if not started.
  int? daysLeft(DateTime now) =>
      expiresAt?.difference(now).inDays.clamp(0, 100000);

  /// The string a phone's eSIM installer reads (QR code content).
  String get lpa => lpaString ?? 'LPA:1\$$smdpAddress\$$activationCode';

  /// iOS 17.4+: opens Apple's installer straight from a link.
  Uri get appleInstallUri => appleUniversalLink != null
      ? Uri.parse(appleUniversalLink!)
      : Uri.https('esimsetup.apple.com', '/esim_qrcode_provisioning', {
          'carddata': lpa,
        });

  Esim copyWith({
    EsimStatus? status,
    int? usedBytes,
    int? volumeBytes,
    int? days,
    DateTime? expiresAt,
    String? deviceName,
    DateTime? updatedAt,
  }) => Esim(
    id: id,
    destinationCode: destinationCode,
    destinationNames: destinationNames,
    kind: kind,
    days: days ?? this.days,
    status: status ?? this.status,
    smdpAddress: smdpAddress,
    activationCode: activationCode,
    iccid: iccid,
    countryCount: countryCount,
    volumeBytes: volumeBytes ?? this.volumeBytes,
    dailyBytes: dailyBytes,
    usedBytes: usedBytes ?? this.usedBytes,
    expiresAt: expiresAt ?? this.expiresAt,
    installBy: installBy,
    deviceName: deviceName ?? this.deviceName,
    updatedAt: updatedAt ?? this.updatedAt,
    topUpSupported: topUpSupported,
    lpaString: lpaString,
    appleUniversalLink: appleUniversalLink,
  );

  @override
  List<Object?> get props => [
    id,
    destinationCode,
    kind,
    days,
    volumeBytes,
    dailyBytes,
    usedBytes,
    status,
    expiresAt,
    installBy,
    deviceName,
    updatedAt,
    smdpAddress,
    activationCode,
    iccid,
    countryCount,
    topUpSupported,
  ];

  // Bloc transitions stringify eSIMs in debug logs. Installation credentials
  // remain in props for equality, but must never appear in those logs.
  @override
  String toString() => 'Esim($id, $destinationCode, $kind, $days, $status)';
}
