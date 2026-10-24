import 'dart:io';
import '../core/core.dart';
import '../models/wallaza_cloud_wallpaper.dart';

/// Application API service communicating with the Wallaza Spring Boot REST proxy.
/// Adheres to SOLID Principles:
/// - Single Responsibility (SRP): Manages only Wallaza endpoint routing, DTO transformation, and offline fallback.
/// - Dependency Inversion (DIP): Injects the abstract [NetworkClient] interface rather than low-level socket clients.
/// - Open/Closed (OCP): Network behavior can be extended via interceptors without altering this service.
class WallazaApiService {
  final String baseUrl;
  final NetworkClient _networkClient;
  final Duration timeout;

  /// Injects [NetworkClient] interface (Dependency Inversion).
  /// Retains full backward compatibility with optional [httpClient] and [timeout].
  WallazaApiService({
    String? baseUrl,
    NetworkClient? networkClient,
    HttpClient? httpClient,
    this.timeout = const Duration(seconds: 4),
  })  : baseUrl = baseUrl ?? _defaultBaseUrl(),
        _networkClient = networkClient ??
            HttpNetworkClient(
              httpClient: httpClient,
              defaultTimeout: timeout,
            );

  static String _defaultBaseUrl() {
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8080/api/v1/wallpapers';
      }
    } catch (_) {
      // In web or non-standard environments
    }
    return 'http://localhost:8080/api/v1/wallpapers';
  }

  /// Fetches a paginated collection of cloud wallpapers with optional category filtering.
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

    // Curated offline library fallback
    return _curatedFallback(category: category);
  }

  /// Searches wallpapers across Wallaza matching keywords and resolution filters.
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

    // Curated offline keyword search fallback
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

  /// Fetches individual wallpaper specifications by ID.
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

    // Curated offline library fallback
    try {
      return WallazaCloudWallpaper.curatedCloudLibrary.firstWhere(
        (w) => w.id == id,
      );
    } catch (_) {
      return null;
    }
  }

  /// Downloads raw high-resolution wallpaper binary bytes from the Wallaza API proxy.
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

  /// Curated fallback matching category
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
