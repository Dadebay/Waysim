import '../../../core/error/failure.dart';
import '../../../core/utils/result.dart';
import '../domain/entities/destination.dart';
import '../domain/entities/esim_package.dart';
import '../domain/repositories/catalog_repository.dart';
import 'mock/catalog_fixtures.dart';

/// Fixture-backed catalog. [latency] imitates the network so skeletons show.
class MockCatalogRepository implements CatalogRepository {
  MockCatalogRepository({
    this.latency = const Duration(milliseconds: 450),
    required String? Function(String esimId) destinationOfEsim,
  }) : _destinationOfEsim = destinationOfEsim;

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
