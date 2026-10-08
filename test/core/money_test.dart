import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/core/utils/formatters/money.dart';

void main() {
  group('Money.format', () {
    test('always shows two decimals with a dot', () {
      expect(const Money(599).format(), r'$5.99');
      expect(const Money(2450).format(), r'$24.50');
      expect(const Money(5).format(), r'$0.05');
      expect(const Money.zero().format(), r'$0.00');
    });

    test('groups thousands and keeps the sign', () {
      expect(const Money(123456789).format(), r'$1,234,567.89');
      expect(const Money(-300).format(), r'-$3.00');
    });

    test('drops cents of whole dollars only when asked', () {
      expect(const Money(2000).format(withCents: false), r'$20');
      expect(const Money(2050).format(withCents: false), r'$20.50');
    });
  });

  group('Money arithmetic', () {
    test('adds and subtracts in cents without rounding drift', () {
      expect(const Money(2450) - const Money(599), const Money(1851));
      expect(const Money(10) + const Money(20), const Money(30));
    });

    test('compares', () {
      expect(const Money(100) < const Money(101), isTrue);
      expect(const Money(100) >= const Money(100), isTrue);
      expect(const Money(-1).isNegative, isTrue);
    });
  });
}
