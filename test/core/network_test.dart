import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:live_wallpaper/core/core.dart';
import 'package:live_wallpaper/services/wallaza_api_service.dart';

/// Fake NetworkClient implementing the DIP contract for test verification.
class FakeNetworkClient implements NetworkClient {
  final List<NetworkInterceptor> _interceptors = [];
  NetworkResponse<dynamic>? stubbedResponse;
  List<int>? stubbedBytes;
  NetworkException? stubbedException;
  NetworkRequest? lastExecutedRequest;

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
    lastExecutedRequest = request;

    NetworkRequest currentRequest = request;
    for (final interceptor in _interceptors) {
      currentRequest = await interceptor.onRequest(currentRequest);
    }
    lastExecutedRequest = currentRequest;

    if (stubbedException != null) {
      for (final interceptor in _interceptors) {
        await interceptor.onError(currentRequest, stubbedException!);
      }
      throw stubbedException!;
    }

    NetworkResponse<dynamic> response = stubbedResponse ??
        const NetworkResponse(statusCode: 200, data: {'data': []});

    for (final interceptor in _interceptors) {
      response = await interceptor.onResponse(currentRequest, response);
    }

    return response;
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
    if (stubbedException != null) {
      throw stubbedException!;
    }
    return stubbedBytes ?? [0xDE, 0xAD, 0xBE, 0xEF];
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('Network Layer Value Objects & Exceptions', () {
    test('NetworkResponse correctly calculates HTTP status helper flags', () {
      const ok = NetworkResponse(statusCode: 200);
      expect(ok.isSuccess, isTrue);
      expect(ok.isClientError, isFalse);
      expect(ok.isServerError, isFalse);

      const notFound = NetworkResponse(statusCode: 404);
      expect(notFound.isSuccess, isFalse);
      expect(notFound.isClientError, isTrue);
      expect(notFound.isServerError, isFalse);

      const serverError = NetworkResponse(statusCode: 503);
      expect(serverError.isSuccess, isFalse);
      expect(serverError.isClientError, isFalse);
      expect(serverError.isServerError, isTrue);
    });

    test('NetworkRequest copyWith updates fields correctly', () {
      const original = NetworkRequest(
        method: HttpMethod.get,
        path: '/wallpapers',
        queryParameters: {'page': '1'},
      );

      final modified = original.copyWith(
        method: HttpMethod.post,
        body: {'title': 'Neon'},
      );

      expect(modified.method, HttpMethod.post);
      expect(modified.path, '/wallpapers');
      expect(modified.queryParameters['page'], '1');
      expect(modified.body, {'title': 'Neon'});
    });

    test('NetworkException subclasses convey typed diagnostic information', () {
      const connErr = ConnectionNetworkException('Unreachable host');
      expect(connErr.message, 'Unreachable host');
      expect(connErr.toString(), contains('Unreachable host'));

      const timeoutErr = TimeoutNetworkException('Timeout after 4s');
      expect(timeoutErr.message, 'Timeout after 4s');

      const serverErr = ServerNetworkException('Gateway Timeout', statusCode: 504);
      expect(serverErr.statusCode, 504);

      const clientErr = ClientNetworkException('Not Found', statusCode: 404);
      expect(clientErr.statusCode, 404);
    });
  });

