import '../../../core/network/api_client.dart';
import '../../../core/network/api_helpers.dart';
import '../../../core/network/api_response.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../core/utils/formatters/money.dart';
import '../../../core/utils/result.dart';
import '../domain/entities/catalog_banner.dart';
import '../domain/entities/destination.dart';
import '../domain/entities/esim_package.dart';
import '../domain/repositories/catalog_repository.dart';

class ApiCatalogRepository implements CatalogRepository {
  ApiCatalogRepository(this.api, this.local);
  final ApiClient api;
  final LocalStorage local;
  String get language => local.getString(StorageKeys.contentLanguage) ?? 'en';
  @override
  List<CatalogBanner>? banners;
  @override
  Future<Result<Destination>> location(String code) => apiResult(() async {
    final j = asMap(
      asMap(
        await api.get('/v1/catalog/locations/${Uri.encodeComponent(code)}'),
      )['location'],
    );
    return _location(j, j.str('kind') == 'region');
  });
  @override
  Future<Result<EsimPackage>> package(String id) => apiResult(
    () async => packageFromApi(
      asMap(await api.get('/v1/catalog/packages/${Uri.encodeComponent(id)}')),
    ),
  );

  Destination _location(Map<String, dynamic> j, bool region) => Destination(
    code: j.str('code'),
    kind: region ? DestinationKind.region : DestinationKind.country,
    names: {language: j.str('name'), 'en': j.str('name')},
    minPrice: Money(j.intVal('fromCents')),
    countryCount: region ? j.intVal('countriesCount') : null,
  );

  @override
  Future<Result<List<Destination>>> destinations() => apiResult(() async {
    final j = asMap(await api.get('/v1/catalog/home'));
    banners = j
        .listOf('banners')
        .map(
          (b) => CatalogBanner(
            id: b.str('id'),
            imageUrl: b.str('imageUrl'),
            width: b.numVal('width', 1200).toDouble(),
            height: b.numVal('height', 1200).toDouble(),
            link: b.strOrNull('link'),
          ),
        )
        .toList();
    return [
      ...j.listOf('local').map((x) => _location(x, false)),
      ...j.listOf('regional').map((x) => _location(x, true)),
    ];
  });

  @override
  Future<Result<List<Destination>>> search(String query) => apiResult(() async {
    final j = asMap(
      await api.get('/v1/catalog/search', queryParameters: {'q': query}),
    );
    return [
      ...j.listOf('countries').map((x) => _location(x, false)),
      ...j.listOf('regions').map((x) => _location(x, true)),
    ];
  });

  @override
  Future<Result<List<EsimPackage>>> packages(
    String destinationCode,
  ) => apiResult(() async {
    final j = asMap(
      await api.get(
        '/v1/catalog/locations/${Uri.encodeComponent(destinationCode)}',
      ),
    );
    final location = j.mapOrNull('location') ?? <String, dynamic>{};
    final limited = j.listOf('limited');
    final unlimited = j.listOf('unlimited');
    var coverage = _coverageFrom(location.listOf('countries'));
    final firstCard = [...limited, ...unlimited].firstOrNull;
    final isRegion =
        location.str('kind') == 'region' ||
        firstCard?.mapOrNull('direction')?.str('kind') == 'region';
    if (isRegion && coverage.codes.isEmpty && firstCard != null) {
      final id = firstCard.str('id', firstCard.str('slug'));
      if (id.isNotEmpty) {
        try {
          final detail = asMap(
            await api.get('/v1/catalog/packages/${Uri.encodeComponent(id)}'),
          );
          coverage = _coverageFrom(detail.listOf('coverage'));
        } on Object {
          // Plans remain available even if the optional coverage lookup fails.
        }
      }
    }
    final limits = j.mapOrNull('perDay') ?? {};
    final result = [
      for (final p in limited)
        packageFromApi(
          p,
          kind: PackageKind.limited,
          perDayOptions: limits,
          regionCoverage: coverage.codes,
          regionCoverageNames: coverage.names,
        ),
      for (final p in unlimited)
        packageFromApi(
          p,
          kind: PackageKind.unlimited,
          perDayOptions: limits,
          regionCoverage: coverage.codes,
          regionCoverageNames: coverage.names,
        ),
    ];
    result.sort((a, b) => a.price.cents.compareTo(b.price.cents));
    return result;
  });

