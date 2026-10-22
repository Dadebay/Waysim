import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/cubit/locale_cubit.dart';
import '../../app/cubit/theme_cubit.dart';
import '../../app/session_coordinator.dart';
import '../../app/telemetry_coordinator.dart';
import '../../features/auth/data/auth_token_refresher.dart';
import '../../features/auth/data/mock_auth_repository.dart';
import '../../features/auth/data/api_auth_repository.dart';
import '../../features/auth/domain/entities/user.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/login_cubit.dart';
import '../../features/catalog/data/mock_catalog_repository.dart';
import '../../features/catalog/data/api_catalog_repository.dart';
import '../../features/catalog/domain/entities/esim_package.dart';
import '../../features/catalog/domain/repositories/catalog_repository.dart';
import '../../features/catalog/presentation/cubit/catalog_cubit.dart';
import '../../features/catalog/presentation/cubit/search_cubit.dart';
import '../../features/config/data/mock_config_repository.dart';
import '../../features/config/data/api_config_repository.dart';
import '../../features/config/domain/repositories/config_repository.dart';
import '../../features/config/presentation/cubit/config_cubit.dart';
import '../../features/esim/data/mock_esim_repository.dart';
import '../../features/esim/data/api_esim_repository.dart';
import '../../features/esim/domain/repositories/esim_repository.dart';
import '../../features/esim/presentation/cubit/esim_list_cubit.dart';
import '../../features/legal/data/mock_legal_repository.dart';
import '../../features/legal/data/api_legal_repository.dart';
import '../../features/legal/domain/entities/legal_document.dart';
import '../../features/legal/domain/repositories/legal_repository.dart';
import '../../features/notification/presentation/cubit/notification_prefs_cubit.dart';
import '../../features/purchase/data/mock_purchase_repository.dart';
import '../../features/purchase/data/api_purchase_repository.dart';
import '../../features/purchase/domain/repositories/purchase_repository.dart';
import '../../features/purchase/presentation/cubit/purchase_cubit.dart';
import '../../features/referral/data/mock_referral_repository.dart';
import '../../features/referral/data/api_referral_repository.dart';
import '../../features/referral/domain/entities/referral.dart';
import '../../features/referral/domain/repositories/referral_repository.dart';
import '../../features/support/data/mock_support_repository.dart';
import '../../features/support/data/api_support_repository.dart';
import '../../features/support/domain/repositories/support_repository.dart';
import '../../features/support/presentation/cubit/chat_cubit.dart';
import '../../features/wallet/data/mock_wallet_repository.dart';
import '../../features/wallet/data/api_wallet_repository.dart';
import '../../features/wallet/domain/entities/wallet_entities.dart';
import '../../features/wallet/domain/repositories/wallet_repository.dart';
import '../../features/wallet/presentation/cubit/top_up_cubit.dart';
import '../../features/wallet/presentation/cubit/wallet_cubit.dart';
import '../../mock/mock_backend.dart';
import '../bloc/async_cubit.dart';
import '../services/analytics_service.dart';
import '../services/app_attestation.dart';
import '../services/crash_report.dart';
import '../services/device_context.dart';
import '../services/fcm_push_service.dart';
import '../services/firebase_services.dart';
import '../services/firebase_setup.dart';
import '../services/firestore_crash_reporter.dart';
import '../services/slow_frame_reporter.dart';
import '../services/local_notifications_service.dart';
import '../services/crash_reporter.dart';
import '../services/device_integrity.dart';
import '../services/esim_compatibility.dart';
import '../services/esim_support_cubit.dart';
import '../services/push_service.dart';
import '../constants/app_environment.dart';
import '../network/api_client.dart';
import '../network/device_session.dart';
import '../network/interceptors/app_check_interceptor.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/token_refresher.dart';
import '../error/failure.dart';
import '../utils/formatters/money.dart';
import '../network/interceptors/api_log_interceptor.dart';
import '../network/interceptors/language_interceptor.dart';
import '../network/network_info.dart';
import '../storage/local_storage.dart';
import '../storage/secure_storage.dart';

/// Service locator. One `getIt` for the whole app.
final getIt = GetIt.instance;
bool _useMockApi = AppEnvironment.useMockApi;

/// Registration order: external packages -> core services -> global cubits ->
/// feature layers.
///
/// Each feature registers itself in its own `_registerX()` function so the
/// features stay self-contained. `AuthInterceptor` joins the Dio instance in
/// docs/06-roadmap.md T4.2, once the auth feature exists to refresh tokens.
Future<void> configureDependencies({bool? useMockApi}) async {
  _useMockApi = useMockApi ?? AppEnvironment.useMockApi;
  await _registerExternal();
  _registerCore();
  _registerGlobalCubits();
  _registerFeatures();
}

