import 'interceptors/network_interceptor.dart';
import 'network_request.dart';
import 'network_response.dart';

/// Abstract contract defining the Network Service interface.
/// Adheres strictly to the Dependency Inversion Principle (DIP):
/// Higher-level modules (e.g. [WallazaApiService]) depend on this abstraction,
/// allowing any transport implementation (HttpClient, Dio, Http) or mock to be substituted.
abstract class NetworkClient {
  /// Executes an arbitrary [NetworkRequest] through the configured interceptor pipeline.
  Future<NetworkResponse<dynamic>> execute(NetworkRequest request);

  /// Convenience method for sending an HTTP GET request.
  Future<NetworkResponse<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
  });

  /// Convenience method for sending an HTTP POST request.
  Future<NetworkResponse<dynamic>> post(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
  });

  /// Convenience method for sending an HTTP PUT request.
  Future<NetworkResponse<dynamic>> put(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
  });

  /// Convenience method for sending an HTTP DELETE request.
  Future<NetworkResponse<dynamic>> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
  });

  /// Streams raw binary bytes (e.g. wallpaper downloads, images, video assets).
  Future<List<int>> downloadBytes(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
  });

  /// Adds a [NetworkInterceptor] to the processing pipeline (Open/Closed Principle).
  void addInterceptor(NetworkInterceptor interceptor);

  /// Removes a [NetworkInterceptor] from the processing pipeline.
  void removeInterceptor(NetworkInterceptor interceptor);

  /// Closes internal connection pools and cleans up resources.
  void close({bool force = false});
}
