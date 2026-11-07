import 'package:equatable/equatable.dart';

import '../../../../core/utils/formatters/money.dart';

enum DestinationKind { country, region }

class Destination extends Equatable {
  const Destination({
    required this.code,
    required this.kind,
    required this.names,
    required this.minPrice,
    this.aliases = const [],
    this.countryCount,
    this.coverageNote,
  });

  factory Destination.fromJson(Map<String, dynamic> json) => Destination(
    code: json['code'] as String,
    kind: json['kind'] == 'region'
        ? DestinationKind.region
        : DestinationKind.country,
    names: Map<String, String>.from(json['names'] as Map),
    minPrice: Money(json['minPriceCents'] as int),
    aliases: List<String>.from(json['aliases'] as List? ?? const []),
    countryCount: json['countryCount'] as int?,
    coverageNote: json['coverageNote'] as String?,
  );

  final String code;
  final DestinationKind kind;

  final Map<String, String> names;

  final Money minPrice;

  final List<String> aliases;

  final int? countryCount;

  final String? coverageNote;

  bool get isRegion => kind == DestinationKind.region;

  String nameFor(String language) => names[language] ?? names['en'] ?? code;

  String? get flagCode => isRegion ? null : code.toLowerCase();

  Map<String, dynamic> toJson() => {
    'code': code,
    'kind': kind.name,
    'names': names,
    'minPriceCents': minPrice.cents,
    'aliases': aliases,
    'countryCount': countryCount,
    'coverageNote': coverageNote,
  };

  @override
  List<Object?> get props => [
    code,
    kind,
    names,
    minPrice,
    aliases,
    countryCount,
    coverageNote,
  ];
}
