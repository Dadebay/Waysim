import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_constants.dart';
import '../core/di/injector.dart';
import '../core/services/esim_support_cubit.dart';
import '../core/widgets/app_crossfade.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/catalog/presentation/cubit/catalog_cubit.dart';
import '../features/config/presentation/cubit/config_cubit.dart';
import '../features/esim/presentation/cubit/esim_list_cubit.dart';
import '../features/notification/presentation/cubit/notification_prefs_cubit.dart';
import '../features/wallet/presentation/cubit/wallet_cubit.dart';
import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../core/services/device_integrity.dart';
import '../core/services/push_router.dart';
import '../core/services/push_service.dart';
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

class _AppState extends State<App> {
  late final GoRouter _router = AppRouter.create();
  StreamSubscription<PushTap>? _pushTaps;

  @override
  void initState() {
    super.initState();
    // A tapped notification opens the screen it is about (never anything the
    // router does not know — see PushRouter).
    _pushTaps = getIt<PushService>().taps.listen((tap) {
      final route = PushRouter.routeFor(tap.data);
      if (route != null) unawaited(_router.push(route));
    });
  }

  @override
  void dispose() {
    _pushTaps?.cancel();
    _router.dispose();
    super.dispose();
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
