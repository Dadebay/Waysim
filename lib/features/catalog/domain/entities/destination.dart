import 'package:equatable/equatable.dart';

import '../../../../core/utils/formatters/money.dart';

enum DestinationKind { country, region }

/// A place an eSIM can be bought for: one country or a multi-country region.
/// The server sends names already translated; [names] keeps every language
/// the catalog knows so search can match "США", "USA" and "US" alike.
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

  /// ISO 3166-1 alpha-2 for a country (`TR`), a stable key for a region
  /// (`EU`, `ASIA`, `GLOBAL`).
  final String code;
  final DestinationKind kind;

  /// Display name per language code (`en`, `ru`, …).
  final Map<String, String> names;

  /// Lowest package price: the "from $X" figure.
  final Money minPrice;

  /// Extra search terms: synonyms, three-letter codes, old names.
  final List<String> aliases;

  /// Regions only: how many countries the plans cover.
  final int? countryCount;

  /// Regions only: short note such as "USA and Canada".
  final String? coverageNote;

  bool get isRegion => kind == DestinationKind.region;

  /// Name in [language], falling back to English then the code.
  String nameFor(String language) => names[language] ?? names['en'] ?? code;

  /// Name of the flag asset for a country; null for a region.
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