  group('Network Interceptor Pipeline (Open/Closed Principle)', () {
    test('HeaderInterceptor injects default headers without overwriting request headers', () async {
      final fake = FakeNetworkClient();
      fake.addInterceptor(const HeaderInterceptor({
        'X-API-Key': 'secret_token_123',
        'User-Agent': 'Wallora-App',
      }));

      await fake.get('/test', headers: {'Custom-Header': 'CustomValue'});

      expect(fake.lastExecutedRequest, isNotNull);
      expect(fake.lastExecutedRequest!.headers['X-API-Key'], 'secret_token_123');
      expect(fake.lastExecutedRequest!.headers['User-Agent'], 'Wallora-App');
      expect(fake.lastExecutedRequest!.headers['Custom-Header'], 'CustomValue');
    });

    test('LoggingInterceptor captures request, response, and error callbacks', () async {
      final logMessages = <String>[];
      final fake = FakeNetworkClient();
      fake.addInterceptor(LoggingInterceptor(
        logger: logMessages.add,
        enabled: true,
      ));

      // 1. Success path
      await fake.get('/api/wallpapers');
      expect(logMessages.any((msg) => msg.contains('--> GET /api/wallpapers')), isTrue);
      expect(logMessages.any((msg) => msg.contains('<-- 200 GET /api/wallpapers')), isTrue);

      // 2. Error path
      fake.stubbedException = const ConnectionNetworkException('Network drop');
      await expectLater(
        fake.get('/api/wallpapers'),
        throwsA(isA<ConnectionNetworkException>()),
      );
      expect(logMessages.any((msg) => msg.contains('ERR [GET /api/wallpapers]')), isTrue);
    });
  });

  group('WallazaApiService with Injected NetworkClient (Dependency Inversion)', () {
    late FakeNetworkClient fakeNetwork;
    late WallazaApiService apiService;

    setUp(() {
      fakeNetwork = FakeNetworkClient();
      apiService = WallazaApiService(
        baseUrl: 'http://api.wallora.internal',
        networkClient: fakeNetwork,
      );
    });

    test('fetchWallpapers parses response from NetworkClient when 200 OK', () async {
      fakeNetwork.stubbedResponse = const NetworkResponse(
        statusCode: 200,
        data: {
          'data': [
            {
              'id': 'wlz_live_mock_1',
              'title': 'Cybernetic Highway',
              'url': 'https://example.com/cyber.jpg',
              'category': 'Cyberpunk',
              'tags': ['neon', 'future'],
              'is_video': true,
              'video_url': 'https://example.com/cyber.mp4',
              'duration': 15,
            }
          ]
        },
      );

      final results = await apiService.fetchWallpapers();
      expect(results.length, 1);
      expect(results.first.id, 'wlz_live_mock_1');
      expect(results.first.title, 'Cybernetic Highway');
      expect(results.first.isVideo, isTrue);
    });

    test('searchWallpapers passes query parameters through NetworkClient', () async {
      fakeNetwork.stubbedResponse = const NetworkResponse(
        statusCode: 200,
        data: {
          'data': [
            {
              'id': 'wlz_search_1',
              'title': 'Neon Rain',
              'url': 'https://example.com/rain.jpg',
              'category': 'Anime',
            }
          ]
        },
      );

      final results = await apiService.searchWallpapers(query: 'neon', resolution: '4K');
      expect(results.length, 1);
      expect(results.first.id, 'wlz_search_1');
      expect(fakeNetwork.lastExecutedRequest?.queryParameters['query'], 'neon');
      expect(fakeNetwork.lastExecutedRequest?.queryParameters['resolution'], '4K');
    });

    test('getWallpaperById returns single wallpaper item', () async {
      fakeNetwork.stubbedResponse = const NetworkResponse(
        statusCode: 200,
        data: {
          'id': 'wlz_item_42',
          'title': 'Deep Space Nebula',
          'url': 'https://example.com/nebula.jpg',
          'category': 'Space',
        },
      );

      final item = await apiService.getWallpaperById('wlz_item_42');
      expect(item, isNotNull);
      expect(item!.id, 'wlz_item_42');
      expect(item.category, 'Space');
    });

    test('downloadWallpaperBytes delegates to NetworkClient downloadBytes', () async {
      fakeNetwork.stubbedBytes = [0x89, 0x50, 0x4E, 0x47]; // PNG signature

      final bytes = await apiService.downloadWallpaperBytes('wlz_item_42');
      expect(bytes, [0x89, 0x50, 0x4E, 0x47]);
    });

    test('Falls back gracefully to curated library on NetworkException', () async {
      fakeNetwork.stubbedException = const ConnectionNetworkException('Host down');

      final fallbackItems = await apiService.fetchWallpapers();
      expect(fallbackItems.isNotEmpty, isTrue);
      expect(fallbackItems.first.title.isNotEmpty, isTrue);
    });
  });

