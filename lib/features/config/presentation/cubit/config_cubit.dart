import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/app_config.dart';
import '../../domain/repositories/config_repository.dart';

/// Server-controlled switches: referral on/off and its reward, maintenance,
/// top-up limits. Fetched at launch and whenever the app returns to the
/// foreground. Defaults apply until the first answer, and stay if a fetch
/// fails.
class ConfigCubit extends Cubit<AppConfig> {
  ConfigCubit(this._repository) : super(const AppConfig());

  final ConfigRepository _repository;

  Future<void> refresh() async {
    final result = await _repository.load();
    if (isClosed) return;
    if (result case Success(:final data)) emit(data);
  }
}