  @override
  Future<Result<EsimPackage>> detail(EsimPackage package) => apiResult(
    () async => packageFromApi(
      asMap(
        await api.get(
          '/v1/catalog/packages/${Uri.encodeComponent(package.id)}',
        ),
      ),
      days: package.purchaseDays,
      kind: package.kind,
      perDayOptions: {
        'minDays': package.minPurchaseDays,
        'maxDays': package.maxPurchaseDays,
      },
    ),
  );

  @override
  Future<Result<List<EsimPackage>>> topUpPackages(String esimId) =>
      apiResult(() async {
        final j = asMap(
          await api.get('/v1/esims/${Uri.encodeComponent(esimId)}/topups'),
        );
        return j.listOf('options').map(packageFromApi).toList();
      });
}

EsimPackage packageFromApi(
  Map<String, dynamic> j, {
  int? days,
  PackageKind? kind,
  Map<String, dynamic>? perDayOptions,
  List<String> regionCoverage = const [],
  Map<String, String> regionCoverageNames = const {},
}) {
  final direction = j.mapOrNull('direction') ?? {};
  final perDay = j.boolVal('perDay');
  final options = j.mapOrNull('perDayOptions') ?? perDayOptions ?? {};
  final rawMinDays = options.intVal('minDays', 1);
  final minDays = rawMinDays < 1 ? 1 : rawMinDays;
  final rawMaxDays = options.intVal('maxDays', minDays);
  final maxDays = rawMaxDays < minDays ? minDays : rawMaxDays;
  final duration = perDay
      ? (days ?? minDays).clamp(minDays, maxDays)
      : j.intVal('days');
  final priceCents = j.intVal('priceCents');
  final packageKind =
      kind ??
      (j.boolVal('unlimited') || perDay
          ? PackageKind.unlimited
          : PackageKind.limited);
  final dataBytes =
      j.intOrNull('dataBytes') ??
      (j.numOrNull('dataGb') == null
          ? null
          : (j.numVal('dataGb') * 1073741824).round());
  final packageCoverage = _coverageFrom(j.listOf('coverage'));
  return EsimPackage(
    id: j.str('id', j.str('slug')),
    destinationCode: direction.str('code'),
    kind: packageKind,
    days: duration,
    price: Money(priceCents * (perDay ? duration : 1)),
    volumeBytes: packageKind == PackageKind.limited ? dataBytes : null,
    dailyBytes: perDay && packageKind == PackageKind.unlimited
        ? dataBytes
        : null,
    details: j.strOrNull('details'),
    activationOnInstall: j.str('activationRule') == 'install',
    network: j.strOrNull('network'),
    hotspot: j.boolVal('hotspot'),
    topUp: j.boolVal('topUpAllowed'),
    installWithinDays: j.intVal('installWithinDays', 180),
    speed: j.strOrNull('speed'),
    coverage: regionCoverage.isNotEmpty
        ? regionCoverage
        : packageCoverage.codes,
    coverageNames: regionCoverage.isNotEmpty
        ? regionCoverageNames
        : packageCoverage.names,
    purchaseDays: perDay ? duration : null,
    dailyPrice: perDay ? Money(priceCents) : null,
    minPurchaseDays: perDay ? minDays : null,
    maxPurchaseDays: perDay ? maxDays : null,
  );
}

({List<String> codes, Map<String, String> names}) _coverageFrom(
  List<Map<String, dynamic>> entries,
) {
  final names = <String, String>{};
  for (final country in entries) {
    final code = country.str('code').trim().toUpperCase();
    if (code.isEmpty) continue;
    final name = country.str('name').trim();
    if (!names.containsKey(code) || names[code]!.isEmpty) names[code] = name;
  }
  return (codes: names.keys.toList(), names: names);
}
