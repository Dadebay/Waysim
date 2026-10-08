import 'package:equatable/equatable.dart';

import '../../catalog/domain/entities/esim_package.dart';

/// What is being bought, in words the customer sees on the confirmation and
/// the result screens. Built once by whoever starts the purchase.
class PurchaseSubject extends Equatable {
  const PurchaseSubject({
    required this.package,
    required this.title,
    required this.planLine,
    this.flagCode,
    this.esimId,
  });

  final EsimPackage package;

  /// "Türkiye" / "Europe (12 countries)".
  final String title;

  /// "5 GB · 30 days".
  final String planLine;

  /// Flag asset; null draws the globe used for regions.
  final String? flagCode;

  /// Set when the package is added to an existing eSIM.
  final String? esimId;

  bool get isTopUp => esimId != null;

  @override
  List<Object?> get props => [package, title, planLine, flagCode, esimId];
}
