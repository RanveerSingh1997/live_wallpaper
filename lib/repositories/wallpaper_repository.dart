import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/curated_shorts_data.dart';
import '../models/motivational_short.dart';
import '../services/wallpaper_renderer_service.dart';
import '../services/wallpaper_service_bridge.dart';

class WallpaperRepository {
  final WallpaperServiceBridge _bridge;
  final SharedPreferences prefs;

  static const String _keyFavorites = 'favorite_short_ids';
  static const String _keyDownloads = 'downloaded_wallpaper_ids';
  static const String _keyActiveId = 'active_wallpaper_id';
  static const String _keyCustomQuotesPrefix = 'custom_quote_';
  static const String _keyUserPreferences = 'user_preferred_categories';
  static const String _keyTextOverlayEnabled = 'text_overlay_enabled_by_default';
  static const String _keyRecentlyViewed = 'recently_viewed_wallpaper_ids';
  static const String _keyReported = 'reported_wallpaper_ids';

  WallpaperRepository({
    WallpaperServiceBridge? bridge,
    required this.prefs,
  }) : _bridge = bridge ?? WallpaperServiceBridge();

  /// Returns list of all curated motivational shorts and static wallpapers.
  List<MotivationalShort> getCuratedShorts() {
    return CuratedShortsData.shorts;
  }

  /// Returns set of user preferred wallpaper categories.
  Set<String> getUserPreferences() {
    final list = prefs.getStringList(_keyUserPreferences);
    if (list != null && list.isNotEmpty) {
      return list.toSet();
    }
    // Default preferences: Anime, Nature, Motivation
    return {'Anime & Gaming', 'Nature & Scenery', 'Motivation & Mindset'};
  }

  /// Saves user preferred categories.
  Future<void> saveUserPreferences(Set<String> preferences) async {
    await prefs.setStringList(_keyUserPreferences, preferences.toList());
  }

  /// Checks if text overlays should be shown by default.
  bool isTextOverlayEnabledByDefault() {
    return prefs.getBool(_keyTextOverlayEnabled) ?? true;
  }

  /// Toggles global text overlay preference.
  Future<void> setTextOverlayEnabled(bool enabled) async {
    await prefs.setBool(_keyTextOverlayEnabled, enabled);
  }

  /// Returns set of favorite IDs.
  Set<String> getFavorites() {
    final list = prefs.getStringList(_keyFavorites) ?? [];
    return list.toSet();
  }

  /// Toggles favorite status for a short.
  Future<Set<String>> toggleFavorite(String shortId) async {
    final current = getFavorites();
    if (current.contains(shortId)) {
      current.remove(shortId);
    } else {
      current.add(shortId);
    }
    await prefs.setStringList(_keyFavorites, current.toList());
    return current;
  }

  /// Returns set of physically downloaded wallpaper IDs for offline use.
  Set<String> getDownloads() {
    final list = prefs.getStringList(_keyDownloads) ?? [];
    return list.toSet();
  }