Future<void> _registerExternal() async {
  final prefs = await SharedPreferences.getInstance();
  getIt
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage(
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock_this_device,
        ),
      ),
    )
    ..registerLazySingleton<Connectivity>(Connectivity.new)
    // The phone and build, read once for crash reports.
    ..registerSingleton<DeviceContext>(await readDeviceContext());
}

void _registerCore() {
  getIt
    ..registerLazySingleton<LocalStorage>(
      () => LocalStorageImpl(getIt<SharedPreferences>()),
    )
    ..registerLazySingleton<SecureStorage>(
      () => SecureStorageImpl(getIt<FlutterSecureStorage>()),
    )
    ..registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(getIt<Connectivity>()),
    )
    // Firebase-backed services, or no-ops when Firebase did not start (tests,
    // builds without the config files).
    ..registerLazySingleton<AppAttestation>(
      () =>
          FirebaseSetup.ready ? FirebaseAppAttestation() : NoopAppAttestation(),
    )
    ..registerLazySingleton<AnalyticsService>(
      () => FirebaseSetup.ready ? FirebaseAnalyticsService() : NoopAnalytics(),
    )
    ..registerLazySingleton<CrashReporter>(
      () => FirebaseSetup.ready
          ? CompositeCrashReporter([
              CrashlyticsReporter(),
              FirestoreCrashReporter(
                store: FirestoreCrashReportStore(),
                device: getIt<DeviceContext>(),
              ),
            ])
          : LogCrashReporter(),
    )
    ..registerLazySingleton<SlowFrameReporter>(
      () => FirebaseSetup.ready && kReleaseMode
          ? FirestoreSlowFrameReporter(
              store: FirestoreSlowFrameReportStore(),
              device: getIt<DeviceContext>(),
            )
          : NoopSlowFrameReporter(),
    )
    ..registerLazySingleton<PushService>(
      () => FirebaseSetup.ready
          ? FcmPushService(
              LocalNotificationsService(),
              onSignedOut: () async {
                final storage = getIt<SecureStorage>();
                if (await storage.readAccessToken() == null) return;
                await storage.clearSession();
                getIt<AuthCubit>().sessionExpired(revoked: true);
              },
              onSupportReply: () => getIt<AuthCubit>().revalidate(),
              tokenSink: (token) async {
                await getIt<AuthRepository>().registerPushToken(token);
              },
            )
          : NoopPushService(),
    )
    ..registerLazySingleton<PushPermissionGate>(
      () => PushPermissionGate(getIt<PushService>(), getIt<LocalStorage>()),
    )
    ..registerLazySingleton<DeviceIntegrity>(
      () => DeviceContextIntegrity(getIt<DeviceContext>()),
    )
    ..registerLazySingleton<DeviceIntegrityCubit>(
      () => DeviceIntegrityCubit(getIt<DeviceIntegrity>()),
    )
    ..registerLazySingleton<TokenRefresher>(
      () => AuthTokenRefresher(getIt<SecureStorage>()),
    )
    ..registerLazySingleton<ApiClient>(
      () => ApiClient(
        ApiClient.createDio(
          interceptors: [LanguageInterceptor(getIt<LocalStorage>())],
        ),
      ),
      instanceName: 'publicApi',
    )
    ..registerLazySingleton<DeviceSession>(
      () => DeviceSession(
        getIt<ApiClient>(instanceName: 'publicApi'),
        getIt<SecureStorage>(),
        getIt<LocalStorage>(),
        getIt<DeviceContext>(),
      ),
    )
    ..registerLazySingleton<Dio>(
      () => ApiClient.createDio(
        interceptors: [
          AuthInterceptor(
            getIt<SecureStorage>(),
            deviceSession: _useMockApi ? null : getIt<DeviceSession>(),
            // Looked up lazily: both are registered after Dio.
            refresher: () => getIt<TokenRefresher>(),
            onUnauthorized: (failure) => getIt<AuthCubit>().sessionExpired(
              revoked:
                  failure is ApiFailure && failure.code == 'session_revoked',
            ),
          ),
          AppCheckInterceptor(getIt<AppAttestation>()),
          LanguageInterceptor(getIt<LocalStorage>()),
          if (AppEnvironment.enableLogging) ApiLogInterceptor(),
        ],
      ),
    )
    ..registerLazySingleton<ApiClient>(() => ApiClient(getIt<Dio>()));
}

