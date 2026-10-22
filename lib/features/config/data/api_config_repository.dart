import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/network/api_helpers.dart';
import '../../../core/network/api_response.dart';
import '../../../core/utils/result.dart';
import '../domain/entities/app_config.dart';
import '../domain/repositories/config_repository.dart';

class ApiConfigRepository implements ConfigRepository {
  ApiConfigRepository(this.api, {this.authenticated, this.secure});
  final ApiClient? authenticated;
  final SecureStorage? secure;
  final ApiClient api;
  @override
  Future<Result<AppConfig>> load() => apiResult(() async {
    final j = asMap(await api.get('/v1/meta'));
    var referral = <String, dynamic>{};
    var wallet = <String, dynamic>{};
    if (await secure?.readAccessToken() != null && authenticated != null) {
      final results = await Future.wait([
        apiResult(() => authenticated!.get('/v1/referral')),
        apiResult(() => authenticated!.get('/v1/wallet')),
      ]);
      if (results[0].dataOrNull is Map<String, dynamic>) {
        referral = asMap(results[0].dataOrNull);
      }
      if (results[1].dataOrNull is Map<String, dynamic>) {
        wallet = asMap(results[1].dataOrNull);
      }
    }
    final limits = wallet.mapOrNull('limits') ?? {};
    final serverLocales = (j['supportedLocales'] as List? ?? const [])
        .whereType<String>()
        .where((code) => const {'en', 'zh', 'ru', 'es', 'fr'}.contains(code))
        .toSet()
        .toList();
    return AppConfig(
      referralEnabled: referral.boolVal('enabled'),
      referralRewardCents: referral.intVal('bonusCents'),
      minTopUpCents: limits.intVal('minCents', 500),
      maxTopUpCents: limits.intVal('maxCents', 50000),
      maintenance: j.boolVal('maintenance'),
      minSupportedVersion: j.strOrNull('minAppVersion'),
      supportEmail: j.str('supportEmail', 'support@waysim.co'),
      supportedLocales: serverLocales.isEmpty
          ? const ['en', 'zh', 'ru', 'es', 'fr']
          : serverLocales,
      defaultLocale: j.str('defaultLocale', 'en'),
      paypalEnabled: false,
      cryptoEnabled: true,
    );
  });
}
