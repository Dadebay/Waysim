/// Low-level errors thrown by data sources. They never leave the data layer —
/// repositories map them to a [Failure].
///
/// [code] is the backend's stable machine-readable `code` (`otp-invalid`,
/// `price-changed`, …) when the response carried one. Branch on it,
/// never on [message].
sealed class AppException implements Exception {
  const AppException(this.message, {this.statusCode, this.code, this.details});

  final String message;
  final int? statusCode;

  /// Backend `code`, or null when the response did not carry one.
  final String? code;

  /// Backend `details` — structured extra data (e.g. the new price on a 409).
  final Map<String, dynamic>? details;

  @override
  String toString() => '$runtimeType($statusCode/$code): $message';
}

class ServerException extends AppException {
  const ServerException(
    super.message, {
    super.statusCode,
    super.code,
    super.details,
  });
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

class TimeoutException extends AppException {
  const TimeoutException([super.message = 'Request timed out']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Unauthorized', String? apiCode])
    : super(statusCode: 401, code: apiCode);
}

/// 403 — today always `user-blocked`, which can also hit a live session.
class ForbiddenException extends AppException {
  const ForbiddenException(super.message, {super.code, super.details})
    : super(statusCode: 403);
}

class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.code, super.details})
    : super(statusCode: 404);
}

/// 400 with an `errors: string[]` array, one entry per invalid field.
class ValidationException extends AppException {
  const ValidationException(
    super.message, {
    this.errors = const [],
    super.code,
    super.details,
  }) : super(statusCode: 400);

  final List<String> errors;
}

/// 409 — `price-changed`, package unavailable, duplicate transaction.
/// Nothing was created.
class ConflictException extends AppException {
  const ConflictException(super.message, {super.code, super.details})
    : super(statusCode: 409);
}

/// 429 `too-many-requests` — rate limit on login, OTP, orders, top-ups, chat.
class RateLimitException extends AppException {
  const RateLimitException(super.message, {super.code, super.details})
    : super(statusCode: 429);
}

/// 503 — the supplier did not answer or maintenance mode is on. Not "out of
/// stock": keep the screen and offer a retry.
class ServiceUnavailableException extends AppException {
  const ServiceUnavailableException(super.message, {super.code, super.details})
    : super(statusCode: 503);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Cache error']);
}

class ParsingException extends AppException {
  const ParsingException([super.message = 'Failed to parse response']);
}
