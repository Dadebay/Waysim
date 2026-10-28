import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/app/router/app_router.dart';
import 'package:waysim/core/constants/app_environment.dart';
import 'package:waysim/core/network/interceptors/auth_interceptor.dart';
import 'package:waysim/core/services/crash_report.dart';
import 'package:waysim/core/services/device_integrity.dart';
import 'package:waysim/core/utils/safe_url.dart';
import 'package:waysim/core/utils/scrub.dart';
import 'package:waysim/features/auth/data/auth_token_refresher.dart';
import 'package:waysim/features/esim/domain/entities/esim.dart';
import 'package:waysim/features/catalog/domain/entities/esim_package.dart';

import '../helpers/test_dependencies.dart';

class _Capture implements HttpClientAdapter {
  final headers = <Map<String, dynamic>>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    headers.add(Map.of(options.headers));
    return ResponseBody.fromString('{}', 200);
  }

  @override
  void close({bool force = false}) {}
}

class _NeverRefresh extends AuthTokenRefresher {
  _NeverRefresh(super.storage);
}

DeviceContext _device({bool rooted = false, String platform = 'android'}) =>
    DeviceContext(
      platform: platform,
      osVersion: '14',
      model: 'Pixel',
      appVersion: '1.0.0',
      buildNumber: '1',
      locale: 'en',
      flavor: 'dev',
      isRooted: rooted,
    );

void main() {
  group('safeHttpsUri', () {
    test('accepts plain https links only', () {
      expect(safeHttpsUri('https://waysim.co/app'), isNotNull);
      expect(safeHttpsUri('http://waysim.co/app'), isNull);
      expect(safeHttpsUri('javascript:alert(1)'), isNull);
      expect(safeHttpsUri('intent://scan#Intent;scheme=zxing;end'), isNull);
      expect(safeHttpsUri('file:///etc/passwd'), isNull);
      expect(safeHttpsUri('https://user:pass@waysim.co/'), isNull);
      expect(safeHttpsUri('https:///no-host'), isNull);
      expect(safeHttpsUri(''), isNull);
      expect(safeHttpsUri(null), isNull);
    });

    test('safeHttpsUriOn pins the host', () {
      const link = 'https://esimsetup.apple.com/esim_qrcode_provisioning';
      expect(safeHttpsUriOn(link, 'esimsetup.apple.com'), isNotNull);
      expect(
        safeHttpsUriOn('https://evil.test/', 'esimsetup.apple.com'),
        isNull,
      );
      expect(
        safeHttpsUriOn(
          'https://esimsetup.apple.com.evil.test/',
          'esimsetup.apple.com',
        ),
        isNull,
      );
    });
  });

  test('a foreign universal link never reaches the installer', () {
    const esim = Esim(
      id: 'e1',
      destinationCode: 'AE',
      destinationNames: {'en': 'UAE'},
      kind: PackageKind.limited,
      days: 7,
      status: EsimStatus.notInstalled,
      smdpAddress: 'smdp.test',
      activationCode: 'code',
      iccid: '1',
      appleUniversalLink: 'https://evil.test/?carddata=x',
    );
    expect(esim.appleInstallUri.host, 'esimsetup.apple.com');
  });

  test('the one-tap link is Apple’s plain carddata form', () {
    const esim = Esim(
      id: 'e1',
      destinationCode: 'AE',
      destinationNames: {'en': 'UAE'},
      kind: PackageKind.limited,
      days: 7,
      status: EsimStatus.notInstalled,
      smdpAddress: 'rsp-eu.redteamobile.com',
      activationCode: '43DE23C67EE747BCAD6B63E8B67B261F',
      iccid: '1',
      appleUniversalLink:
          'https://esimsetup.apple.com/esim_qrcode_provisioning'
          '?carddata=LPA%3A1%24other%24code',
    );
    expect(
      esim.appleInstallUri.toString(),
      'https://esimsetup.apple.com/esim_qrcode_provisioning'
      '?carddata=LPA:1\$rsp-eu.redteamobile.com'
      '\$43DE23C67EE747BCAD6B63E8B67B261F',
    );
  });

  group('scrubSensitive', () {
    test('removes e-mail, tokens and install strings', () {
      final text = scrubSensitive(
        'DioException anna@example.com Bearer abc.def-123 '
        'eyJhbGciOi.eyJzdWIiOi.sig LPA:1\$smdp.test\$secret '
        'https://x.test/p?carddata=private&code=123456&ok=1',
      );
      expect(text, isNot(contains('anna@example.com')));
      expect(text, isNot(contains('abc.def-123')));
      expect(text, isNot(contains('eyJhbGciOi')));
      expect(text, isNot(contains('secret')));
      expect(text, isNot(contains('private')));
      expect(text, isNot(contains('123456')));
      expect(text, contains('ok=1'));
    });

    test('leaves ordinary errors readable', () {
      const error =
          'Bad state: No element at Foo.bar (package:waysim/x.dart:1)';
      expect(scrubSensitive(error), error);
    });
  });

  group('AuthInterceptor', () {
    Dio dio(_Capture adapter, MemorySecureStorage storage) {
      final d = Dio(BaseOptions(baseUrl: 'https://api.test'))
        ..httpClientAdapter = adapter;
      d.interceptors.add(
        AuthInterceptor(storage, refresher: () => _NeverRefresh(storage)),
      );
      return d;
    }

    test('sends the token to the API host', () async {
      final storage = MemorySecureStorage();
      await storage.saveTokens(accessToken: 'secret', refreshToken: 'r');
      final adapter = _Capture();
      await dio(adapter, storage).get<dynamic>('/v1/me');
      expect(adapter.headers.single['Authorization'], 'Bearer secret');
    });

    test('never sends the token to another host', () async {
      final storage = MemorySecureStorage();
      await storage.saveTokens(accessToken: 'secret', refreshToken: 'r');
      final adapter = _Capture();
      await dio(adapter, storage).get<dynamic>('https://evil.test/collect');
      expect(adapter.headers.single.containsKey('Authorization'), isFalse);
    });
  });

  group('DeviceContextIntegrity', () {
    test('flags a rooted phone, trusts a normal one', () async {
      expect(
        await DeviceContextIntegrity(_device(rooted: true)).check(),
        IntegrityStatus.compromised,
      );
      expect(
        await DeviceContextIntegrity(_device()).check(),
        IntegrityStatus.ok,
      );
      expect(
        await const DeviceContextIntegrity(DeviceContext.unknown).check(),
        IntegrityStatus.unknown,
      );
    });
  });

  test('the debug build keeps the mock switch and the gallery route', () {
    expect(AppEnvironment.apiBaseUrl, startsWith('https://'));
    expect(AppEnvironment.ensureSecureApiBaseUrl, returnsNormally);
    expect(AppRouter.create, returnsNormally);
  });
}
