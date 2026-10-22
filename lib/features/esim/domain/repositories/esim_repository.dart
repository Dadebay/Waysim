import '../../../../core/utils/result.dart';
import '../entities/esim.dart';

abstract interface class EsimRepository {
  /// The signed-in customer's eSIMs, newest first.
  Future<Result<List<Esim>>> list();

  Future<Result<Esim>> get(String id);
  Future<Result<Esim>> refresh(String id);

  /// Called when the customer taps "Install": binds the package to this
  /// phone (one package, one device) and returns the refreshed eSIM.
  Future<Result<Esim>> bindToDevice(String id, {required String deviceName});
}
