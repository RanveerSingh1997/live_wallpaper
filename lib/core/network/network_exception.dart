/// Base exception class for all networking and transport layer failures.
sealed class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  final Object? cause;

  const NetworkException(this.message, {this.statusCode, this.cause});

  @override
  String toString() => 'NetworkException: $message (statusCode: $statusCode)';
}

/// Thrown when connection cannot be established or host is unreachable.
class ConnectionNetworkException extends NetworkException {
  const ConnectionNetworkException(super.message, {super.cause});
}

/// Thrown when an HTTP request exceeds configured timeout threshold.
class TimeoutNetworkException extends NetworkException {
  const TimeoutNetworkException(super.message, {super.cause});
}

/// Thrown on 5xx Internal Server Errors.
class ServerNetworkException extends NetworkException {
  const ServerNetworkException(super.message, {super.statusCode, super.cause});
}

/// Thrown on 4xx Client Errors (Bad Request, Unauthorized, Forbidden, Not Found).
class ClientNetworkException extends NetworkException {
  const ClientNetworkException(super.message, {super.statusCode, super.cause});
}

/// Thrown when response body cannot be decoded or parsed as JSON.
class FormatNetworkException extends NetworkException {
  const FormatNetworkException(super.message, {super.cause});
}
