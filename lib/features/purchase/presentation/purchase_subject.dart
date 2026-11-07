import 'package:equatable/equatable.dart';

import '../../catalog/domain/entities/esim_package.dart';

class PurchaseSubject extends Equatable {
  const PurchaseSubject({
    required this.package,
    required this.title,
    required this.planLine,
    this.flagCode,
    this.esimId,
  });

  final EsimPackage package;

  final String title;

  final String planLine;

  final String? flagCode;

  final String? esimId;

  bool get isTopUp => esimId != null;

  @override
  List<Object?> get props => [package, title, planLine, flagCode, esimId];
}
