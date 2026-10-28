import 'dart:async';

import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'core/bloc/app_bloc_observer.dart';
import 'core/constants/app_environment.dart';
import 'core/di/injector.dart';
import 'app/session_coordinator.dart';
import 'app/telemetry_coordinator.dart';
import 'core/services/crash_reporter.dart';
import 'core/services/slow_frame_reporter.dart';
import 'core/services/firebase_setup.dart';
import 'core/services/device_integrity.dart';
import 'core/services/esim_support_cubit.dart';
import 'core/services/push_service.dart';
import 'core/utils/app_logger.dart';
import 'core/utils/system_ui_manager.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/catalog/presentation/cubit/catalog_cubit.dart';
import 'features/config/presentation/cubit/config_cubit.dart';

/// Everything that must happen before the first frame, in one place.
/// `main.dart` stays a two-liner and tests can reuse this setup.
Future<void> bootstrap(Widget Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();
  AppEnvironment.ensureSecureApiBaseUrl();

  FlutterError.onError = (details) {
    AppLogger.e(details.exceptionAsString(), details.exception, details.stack);
  };

  // Phones only: portrait.
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
  ]);

  // Android: hide the navigation bar (keep the status bar); it is hidden
  // again a few seconds after a swipe from the bottom edge brings it back.
  await SystemUiManager().start();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getApplicationDocumentsDirectory()).path,
    ),
  );

  Bloc.observer = const AppBlocObserver();

  // Firebase before the dependency graph: the injector picks the real
  // push / analytics / crash services only when it came up.
  await FirebaseSetup.init();

  await configureDependencies();

  // From here on uncaught errors go to the crash reporter (a logger until
  // Crashlytics is wired).
  final reporter = getIt<CrashReporter>();
  Bloc.observer = AppBlocObserver(reporter);
  FlutterError.onError = (details) =>
      reporter.recordError(details.exception, details.stack);
  PlatformDispatcher.instance.onError = (error, stack) {
    reporter.recordError(error, stack, fatal: true);
    return true;
  };

  // Session first, so sign-in state reaches the coordinator before the data
  // loads. None of this blocks the first frame: Home shows skeletons, the
  // profile shows a loading indicator until the stored session answers.
  getIt<SessionCoordinator>().start();
  getIt<TelemetryCoordinator>().start();
  getIt<SlowFrameReporter>().start();
  unawaited(getIt<AuthCubit>().restore());
  unawaited(getIt<ConfigCubit>().refresh());
  unawaited(getIt<CatalogCubit>().load());
  // Show the fresh compatibility result on the first frame.
  await getIt<EsimSupportCubit>().check();

  unawaited(getIt<DeviceIntegrityCubit>().check());
  unawaited(getIt<PushService>().init());

  runApp(builder());
}