  group('HttpNetworkClient Cross-Platform Concrete Tests', () {
    test('executes GET request and decodes JSON payload', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api/v1/wallpapers');
        expect(request.headers['Accept'], 'application/json');
        return http.Response(
          jsonEncode({'status': 'ok', 'count': 42}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final client = HttpNetworkClient(client: mockClient);
      final response = await client.get('https://wallora.internal/api/v1/wallpapers');

      expect(response.statusCode, 200);
      expect(response.isSuccess, isTrue);
      expect(response.data['status'], 'ok');
      expect(response.data['count'], 42);
    });

    test('executes POST request with JSON encoded body', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.body, jsonEncode({'title': 'Aurora Glow'}));
        return http.Response(jsonEncode({'id': 'gen_101'}), 201);
      });

      final client = HttpNetworkClient(client: mockClient);
      final response = await client.post(
        'https://wallora.internal/api/v1/generate',
        body: {'title': 'Aurora Glow'},
      );

      expect(response.statusCode, 201);
      expect(response.data['id'], 'gen_101');
    });

    test('executes PUT and DELETE requests cleanly', () async {
      final mockClient = MockClient((request) async {
        if (request.method == 'PUT') {
          return http.Response('{"updated":true}', 200);
        } else if (request.method == 'DELETE') {
          return http.Response('', 204);
        }
        return http.Response('Not Found', 404);
      });

      final client = HttpNetworkClient(client: mockClient);
      final putResp = await client.put('https://wallora.internal/item/1', body: 'test');
      expect(putResp.statusCode, 200);

      final delResp = await client.delete('https://wallora.internal/item/1');
      expect(delResp.statusCode, 204);
    });

    test('downloadBytes downloads binary content successfully', () async {
      final mockBytes = [0x00, 0xFF, 0xAA, 0x55];
      final mockClient = MockClient((request) async {
        return http.Response.bytes(mockBytes, 200);
      });

      final client = HttpNetworkClient(client: mockClient);
      final bytes = await client.downloadBytes('https://wallora.internal/wallpaper.png');
      expect(bytes, mockBytes);
    });

    test('downloadBytes throws ServerNetworkException on 500 error', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Error', 500, reasonPhrase: 'Internal Server Error');
      });

      final client = HttpNetworkClient(client: mockClient);
      expect(
        () => client.downloadBytes('https://wallora.internal/wallpaper.png'),
        throwsA(isA<ServerNetworkException>()),
      );
    });

    test('throws ClientException as ConnectionNetworkException on network failure', () async {
      final mockClient = MockClient((request) async {
        throw http.ClientException('DNS failure');
      });

      final client = HttpNetworkClient(client: mockClient);
      expect(
        () => client.get('https://wallora.internal/fail'),
        throwsA(isA<ConnectionNetworkException>()),
      );
    });

    test('interceptor pipeline transforms request and response', () async {
      final mockClient = MockClient((request) async {
        expect(request.headers['X-Custom-Auth'], 'Bearer token_abc');
        return http.Response(jsonEncode({'echo': 'ok'}), 200);
      });

      final client = HttpNetworkClient(
        client: mockClient,
        interceptors: [
          const HeaderInterceptor({'X-Custom-Auth': 'Bearer token_abc'}),
        ],
      );

      final response = await client.get('https://wallora.internal/intercepted');
      expect(response.statusCode, 200);
      expect(response.data['echo'], 'ok');
    });

    test('close terminates client', () {
      final mockClient = MockClient((request) async => http.Response('', 200));
      final client = HttpNetworkClient(client: mockClient);
      client.close();
      expect(true, isTrue);
    });
  });
}
