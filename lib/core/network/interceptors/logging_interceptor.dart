import 'package:flutter/foundation.dart';
import '../network_exception.dart';
import '../network_request.dart';
import '../network_response.dart';
import 'network_interceptor.dart';

/// Pluggable interceptor for logging HTTP request/response metrics and errors.
class LoggingInterceptor extends NetworkInterceptor {
  final void Function(String message)? logger;
  final bool enabled;

  const LoggingInterceptor({
    this.logger,
    this.enabled = kDebugMode,
  });

  void _log(String msg) {
    if (!enabled) return;
    if (logger != null) {
      logger!(msg);
    } else {
      debugPrint('[Network] $msg');
    }
  }

  @override
  NetworkRequest onRequest(NetworkRequest request) {
    _log('--> ${request.method.value} ${request.path} (params: ${request.queryParameters})');
    return request;
  }

  @override
  NetworkResponse<dynamic> onResponse(
    NetworkRequest request,
    NetworkResponse<dynamic> response,
  ) {
    _log('<-- ${response.statusCode} ${request.method.value} ${request.path}');
    return response;
  }

  @override
  void onError(NetworkRequest request, NetworkException error) {
    _log('ERR [${request.method.value} ${request.path}]: $error');
  }
}
