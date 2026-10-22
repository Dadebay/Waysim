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
  Future<Result<List<EsimPackage>>> packages(String destinationCode) =>
      apiResult(() async {
        final j = asMap(
          await api.get(
            '/v1/catalog/locations/${Uri.encodeComponent(destinationCode)}',
          ),
        );
        final limits = j.mapOrNull('perDay') ?? {};
        final result = [
          for (final p in j.listOf('limited'))
            packageFromApi(p, kind: PackageKind.limited, perDayOptions: limits),
          for (final p in j.listOf('unlimited'))
            packageFromApi(
              p,
              kind: PackageKind.unlimited,
              perDayOptions: limits,
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
    coverage: j.listOf('coverage').map((c) => c.str('code')).toList(),
    purchaseDays: perDay ? duration : null,
    dailyPrice: perDay ? Money(priceCents) : null,
    minPurchaseDays: perDay ? minDays : null,
    maxPurchaseDays: perDay ? maxDays : null,
  );
}
