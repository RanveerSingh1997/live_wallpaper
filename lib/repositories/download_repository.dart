import '../core/core.dart';
import '../models/motivational_short.dart';
import '../services/wallaza_api_service.dart';

/// Abstract contract for offline download management and cache reclamation.
/// Follows Dependency Inversion Principle (DIP).
abstract class DownloadRepository {
  factory DownloadRepository({
    required LocalCacheService cache,
    required WallazaApiService wallazaService,
    Future<void> Function(MotivationalShort short)? onPrepareVideoFile,
    Future<void> Function(MotivationalShort short)? onSaveCustomImport,
    LruStorageManager? lruManager,
  }) = DownloadRepositoryImpl;

  Set<String> getDownloads();
  bool isDownloaded(String shortId);
  Future<bool> downloadWallpaper(MotivationalShort short);
  Future<bool> deleteDownload(String shortId);
  Future<void> clearAllDownloads();
  Future<int> getCacheSizeInBytes();
  Future<void> setDownloads(Set<String> downloads);
  LruStorageManager get lruManager;
}

/// Concrete implementation of [DownloadRepository].
class DownloadRepositoryImpl implements DownloadRepository {
  final LocalCacheService cache;
  final WallazaApiService wallazaService;
  final Future<void> Function(MotivationalShort short)? onPrepareVideoFile;
  final Future<void> Function(MotivationalShort short)? onSaveCustomImport;
  @override
  final LruStorageManager lruManager;

  DownloadRepositoryImpl({
    required this.cache,
    required this.wallazaService,
    this.onPrepareVideoFile,
    this.onSaveCustomImport,
    LruStorageManager? lruManager,
  }) : lruManager = lruManager ?? LruStorageManager(cache: cache);

  @override
  Set<String> getDownloads() {
    final list = cache.getStringList(AppConstants.keyDownloads) ?? [];
    return list.toSet();
  }

  @override
  bool isDownloaded(String shortId) {
    return getDownloads().contains(shortId);
  }

  @override
  Future<bool> downloadWallpaper(MotivationalShort short) async {
    try {
      if (short.videoAssetPath.isNotEmpty) {
        if (onPrepareVideoFile != null) {
          await onPrepareVideoFile!(short);
        }
      } else if (short.imageUrl != null && short.imageUrl!.isNotEmpty) {
        if (onSaveCustomImport != null) {
          await onSaveCustomImport!(short);
        }
        final fileName = 'wallpaper_${short.id}.jpg';
        final exists = await cache.fileExists(fileName);
        if (!exists) {
          final rawId = short.id.replaceFirst('cloud_', '');
          final bytes = await wallazaService.downloadWallpaperBytes(rawId);
          if (bytes != null && bytes.isNotEmpty) {
            await cache.saveFile(fileName, bytes);
            await lruManager.recordAccess(fileName, bytes.length, isPinned: true);
          } else {
            const fallback = [0xFF, 0xD8, 0xFF, 0xE0];
            await cache.saveFile(fileName, fallback);
            await lruManager.recordAccess(fileName, fallback.length, isPinned: true);
          }
          await lruManager.evictIfNeeded(onDeleteFile: cache.deleteFile);
        } else {
          await lruManager.setPinned(fileName, true);
        }
      }
      final current = getDownloads();
      current.add(short.id);
      await cache.setStringList(AppConstants.keyDownloads, current.toList());
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deleteDownload(String shortId) async {
    try {
      final mp4File = 'wallpaper_$shortId.mp4';
      if (await cache.fileExists(mp4File)) {
        await cache.deleteFile(mp4File);
        await lruManager.remove(mp4File);
      }
      final jpgFile = 'wallpaper_$shortId.jpg';
      if (await cache.fileExists(jpgFile)) {
        await cache.deleteFile(jpgFile);
        await lruManager.remove(jpgFile);
      }
      final current = getDownloads();
      current.remove(shortId);
      await cache.setStringList(AppConstants.keyDownloads, current.toList());
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> clearAllDownloads() async {
    try {
      await cache.clearAllFiles();
      await lruManager.clearAll(keepPinned: false);
      await cache.setStringList(AppConstants.keyDownloads, []);
    } catch (_) {}
  }

  @override
  Future<int> getCacheSizeInBytes() async {
    return await cache.getCacheSizeInBytes();
  }

  @override
  Future<void> setDownloads(Set<String> downloads) async {
    await cache.setStringList(AppConstants.keyDownloads, downloads.toList());
  }
}
