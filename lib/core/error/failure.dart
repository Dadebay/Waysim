import 'package:equatable/equatable.dart';

import 'exceptions.dart';

/// Domain-level error. Everything above the data layer speaks in [Failure]s.
///
/// [code] is a stable key the presentation layer maps to a localized string,
/// so error text never has to be hard-coded in a bloc. For failures that came
/// off the wire it is the backend's own `code` when there was one
/// (`otp_invalid`, `price_mismatch`, …).
sealed class Failure extends Equatable {
  const Failure({
    required this.code,
    this.message,
    this.statusCode,
    this.details,
  });

  final String code;
  final String? message;
  final int? statusCode;

  /// Structured extra data — on `price_mismatch` this carries the new price.
  final Map<String, dynamic>? details;

  @override
  List<Object?> get props => [code, message, statusCode, details];
}

class ServerFailure extends Failure {
  const ServerFailure({super.message, super.statusCode})
    : super(code: 'server_error');
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message}) : super(code: 'network_error');
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({super.message}) : super(code: 'timeout_error');
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message})
    : super(code: 'unauthorized_error', statusCode: 401);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message}) : super(code: 'not_found_error');
}

class CacheFailure extends Failure {
  const CacheFailure({super.message}) : super(code: 'cache_error');
}

class UnknownFailure extends Failure {
  const UnknownFailure({super.message}) : super(code: 'unknown_error');
}

/// A documented backend error: [code] is the API's own code, so a bloc can
/// switch on [ApiCodes] and the widget can map it to its own copy.
class ApiFailure extends Failure {
  const ApiFailure({
    required super.code,
    super.message,
    super.statusCode,
    super.details,
    this.errors = const [],
  });

  /// Only on 400 validation failures: one entry per invalid field.
  final List<String> errors;

  @override
  List<Object?> get props => [...super.props, errors];
}

/// Error codes the app branches on.
///
/// Codes from docs/api/client-api.md; retain them through the data layer.
abstract final class ApiCodes {
  static const otpInvalid = 'otp_invalid';
  static const otpExpired = 'otp_expired';
  static const otpRateLimited = 'otp_cooldown';
  static const otpTooManyAttempts = 'otp_too_many_attempts';
  static const userBlocked = 'user_banned';
  static const insufficientBalance = 'insufficient_balance';
  static const priceChanged = 'price_mismatch';
  static const packageUnavailable = 'package_unavailable';
  static const maintenance = 'maintenance';
  static const countryRestricted = 'country_restricted';
  static const referralDisabled = 'referral_disabled';
  static const tooManyRequests = 'rate_limited';
}

extension AppExceptionToFailure on AppException {
  /// Single place where data-layer exceptions become domain failures.
  ///
  /// A response that carried a backend `code` keeps it, so the presentation
  /// layer never has to read `message` to know what happened.
  Failure toFailure() {
    final backendCode = code;
    if (backendCode != null) {
      return ApiFailure(
        code: backendCode,
        message: message,
        statusCode: statusCode,
        details: details,
        errors: switch (this) {
          ValidationException(:final errors) => errors,
          _ => const [],
        },
      );
    }

    return switch (this) {
      NetworkException() => NetworkFailure(message: message),
      TimeoutException() => TimeoutFailure(message: message),
      UnauthorizedException() => UnauthorizedFailure(message: message),
      ForbiddenException() => UnauthorizedFailure(message: message),
      NotFoundException() => NotFoundFailure(message: message),
      CacheException() => CacheFailure(message: message),
      ParsingException() => UnknownFailure(message: message),
      ValidationException(:final errors) => ApiFailure(
        code: 'validation_error',
        message: message,
        statusCode: 400,
        errors: errors,
      ),
      ConflictException() => ApiFailure(
        code: 'conflict',
        message: message,
        statusCode: 409,
        details: details,
      ),
      RateLimitException() => ApiFailure(
        code: ApiCodes.tooManyRequests,
        message: message,
        statusCode: 429,
      ),
      ServiceUnavailableException() => ApiFailure(
        code: 'service_unavailable',
        message: message,
        statusCode: 503,
      ),
      ServerException() => ServerFailure(
        message: message,
        statusCode: statusCode,
      ),
    };
  }
}
