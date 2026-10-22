import '../../../../core/utils/result.dart';
import '../entities/destination.dart';
import '../entities/esim_package.dart';
import '../entities/catalog_banner.dart';

abstract interface class CatalogRepository {
  Future<Result<Destination>> location(String code);
  Future<Result<EsimPackage>> package(String id);

  /// Every country and region that has at least one package, with "from"
  /// prices. Destinations without packages are never returned.
  Future<Result<List<Destination>>> destinations();

  List<CatalogBanner>? get banners;
  Future<Result<List<Destination>>> search(String query);
  Future<Result<EsimPackage>> detail(EsimPackage package);

  /// Plans for one destination, cheapest first within each [PackageKind].
  Future<Result<List<EsimPackage>>> packages(String destinationCode);

  /// Plans that can be added to an installed eSIM (top-up).
  Future<Result<List<EsimPackage>>> topUpPackages(String esimId);
}
