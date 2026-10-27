import '../core/core.dart';
import '../models/wallaza_cloud_wallpaper.dart';

/// Abstract service contract communicating with the Wallaza / Pixabay REST API.
/// Conforms to https://pixabay.com/api/docs/#api_support
/// Adheres to SOLID Principles:
/// - Single Responsibility (SRP): Manages endpoint routing, DTO transformation, and offline fallback.
/// - Dependency Inversion (DIP): Injects the abstract [NetworkClient] interface rather than low-level socket clients.
/// - Open/Closed (OCP): Network behavior can be extended via interceptors without altering this service.
abstract class WallazaApiService {
  factory WallazaApiService({
    String? baseUrl,
    String? apiKey,
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

/// Concrete implementation of [WallazaApiService] with native Pixabay API integration.
class WallazaApiServiceImpl implements WallazaApiService {
  static const String pixabayImagesUrl = 'https://pixabay.com/api/';
  static const String pixabayVideosUrl = 'https://pixabay.com/api/videos/';

  final String baseUrl;
  final String? apiKey;
  final NetworkClient _networkClient;
  final Duration timeout;

  WallazaApiServiceImpl({
    String? baseUrl,
    String? apiKey,
    NetworkClient? networkClient,
    this.timeout = const Duration(seconds: 10),
  })  : baseUrl = baseUrl ?? pixabayImagesUrl,
        apiKey = apiKey ?? AppConstants.pixabayApiKey,
        _networkClient = networkClient ??
            HttpNetworkClient(
              defaultTimeout: timeout,
            );

  @override
  Future<List<WallazaCloudWallpaper>> fetchWallpapers({
    int page = 1,
    int limit = 20,
    String? category,
  }) async {
    final bool isPixabay = baseUrl.contains('pixabay.com');
    final bool isLiveCategory = category?.toLowerCase() == 'live';

    final targetUrl =
        (isPixabay && isLiveCategory) ? pixabayVideosUrl : baseUrl;

    final queryParams = <String, String>{
      if (apiKey != null && apiKey!.isNotEmpty) 'key': apiKey!,
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (isPixabay) {
      queryParams['per_page'] = limit.clamp(3, 200).toString();
      queryParams.remove('limit');
      if (isLiveCategory) {
        queryParams['video_type'] = 'all';
      } else {
        queryParams['image_type'] = 'all';
        queryParams['orientation'] = 'vertical';
        queryParams['safesearch'] = 'true';
        final bool isSpecialFeed = category == null ||
            category.isEmpty ||
            category == 'All' ||
            category.toLowerCase() == 'for you' ||
            category.toLowerCase() == 'curated';
        if (!isSpecialFeed) {
          final mappedCategory = _mapCategoryToPixabay(category);
          if (mappedCategory != null) {
            queryParams['category'] = mappedCategory;
          } else {
            queryParams['q'] = category.toLowerCase();
          }
        }
      }
    } else {
      if (category != null && category.isNotEmpty && category != 'All') {
        queryParams['category'] = category;
      }
    }

    try {
      final response = await _networkClient.get(
        targetUrl,
        queryParameters: queryParams,
        timeout: timeout,
      );

      if (response.isSuccess && response.data is Map<String, dynamic>) {
        final json = response.data as Map<String, dynamic>;
        if (json.containsKey('hits') && json['hits'] is List) {
          final hits = json['hits'] as List<dynamic>;
          return hits
              .map((item) => WallazaCloudWallpaper.fromPixabayJson(
                  item as Map<String, dynamic>))
              .toList();
        } else if (json.containsKey('data') && json['data'] is List) {
          final data = json['data'] as List<dynamic>;
          return data
              .map((item) =>
                  WallazaCloudWallpaper.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (_) {
      // Fallback on network failure / connection refused / missing API key
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
    final bool isPixabay = baseUrl.contains('pixabay.com');
    final bool isLiveQuery = query.toLowerCase().contains('live') ||
        query.toLowerCase().contains('video');

    final targetUrl = isPixabay
        ? (isLiveQuery ? pixabayVideosUrl : pixabayImagesUrl)
        : '$baseUrl/search';

    final queryParams = <String, String>{
      if (apiKey != null && apiKey!.isNotEmpty) 'key': apiKey!,
      'query': query,
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (isPixabay) {
      queryParams['q'] = query;
      queryParams.remove('query');
      queryParams['per_page'] = limit.clamp(3, 200).toString();
      queryParams.remove('limit');
      if (isLiveQuery) {
        queryParams['video_type'] = 'all';
      } else {
        queryParams['image_type'] = 'all';
        queryParams['safesearch'] = 'true';
        if (resolution == 'AMOLED') {
          queryParams['colors'] = 'black';
        }
      }
    } else {
      if (resolution != null && resolution.isNotEmpty && resolution != 'All') {
        queryParams['resolution'] = resolution;
      }
    }

    try {
      final response = await _networkClient.get(
        targetUrl,
        queryParameters: queryParams,
        timeout: timeout,
      );

      if (response.isSuccess && response.data is Map<String, dynamic>) {
        final json = response.data as Map<String, dynamic>;
        if (json.containsKey('hits') && json['hits'] is List) {
          final hits = json['hits'] as List<dynamic>;
          return hits
              .map((item) => WallazaCloudWallpaper.fromPixabayJson(
                  item as Map<String, dynamic>))
              .toList();
        } else if (json.containsKey('data') && json['data'] is List) {
          final data = json['data'] as List<dynamic>;
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
    final bool isPixabay =
        baseUrl.contains('pixabay.com') || id.startsWith('pixabay_');

    if (isPixabay) {
      final rawId = id.replaceFirst('pixabay_', '');
      try {
        final queryParams = <String, String>{
          if (apiKey != null && apiKey!.isNotEmpty) 'key': apiKey!,
          'id': rawId,
        };
        final response = await _networkClient.get(
          pixabayImagesUrl,
          queryParameters: queryParams,
          timeout: timeout,
        );
        if (response.isSuccess && response.data is Map<String, dynamic>) {
          final json = response.data as Map<String, dynamic>;
          final hits = json['hits'] as List<dynamic>?;
          if (hits != null && hits.isNotEmpty) {
            return WallazaCloudWallpaper.fromPixabayJson(
                hits.first as Map<String, dynamic>);
          }
        }
        // Fallback to checking videos endpoint
        final videoResponse = await _networkClient.get(
          pixabayVideosUrl,
          queryParameters: queryParams,
          timeout: timeout,
        );
        if (videoResponse.isSuccess && videoResponse.data is Map<String, dynamic>) {
          final json = videoResponse.data as Map<String, dynamic>;
          final hits = json['hits'] as List<dynamic>?;
          if (hits != null && hits.isNotEmpty) {
            return WallazaCloudWallpaper.fromPixabayJson(
                hits.first as Map<String, dynamic>);
          }
        }
      } catch (_) {}
    } else {
      try {
        final response = await _networkClient.get(
          '$baseUrl/$id',
          timeout: timeout,
        );

        if (response.isSuccess && response.data is Map<String, dynamic>) {
          final json = response.data as Map<String, dynamic>;
          return WallazaCloudWallpaper.fromJson(json);
        }
      } catch (_) {}
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
    final wallpaper = await getWallpaperById(id);
    if (wallpaper != null) {
      final downloadUrl = wallpaper.isVideo
          ? (wallpaper.videoStreamUrl ?? wallpaper.url)
          : wallpaper.url;
      if (downloadUrl.startsWith('http://') ||
          downloadUrl.startsWith('https://')) {
        try {
          return await _networkClient.downloadBytes(
            downloadUrl,
            timeout: timeout * 3,
          );
        } catch (_) {}
      }
    }

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

  static String? _mapCategoryToPixabay(String category) {
    switch (category.toLowerCase()) {
      case 'nature':
      case 'landscape':
        return 'nature';
      case 'space':
      case 'galaxy':
        return 'science';
      case 'cyberpunk':
      case 'technology':
        return 'computer';
      case 'urban':
      case 'architecture':
        return 'buildings';
      case 'amoled':
      case 'minimalist':
        return 'backgrounds';
      case 'people':
        return 'people';
      case 'places':
        return 'places';
      case 'animals':
        return 'animals';
      case 'music':
        return 'music';
      default:
        return null;
    }
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
