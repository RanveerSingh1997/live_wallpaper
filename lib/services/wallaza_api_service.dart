import '../core/core.dart';
import '../models/wallaza_cloud_wallpaper.dart';

/// Abstract service contract communicating with the Wallaza REST proxy.
/// Adheres to SOLID Principles:
/// - Single Responsibility (SRP): Manages only Wallaza endpoint routing, DTO transformation, and offline fallback.
/// - Dependency Inversion (DIP): Injects the abstract [NetworkClient] interface rather than low-level socket clients.
/// - Open/Closed (OCP): Network behavior can be extended via interceptors without altering this service.
abstract class WallazaApiService {
  factory WallazaApiService({
    String? baseUrl,
    NetworkClient? networkClient,
    Duration timeout,
  }) = WallazaApiServiceImpl;

  Future<List<WallazaCloudWallpaper>> fetchWallpapers({
    int page = 1,
    int limit = 20,
    String? category,
  });

  Future<List<WallazaCloudWallpaper>> searchWallpapers({
    required String query,
    String? resolution,
    int page = 1,
    int limit = 20,
  });

  Future<WallazaCloudWallpaper?> getWallpaperById(String id);

  Future<List<int>?> downloadWallpaperBytes(String id);
}

/// Concrete implementation of [WallazaApiService].
class WallazaApiServiceImpl implements WallazaApiService {
  final String baseUrl;
  final NetworkClient _networkClient;
  final Duration timeout;

  WallazaApiServiceImpl({
    String? baseUrl,
    NetworkClient? networkClient,
    this.timeout = const Duration(seconds: 4),
  })  : baseUrl = baseUrl ?? _defaultBaseUrl(),
        _networkClient = networkClient ??
            HttpNetworkClient(
              defaultTimeout: timeout,
            );

  static String _defaultBaseUrl() {
    if (AppPlatform.isAndroid) {
      return 'http://10.0.2.2:8080/api/v1/wallpapers';
    }
    return 'http://localhost:8080/api/v1/wallpapers';
  }

  @override
  Future<List<WallazaCloudWallpaper>> fetchWallpapers({
    int page = 1,
    int limit = 20,
    String? category,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (category != null && category.isNotEmpty && category != 'All') {
      queryParams['category'] = category;
    }

    try {
      final response = await _networkClient.get(
        baseUrl,
        queryParameters: queryParams,
        timeout: timeout,
      );

      if (response.isSuccess && response.data is Map<String, dynamic>) {
        final json = response.data as Map<String, dynamic>;
        final data = json['data'] as List<dynamic>?;
        if (data != null) {
          return data
              .map((item) =>
                  WallazaCloudWallpaper.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (_) {
      // Fallback on network failure / connection refused
    }

    return _curatedFallback(category: category);
  }

  @override
  Future<List<WallazaCloudWallpaper>> searchWallpapers({
    required String query,
    String? resolution,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'query': query,
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (resolution != null && resolution.isNotEmpty && resolution != 'All') {
      queryParams['resolution'] = resolution;
    }

    try {
      final response = await _networkClient.get(
        '$baseUrl/search',
        queryParameters: queryParams,
        timeout: timeout,
      );

      if (response.isSuccess && response.data is Map<String, dynamic>) {
        final json = response.data as Map<String, dynamic>;
        final data = json['data'] as List<dynamic>?;
        if (data != null) {
          return data
              .map((item) =>
                  WallazaCloudWallpaper.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (_) {
      // Fallback on network failure / connection refused
    }

    final q = query.trim().toLowerCase();
    return WallazaCloudWallpaper.curatedCloudLibrary.where((w) {
      final matchesQuery = q.isEmpty ||
          w.title.toLowerCase().contains(q) ||
          w.description.toLowerCase().contains(q) ||
          w.category.toLowerCase().contains(q) ||
          (w.authorName?.toLowerCase().contains(q) ?? false) ||
          (w.authorUsername?.toLowerCase().contains(q) ?? false) ||
          w.tags.any((t) => t.toLowerCase().contains(q));

      final bool matchesRes;
      if (resolution == null || resolution.isEmpty || resolution == 'All') {
        matchesRes = true;
      } else if (resolution == 'AMOLED') {
        matchesRes = w.isAmoled;
      } else if (resolution == '3840x2160' || resolution == '4K') {
        matchesRes = w.is4K || w.resolution.contains('3840x2160');
      } else {
        matchesRes = w.resolution.contains(resolution);
      }

      return matchesQuery && matchesRes;
    }).toList();
  }

  @override
  Future<WallazaCloudWallpaper?> getWallpaperById(String id) async {
    try {
      final response = await _networkClient.get(
        '$baseUrl/$id',
        timeout: timeout,
      );

      if (response.isSuccess && response.data is Map<String, dynamic>) {
        final json = response.data as Map<String, dynamic>;
        return WallazaCloudWallpaper.fromJson(json);
      }
    } catch (_) {
      // Fallback on network failure / connection refused
    }

    try {
      return WallazaCloudWallpaper.curatedCloudLibrary.firstWhere(
        (w) => w.id == id,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<int>?> downloadWallpaperBytes(String id) async {
    try {
      final bytes = await _networkClient.downloadBytes(
        '$baseUrl/$id/download',
        timeout: timeout,
      );
      return bytes;
    } catch (_) {
      // Fallback on network failure / connection refused
    }
    return null;
  }

  List<WallazaCloudWallpaper> _curatedFallback({String? category}) {
    if (category == null || category.isEmpty || category == 'All') {
      return List.from(WallazaCloudWallpaper.curatedCloudLibrary);
    }
    final c = category.toLowerCase();
    final filtered = WallazaCloudWallpaper.curatedCloudLibrary
        .where((w) => w.category.toLowerCase() == c)
        .toList();
    return filtered.isNotEmpty
        ? filtered
        : List.from(WallazaCloudWallpaper.curatedCloudLibrary);
  }
}
