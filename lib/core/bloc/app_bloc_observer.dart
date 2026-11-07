import 'package:bloc/bloc.dart';

import '../utils/app_logger.dart';
import '../services/crash_reporter.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver([this._reporter]);

  final CrashReporter? _reporter;

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);

    AppLogger.group(
      '${bloc.runtimeType}',
      lines: ['${change.currentState}', '-> ${change.nextState}'],
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    AppLogger.e('${bloc.runtimeType} error', error, stackTrace);
    _reporter?.recordError(error, stackTrace);
    super.onError(bloc, error, stackTrace);
  }
}
