import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/curated_shorts_data.dart';
import '../models/battery_telemetry_config.dart';
import '../models/day_night_schedule_config.dart';
import '../models/lock_screen_style_config.dart';
import '../models/motivational_short.dart';
import '../models/parallax_effect_config.dart';
import '../models/smart_filter_config.dart';
import '../models/wallpaper_collection.dart';
import '../models/wallpaper_effect_config.dart';
import '../services/wallpaper_renderer_service.dart';
import '../services/wallpaper_service_bridge.dart';

class WallpaperRepository {
  final WallpaperServiceBridge _bridge;
  final SharedPreferences prefs;

  static const String _keyFavorites = 'favorite_short_ids';
  static const String _keyDownloads = 'downloaded_wallpaper_ids';
  static const String _keyActiveId = 'active_wallpaper_id';
  static const String _keyCustomQuotesPrefix = 'custom_quote_';
  static const String _keyCustomEffectsPrefix = 'custom_effects_';
  static const String _keyUserPreferences = 'user_preferred_categories';
  static const String _keyTextOverlayEnabled = 'text_overlay_enabled_by_default';
  static const String _keyRecentlyViewed = 'recently_viewed_wallpaper_ids';
  static const String _keyReported = 'reported_wallpaper_ids';
  static const String _keyHasSeenOnboarding = 'has_seen_onboarding';
  static const String _keyAutoRotationEnabled = 'auto_rotation_enabled';
  static const String _keyAutoRotationIntervalMinutes = 'auto_rotation_interval_minutes';
  static const String _keyAutoRotationSource = 'auto_rotation_source';
  static const String _keyAutoRotationWifiOnly = 'auto_rotation_wifi_only';
  static const String _keyAutoRotationTarget = 'auto_rotation_target';
  static const String _keyCustomImportedWallpapers = 'custom_imported_wallpapers';
  static const String _keyCustomCollections = 'custom_user_collections';
  static const String _keyAmoledSaverMode = 'amoled_saver_mode_enabled';
  static const String _keyDayNightSchedule = 'day_night_schedule_config';
  static const String _keyLockScreenStyle = 'lock_screen_style_config';
  static const String _keyParallaxConfig = 'parallax_effect_config';
  static const String _keySmartFilter = 'smart_filter_config';
  static const String _keyBatteryTelemetry = 'battery_telemetry_config';

  WallpaperRepository({
    WallpaperServiceBridge? bridge,
    required this.prefs,
  }) : _bridge = bridge ?? WallpaperServiceBridge();

  /// Returns the configured Battery & Display Telemetry settings.
  BatteryTelemetryConfig getBatteryTelemetryConfig() {
    final raw = prefs.getString(_keyBatteryTelemetry);
    if (raw == null || raw.isEmpty) {
      return BatteryTelemetryConfig.defaultConfig;
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return BatteryTelemetryConfig.fromJson(json);
    } catch (_) {
      return BatteryTelemetryConfig.defaultConfig;
    }
  }

  /// Saves the Battery & Display Telemetry settings.
  Future<void> saveBatteryTelemetryConfig(BatteryTelemetryConfig config) async {
    await prefs.setString(_keyBatteryTelemetry, jsonEncode(config.toJson()));
  }

  /// Resets the Battery & Display Telemetry settings to default.
  Future<void> resetBatteryTelemetryConfig() async {
    await prefs.remove(_keyBatteryTelemetry);
  }

  /// Returns the configured Smart Semantic Discovery filter settings.
  SmartFilterConfig getSmartFilterConfig() {
    final raw = prefs.getString(_keySmartFilter);
    if (raw == null || raw.isEmpty) {
      return SmartFilterConfig.defaultConfig;
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return SmartFilterConfig.fromJson(json);
    } catch (_) {
      return SmartFilterConfig.defaultConfig;
    }
  }

  /// Saves the Smart Semantic Discovery filter settings.
  Future<void> saveSmartFilterConfig(SmartFilterConfig config) async {
    await prefs.setString(_keySmartFilter, jsonEncode(config.toJson()));
  }

  /// Resets the Smart Semantic Discovery filter settings to default.
  Future<void> resetSmartFilterConfig() async {
    await prefs.remove(_keySmartFilter);
  }

  /// Returns the configured 3D Spatial Parallax settings.
  ParallaxEffectConfig getParallaxEffectConfig() {
    final raw = prefs.getString(_keyParallaxConfig);
    if (raw == null || raw.isEmpty) {
      return ParallaxEffectConfig.defaultConfig;
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return ParallaxEffectConfig.fromJson(json);
    } catch (_) {
      return ParallaxEffectConfig.defaultConfig;
    }
  }

  /// Saves the 3D Spatial Parallax settings.
  Future<void> saveParallaxEffectConfig(ParallaxEffectConfig config) async {
    await prefs.setString(_keyParallaxConfig, jsonEncode(config.toJson()));
  }

  /// Resets the 3D Spatial Parallax settings to default.
  Future<void> resetParallaxEffectConfig() async {
    await prefs.remove(_keyParallaxConfig);
  }

