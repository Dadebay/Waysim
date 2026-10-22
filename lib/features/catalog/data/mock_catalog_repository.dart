import '../../../core/error/failure.dart';
import '../../../core/utils/result.dart';
import '../domain/entities/destination.dart';
import '../domain/entities/esim_package.dart';
import '../domain/repositories/catalog_repository.dart';
import '../domain/entities/catalog_banner.dart';
import 'mock/catalog_fixtures.dart';

/// Fixture-backed catalog. [latency] imitates the network so skeletons show.
class MockCatalogRepository implements CatalogRepository {
  @override
  List<CatalogBanner>? get banners => null;
  @override
  Future<Result<Destination>> location(String code) async {
    final d = CatalogFixtures.destinations()
        .where((d) => d.code == code)
        .firstOrNull;
    return d == null ? const Error(NotFoundFailure()) : Success(d);
  }

  @override
  Future<Result<EsimPackage>> package(String id) async {
    for (final d in CatalogFixtures.destinations()) {
      final p = CatalogFixtures.packages(
        d.code,
      ).where((p) => p.id == id).firstOrNull;
      if (p != null) return Success(p);
    }
    return const Error(NotFoundFailure());
  }

  @override
  Future<Result<List<Destination>>> search(String query) => destinations();
  @override
  Future<Result<EsimPackage>> detail(EsimPackage package) async =>
      Success(package);

  MockCatalogRepository({
    this.latency = const Duration(milliseconds: 450),
    required this._destinationOfEsim,
  });

  final Duration latency;
  final String? Function(String esimId) _destinationOfEsim;

  @override
  Future<Result<List<Destination>>> destinations() async {
    await Future<void>.delayed(latency);
    return Success(CatalogFixtures.destinations());
  }

  @override
  Future<Result<List<EsimPackage>>> packages(String destinationCode) async {
    await Future<void>.delayed(latency);
    final list = CatalogFixtures.packages(destinationCode);
    return Success(list);
  }

  @override
  Future<Result<List<EsimPackage>>> topUpPackages(String esimId) async {
    await Future<void>.delayed(latency);
    final code = _destinationOfEsim(esimId);
    if (code == null) return const Error(NotFoundFailure());
    return Success(CatalogFixtures.topUps(code));
  }
}
