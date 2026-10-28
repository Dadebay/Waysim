import 'package:equatable/equatable.dart';

import '../../../../core/utils/formatters/money.dart';

enum PackageKind { limited, unlimited }

class EsimPackage extends Equatable {
  const EsimPackage({
    required this.id,
    required this.destinationCode,
    required this.kind,
    required this.days,
    required this.price,
    this.volumeBytes,
    this.dailyBytes,
    this.network,
    this.hotspot = true,
    this.topUp = true,
    this.smsAndCalls = false,
    this.installWithinDays = 180,
    this.coverage = const [],
    this.coverageNames = const {},
    this.speed,
    this.purchaseDays,
    this.dailyPrice,
    this.minPurchaseDays,
    this.maxPurchaseDays,
    this.details,
    this.activationOnInstall = false,
  });

  final String id;
  final String destinationCode;
  final PackageKind kind;
  final int days;
  final Money price;

  final int? volumeBytes;

  final int? dailyBytes;

  final String? network;

  final bool hotspot;
  final bool topUp;
  final bool smsAndCalls;
  final int installWithinDays;

  final List<String> coverage;

  final Map<String, String> coverageNames;
  final String? speed;
  final String? details;
  final bool activationOnInstall;
  final int? purchaseDays;
  final Money? dailyPrice;
  final int? minPurchaseDays;
  final int? maxPurchaseDays;
  String get selectionKey => '$id:${purchaseDays ?? 0}';

  EsimPackage withPurchaseDays(int selectedDays) {
    final daily = dailyPrice;
    if (daily == null) return this;
    final days = selectedDays.clamp(
      minPurchaseDays ?? 1,
      maxPurchaseDays ?? selectedDays,
    );
    return EsimPackage(
      id: id,
      destinationCode: destinationCode,
      kind: kind,
      days: days,
      price: Money(daily.cents * days),
      volumeBytes: volumeBytes,
      dailyBytes: dailyBytes,
      network: network,
      hotspot: hotspot,
      topUp: topUp,
      smsAndCalls: smsAndCalls,
      installWithinDays: installWithinDays,
      coverage: coverage,
      coverageNames: coverageNames,
      speed: speed,
      purchaseDays: days,
      dailyPrice: daily,
      minPurchaseDays: minPurchaseDays,
      maxPurchaseDays: maxPurchaseDays,
      details: details,
      activationOnInstall: activationOnInstall,
    );
  }

  bool get isUnlimited => kind == PackageKind.unlimited;

  @override
  List<Object?> get props => [
    id,
    destinationCode,
    kind,
    days,
    price,
    volumeBytes,
    dailyBytes,
    network,
    hotspot,
    topUp,
    smsAndCalls,
    installWithinDays,
    coverage,
    coverageNames,
    speed,
    purchaseDays,
    dailyPrice,
    minPurchaseDays,
    maxPurchaseDays,
  ];
}