void _registerGlobalCubits() {
  getIt
    ..registerLazySingleton<ThemeCubit>(ThemeCubit.new)
    ..registerLazySingleton<LocaleCubit>(
      () => LocaleCubit(getIt<LocalStorage>()),
    );
}

/// What a [PurchaseCubit] needs to know: the plan, and the eSIM it extends
/// when this is a top-up rather than a new purchase.
class PurchaseArgs {
  const PurchaseArgs(this.package, {this.esimId});

  final EsimPackage package;
  final String? esimId;
}

void _registerFeatures() {
  _registerRepositories();
  _registerSessionCubits();
  _registerScreenCubits();
}

/// Live mobile API by default; fixtures remain available through an explicit opt-in.
void _registerRepositories() {
  if (!_useMockApi) {
    getIt
      ..registerLazySingleton<AuthRepository>(
        () => ApiAuthRepository(
          getIt<ApiClient>(),
          getIt<SecureStorage>(),
          getIt<DeviceSession>(),
        ),
      )
      ..registerLazySingleton<CatalogRepository>(
        () => ApiCatalogRepository(getIt<ApiClient>(), getIt<LocalStorage>()),
      )
      ..registerLazySingleton<ApiEsimRepository>(
        () => ApiEsimRepository(getIt<ApiClient>(), getIt<LocalStorage>()),
      )
      ..registerLazySingleton<EsimRepository>(() => getIt<ApiEsimRepository>())
      ..registerLazySingleton<PurchaseRepository>(
        () => ApiPurchaseRepository(
          getIt<ApiClient>(),
          getIt<ApiEsimRepository>(),
        ),
      )
      ..registerLazySingleton<WalletRepository>(
        () => ApiWalletRepository(getIt<ApiClient>()),
      )
      ..registerLazySingleton<ReferralRepository>(
        () => ApiReferralRepository(getIt<ApiClient>()),
      )
      ..registerLazySingleton<ConfigRepository>(
        () => ApiConfigRepository(
          getIt<ApiClient>(instanceName: 'publicApi'),
          authenticated: getIt<ApiClient>(),
          secure: getIt<SecureStorage>(),
        ),
      )
      ..registerLazySingleton<SupportRepository>(
        () => ApiSupportRepository(getIt<ApiClient>()),
      )
      ..registerLazySingleton<LegalRepository>(
        () => ApiLegalRepository(getIt<ApiClient>(instanceName: 'publicApi')),
      );
    return;
  }
  getIt
    ..registerLazySingleton<MockBackend>(MockBackend.new)
    ..registerLazySingleton<AuthRepository>(
      () => MockAuthRepository(getIt<MockBackend>(), getIt<SecureStorage>()),
    )
    ..registerLazySingleton<CatalogRepository>(
      () => MockCatalogRepository(
        destinationOfEsim: getIt<MockBackend>().destinationOfEsim,
      ),
    )
    ..registerLazySingleton<EsimRepository>(
      () => MockEsimRepository(getIt<MockBackend>()),
    )
    ..registerLazySingleton<PurchaseRepository>(
      () => MockPurchaseRepository(getIt<MockBackend>()),
    )
    ..registerLazySingleton<WalletRepository>(
      () => MockWalletRepository(getIt<MockBackend>()),
    )
    ..registerLazySingleton<ReferralRepository>(
      () => MockReferralRepository(getIt<MockBackend>()),
    )
    ..registerLazySingleton<ConfigRepository>(
      () => MockConfigRepository(getIt<MockBackend>()),
    )
    ..registerLazySingleton<SupportRepository>(MockSupportRepository.new)
    ..registerLazySingleton<LegalRepository>(() => const MockLegalRepository());
}

