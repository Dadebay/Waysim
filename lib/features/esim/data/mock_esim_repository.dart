import '../../../core/utils/result.dart';
import '../../../mock/mock_backend.dart';
import '../domain/entities/esim.dart';
import '../domain/repositories/esim_repository.dart';

class MockEsimRepository implements EsimRepository {
  MockEsimRepository(this._backend);

  final MockBackend _backend;

  @override
  Future<Result<List<Esim>>> list() => _backend.esims();

  @override
  Future<Result<Esim>> get(String id) => _backend.esim(id);

  @override
  Future<Result<Esim>> refresh(String id) => get(id);

  @override
  Future<Result<Esim>> bindToDevice(String id, {required String deviceName}) =>
      _backend.bindToDevice(id, deviceName);
}
