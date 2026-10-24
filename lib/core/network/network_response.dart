/// Encapsulates a standardized, type-safe network response.
class NetworkResponse<T> {
  /// The HTTP status code of the response.
  final int statusCode;

  /// The decoded response body payload.
  final T? data;

  /// Response HTTP headers.
  final Map<String, String> headers;

  /// Optional status message or reason phrase.
  final String? statusMessage;

  const NetworkResponse({
    required this.statusCode,
    this.data,
    this.headers = const {},
    this.statusMessage,
  });

  /// True if HTTP status code is in 2xx range.
  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  /// True if HTTP status code is in 4xx range.
  bool get isClientError => statusCode >= 400 && statusCode < 500;

  /// True if HTTP status code is in 5xx range.
  bool get isServerError => statusCode >= 500 && statusCode < 600;
}
