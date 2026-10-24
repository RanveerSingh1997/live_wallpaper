import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import '../core/core.dart';
import '../data/curated_shorts_data.dart';
import '../models/motivational_short.dart';
import '../models/wallaza_cloud_wallpaper.dart';
import '../models/wallpaper_effect_config.dart';
import '../services/wallaza_api_service.dart';
import '../services/wallpaper_renderer_service.dart';
import '../services/wallpaper_service_bridge.dart';

/// Abstract contract for wallpaper catalog, active state, live motion, and custom imports.
/// Follows Dependency Inversion Principle (DIP).
abstract class CatalogRepository {
  factory CatalogRepository({
    required LocalCacheService cache,
    required WallpaperServiceBridge bridge,
    required WallazaApiService wallazaService,
    WallpaperRendererService? rendererService,
  }) = CatalogRepositoryImpl;

  List<MotivationalShort> getCuratedShorts();
  String? getActiveWallpaperId();
  Future<void> setActiveWallpaperId(String id);

  List<MotivationalShort> getCustomImportedWallpapers();
  Future<void> saveCustomImportedWallpaper(MotivationalShort short);
  Future<void> deleteCustomImportedWallpaper(String id);

  Future<Map<String, dynamic>> applyAsLiveWallpaper({
    required MotivationalShort short,
    bool isMuted = true,
  });

  Future<Map<String, dynamic>> applyStaticWallpaper({
    required MotivationalShort short,
    String targetScreen = 'both',
    String? customQuote,
    WallpaperEffectConfig? effectConfig,
  });

  Future<File?> prepareVideoFile(MotivationalShort short);

  Future<List<WallazaCloudWallpaper>> fetchCloudWallpapers({
    int page = 1,
    int limit = 20,
    String? category,
  });

  Future<List<WallazaCloudWallpaper>> searchCloudWallpapers({
    required String query,
    String? resolution,
    int page = 1,
    int limit = 20,
  });

  Future<WallazaCloudWallpaper?> getCloudWallpaper(String id);
}

/// Concrete implementation of [CatalogRepository].
class CatalogRepositoryImpl implements CatalogRepository {
  final LocalCacheService cache;
  final WallpaperServiceBridge bridge;
  final WallazaApiService wallazaService;
  final WallpaperRendererService _rendererService;

  CatalogRepositoryImpl({
    required this.cache,
    required this.bridge,
    required this.wallazaService,
    WallpaperRendererService? rendererService,
  }) : _rendererService = rendererService ?? WallpaperRendererService();

  @override
  List<MotivationalShort> getCuratedShorts() {
    final custom = getCustomImportedWallpapers();
    if (custom.isEmpty) {
      return List.from(CuratedShortsData.shorts);
    }
    return [...custom, ...CuratedShortsData.shorts];
  }

  @override
  String? getActiveWallpaperId() {
    return cache.getString(AppConstants.keyActiveId);
  }

  @override
  Future<void> setActiveWallpaperId(String id) async {
    await cache.setString(AppConstants.keyActiveId, id);
  }

  @override
  List<MotivationalShort> getCustomImportedWallpapers() {
    final rawList =
        cache.getStringList(AppConstants.keyCustomImportedWallpapers) ?? [];
    return rawList
        .map((str) {
          try {
            return MotivationalShort.fromJson(
              jsonDecode(str) as Map<String, dynamic>,
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<MotivationalShort>()
        .toList();
  }

  @override
  Future<void> saveCustomImportedWallpaper(MotivationalShort short) async {
    final current = getCustomImportedWallpapers();
    current.removeWhere((w) => w.id == short.id);
    current.insert(0, short);
    await cache.setStringList(
      AppConstants.keyCustomImportedWallpapers,
      current.map((w) => jsonEncode(w.toJson())).toList(),
    );
  }

  @override
  Future<void> deleteCustomImportedWallpaper(String id) async {
    final current = getCustomImportedWallpapers();
    current.removeWhere((w) => w.id == id);
    await cache.setStringList(
      AppConstants.keyCustomImportedWallpapers,
      current.map((w) => jsonEncode(w.toJson())).toList(),
    );
  }

  @override
  Future<Map<String, dynamic>> applyAsLiveWallpaper({
    required MotivationalShort short,
    bool isMuted = true,
  }) async {
    final file = await prepareVideoFile(short);
    if (file == null) {
      return {'status': 'error', 'message': 'Failed to prepare video file.'};
    }

    try {
      final result = await bridge.setLiveWallpaper(
        videoPath: file.path,
        isMuted: isMuted,
      );
      if (result['status'] == 'updated_active' ||
          result['status'] == 'opened_chooser' ||
          result['status'] == 'opened_chooser_fallback' ||
          result['status'] == 'saved_to_photos') {
        await setActiveWallpaperId(short.id);
      }
      return result;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  @override
  Future<Map<String, dynamic>> applyStaticWallpaper({
    required MotivationalShort short,
    String targetScreen = 'both',
    String? customQuote,
    WallpaperEffectConfig? effectConfig,
  }) async {
    final file = await _rendererService.renderWallpaper(
      wallpaper: short,
      quoteOverride: customQuote,
      effectConfig: effectConfig,
    );

    if (Platform.isAndroid) {
      final result = await bridge.setStaticWallpaper(
        filePath: file.path,
        targetScreen: targetScreen,
      );
      if (result['status'] == 'applied_static') {
        await setActiveWallpaperId(short.id);
      }
      return result;
    } else if (Platform.isIOS) {
      await bridge.shareVideo(file.path);
      return {'status': 'shared_ios', 'targetScreen': targetScreen};
    } else {
      return {
        'status': 'unsupported_platform',
        'message': 'Setting static wallpaper is supported on Android and iOS.'
      };
    }
  }

  @override
  Future<File?> prepareVideoFile(MotivationalShort short) async {
    final fileName = 'wallpaper_${short.id}.mp4';
    final existingFile = await cache.getFile(fileName);
    if (existingFile != null && await existingFile.length() > 0) {
      return existingFile;
    }

    // Cloud streaming video
    if (short.videoAssetPath.startsWith('http://') ||
        short.videoAssetPath.startsWith('https://')) {
      final rawId = short.id.replaceFirst('cloud_', '');
      final bytes = await wallazaService.downloadWallpaperBytes(rawId);
      if (bytes != null && bytes.isNotEmpty) {
        return await cache.saveFile(fileName, bytes);
      }
    }

    // Local file path
    if (short.videoAssetPath.startsWith('/') ||
        short.videoAssetPath.startsWith('file://')) {
      final cleanPath = short.videoAssetPath.startsWith('file://')
          ? short.videoAssetPath.replaceFirst('file://', '')
          : short.videoAssetPath;
      final file = File(cleanPath);
      if (await file.exists()) {
        return file;
      }
    }

    // Flutter asset bundle copy
    try {
      final ByteData byteData = await rootBundle.load(short.videoAssetPath);
      final Uint8List bytes = byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      );
      return await cache.saveFile(fileName, bytes);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<WallazaCloudWallpaper>> fetchCloudWallpapers({
    int page = 1,
    int limit = 20,
    String? category,
  }) {
    return wallazaService.fetchWallpapers(
      page: page,
      limit: limit,
      category: category,
    );
  }

  @override
  Future<List<WallazaCloudWallpaper>> searchCloudWallpapers({
    required String query,
    String? resolution,
    int page = 1,
    int limit = 20,
  }) {
    return wallazaService.searchWallpapers(
      query: query,
      resolution: resolution,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<WallazaCloudWallpaper?> getCloudWallpaper(String id) {
    return wallazaService.getWallpaperById(id);
  }
}
