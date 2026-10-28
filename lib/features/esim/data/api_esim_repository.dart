import '../../../core/error/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_helpers.dart';
import '../../../core/network/api_response.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../core/utils/result.dart';
import '../../catalog/domain/entities/esim_package.dart';
import '../domain/entities/esim.dart';
import '../domain/repositories/esim_repository.dart';

class ApiEsimRepository implements EsimRepository {
  ApiEsimRepository(this.api, this.local);
  final ApiClient api;
  final LocalStorage local;
  final _packages = <String, Future<Map<String, dynamic>>>{};

  Future<Esim> decode(Map<String, dynamic> j) async {
    final package = j.mapOrNull('package') ?? {};
    final language = local.getString(StorageKeys.contentLanguage) ?? 'en';
    final packageId = package.str('id', package.str('slug'));
    var details = <String, dynamic>{};
    if (packageId.isNotEmpty) {
      final key = '$language:$packageId';
      try {
        details = await (_packages[key] ??= api
            .get('/v1/catalog/packages/${Uri.encodeComponent(packageId)}')
            .then(asMap));
      } on AppException {
        final failed = _packages.remove(key);
        if (failed != null) {
          try {
            await failed;
            // ignore: empty_catches
          } on Object {}
        }
      }
    }
    final usage = j.mapOrNull('usage') ?? {};
    final install = j.mapOrNull('install') ?? {};
    final topup = j.mapOrNull('topup') ?? {};
    final direction = details.mapOrNull('direction') ?? {};
    final total = usage.intOrNull('totalBytes');
    final region = package.str('directionKind') == 'region';
    final name = direction.str('name', j.str('title'));
    return Esim(
      id: j.str('id'),
      destinationCode: package.str('locationCode'),
      destinationNames: {language: name, 'en': name},
      kind: total == null ? PackageKind.unlimited : PackageKind.limited,
      days: details.intVal('days', j.intVal('daysLeft')),
      volumeBytes: total,
      countryCount: region ? details.intVal('coverageCount') : null,
      usedBytes: usage.intVal('usedBytes'),
      status: switch (j.str('status')) {
        'not_installed' => EsimStatus.notInstalled,
        'installed' => EsimStatus.installed,
        'active' => EsimStatus.active,
        'used_up' => EsimStatus.usedUp,
        'expired' => EsimStatus.expired,
        'suspended' => EsimStatus.suspended,
        'cancelled' => EsimStatus.cancelled,
        'revoked' => EsimStatus.revoked,
        'failed' => EsimStatus.failed,
        _ => EsimStatus.provisioning,
      },

      smdpAddress: install.str('smdpAddress').trim(),
      activationCode: install.str('activationCode').trim(),
      iccid: install.str('iccid'),
      lpaString: install.strOrNull('lpaString')?.trim(),
      appleUniversalLink: install.strOrNull('appleUniversalLink'),
      expiresAt: j.dateOrNull('expiresAt'),
      installBy: j.dateOrNull('installBefore'),
      updatedAt: usage.dateOrNull('updatedAt') ?? j.dateOrNull('lastSyncedAt'),
      deviceName: j.strOrNull('deviceLabel'),
      topUpSupported: topup.boolVal('allowed'),
    );
  }

  @override
  Future<Result<List<Esim>>> list() => apiResult(() async {
    final pages = await Future.wait([
      apiPages(api, '/v1/esims', query: {'tab': 'current'}),
      apiPages(api, '/v1/esims', query: {'tab': 'archive'}),
    ]);
    final cards = {
      for (final j in pages.expand((x) => x)) j.str('id'): j,
    }.values.toList();
    final result = <Esim>[];
    for (var i = 0; i < cards.length; i += 4) {
      result.addAll(await Future.wait(cards.skip(i).take(4).map(decode)));
    }
    return result;
  });
  @override
  Future<Result<Esim>> get(String id) => apiResult(
    () async =>
        decode(asMap(await api.get('/v1/esims/${Uri.encodeComponent(id)}'))),
  );
  @override
  Future<Result<Esim>> refresh(String id) => apiResult(
    () async => decode(
      asMap(await api.post('/v1/esims/${Uri.encodeComponent(id)}/refresh')),
    ),
  );
  @override
  Future<Result<Esim>> bindToDevice(String id, {required String deviceName}) =>
      get(id);
}
