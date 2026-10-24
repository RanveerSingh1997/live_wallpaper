import 'dart:async';
import '../network_exception.dart';
import '../network_request.dart';
import '../network_response.dart';

/// Extensible contract for intercepting network requests, responses, and errors.
/// Follows the Open/Closed Principle (OCP) enabling features like auth injection,
/// request logging, retry strategies, and caching without altering transport code.
abstract class NetworkInterceptor {
  const NetworkInterceptor();

  /// Invoked before an HTTP request is transmitted over the wire.
  /// Can mutate the [request] (e.g. inject headers, attach query params).
  FutureOr<NetworkRequest> onRequest(NetworkRequest request) => request;

  /// Invoked immediately after receiving a network response.
  /// Can transform, decrypt, or log the [response].
  FutureOr<NetworkResponse<dynamic>> onResponse(
    NetworkRequest request,
    NetworkResponse<dynamic> response,
  ) =>
      response;

  /// Invoked whenever a [NetworkException] occurs in the network pipeline.
  /// Can log telemetry, perform alert tracking, or trigger recovery procedures.
  FutureOr<void> onError(
    NetworkRequest request,
    NetworkException error,
  ) {}
}