  /// Downloads and caches the full-resolution wallpaper file for offline storage.
  Future<bool> downloadWallpaper(MotivationalShort short) async {
    try {
      await prepareVideoFile(short);
      final current = getDownloads();
      current.add(short.id);
      await prefs.setStringList(_keyDownloads, current.toList());
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Removes a downloaded wallpaper file from storage and reclaims disk space.
  Future<bool> deleteDownload(String shortId) async {
    try {
      final Directory dir = await getApplicationDocumentsDirectory();
      final File targetFile = File('${dir.path}/wallpaper_$shortId.mp4');
      if (await targetFile.exists()) {
        await targetFile.delete();
      }
      final current = getDownloads();
      current.remove(shortId);
      await prefs.setStringList(_keyDownloads, current.toList());
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Removes all downloaded files from storage and resets downloads index.
  Future<void> clearAllDownloads() async {
    try {
      final Directory dir = await getApplicationDocumentsDirectory();
      final List<FileSystemEntity> entities = dir.listSync();
      for (final entity in entities) {
        if (entity is File && entity.path.contains('wallpaper_')) {
          try {
            await entity.delete();
          } catch (_) {}
        }
      }
      await prefs.setStringList(_keyDownloads, []);
    } catch (_) {}
  }

  /// Calculates total bytes of disk space occupied by downloaded wallpapers.
  Future<int> getTotalDownloadSizeBytes() async {
    try {
      final Directory dir = await getApplicationDocumentsDirectory();
      int total = 0;
      final List<FileSystemEntity> entities = dir.listSync();
      for (final entity in entities) {
        if (entity is File && entity.path.contains('wallpaper_')) {
          try {
            total += await entity.length();
          } catch (_) {}
        }
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  /// Returns all stored custom quotes by shortId.
  Map<String, String> getCustomQuotes() {
    final Map<String, String> map = {};
    for (final short in CuratedShortsData.shorts) {
      final saved = prefs.getString('$_keyCustomQuotesPrefix${short.id}');
      if (saved != null && saved.isNotEmpty) {
        map[short.id] = saved;
      }
    }
    return map;
  }

  /// Saves a user-customized quote for a given short.
  Future<void> saveCustomQuote(String shortId, String quote) async {
    await prefs.setString('$_keyCustomQuotesPrefix$shortId', quote);
  }

  /// Returns the ID of the currently active wallpaper.
  String? getActiveWallpaperId() {
    return prefs.getString(_keyActiveId);
  }

  /// Prepares the video asset by extracting it to local device storage.
  /// Android's native MediaPlayer requires a physical file path.
  Future<String> prepareVideoFile(MotivationalShort short) async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final String targetPath = '${dir.path}/wallpaper_${short.id}.mp4';
    final File targetFile = File(targetPath);

    if (await targetFile.exists() && await targetFile.length() > 0) {
      return targetFile.path;
    }

    // Copy bytes from Flutter asset bundle to application directory
    final ByteData byteData = await rootBundle.load(short.videoAssetPath);
    final Uint8List bytes = byteData.buffer.asUint8List(
      byteData.offsetInBytes,
      byteData.lengthInBytes,
    );
    await targetFile.writeAsBytes(bytes, flush: true);

    return targetFile.path;
  }

  /// Applies the motivational short as a looping live wallpaper.
  Future<Map<String, dynamic>> applyAsLiveWallpaper({
    required MotivationalShort short,
    bool isMuted = true,
  }) async {
    final String localVideoPath = await prepareVideoFile(short);
    final result = await _bridge.setLiveWallpaper(
      videoPath: localVideoPath,
      isMuted: isMuted,
    );

    if (result['status'] == 'updated_active' ||
        result['status'] == 'opened_chooser' ||
        result['status'] == 'opened_chooser_fallback' ||
        result['status'] == 'saved_to_photos') {
      await prefs.setString(_keyActiveId, short.id);
    }

    return result;
  }

  /// Checks if wallpaper is actively running on device.
  Future<bool> isWallpaperActiveOnDevice() async {
    return await _bridge.isWallpaperActive();
  }

  /// Shares video via native iPad/iOS share sheet with "Use as Wallpaper" option.
  Future<void> shareVideo(MotivationalShort short) async {
    final String localVideoPath = await prepareVideoFile(short);
    await _bridge.shareVideo(localVideoPath);
  }

  /// Opens the iPad Photos app directly.
  Future<void> openPhotos() async {
    await _bridge.openPhotos();
  }

  /// Toggles audio for wallpaper.
  Future<void> setWallpaperAudioMuted(bool isMuted) async {
    await _bridge.setAudioMuted(isMuted);
  }

  /// Re-opens chooser.
  Future<void> openChooser() async {
    await _bridge.openChooser();
  }

  /// Returns list of recently viewed wallpaper IDs in MRU order.
  List<String> getRecentlyViewed() {
    return prefs.getStringList(_keyRecentlyViewed) ?? [];
  }

  /// Records a wallpaper as recently viewed (persists top 20 unique items).
  Future<void> recordRecentlyViewed(String id) async {
    final list = prefs.getStringList(_keyRecentlyViewed) ?? [];
    list.remove(id);
    list.insert(0, id);
    if (list.length > 20) {
      list.removeRange(20, list.length);
    }
    await prefs.setStringList(_keyRecentlyViewed, list);
  }

  /// Returns set of reported wallpaper IDs.
  Set<String> getReportedIds() {
    final list = prefs.getStringList(_keyReported) ?? [];
    return list.toSet();
  }

  /// Reports a wallpaper for copyright, broken asset, or policy violations.
  Future<void> reportWallpaper(String id, String reason) async {
    final list = prefs.getStringList(_keyReported) ?? [];
    if (!list.contains(id)) {
      list.add(id);
      await prefs.setStringList(_keyReported, list);
    }
  }

  /// Renders a high-resolution static wallpaper PNG file with custom typography.
  Future<File> renderStaticWallpaperFile({
    required MotivationalShort short,
    String? customQuote,
  }) async {
    return await WallpaperRendererService.renderWallpaperToFile(
      wallpaper: short,
      quoteOverride: customQuote,
    );
  }

  /// Sets static wallpaper on Android directly (home, lock, or both).
  Future<Map<String, dynamic>> applyStaticWallpaper({
    required MotivationalShort short,
    String targetScreen = 'both',
    String? customQuote,
  }) async {
    final file = await renderStaticWallpaperFile(
      short: short,
      customQuote: customQuote,
    );

    if (Platform.isAndroid) {
      final result = await _bridge.setStaticWallpaper(
        filePath: file.path,
        targetScreen: targetScreen,
      );
      if (result['status'] == 'applied_static') {
        await prefs.setString(_keyActiveId, short.id);
      }
      return result;
    } else if (Platform.isIOS) {
      await _bridge.shareVideo(file.path);
      return {'status': 'shared_ios', 'targetScreen': targetScreen};
    } else {
      return {
        'status': 'unsupported_platform',
        'message': 'Setting static wallpaper is supported on Android and iOS.'
      };
    }
  }
}
