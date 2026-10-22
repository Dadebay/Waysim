import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/core/network/interceptors/api_log_interceptor.dart';
import 'package:waysim/features/catalog/domain/entities/esim_package.dart';
import 'package:waysim/features/esim/domain/entities/esim.dart';

void main() {
  test('eSIM debug output never includes installation credentials', () {
    const esim = Esim(
      id: 'esim-1',
      destinationCode: 'AE',
      destinationNames: {'en': 'United Arab Emirates'},
      kind: PackageKind.limited,
      days: 7,
      status: EsimStatus.notInstalled,
      smdpAddress: 'private.smdp.example',
      activationCode: 'private-activation-code',
      iccid: 'private-iccid',
      lpaString: 'private-lpa',
      appleUniversalLink: 'https://example.com/?carddata=private-carddata',
    );

    final output = esim.toString();
    expect(output, contains('EsimStatus.notInstalled'));
    for (final secret in [
      esim.smdpAddress,
      esim.activationCode,
      esim.iccid,
      esim.lpaString!,
      esim.appleUniversalLink!,
    ]) {
      expect(output, isNot(contains(secret)));
    }
  });

  test('API response log redacts one-tap eSIM installation URL', () {
    final output = <String>[];
    runZoned(
      () => ApiLogInterceptor().onResponse(
        Response<dynamic>(
          requestOptions: RequestOptions(
            baseUrl: 'https://api.waysim.co',
            path: '/v1/esims/esim-1',
          ),
          statusCode: 200,
          data: {
            'install': {
              'appleUniversalLink':
                  'https://example.com/?carddata=private-carddata',
              'activationCode': 'private-activation-code',
            },
          },
        ),
        ResponseInterceptorHandler(),
      ),
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) => output.add(line),
      ),
    );

    final log = output.join('\n');
    expect(log, contains('appleUniversalLink'));
    expect(log, isNot(contains('private-carddata')));
    expect(log, isNot(contains('private-activation-code')));
  });
}
