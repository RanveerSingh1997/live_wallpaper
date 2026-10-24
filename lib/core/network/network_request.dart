/// Supported HTTP methods.
enum HttpMethod {
  get('GET'),
  post('POST'),
  put('PUT'),
  delete('DELETE'),
  patch('PATCH'),
  head('HEAD');

  final String value;
  const HttpMethod(this.value);
}

/// Immutable value object encapsulating an HTTP network request.
class NetworkRequest {
  final HttpMethod method;
  final String path;
  final Map<String, dynamic> queryParameters;
  final Map<String, String> headers;
  final dynamic body;
  final Duration? timeout;

  /// Extensible metadata bag for interceptors (e.g. auth required, retry count, caching).
  final Map<String, dynamic> extra;

  const NetworkRequest({
    required this.method,
    required this.path,
    this.queryParameters = const {},
    this.headers = const {},
    this.body,
    this.timeout,
    this.extra = const {},
  });

  NetworkRequest copyWith({
    HttpMethod? method,
    String? path,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    dynamic body,
    Duration? timeout,
    Map<String, dynamic>? extra,
  }) {
    return NetworkRequest(
      method: method ?? this.method,
      path: path ?? this.path,
      queryParameters: queryParameters ?? this.queryParameters,
      headers: headers ?? this.headers,
      body: body ?? this.body,
      timeout: timeout ?? this.timeout,
      extra: extra ?? this.extra,
    );
  }
}
