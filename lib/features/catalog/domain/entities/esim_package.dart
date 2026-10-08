import 'package:equatable/equatable.dart';

import '../../../../core/utils/formatters/money.dart';

enum PackageKind {
  /// A fixed amount of data for the whole period ("5 GB · 30 days").
  limited,

  /// Unlimited data, usually with a daily full-speed allowance.
  unlimited,
}

/// A plan the customer can buy. Only what the app shows — the supplier's
/// package code, wholesale price and margin never leave the backend.
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
    this.speed,
  });

  /// Stable slug (`TR_5_30`) — the only thing the app sends to buy.
  final String id;
  final String destinationCode;
  final PackageKind kind;
  final int days;
  final Money price;

  /// Total data for [PackageKind.limited].
  final int? volumeBytes;

  /// Full-speed data per day for [PackageKind.unlimited] ("1 GB a day").
  final int? dailyBytes;

  /// "Operator · 4G/5G".
  final String? network;

  final bool hotspot;
  final bool topUp;
  final bool smsAndCalls;
  final int installWithinDays;

  /// Country codes covered; one entry for a country plan.
  final List<String> coverage;
  final String? speed;

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
    speed,
  ];
}
