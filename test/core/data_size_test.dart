import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/core/utils/formatters/data_size.dart';

void main() {
  const gb = 1024 * 1024 * 1024;

  test('whole gigabytes have no decimal', () {
    expect(DataSize.of(5 * gb), (value: '5', inGigabytes: true));
    expect(DataSize.of(50 * gb), (value: '50', inGigabytes: true));
  });

  test('fractional gigabytes keep one decimal under 10 GB', () {
    expect(DataSize.of((3.2 * gb).round()), (value: '3.2', inGigabytes: true));
  });

  test('below one gigabyte reports megabytes', () {
    expect(DataSize.of(850 * 1024 * 1024), (value: '850', inGigabytes: false));
    expect(DataSize.of(100 * 1024 * 1024), (value: '100', inGigabytes: false));
  });
}
