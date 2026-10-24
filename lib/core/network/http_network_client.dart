import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'interceptors/header_interceptor.dart';
import 'interceptors/network_interceptor.dart';
import 'network_client.dart';
import 'network_exception.dart';
import 'network_request.dart';
import 'network_response.dart';

/// Concrete [NetworkClient] implemented via [HttpClient] and an extensible [NetworkInterceptor] pipeline.
/// Adheres to SOLID:
/// - Single Responsibility (SRP): Manages only HTTP transport execution and interceptor lifecycle.
/// - Open/Closed (OCP): Pipeline can be extended indefinitely via [addInterceptor].
/// - Liskov Substitution (LSP): Fully interchangeable with any [NetworkClient] mock or proxy.
/// - Interface Segregation (ISP): Exposes granular request helpers and pipeline hooks.
/// - Dependency Inversion (DIP): Injected wherever network access is needed.
class HttpNetworkClient implements NetworkClient {
  final HttpClient _httpClient;
  final Duration defaultTimeout;
  final List<NetworkInterceptor> _interceptors = [];

  HttpNetworkClient({
    HttpClient? httpClient,
    this.defaultTimeout = const Duration(seconds: 5),
    List<NetworkInterceptor>? interceptors,
    Map<String, String>? defaultHeaders,
  }) : _httpClient = httpClient ?? HttpClient() {
    // Register default header injector interceptor if headers provided or default
    final headers = defaultHeaders ??
        const {
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
          'User-Agent': 'Wallora-Flutter-Client/1.0',
        };
    _interceptors.add(HeaderInterceptor(headers));

    if (interceptors != null) {
      _interceptors.addAll(interceptors);
    }
  }

  @override
  void addInterceptor(NetworkInterceptor interceptor) {
    _interceptors.add(interceptor);
  }

  @override
  void removeInterceptor(NetworkInterceptor interceptor) {
    _interceptors.remove(interceptor);
  }

  @override
  Future<NetworkResponse<dynamic>> execute(NetworkRequest request) async {
    NetworkRequest currentRequest = request;

    // 1. Run through interceptor onRequest hooks
    for (final interceptor in _interceptors) {
      currentRequest = await interceptor.onRequest(currentRequest);
    }

    final effectiveTimeout = currentRequest.timeout ?? defaultTimeout;

    try {
      final uri = _buildUri(currentRequest.path, currentRequest.queryParameters);
      final httpRequest = await _httpClient
          .openUrl(currentRequest.method.value, uri)
          .timeout(effectiveTimeout);

      // Apply request headers
      currentRequest.headers.forEach((key, value) {
        httpRequest.headers.set(key, value);
      });

      // Write body if present
      if (currentRequest.body != null) {
        final dynamic raw = currentRequest.body;
        final encodedBody = raw is String ? raw : jsonEncode(raw);
        httpRequest.write(encodedBody);
      }

      final httpResponse = await httpRequest.close().timeout(effectiveTimeout);

      final responseHeaders = <String, String>{};
      httpResponse.headers.forEach((name, values) {
        responseHeaders[name] = values.join(', ');
      });

      final rawBody = await httpResponse.transform(utf8.decoder).join();
      dynamic decodedData;
      if (rawBody.isNotEmpty) {
        try {
          decodedData = jsonDecode(rawBody);
        } catch (_) {
          decodedData = rawBody;
        }
      }

      NetworkResponse<dynamic> response = NetworkResponse<dynamic>(
        statusCode: httpResponse.statusCode,
        data: decodedData,
        headers: responseHeaders,
        statusMessage: httpResponse.reasonPhrase,
      );

      // 2. Run through interceptor onResponse hooks
      for (final interceptor in _interceptors) {
        response = await interceptor.onResponse(currentRequest, response);
      }

      return response;
    } on TimeoutException catch (e) {
      final error = TimeoutNetworkException(
        'Request timed out for ${currentRequest.method.value} ${currentRequest.path}',
        cause: e,
      );
      await _notifyError(currentRequest, error);
      throw error;
    } on SocketException catch (e) {
      final error = ConnectionNetworkException(
        'Connection failed for ${currentRequest.method.value} ${currentRequest.path}',
        cause: e,
      );
      await _notifyError(currentRequest, error);
      throw error;
    } on FormatException catch (e) {
      final error = FormatNetworkException(
        'Formatting error for ${currentRequest.method.value} ${currentRequest.path}',
        cause: e,
      );
      await _notifyError(currentRequest, error);
      throw error;
    } on NetworkException catch (e) {
      await _notifyError(currentRequest, e);
      rethrow;
    } catch (e) {
      final error = ConnectionNetworkException(
        'Unexpected transport error: $e',
        cause: e,
      );
      await _notifyError(currentRequest, error);
      throw error;
    }
  }

