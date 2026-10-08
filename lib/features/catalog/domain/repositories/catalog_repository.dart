import '../../../../core/utils/result.dart';
import '../entities/destination.dart';
import '../entities/esim_package.dart';

abstract interface class CatalogRepository {
  /// Every country and region that has at least one package, with "from"
  /// prices. Destinations without packages are never returned.
  Future<Result<List<Destination>>> destinations();

  /// Plans for one destination, cheapest first within each [PackageKind].
  Future<Result<List<EsimPackage>>> packages(String destinationCode);

  /// Plans that can be added to an installed eSIM (top-up).
  Future<Result<List<EsimPackage>>> topUpPackages(String esimId);
}
