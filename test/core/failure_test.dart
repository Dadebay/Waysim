import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/core/error/exceptions.dart';
import 'package:waysim/core/error/failure.dart';

void main() {
  test('a backend code survives the trip to a Failure', () {
    const exception = ConflictException(
      'changed',
      code: ApiCodes.priceChanged,
      details: {'newPriceCents': 699},
    );

    final failure = exception.toFailure();

    expect(failure, isA<ApiFailure>());
    expect(failure.code, ApiCodes.priceChanged);
    expect(failure.details, {'newPriceCents': 699});
  });

  test('transport errors map to typed failures', () {
    expect(const NetworkException().toFailure(), isA<NetworkFailure>());
    expect(const TimeoutException().toFailure(), isA<TimeoutFailure>());
    expect(
      const UnauthorizedException().toFailure(),
      isA<UnauthorizedFailure>(),
    );
  });
}
