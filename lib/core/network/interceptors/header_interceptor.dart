import '../network_request.dart';
import 'network_interceptor.dart';

/// Interceptor that transparently injects default headers into every outgoing request.
class HeaderInterceptor extends NetworkInterceptor {
  final Map<String, String> defaultHeaders;

  const HeaderInterceptor(this.defaultHeaders);

  @override
  NetworkRequest onRequest(NetworkRequest request) {
    final mergedHeaders = Map<String, String>.from(defaultHeaders)
      ..addAll(request.headers);
    return request.copyWith(headers: mergedHeaders);
  }
}
