import 'dart:async';
import '../../models/motivational_short.dart';
import '../../services/wallaza_api_service.dart';
import '../network/network_connectivity_service.dart';
import 'local_cache_service.dart';
import 'lru_storage_manager.dart';

/// Pre-caching manager that prefetches upcoming wallpapers in the vertical live feed
/// so scroll interactions remain 60/120 FPS buttery smooth and zero-buffering.
class FeedPrefetchManager {
  final LocalCacheService cache;
  final LruStorageManager lruManager;
  final WallazaApiService apiService;
  final NetworkConnectivityService connectivity;

  final int prefetchAheadCount;
  final Set<String> _inFlightFetches = {};

  FeedPrefetchManager({
    required this.cache,
    required this.lruManager,
    required this.apiService,
    required this.connectivity,
    this.prefetchAheadCount = 2,
  });

  Set<String> get inFlightFetches => Set.unmodifiable(_inFlightFetches);

  /// Triggers background pre-caching when user settles on a feed page.
  Future<void> onFeedIndexChanged({
    required int currentIndex,
    required List<MotivationalShort> shorts,
    bool wifiOnly = false,
  }) async {
    if (shorts.isEmpty) return;
    if (!connectivity.isOnline) return;
    if (wifiOnly && !connectivity.isWifi) return;

    // Collect next target items within range
    final targetIndices = <int>[];
    for (int i = 1; i <= prefetchAheadCount; i++) {
      final targetIdx = currentIndex + i;
      if (targetIdx < shorts.length) {
        targetIndices.add(targetIdx);
      }
    }

    for (final idx in targetIndices) {
      final short = shorts[idx];
      unawaited(_prefetchShort(short));
    }
  }

  Future<void> _prefetchShort(MotivationalShort short) async {
    // Only prefetch cloud wallpapers that are not already cached
    final isCloud = short.id.startsWith('cloud_') || short.imageUrl?.isNotEmpty == true;
    if (!isCloud) return;

    final fileName = 'wallpaper_${short.id}.jpg';
    if (_inFlightFetches.contains(short.id)) return;

    // Check if already on disk/cache
    final exists = await cache.fileExists(fileName);
    if (exists) {
      await lruManager.recordAccess(fileName, 0);
      return;
    }

    _inFlightFetches.add(short.id);

    try {
      final rawId = short.id.replaceFirst('cloud_', '');
      final bytes = await apiService.downloadWallpaperBytes(rawId);
      if (bytes != null && bytes.isNotEmpty) {
        await cache.saveFile(fileName, bytes);
        await lruManager.recordAccess(fileName, bytes.length, isPinned: false);
        await lruManager.evictIfNeeded(onDeleteFile: cache.deleteFile);
      }
    } catch (_) {
      // Background prefetching failures should fail silently without interrupting the feed
    } finally {
      _inFlightFetches.remove(short.id);
    }
  }
}
