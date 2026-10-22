import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_constants.dart';
import '../core/constants/app_environment.dart';
import '../core/network/api_client.dart';
import '../core/network/api_helpers.dart';
import '../core/di/injector.dart';
import '../core/services/esim_support_cubit.dart';
import '../core/widgets/app_crossfade.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import 'router/app_routes.dart';
import '../features/catalog/presentation/cubit/catalog_cubit.dart';
import '../features/config/presentation/cubit/config_cubit.dart';
import '../features/config/domain/entities/app_config.dart';
import '../features/esim/presentation/cubit/esim_list_cubit.dart';
import '../features/notification/presentation/cubit/notification_prefs_cubit.dart';
import '../features/wallet/presentation/cubit/wallet_cubit.dart';
import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../core/services/device_integrity.dart';
import '../core/services/analytics_service.dart';
import '../core/services/slow_frame_reporter.dart';
import '../core/services/push_router.dart';
import '../core/services/push_service.dart';
import '../core/storage/secure_storage.dart';
import 'cubit/locale_cubit.dart';
import 'view/connection_gate.dart';
import 'view/force_update_gate.dart';
import 'cubit/theme_cubit.dart';
import 'router/app_router.dart';

/// Root widget: global blocs, theme, localization and the router.
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  late final GoRouter _router = AppRouter.create();
  late final AnalyticsScreenTracker _screenTracker = AnalyticsScreenTracker(
    getIt<AnalyticsService>(),
  );
  StreamSubscription<PushTap>? _pushTaps;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _router.routerDelegate.addListener(_trackScreen);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _trackScreen();
      _syncLocale(getIt<ConfigCubit>().state);
      if (getIt<AuthCubit>().state.signedOutRemotely) {
        _showRemoteSignOut();
      }
    });
    // A tapped notification opens the screen it is about (never anything the
    // router does not know — see PushRouter).
    _pushTaps = getIt<PushService>().taps.listen((tap) {
      unawaited(_handlePushTap(tap));
    });
  }

  void _trackScreen() {
    final match = _router.routerDelegate.currentConfiguration.lastOrNull;
    if (match == null) return;
    _screenTracker.enter(
      match.route.name ?? match.route.path,
      routeKey: match.pageKey,
    );
  }

  Future<void> _handlePushTap(PushTap tap) async {
    if (tap.data['type'] == 'signed_out' &&
        getIt<AuthCubit>().state.isSignedIn) {
      await getIt<SecureStorage>().clearSession();
      if (!mounted) return;
      getIt<AuthCubit>().sessionExpired(revoked: true);
    }
    final deliveryId = tap.data['deliveryId']?.trim();
    final broadcastId = tap.data['broadcastId']?.trim();
    final opened = {
      if (deliveryId != null && deliveryId.isNotEmpty) 'deliveryId': deliveryId,
      if (broadcastId != null && broadcastId.isNotEmpty)
        'broadcastId': broadcastId,
    };
    if (!AppEnvironment.useMockApi && getIt.isRegistered<ApiClient>()) {
      unawaited(
        apiResult(() async {
          await getIt<ApiClient>().post(
            '/v1/notifications/opened',
            data: opened,
          );
        }),
      );
    }
    if (tap.data['type'] == 'signed_out') return;
    final route = PushRouter.routeFor(tap.data);
    if (route != null) unawaited(_router.push(route));
  }

  void _showRemoteSignOut() {
    if (_router.routeInformationProvider.value.uri.path !=
        AppRoute.login.path) {
      _router.go(AppRoute.login.path);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _router.routerDelegate.removeListener(_trackScreen);
    _screenTracker.pause();
    getIt<SlowFrameReporter>().stop();
    _pushTaps?.cancel();
    _router.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _screenTracker.resume();
      unawaited(getIt<AuthCubit>().revalidate());
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      _screenTracker.pause();
    }
  }

  void _syncLocale(AppConfig config) {
    if (config.supportedLocales.isEmpty) return;
    final localeCubit = getIt<LocaleCubit>();
    if (config.supportedLocales.contains(localeCubit.state.languageCode)) {
      return;
    }
    final fallback = config.supportedLocales.contains(config.defaultLocale)
        ? config.defaultLocale
        : config.supportedLocales.first;
    localeCubit.setLocale(Locale(fallback));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>.value(value: getIt<ThemeCubit>()),
        BlocProvider<LocaleCubit>.value(value: getIt<LocaleCubit>()),
        BlocProvider<AuthCubit>.value(value: getIt<AuthCubit>()),
        BlocProvider<WalletCubit>.value(value: getIt<WalletCubit>()),
        BlocProvider<ConfigCubit>.value(value: getIt<ConfigCubit>()),
        BlocProvider<CatalogCubit>.value(value: getIt<CatalogCubit>()),
        BlocProvider<EsimListCubit>.value(value: getIt<EsimListCubit>()),
        BlocProvider<EsimSupportCubit>.value(value: getIt<EsimSupportCubit>()),
        BlocProvider<DeviceIntegrityCubit>.value(
          value: getIt<DeviceIntegrityCubit>(),
        ),
        BlocProvider<NotificationPrefsCubit>.value(
          value: getIt<NotificationPrefsCubit>(),
        ),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (previous, current) =>
            !previous.signedOutRemotely && current.signedOutRemotely,
        listener: (_, _) => _showRemoteSignOut(),
        child: BlocListener<ConfigCubit, AppConfig>(
          listener: (_, config) => _syncLocale(config),
          child: BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return BlocBuilder<LocaleCubit, Locale>(
                builder: (context, locale) {
                  return MaterialApp.router(
                    title: AppConstants.appName,
                    debugShowCheckedModeBanner: false,
                    routerConfig: _router,
                    builder: (context, child) => _SystemBars(
                      child: AppCrossfade(
                        child: ConnectionGate(
                          child: ForceUpdateGate(
                            child: child ?? const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ),
                    theme: AppTheme.light,
                    darkTheme: AppTheme.dark,
                    themeMode: themeMode,
                    themeAnimationDuration: AppConstants.themeFallbackAnimation,
                    themeAnimationCurve: Curves.easeOutCubic,
                    locale: locale,
                    supportedLocales: AppLocalizations.supportedLocales,
                    localizationsDelegates: const [
                      AppLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Status-bar icons follow the theme: dark icons on the light theme, light
/// icons on the dark one, over a transparent bar. (iOS names the same thing
/// from the other side, hence the inverse `statusBarBrightness`.)
class _SystemBars extends StatelessWidget {
  const _SystemBars({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: child,
    );
  }
}
