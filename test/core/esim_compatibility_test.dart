import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/core/services/esim_compatibility.dart';

void main() {
  final compatibility = DeviceEsimCompatibility();

  test('iPhone XS/XR and later support eSIM', () {
    expect(compatibility.iosSupport('iPhone17,3'), EsimSupport.yes);
    expect(compatibility.iosSupport('iPhone11,8'), EsimSupport.yes);
    expect(compatibility.iosSupport('iPhone11,6'), EsimSupport.yes);
  });

  test('older iPhones are known not to support eSIM', () {
    expect(compatibility.iosSupport('iPhone10,6'), EsimSupport.no);
  });

  test('other devices need a separate capability check', () {
    expect(compatibility.iosSupport('iPad16,1'), EsimSupport.unknown);
    expect(compatibility.iosSupport('x86_64'), EsimSupport.unknown);
  });
}
