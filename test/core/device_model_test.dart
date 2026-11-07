import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/core/utils/formatters/device_model.dart';

void main() {
  test('legacy device codes display marketing names', () {
    expect(deviceModelName('iPhone11,6'), 'iPhone XS Max');
    expect(deviceModelName('iPhone11,4'), 'iPhone XS Max');
    expect(deviceModelName('samsung SM-A346E'), 'Galaxy A34');
    expect(deviceModelName(' Samsung SM-A346E/DSN '), 'Galaxy A34');
    expect(deviceModelName('SM-A346B'), 'Galaxy A34');
  });

  test('friendly and unknown names are preserved without guessing', () {
    for (final model in [
      'iPhone XS Max',
      'Galaxy A34',
      'SM-A345E',
      'Pixel 8',
    ]) {
      expect(deviceModelName(model), model);
    }
  });
}