  @override
  Future<NetworkResponse<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
  }) {
    return execute(
      NetworkRequest(
        method: HttpMethod.get,
        path: path,
        queryParameters: queryParameters ?? const {},
        headers: headers ?? const {},
        timeout: timeout,
      ),
    );
  }

  @override
  Future<NetworkResponse<dynamic>> post(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
  }) {
    return execute(
      NetworkRequest(
        method: HttpMethod.post,
        path: path,
        body: body,
        queryParameters: queryParameters ?? const {},
        headers: headers ?? const {},
        timeout: timeout,
      ),
    );
  }

  @override
  Future<NetworkResponse<dynamic>> put(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
  }) {
    return execute(
      NetworkRequest(
        method: HttpMethod.put,
        path: path,
        body: body,
        queryParameters: queryParameters ?? const {},
        headers: headers ?? const {},
        timeout: timeout,
      ),
    );
  }

  @override
  Future<NetworkResponse<dynamic>> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
  }) {
    return execute(
      NetworkRequest(
        method: HttpMethod.delete,
        path: path,
        queryParameters: queryParameters ?? const {},
        headers: headers ?? const {},
        timeout: timeout,
      ),
    );
  }

  @override
  Future<List<int>> downloadBytes(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    final effectiveTimeout = timeout ?? defaultTimeout;

    try {
      final uri = _buildUri(path, queryParameters);
      final request = await _httpClient.getUrl(uri).timeout(effectiveTimeout);

      headers?.forEach((key, value) {
        request.headers.set(key, value);
      });

      final response = await request.close().timeout(effectiveTimeout);
      if (response.statusCode >= 400) {
        final error = response.statusCode >= 500
            ? ServerNetworkException(response.reasonPhrase,
                statusCode: response.statusCode)
            : ClientNetworkException(response.reasonPhrase,
                statusCode: response.statusCode);
        throw error;
      }

      final List<int> bytes = [];
      await for (final chunk in response) {
        bytes.addAll(chunk);
      }
      return bytes;
    } on TimeoutException catch (e) {
      throw TimeoutNetworkException('Download timed out: $path', cause: e);
    } on SocketException catch (e) {
      throw ConnectionNetworkException('Download connection failed: $path',
          cause: e);
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw ConnectionNetworkException('Download failed: $e', cause: e);
    }
  }

  @override
  void close({bool force = false}) {
    _httpClient.close(force: force);
  }

  Future<void> _notifyError(
    NetworkRequest request,
    NetworkException error,
  ) async {
    for (final interceptor in _interceptors) {
      await interceptor.onError(request, error);
    }
  }

  Uri _buildUri(String path, Map<String, dynamic>? queryParameters) {
    final uri = Uri.parse(path);
    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }

    final sanitizedParams = <String, String>{};
    queryParameters.forEach((key, value) {
      if (value != null) {
        sanitizedParams[key] = value.toString();
      }
    });

    return uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        ...sanitizedParams,
      },
    );
  }
}
