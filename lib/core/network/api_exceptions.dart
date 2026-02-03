/// Base exception for API errors.
abstract class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic body;

  const ApiException(this.message, {this.statusCode, this.body});

  @override
  String toString() => 'ApiException: $message${statusCode != null ? ' (status: $statusCode)' : ''}';
}

/// Thrown when the request is invalid (400).
class BadRequestException extends ApiException {
  const BadRequestException(super.message, {super.statusCode, super.body});
}

/// Thrown when authentication is required or credentials are invalid (401).
class UnauthorizedException extends ApiException {
  const UnauthorizedException(super.message, {super.statusCode, super.body});
}

/// Thrown when the user is not allowed to perform the action (403).
class ForbiddenException extends ApiException {
  const ForbiddenException(super.message, {super.statusCode, super.body});
}

/// Thrown when a resource is not found (404).
class NotFoundException extends ApiException {
  const NotFoundException(super.message, {super.statusCode, super.body});
}

/// Thrown when the server returns 5xx or request times out.
class ServerException extends ApiException {
  const ServerException(super.message, {super.statusCode, super.body});
}

/// Thrown when no network connection or DNS/connection failure.
class NetworkException extends ApiException {
  const NetworkException(super.message, {super.statusCode, super.body});
}
