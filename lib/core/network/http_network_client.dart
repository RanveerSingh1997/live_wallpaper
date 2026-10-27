import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'interceptors/diagnostic_interceptor.dart';
import 'interceptors/header_interceptor.dart';
import 'interceptors/network_interceptor.dart';
import 'network_client.dart';
import 'network_exception.dart';
import 'network_request.dart';
import 'network_response.dart';

/// Concrete [NetworkClient] implemented via [http.Client] and an extensible [NetworkInterceptor] pipeline.
/// Adheres strictly to SOLID Principles:
/// - Single Responsibility (SRP): Manages only HTTP transport execution and interceptor lifecycle.
/// - Open/Closed (OCP): Pipeline can be extended indefinitely via [addInterceptor].
/// - Liskov Substitution (LSP): Fully interchangeable with any [NetworkClient] mock or proxy.
/// - Interface Segregation (ISP): Exposes granular request helpers and pipeline hooks.
/// - Dependency Inversion (DIP): Injected wherever network access is needed.
/// - Cross-Platform: Runs seamlessly across Android, iOS, Web, macOS, Windows, and Linux.
class HttpNetworkClient implements NetworkClient {
  final http.Client _client;
  final Duration defaultTimeout;
  final List<NetworkInterceptor> _interceptors = [];

  HttpNetworkClient({
    http.Client? client,
    this.defaultTimeout = const Duration(seconds: 10),
    List<NetworkInterceptor>? interceptors,
    Map<String, String>? defaultHeaders,
  }) : _client = client ?? http.Client() {
    // Register default header injector interceptor.
    // On Web (and for GET requests), avoid non-safelisted Content-Type or User-Agent headers
    // that trigger CORS preflight OPTIONS requests which external APIs (e.g. Pixabay) reject.
    final headers = defaultHeaders ??
        (kIsWeb
            ? const <String, String>{}
            : const {
                'Accept': 'application/json',
                'User-Agent': 'Wallora-Flutter-Client/1.0',
              });
    _interceptors.add(HeaderInterceptor(headers));
    _interceptors.add(const DiagnosticNetworkInterceptor());

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
      final httpRequest = http.Request(currentRequest.method.value, uri);

      // Apply request headers
      currentRequest.headers.forEach((key, value) {
        final lower = key.toLowerCase();
        // On web, skip browser-forbidden or preflight-triggering headers like User-Agent to avoid CORS preflight errors
        if (kIsWeb &&
            (lower == 'user-agent' ||
                lower == 'content-length' ||
                (currentRequest.body == null && lower == 'accept'))) {
          return;
        }
        // Never send Content-Type on requests without a body (e.g. GET/HEAD) to prevent CORS preflight
        if (currentRequest.body == null && lower == 'content-type') {
          return;
        }
        httpRequest.headers[key] = value;
      });

      // Write body if present
      if (currentRequest.body != null) {
        if (!httpRequest.headers.containsKey('Content-Type')) {
          httpRequest.headers['Content-Type'] = 'application/json; charset=utf-8';
        }
        final dynamic raw = currentRequest.body;
        final encodedBody = raw is String ? raw : jsonEncode(raw);
        httpRequest.body = encodedBody;
      }

      final streamedResponse = await _client.send(httpRequest).timeout(effectiveTimeout);
      final httpResponse = await http.Response.fromStream(streamedResponse);

      final responseHeaders = httpResponse.headers;
      final rawBody = httpResponse.body;
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
    } on http.ClientException catch (e) {
      final error = ConnectionNetworkException(
        'Connection failed for ${currentRequest.method.value} ${currentRequest.path}: ${e.message}',
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
      final response = await _client.get(uri, headers: headers).timeout(effectiveTimeout);
      if (response.statusCode >= 400) {
        final error = response.statusCode >= 500
            ? ServerNetworkException(response.reasonPhrase ?? 'Server error',
                statusCode: response.statusCode)
            : ClientNetworkException(response.reasonPhrase ?? 'Client error',
                statusCode: response.statusCode);
        throw error;
      }
      return response.bodyBytes;
    } on TimeoutException catch (e) {
      throw TimeoutNetworkException('Download timed out: $path', cause: e);
    } on http.ClientException catch (e) {
      throw ConnectionNetworkException('Download connection failed: $path: ${e.message}',
          cause: e);
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw ConnectionNetworkException('Download failed: $e', cause: e);
    }
  }

  @override
  void close({bool force = false}) {
    _client.close();
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
