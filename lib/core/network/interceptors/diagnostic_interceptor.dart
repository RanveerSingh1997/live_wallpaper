import '../../diagnostics/app_diagnostics.dart';
import '../network_exception.dart';
import '../network_request.dart';
import '../network_response.dart';
import 'network_interceptor.dart';

/// Interceptor that records diagnostic telemetry breadcrumbs for all outbound HTTP requests,
/// responses, and network exceptions without logging any sensitive headers or payloads.
class DiagnosticNetworkInterceptor implements NetworkInterceptor {
  const DiagnosticNetworkInterceptor();

  @override
  Future<NetworkRequest> onRequest(NetworkRequest request) async {
    AppDiagnostics.record('NETWORK', 'HTTP ${request.method.value} ${request.path}');
    return request;
  }

  @override
  Future<NetworkResponse<dynamic>> onResponse(
    NetworkRequest request,
    NetworkResponse<dynamic> response,
  ) async {
    AppDiagnostics.record('NETWORK', 'HTTP ${response.statusCode} for ${request.path}', {
      'statusCode': response.statusCode,
      'isSuccess': response.isSuccess,
    });
    return response;
  }

  @override
  Future<void> onError(NetworkRequest request, NetworkException error) async {
    AppDiagnostics.record('NETWORK', 'HTTP error for ${request.path}: ${error.message}', {
      'errorType': error.runtimeType.toString(),
      if (error.statusCode != null) 'statusCode': error.statusCode,
    });
  }
}
