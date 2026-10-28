import '../../../../core/utils/result.dart';
import '../entities/esim.dart';

abstract interface class EsimRepository {
  Future<Result<List<Esim>>> list();

  Future<Result<Esim>> get(String id);
  Future<Result<Esim>> refresh(String id);

  Future<Result<Esim>> bindToDevice(String id, {required String deviceName});
}
