import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/core/cache/cache.dart';
import 'package:live_wallpaper/core/network/network.dart';
import 'package:live_wallpaper/models/motivational_short.dart';
import 'package:live_wallpaper/models/wallaza_cloud_wallpaper.dart';
import 'package:live_wallpaper/services/wallaza_api_service.dart';

class MockWallazaApiService implements WallazaApiService {
  final Map<String, List<int>> downloadPayloads = {};
  int downloadCalls = 0;

  @override
  Future<List<int>?> downloadWallpaperBytes(String id) async {
    downloadCalls++;
    return downloadPayloads[id] ?? [1, 2, 3, 4, 5];
  }

  @override
  Future<List<WallazaCloudWallpaper>> fetchWallpapers({
    int page = 1,
    int limit = 20,
    String? category,
  }) async => const [];

  @override
  Future<WallazaCloudWallpaper?> getWallpaperById(String id) async => null;

  @override
  Future<List<WallazaCloudWallpaper>> searchWallpapers({
    required String query,
    String? resolution,
    int page = 1,
    int limit = 20,
  }) async => const [];
}

void main() {
  group('FeedPrefetchManager Tests', () {
    late MemoryCacheService cache;
    late LruStorageManager lruManager;
    late MockWallazaApiService apiService;
    late FakeNetworkConnectivityService connectivity;
    late FeedPrefetchManager prefetchManager;

    final testShorts = [
      const MotivationalShort(
        id: 'local_1',
        title: 'Local Asset',
        quote: 'Stay focused',
        author: 'Wallora',
        category: 'Focus',
        videoAssetPath: 'assets/sample.mp4',
        accentColor: Colors.cyan,
        tags: 'focus',
      ),
      const MotivationalShort(
        id: 'cloud_101',
        title: 'Cloud Aurora',
        quote: 'Breathe deep',
        author: 'Wallora',
        category: 'Aura',
        videoAssetPath: '',
        imageUrl: 'https://images.unsplash.com/photo-101',
        accentColor: Colors.purple,
        tags: 'aura',
      ),
      const MotivationalShort(
        id: 'cloud_102',
        title: 'Cloud Cyber',
        quote: 'Limitless potential',
        author: 'Wallora',
        category: 'Cyber',
        videoAssetPath: '',
        imageUrl: 'https://images.unsplash.com/photo-102',
        accentColor: Colors.teal,
        tags: 'cyber',
      ),
      const MotivationalShort(
        id: 'cloud_103',
        title: 'Cloud Mountain',
        quote: 'Rise above',
        author: 'Wallora',
        category: 'Nature',
        videoAssetPath: '',
        imageUrl: 'https://images.unsplash.com/photo-103',
        accentColor: Colors.green,
        tags: 'nature',
      ),
    ];

    setUp(() {
      cache = MemoryCacheService();
      lruManager = LruStorageManager(cache: cache, maxSizeBytes: 100000);
      apiService = MockWallazaApiService();
      connectivity = FakeNetworkConnectivityService(
        initialStatus: ConnectivityType.wifi,
      );
      prefetchManager = FeedPrefetchManager(
        cache: cache,
        lruManager: lruManager,
        apiService: apiService,
        connectivity: connectivity,
        prefetchAheadCount: 2,
      );
    });

    test('Skips prefetching when offline', () async {
      connectivity.setConnectivity(ConnectivityType.none);

      await prefetchManager.onFeedIndexChanged(
        currentIndex: 0,
        shorts: testShorts,
      );

      expect(apiService.downloadCalls, 0);
      expect(lruManager.entries, isEmpty);
    });

    test('Skips prefetching when wifiOnly is true but network is cellular', () async {
      connectivity.setConnectivity(ConnectivityType.cellular);

      await prefetchManager.onFeedIndexChanged(
        currentIndex: 0,
        shorts: testShorts,
        wifiOnly: true,
      );

      expect(apiService.downloadCalls, 0);
    });

    test('Prefetches ahead up to prefetchAheadCount on Wi-Fi', () async {
      connectivity.setConnectivity(ConnectivityType.wifi);

      // Current index is 0 (local). Next 2 are cloud_101 and cloud_102.
      await prefetchManager.onFeedIndexChanged(
        currentIndex: 0,
        shorts: testShorts,
      );

      // Allow microtasks & futures to run
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(apiService.downloadCalls, 2);
      expect(await cache.fileExists('wallpaper_cloud_101.jpg'), isTrue);
      expect(await cache.fileExists('wallpaper_cloud_102.jpg'), isTrue);
      expect(lruManager.entries.map((e) => e.key), containsAll(['wallpaper_cloud_101.jpg', 'wallpaper_cloud_102.jpg']));
    });

    test('Does not re-download if file is already cached in storage', () async {
      await cache.saveFile('wallpaper_cloud_101.jpg', [10, 20, 30]);

      await prefetchManager.onFeedIndexChanged(
        currentIndex: 0,
        shorts: testShorts,
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));

      // cloud_101 was cached, so only cloud_102 was downloaded via API
      expect(apiService.downloadCalls, 1);
    });
  });
}