  /// Returns the configured Lock Screen clock & widget simulation style.
  LockScreenStyleConfig getLockScreenStyleConfig() {
    final raw = prefs.getString(_keyLockScreenStyle);
    if (raw == null || raw.isEmpty) {
      return LockScreenStyleConfig.defaultConfig;
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return LockScreenStyleConfig.fromJson(json);
    } catch (_) {
      return LockScreenStyleConfig.defaultConfig;
    }
  }

  /// Saves the Lock Screen clock & widget simulation style.
  Future<void> saveLockScreenStyleConfig(LockScreenStyleConfig config) async {
    await prefs.setString(_keyLockScreenStyle, jsonEncode(config.toJson()));
  }

  /// Resets the Lock Screen clock & widget simulation style to default.
  Future<void> resetLockScreenStyleConfig() async {
    await prefs.remove(_keyLockScreenStyle);
  }

  /// Returns the configured Day & Night solar schedule settings.
  DayNightScheduleConfig getDayNightScheduleConfig() {
    final raw = prefs.getString(_keyDayNightSchedule);
    if (raw == null || raw.isEmpty) {
      return DayNightScheduleConfig.defaultConfig;
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return DayNightScheduleConfig.fromJson(json);
    } catch (_) {
      return DayNightScheduleConfig.defaultConfig;
    }
  }

  /// Saves the Day & Night solar schedule settings.
  Future<void> saveDayNightScheduleConfig(DayNightScheduleConfig config) async {
    await prefs.setString(_keyDayNightSchedule, jsonEncode(config.toJson()));
  }

  /// Returns whether AMOLED True-Black battery saver mode is enabled.
  bool isAmoledSaverModeEnabled() {
    return prefs.getBool(_keyAmoledSaverMode) ?? false;
  }

  /// Sets whether AMOLED True-Black battery saver mode is enabled.
  Future<void> setAmoledSaverMode(bool enabled) async {
    await prefs.setBool(_keyAmoledSaverMode, enabled);
  }

  /// Returns whether user has completed first-time onboarding.
  bool hasSeenOnboarding() {
    return prefs.getBool(_keyHasSeenOnboarding) ?? false;
  }

  /// Sets whether user has completed first-time onboarding.
  Future<void> setHasSeenOnboarding(bool seen) async {
    await prefs.setBool(_keyHasSeenOnboarding, seen);
  }

  /// Returns list of custom imported creator wallpapers.
  List<MotivationalShort> getCustomImportedWallpapers() {
    final list = prefs.getStringList(_keyCustomImportedWallpapers) ?? [];
    final List<MotivationalShort> result = [];
    for (final item in list) {
      try {
        final map = jsonDecode(item) as Map<String, dynamic>;
        result.add(MotivationalShort.fromJson(map));
      } catch (_) {}
    }
    return result;
  }

  /// Saves a custom imported creator wallpaper into local storage.
  Future<void> saveCustomImportedWallpaper(MotivationalShort short) async {
    final list = prefs.getStringList(_keyCustomImportedWallpapers) ?? [];
    list.removeWhere((item) {
      try {
        final map = jsonDecode(item) as Map<String, dynamic>;
        return map['id'] == short.id;
      } catch (_) {
        return false;
      }
    });
    list.insert(0, jsonEncode(short.toJson()));
    await prefs.setStringList(_keyCustomImportedWallpapers, list);
  }

  /// Returns list of user-created custom wallpaper collections / playlists.
  List<WallpaperCollection> getCustomCollections() {
    final list = prefs.getStringList(_keyCustomCollections) ?? [];
    final List<WallpaperCollection> result = [];
    for (final item in list) {
      try {
        final map = jsonDecode(item) as Map<String, dynamic>;
        result.add(WallpaperCollection.fromJson(map));
      } catch (_) {}
    }
    return result;
  }

  /// Saves or updates a user-created custom wallpaper collection.
  Future<void> saveCustomCollection(WallpaperCollection collection) async {
    final list = prefs.getStringList(_keyCustomCollections) ?? [];
    list.removeWhere((item) {
      try {
        final map = jsonDecode(item) as Map<String, dynamic>;
        return map['id'] == collection.id;
      } catch (_) {
        return false;
      }
    });
    list.insert(0, jsonEncode(collection.toJson()));
    await prefs.setStringList(_keyCustomCollections, list);
  }

  /// Deletes a user-created custom collection.
  Future<void> deleteCustomCollection(String collectionId) async {
    final list = prefs.getStringList(_keyCustomCollections) ?? [];
    list.removeWhere((item) {
      try {
        final map = jsonDecode(item) as Map<String, dynamic>;
        return map['id'] == collectionId;
      } catch (_) {
        return false;
      }
    });
    await prefs.setStringList(_keyCustomCollections, list);
  }

