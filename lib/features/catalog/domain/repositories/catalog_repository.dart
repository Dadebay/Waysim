import '../../../../core/utils/result.dart';
import '../entities/destination.dart';
import '../entities/esim_package.dart';
import '../entities/catalog_banner.dart';

abstract interface class CatalogRepository {
  Future<Result<Destination>> location(String code);
  Future<Result<EsimPackage>> package(String id);

  Future<Result<List<Destination>>> destinations();

  List<CatalogBanner>? get banners;
  Future<Result<List<Destination>>> search(String query);
  Future<Result<EsimPackage>> detail(EsimPackage package);

  Future<Result<List<EsimPackage>>> packages(String destinationCode);

  Future<Result<List<EsimPackage>>> topUpPackages(String esimId);
}
