sealed class AppException implements Exception {
  const AppException(this.message, {this.statusCode, this.code, this.details});

  final String message;
  final int? statusCode;

  final String? code;

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

class ForbiddenException extends AppException {
  const ForbiddenException(super.message, {super.code, super.details})
    : super(statusCode: 403);
}

class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.code, super.details})
    : super(statusCode: 404);
}

class ValidationException extends AppException {
  const ValidationException(
    super.message, {
    this.errors = const [],
    super.code,
    super.details,
  }) : super(statusCode: 400);

  final List<String> errors;
}

class ConflictException extends AppException {
  const ConflictException(super.message, {super.code, super.details})
    : super(statusCode: 409);
}

class RateLimitException extends AppException {
  const RateLimitException(super.message, {super.code, super.details})
    : super(statusCode: 429);
}

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
