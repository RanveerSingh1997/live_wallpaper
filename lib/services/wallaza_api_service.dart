import 'dart:convert';
import 'dart:io';
import '../models/wallaza_cloud_wallpaper.dart';

/// Client service communicating with the Wallaza Spring Boot REST proxy.
class WallazaApiService {
  final String baseUrl;
  final HttpClient _httpClient;
  final Duration timeout;

  /// Default baseUrl resolves to 10.0.2.2 for Android emulators, and localhost for iOS/desktop.
  WallazaApiService({
    String? baseUrl,
    HttpClient? httpClient,
    this.timeout = const Duration(seconds: 4),
  })  : baseUrl = baseUrl ?? _defaultBaseUrl(),
        _httpClient = httpClient ?? HttpClient();

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
      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      final request = await _httpClient.getUrl(uri).timeout(timeout);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');

      final response = await request.close().timeout(timeout);
      if (response.statusCode == HttpStatus.ok) {
        final body = await response.transform(utf8.decoder).join();
        final json = jsonDecode(body) as Map<String, dynamic>;
        final data = json['data'] as List<dynamic>?;
        if (data != null) {
          return data
              .map((item) =>
                  WallazaCloudWallpaper.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (_) {
      // Fallback on timeout / connection refused
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
      final uri = Uri.parse('$baseUrl/search').replace(queryParameters: queryParams);
      final request = await _httpClient.getUrl(uri).timeout(timeout);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');

      final response = await request.close().timeout(timeout);
      if (response.statusCode == HttpStatus.ok) {
        final body = await response.transform(utf8.decoder).join();
        final json = jsonDecode(body) as Map<String, dynamic>;
        final data = json['data'] as List<dynamic>?;
        if (data != null) {
          return data
              .map((item) =>
                  WallazaCloudWallpaper.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (_) {
      // Fallback on timeout / connection refused
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
      final uri = Uri.parse('$baseUrl/$id');
      final request = await _httpClient.getUrl(uri).timeout(timeout);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');

      final response = await request.close().timeout(timeout);
      if (response.statusCode == HttpStatus.ok) {
        final body = await response.transform(utf8.decoder).join();
        final json = jsonDecode(body) as Map<String, dynamic>;
        return WallazaCloudWallpaper.fromJson(json);
      }
    } catch (_) {
      // Fallback on timeout / connection refused
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
      final uri = Uri.parse('$baseUrl/$id/download');
      final request = await _httpClient.getUrl(uri).timeout(timeout);
      final response = await request.close().timeout(timeout);
      if (response.statusCode == HttpStatus.ok) {
        final List<int> bytes = [];
        await for (final chunk in response) {
          bytes.addAll(chunk);
        }
        return bytes;
      }
    } catch (_) {
      // Fallback on timeout / connection refused
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