  /// Toggles membership of a wallpaper within a user-created collection.
  Future<WallpaperCollection?> toggleWallpaperInCollection(
    String collectionId,
    String wallpaperId,
  ) async {
    final collections = getCustomCollections();
    final index = collections.indexWhere((c) => c.id == collectionId);
    if (index < 0) return null;

    final existing = collections[index];
    final updatedIds = List<String>.from(existing.wallpaperIds);
    if (updatedIds.contains(wallpaperId)) {
      updatedIds.remove(wallpaperId);
    } else {
      updatedIds.add(wallpaperId);
    }

    final updated = existing.copyWith(wallpaperIds: updatedIds);
    await saveCustomCollection(updated);
    return updated;
  }

  /// Returns list of all curated motivational shorts and static wallpapers, including custom imported wallpapers.
  List<MotivationalShort> getCuratedShorts() {
    final custom = getCustomImportedWallpapers();
    return [...custom, ...CuratedShortsData.shorts];
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

  /// Returns all stored custom wallpaper effects by wallpaperId.
  Map<String, WallpaperEffectConfig> getCustomEffects() {
    final Map<String, WallpaperEffectConfig> map = {};
    final allShorts = getCuratedShorts();
    for (final short in allShorts) {
      final saved = prefs.getString('$_keyCustomEffectsPrefix${short.id}');
      if (saved != null && saved.isNotEmpty) {
        try {
          final json = jsonDecode(saved) as Map<String, dynamic>;
          map[short.id] = WallpaperEffectConfig.fromJson(json);
        } catch (_) {}
      }
    }
    return map;
  }

  /// Saves a custom effect configuration for a given wallpaper.
  Future<void> saveCustomEffect(String wallpaperId, WallpaperEffectConfig config) async {
    if (config.isDefault) {
      await prefs.remove('$_keyCustomEffectsPrefix$wallpaperId');
    } else {
      await prefs.setString(
        '$_keyCustomEffectsPrefix$wallpaperId',
        jsonEncode(config.toJson()),
      );
    }
  }

  /// Resets custom effect configuration for a given wallpaper back to default.
  Future<void> resetCustomEffect(String wallpaperId) async {
    await prefs.remove('$_keyCustomEffectsPrefix$wallpaperId');
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

  /// Renders a high-resolution static wallpaper PNG file with custom typography and visual effects.
  Future<File> renderStaticWallpaperFile({
    required MotivationalShort short,
    String? customQuote,
    WallpaperEffectConfig? effectConfig,
  }) async {
    return await WallpaperRendererService.renderWallpaperToFile(
      wallpaper: short,
      quoteOverride: customQuote,
      effectConfig: effectConfig,
    );
  }

  /// Sets static wallpaper on Android directly (home, lock, or both).
  Future<Map<String, dynamic>> applyStaticWallpaper({
    required MotivationalShort short,
    String targetScreen = 'both',
    String? customQuote,
    WallpaperEffectConfig? effectConfig,
  }) async {
    final file = await renderStaticWallpaperFile(
      short: short,
      customQuote: customQuote,
      effectConfig: effectConfig,
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

  /// Returns whether auto wallpaper rotation is enabled.
  bool isAutoRotationEnabled() {
    return prefs.getBool(_keyAutoRotationEnabled) ?? false;
  }

  /// Sets auto wallpaper rotation enabled state.
  Future<void> setAutoRotationEnabled(bool enabled) async {
    await prefs.setBool(_keyAutoRotationEnabled, enabled);
  }

  /// Returns auto wallpaper rotation interval in minutes (default 60).
  int getAutoRotationIntervalMinutes() {
    return prefs.getInt(_keyAutoRotationIntervalMinutes) ?? 60;
  }

  /// Sets auto wallpaper rotation interval in minutes.
  Future<void> setAutoRotationIntervalMinutes(int minutes) async {
    await prefs.setInt(_keyAutoRotationIntervalMinutes, minutes);
  }

  /// Returns auto wallpaper rotation source pool (e.g. 'favorites', 'all', or collection id).
  String getAutoRotationSource() {
    return prefs.getString(_keyAutoRotationSource) ?? 'favorites';
  }

  /// Sets auto wallpaper rotation source pool.
  Future<void> setAutoRotationSource(String source) async {
    await prefs.setString(_keyAutoRotationSource, source);
  }

  /// Returns whether auto rotation only occurs on Wi-Fi.
  bool isAutoRotationWifiOnly() {
    return prefs.getBool(_keyAutoRotationWifiOnly) ?? true;
  }

  /// Sets whether auto rotation only occurs on Wi-Fi.
  Future<void> setAutoRotationWifiOnly(bool wifiOnly) async {
    await prefs.setBool(_keyAutoRotationWifiOnly, wifiOnly);
  }

  /// Returns auto wallpaper rotation target screen ('both', 'home', 'lock').
  String getAutoRotationTarget() {
    return prefs.getString(_keyAutoRotationTarget) ?? 'both';
  }

  /// Sets auto wallpaper rotation target screen.
  Future<void> setAutoRotationTarget(String target) async {
    await prefs.setString(_keyAutoRotationTarget, target);
  }
}
