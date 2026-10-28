import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/core/services/esim_compatibility.dart';
import 'package:waysim/core/services/esim_support_cubit.dart';

import '../helpers/test_dependencies.dart';

void main() {
  final compatibility = DeviceEsimCompatibility();

  test('iPhone Air is eSIM only, so its hardware support is certain', () {
    expect(compatibility.iosSupport('iPhone18,4'), EsimSupport.yes);
  });

  test('iPhone XS/XR and later stay unverified across regional variants', () {
    expect(compatibility.iosSupport('iPhone17,3'), EsimSupport.likely);
    expect(compatibility.iosSupport('iPhone11,8'), EsimSupport.likely);
    expect(compatibility.iosSupport('iPhone11,6'), EsimSupport.likely);
  });

  test('older iPhones are known not to support eSIM', () {
    expect(compatibility.iosSupport('iPhone10,6'), EsimSupport.no);
  });

  test('other devices need a separate capability check', () {
    expect(compatibility.iosSupport('iPad16,1'), EsimSupport.unknown);
    expect(compatibility.iosSupport('x86_64'), EsimSupport.unknown);
  });

  test('old manual answers cannot override a fresh device result', () async {
    final device = FakeCompatibility(support: EsimSupport.likely);
    final cubit = EsimSupportCubit(device);
    await cubit.check();
    expect(cubit.state, EsimSupport.likely);

    device.support = EsimSupport.no;
    await cubit.check();
    expect(cubit.state, EsimSupport.no);
    await cubit.close();
  });
}
