import 'package:equatable/equatable.dart';

import '../../../catalog/domain/entities/esim_package.dart';

enum EsimStatus {
  provisioning,

  notInstalled,

  installed,

  active,
  usedUp,
  expired,
  suspended,
  cancelled,
  revoked,
  failed,
}

extension EsimStatusX on EsimStatus {
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

  final int? countryCount;
  final PackageKind kind;
  final int days;
  final int? volumeBytes;
  final int? dailyBytes;
  final int usedBytes;
  final EsimStatus status;

  final DateTime? expiresAt;

  final DateTime? installBy;

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

  double get remainingFraction => volumeBytes == null || volumeBytes == 0
      ? 1
      : (remainingBytes! / volumeBytes!).clamp(0.0, 1.0);

  int? daysLeft(DateTime now) =>
      expiresAt?.difference(now).inDays.clamp(0, 100000);

  String get lpa => lpaString?.isNotEmpty == true
      ? lpaString!
      : 'LPA:1\$$smdpAddress\$$activationCode';

  Uri get appleInstallUri =>
      Uri.https('esimsetup.apple.com', '/esim_qrcode_provisioning', {
        // Use the complete API LPA string, including any matching ID.
        'carddata': lpa,
      });

  Map<String, dynamic> toJson() => {
    'id': id,
    'destinationCode': destinationCode,
    'destinationNames': destinationNames,
    'countryCount': countryCount,
    'kind': kind.name,
    'days': days,
    'volumeBytes': volumeBytes,
    'dailyBytes': dailyBytes,
    'usedBytes': usedBytes,
    'status': status.name,
    'expiresAt': expiresAt?.toIso8601String(),
    'installBy': installBy?.toIso8601String(),
    'deviceName': deviceName,
    'updatedAt': updatedAt?.toIso8601String(),
    'smdpAddress': smdpAddress,
    'activationCode': activationCode,
    'iccid': iccid,
    'topUpSupported': topUpSupported,
    'lpaString': lpaString,
    'appleUniversalLink': appleUniversalLink,
  };

  factory Esim.fromJson(Map<String, dynamic> j) => Esim(
    id: j['id'] as String,
    destinationCode: j['destinationCode'] as String,
    destinationNames: Map<String, String>.from(j['destinationNames'] as Map),
    countryCount: j['countryCount'] as int?,
    kind: PackageKind.values.byName(j['kind'] as String),
    days: j['days'] as int,
    volumeBytes: j['volumeBytes'] as int?,
    dailyBytes: j['dailyBytes'] as int?,
    usedBytes: j['usedBytes'] as int? ?? 0,
    status: EsimStatus.values.byName(j['status'] as String),
    expiresAt: DateTime.tryParse(j['expiresAt'] as String? ?? ''),
    installBy: DateTime.tryParse(j['installBy'] as String? ?? ''),
    deviceName: j['deviceName'] as String?,
    updatedAt: DateTime.tryParse(j['updatedAt'] as String? ?? ''),
    smdpAddress: j['smdpAddress'] as String,
    activationCode: j['activationCode'] as String,
    iccid: j['iccid'] as String,
    topUpSupported: j['topUpSupported'] as bool? ?? true,
    lpaString: j['lpaString'] as String?,
    appleUniversalLink: j['appleUniversalLink'] as String?,
  );

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

  @override
  String toString() => 'Esim($id, $destinationCode, $kind, $days, $status)';
}
