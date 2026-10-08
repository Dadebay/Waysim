import '../../../core/utils/result.dart';
import '../../../mock/mock_backend.dart';
import '../domain/entities/app_config.dart';
import '../domain/repositories/config_repository.dart';

class MockConfigRepository implements ConfigRepository {
  MockConfigRepository(this._backend);

  final MockBackend _backend;

  @override
  Future<Result<AppConfig>> load() async => Success(_backend.config);
}
