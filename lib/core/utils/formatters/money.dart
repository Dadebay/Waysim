import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class Money extends Equatable implements Comparable<Money> {
  const Money(this.cents);

  const Money.zero() : cents = 0;

  factory Money.fromCents(num cents) => Money(cents.round());

  final int cents;

  Money operator +(Money other) => Money(cents + other.cents);
  Money operator -(Money other) => Money(cents - other.cents);
  Money operator -() => Money(-cents);

  bool get isNegative => cents < 0;
  bool get isZero => cents == 0;

  bool operator <(Money other) => cents < other.cents;
  bool operator <=(Money other) => cents <= other.cents;
  bool operator >(Money other) => cents > other.cents;
  bool operator >=(Money other) => cents >= other.cents;

  @override
  int compareTo(Money other) => cents.compareTo(other.cents);

  String format({bool withCents = true}) {
    final abs = cents.abs();
    final dollars = abs ~/ 100;
    final rest = abs % 100;
    final grouped = NumberFormat.decimalPattern('en_US').format(dollars);
    final sign = cents < 0 ? '-' : '';
    if (!withCents && rest == 0) return '$sign\$$grouped';
    return '$sign\$$grouped.${rest.toString().padLeft(2, '0')}';
  }

  @override
  String toString() => format();

  @override
  List<Object?> get props => [cents];
}