/// Cubits that outlive any one screen: who is signed in, the balance, the
/// catalog, the customer's eSIMs, the server switches.
void _registerSessionCubits() {
  getIt
    ..registerLazySingleton<AuthCubit>(() => AuthCubit(getIt<AuthRepository>()))
    ..registerLazySingleton<WalletCubit>(
      () => WalletCubit(getIt<WalletRepository>()),
    )
    ..registerLazySingleton<ConfigCubit>(
      () => ConfigCubit(getIt<ConfigRepository>()),
    )
    ..registerLazySingleton<CatalogCubit>(
      () => CatalogCubit(
        getIt<CatalogRepository>(),
        cacheKey: _useMockApi ? 'CatalogCubit' : 'ApiCatalogV1',
      ),
    )
    ..registerLazySingleton<EsimListCubit>(
      () => EsimListCubit(getIt<EsimRepository>()),
    )
    ..registerLazySingleton<NotificationPrefsCubit>(
      () => NotificationPrefsCubit(
        save: _useMockApi
            ? null
            : (esim, marketing) => getIt<AuthRepository>().updatePreferences(
                esim: esim,
                marketing: marketing,
              ),
      ),
    )
    ..registerLazySingleton<EsimCompatibility>(DeviceEsimCompatibility.new)
    ..registerLazySingleton<EsimSupportCubit>(
      () => EsimSupportCubit(getIt<EsimCompatibility>()),
    )
    ..registerLazySingleton<TelemetryCoordinator>(
      () => TelemetryCoordinator(
        auth: getIt<AuthCubit>(),
        locale: getIt<LocaleCubit>(),
        theme: getIt<ThemeCubit>(),
        notifications: getIt<NotificationPrefsCubit>(),
        analytics: getIt<AnalyticsService>(),
        crashes: getIt<CrashReporter>(),
        slowFrames: getIt<SlowFrameReporter>(),
        push: getIt<PushService>(),
        preferences: _useMockApi ? null : getIt<AuthRepository>(),
        catalog: getIt<CatalogCubit>(),
        config: getIt<ConfigCubit>(),
      ),
    )
    ..registerLazySingleton<SessionCoordinator>(
      () => SessionCoordinator(
        auth: getIt<AuthCubit>(),
        wallet: getIt<WalletCubit>(),
        esims: getIt<EsimListCubit>(),
      ),
    );
}

/// One per screen: they die with the page.
void _registerScreenCubits() {
  getIt
    ..registerFactory<SearchCubit>(
      () => SearchCubit(
        getIt<LocalStorage>(),
        remoteSearch: _useMockApi ? null : getIt<CatalogRepository>().search,
        onResults: getIt<CatalogCubit>().mergeSearchResults,
      ),
    )
    ..registerFactory<LoginCubit>(
      () => LoginCubit(
        getIt<AuthRepository>(),
        getIt<AuthCubit>(),
        getIt<AnalyticsService>(),
      ),
    )
    ..registerFactory<ChatCubit>(
      () => ChatCubit(
        getIt<SupportRepository>(),
        onRead: getIt<AuthCubit>().clearSupportUnread,
      ),
    )
    ..registerFactoryParam<PurchaseCubit, PurchaseArgs, void>(
      (args, _) => PurchaseCubit(
        repository: getIt<PurchaseRepository>(),
        wallet: getIt<WalletCubit>(),
        esims: getIt<EsimListCubit>(),
        pushGate: getIt<PushPermissionGate>(),
        analytics: getIt<AnalyticsService>(),
        package: args.package,
        esimId: args.esimId,
      ),
    )
    ..registerFactoryParam<TopUpCubit, int?, void>(
      (initialCents, _) => TopUpCubit(
        repository: getIt<WalletRepository>(),
        wallet: getIt<WalletCubit>(),
        analytics: getIt<AnalyticsService>(),
        initialAmount: initialCents == null ? null : Money(initialCents),
      ),
    )
    ..registerFactoryParam<AsyncCubit<List<EsimPackage>>, String, void>(
      (code, _) => AsyncCubit(() => getIt<CatalogRepository>().packages(code)),
      instanceName: 'packages',
    )
    ..registerFactoryParam<AsyncCubit<List<EsimPackage>>, String, void>(
      (esimId, _) =>
          AsyncCubit(() => getIt<CatalogRepository>().topUpPackages(esimId)),
      instanceName: 'topUpPackages',
    )
    ..registerFactoryParam<AsyncCubit<List<WalletOrder>>, OrderType, void>(
      (type, _) => AsyncCubit(() => getIt<WalletRepository>().orders(type)),
    )
    ..registerFactory<AsyncCubit<ReferralInfo>>(
      () => AsyncCubit(getIt<ReferralRepository>().load),
    )
    ..registerFactory<AsyncCubit<List<DeviceInfo>>>(
      () => AsyncCubit(getIt<AuthRepository>().devices),
    )
    ..registerFactoryParam<AsyncCubit<List<LegalDocument>>, String, void>(
      (language, _) =>
          AsyncCubit(() => getIt<LegalRepository>().documents(language)),
    );
}
