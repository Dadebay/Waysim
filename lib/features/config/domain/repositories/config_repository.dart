import '../../../../core/utils/result.dart';
import '../entities/app_config.dart';

abstract interface class ConfigRepository {
  Future<Result<AppConfig>> load();
}
