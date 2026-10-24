import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/curated_shorts_data.dart';
import '../models/aura_palette_config.dart';
import '../models/aurora_synthesizer_config.dart';
import '../models/battery_telemetry_config.dart';
import '../models/day_night_schedule_config.dart';
import '../models/gesture_control_config.dart';
import '../models/lock_screen_style_config.dart';
import '../models/motivational_short.dart';
import '../models/parallax_effect_config.dart';
import '../models/particle_effect_config.dart';
import '../models/smart_filter_config.dart';
import '../models/standby_dock_config.dart';
import '../models/wallpaper_collection.dart';
import '../models/wallpaper_effect_config.dart';
import '../models/wallora_backup_bundle.dart';
import '../models/wallora_screen_blueprint.dart';
import '../models/weather_atmosphere_config.dart';
import '../models/wallaza_cloud_wallpaper.dart';
import '../services/wallaza_api_service.dart';
import '../services/wallpaper_renderer_service.dart';
import '../services/wallpaper_service_bridge.dart';

class WallpaperRepository {
  final WallpaperServiceBridge _bridge;
  final SharedPreferences prefs;
  final WallazaApiService wallazaService;

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
  static const String _keyParticleConfig = 'particle_effect_config';
  static const String _keySmartFilter = 'smart_filter_config';
  static const String _keyBatteryTelemetry = 'battery_telemetry_config';
  static const String _keyAuraPalette = 'aura_palette_config';
  static const String _keyGestureControl = 'gesture_control_config';
  static const String _keyStandbyDock = 'standby_dock_config';
  static const String _keyAuroraSynthesizer = 'aurora_synthesizer_config';
  static const String _keyWeatherAtmosphere = 'wallora_weather_atmosphere_config';
  static const String _keyPublishedBlueprints = 'wallora_published_blueprints';
  static const String _keyLikedBlueprintIds = 'wallora_liked_blueprint_ids';

  WallpaperRepository({
    WallpaperServiceBridge? bridge,
    WallazaApiService? wallazaService,
    required this.prefs,
  })  : _bridge = bridge ?? WallpaperServiceBridge(),
        wallazaService = wallazaService ?? WallazaApiService();

  /// Returns the configured Aura Chromatic Harmonizer & Dynamic Palette settings.
  AuraPaletteConfig getAuraPaletteConfig() {
    final raw = prefs.getString(_keyAuraPalette);
    if (raw == null || raw.isEmpty) {
      return AuraPaletteConfig.defaultConfig;
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return AuraPaletteConfig.fromJson(json);
    } catch (_) {
      return AuraPaletteConfig.defaultConfig;
    }
  }

  /// Saves the Aura Chromatic Harmonizer & Dynamic Palette settings.
  Future<void> saveAuraPaletteConfig(AuraPaletteConfig config) async {
    await prefs.setString(_keyAuraPalette, jsonEncode(config.toJson()));
  }

  /// Resets the Aura Chromatic Harmonizer & Dynamic Palette settings to default.
  Future<void> resetAuraPaletteConfig() async {
    await prefs.remove(_keyAuraPalette);
  }

  /// Returns the configured Gesture Controls & Dynamic Haptics settings.
  GestureControlConfig getGestureControlConfig() {
    final raw = prefs.getString(_keyGestureControl);
    if (raw == null || raw.isEmpty) {
      return GestureControlConfig.defaultConfig;
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return GestureControlConfig.fromJson(json);
    } catch (_) {
      return GestureControlConfig.defaultConfig;
    }
  }

  /// Saves the Gesture Controls & Dynamic Haptics settings.
  Future<void> saveGestureControlConfig(GestureControlConfig config) async {
    await prefs.setString(_keyGestureControl, jsonEncode(config.toJson()));
  }

  /// Resets the Gesture Controls & Dynamic Haptics settings to default.
  Future<void> resetGestureControlConfig() async {
    await prefs.remove(_keyGestureControl);
  }

  /// Returns the configured Horizon Standby & Ambient Desk Dock settings.
  StandbyDockConfig getStandbyDockConfig() {
    final raw = prefs.getString(_keyStandbyDock);
    if (raw == null || raw.isEmpty) {
      return StandbyDockConfig.defaultConfig;
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return StandbyDockConfig.fromJson(json);
    } catch (_) {
      return StandbyDockConfig.defaultConfig;
    }
  }

  /// Saves the Horizon Standby & Ambient Desk Dock settings.
  Future<void> saveStandbyDockConfig(StandbyDockConfig config) async {
    await prefs.setString(_keyStandbyDock, jsonEncode(config.toJson()));
  }

  /// Resets the Horizon Standby & Ambient Desk Dock settings to default.
  Future<void> resetStandbyDockConfig() async {
    await prefs.remove(_keyStandbyDock);
  }

  /// Returns the configured Wallora Procedural Aurora Wave Synthesizer settings.
  AuroraSynthesizerConfig getAuroraSynthesizerConfig() {
    final raw = prefs.getString(_keyAuroraSynthesizer);
    if (raw == null || raw.isEmpty) {
      return AuroraSynthesizerConfig.defaultConfig;
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return AuroraSynthesizerConfig.fromJson(json);
    } catch (_) {
      return AuroraSynthesizerConfig.defaultConfig;
    }
  }

  /// Saves the Wallora Procedural Aurora Wave Synthesizer settings.
  Future<void> saveAuroraSynthesizerConfig(AuroraSynthesizerConfig config) async {
    await prefs.setString(_keyAuroraSynthesizer, jsonEncode(config.toJson()));
  }

  /// Resets the Wallora Procedural Aurora Wave Synthesizer settings to default.
  Future<void> resetAuroraSynthesizerConfig() async {
    await prefs.remove(_keyAuroraSynthesizer);
  }

  /// Returns the configured Wallora Atmospheric Weather & Climate FX settings.
  WeatherAtmosphereConfig getWeatherAtmosphereConfig() {
    final raw = prefs.getString(_keyWeatherAtmosphere);
    if (raw == null || raw.isEmpty) {
      return WeatherAtmosphereConfig.defaultConfig;
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return WeatherAtmosphereConfig.fromJson(json);
    } catch (_) {
      return WeatherAtmosphereConfig.defaultConfig;
    }
  }

  /// Saves the Wallora Atmospheric Weather & Climate FX settings.
  Future<void> saveWeatherAtmosphereConfig(WeatherAtmosphereConfig config) async {
    await prefs.setString(_keyWeatherAtmosphere, jsonEncode(config.toJson()));
  }

  /// Resets the Wallora Atmospheric Weather & Climate FX settings to default.
  Future<void> resetWeatherAtmosphereConfig() async {
    await prefs.remove(_keyWeatherAtmosphere);
  }

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

  /// Returns the configured Interactive Particle FX settings.
  ParticleEffectConfig getParticleEffectConfig() {
    final raw = prefs.getString(_keyParticleConfig);
    if (raw == null || raw.isEmpty) {
      return ParticleEffectConfig.defaultConfig;
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return ParticleEffectConfig.fromJson(json);
    } catch (_) {
      return ParticleEffectConfig.defaultConfig;
    }
  }

  /// Saves the Interactive Particle FX settings.
  Future<void> saveParticleEffectConfig(ParticleEffectConfig config) async {
    await prefs.setString(_keyParticleConfig, jsonEncode(config.toJson()));
  }

  /// Resets the Interactive Particle FX settings to default.
  Future<void> resetParticleEffectConfig() async {
    await prefs.remove(_keyParticleConfig);
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

  /// Resets the Day & Night solar schedule settings to default.
  Future<void> resetDayNightScheduleConfig() async {
    await prefs.remove(_keyDayNightSchedule);
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

  /// Returns list of all community screen blueprints (curated + user-published).
  List<WalloraScreenBlueprint> getCommunityBlueprints() {
    final publishedRaw = prefs.getStringList(_keyPublishedBlueprints) ?? [];
    final List<WalloraScreenBlueprint> userPublished = [];
    for (final item in publishedRaw) {
      try {
        final map = jsonDecode(item) as Map<String, dynamic>;
        userPublished.add(WalloraScreenBlueprint.fromJson(map));
      } catch (_) {}
    }

    final likedIds = getLikedBlueprintIds();
    final all = [...userPublished, ...WalloraScreenBlueprint.curatedBlueprints];

    return all.map((bp) {
      if (likedIds.contains(bp.id)) {
        return bp.copyWith(likesCount: bp.likesCount + 1);
      }
      return bp;
    }).toList();
  }

  /// Saves a user-published screen blueprint to local storage.
  Future<void> savePublishedBlueprint(WalloraScreenBlueprint blueprint) async {
    final list = prefs.getStringList(_keyPublishedBlueprints) ?? [];
    list.removeWhere((item) {
      try {
        final map = jsonDecode(item) as Map<String, dynamic>;
        return map['id'] == blueprint.id;
      } catch (_) {
        return false;
      }
    });
    list.insert(0, jsonEncode(blueprint.toJson()));
    await prefs.setStringList(_keyPublishedBlueprints, list);
  }

  /// Returns set of blueprint IDs liked by the user.
  Set<String> getLikedBlueprintIds() {
    final list = prefs.getStringList(_keyLikedBlueprintIds) ?? [];
    return list.toSet();
  }

  /// Toggles like status for a community screen blueprint.
  Future<Set<String>> toggleBlueprintLike(String blueprintId) async {
    final liked = getLikedBlueprintIds();
    if (liked.contains(blueprintId)) {
      liked.remove(blueprintId);
    } else {
      liked.add(blueprintId);
    }
    await prefs.setStringList(_keyLikedBlueprintIds, liked.toList());
    return liked;
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
      if (short.videoAssetPath.isNotEmpty) {
        await prepareVideoFile(short);
      } else if (short.imageUrl != null && short.imageUrl!.isNotEmpty) {
        // Save as custom imported so it becomes part of local library
        await saveCustomImportedWallpaper(short);
        final Directory dir = await getApplicationDocumentsDirectory();
        final File targetFile = File('${dir.path}/wallpaper_${short.id}.jpg');
        if (!await targetFile.exists() || await targetFile.length() == 0) {
          final rawId = short.id.replaceFirst('cloud_', '');
          final bytes = await wallazaService.downloadWallpaperBytes(rawId);
          if (bytes != null && bytes.isNotEmpty) {
            await targetFile.writeAsBytes(bytes, flush: true);
          } else {
            await targetFile.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0], flush: true);
          }
        }
      }
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
      final File mp4File = File('${dir.path}/wallpaper_$shortId.mp4');
      if (await mp4File.exists()) {
        await mp4File.delete();
      }
      final File jpgFile = File('${dir.path}/wallpaper_$shortId.jpg');
      if (await jpgFile.exists()) {
        await jpgFile.delete();
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
    for (final key in prefs.getKeys()) {
      if (key.startsWith(_keyCustomQuotesPrefix)) {
        final shortId = key.substring(_keyCustomQuotesPrefix.length);
        final saved = prefs.getString(key);
        if (saved != null && saved.isNotEmpty) {
          map[shortId] = saved;
        }
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
    for (final key in prefs.getKeys()) {
      if (key.startsWith(_keyCustomEffectsPrefix)) {
        final shortId = key.substring(_keyCustomEffectsPrefix.length);
        final saved = prefs.getString(key);
        if (saved != null && saved.isNotEmpty) {
          try {
            final json = jsonDecode(saved) as Map<String, dynamic>;
            map[shortId] = WallpaperEffectConfig.fromJson(json);
          } catch (_) {}
        }
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

    // Cloud streaming video wallpapers downloaded and cached on-device
    if (short.videoAssetPath.startsWith('http://') ||
        short.videoAssetPath.startsWith('https://')) {
      final rawId = short.id.replaceFirst('cloud_', '');
      final downloaded = await wallazaService.downloadWallpaperBytes(rawId);
      if (downloaded != null && downloaded.isNotEmpty) {
        await targetFile.writeAsBytes(downloaded, flush: true);
        return targetFile.path;
      }
      try {
        final client = HttpClient();
        final req = await client
            .getUrl(Uri.parse(short.videoAssetPath))
            .timeout(const Duration(seconds: 10));
        final res = await req.close().timeout(const Duration(seconds: 10));
        if (res.statusCode == HttpStatus.ok) {
          final bytes =
              await res.fold<List<int>>([], (acc, chunk) => acc..addAll(chunk));
          await targetFile.writeAsBytes(bytes, flush: true);
          return targetFile.path;
        }
      } catch (_) {}
    } else if (short.videoAssetPath.startsWith('/') ||
        short.videoAssetPath.startsWith('file://')) {
      final cleanPath = short.videoAssetPath.startsWith('file://')
          ? short.videoAssetPath.replaceFirst('file://', '')
          : short.videoAssetPath;
      final file = File(cleanPath);
      if (await file.exists()) {
        return file.path;
      }
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

  /// Creates a versioned, portable backup bundle of all user configurations.
  Future<WalloraBackupBundle> createBackupBundle() async {
    return WalloraBackupBundle(
      exportedAt: DateTime.now(),
      favoriteIds: getFavorites(),
      customCollections: getCustomCollections(),
      customizedQuotes: getCustomQuotes(),
      customEffects: getCustomEffects(),
      dayNightSchedule: getDayNightScheduleConfig(),
      lockScreenStyle: getLockScreenStyleConfig(),
      parallaxConfig: getParallaxEffectConfig(),
      particleConfig: getParticleEffectConfig(),
      auraConfig: getAuraPaletteConfig(),
      gestureConfig: getGestureControlConfig(),
      standbyDockConfig: getStandbyDockConfig(),
      auroraSynthesizerConfig: getAuroraSynthesizerConfig(),
      batteryTelemetry: getBatteryTelemetryConfig(),
      smartFilter: getSmartFilterConfig(),
      weatherConfig: getWeatherAtmosphereConfig(),
      userPreferences: getUserPreferences(),
      isAmoledSaverModeEnabled: isAmoledSaverModeEnabled(),
    );
  }

  /// Restores a backup bundle into local storage.
  /// If [mergeWithExisting] is true, merges favorites, collections, quotes and effects.
  /// Otherwise, replaces configurations with the backup bundle contents.
  Future<bool> restoreBackupBundle(
    WalloraBackupBundle bundle, {
    bool mergeWithExisting = false,
  }) async {
    try {
      // 1. Favorites
      final Set<String> targetFavorites = mergeWithExisting
          ? (getFavorites()..addAll(bundle.favoriteIds))
          : bundle.favoriteIds;
      await prefs.setStringList(_keyFavorites, targetFavorites.toList());

      // 2. Custom Collections
      if (mergeWithExisting) {
        final existing = getCustomCollections();
        final Map<String, WallpaperCollection> map = {
          for (final c in existing) c.id: c
        };
        for (final c in bundle.customCollections) {
          map[c.id] = c;
        }
        await prefs.setStringList(
          _keyCustomCollections,
          map.values.map((c) => jsonEncode(c.toJson())).toList(),
        );
      } else {
        await prefs.setStringList(
          _keyCustomCollections,
          bundle.customCollections.map((c) => jsonEncode(c.toJson())).toList(),
        );
      }

      // 3. Custom Quotes
      if (!mergeWithExisting) {
        final existingQuotes = getCustomQuotes();
        for (final id in existingQuotes.keys) {
          await prefs.remove('$_keyCustomQuotesPrefix$id');
        }
      }
      for (final entry in bundle.customizedQuotes.entries) {
        await saveCustomQuote(entry.key, entry.value);
      }

      // 4. Custom Effects
      if (!mergeWithExisting) {
        final existingEffects = getCustomEffects();
        for (final id in existingEffects.keys) {
          await resetCustomEffect(id);
        }
      }
      for (final entry in bundle.customEffects.entries) {
        await saveCustomEffect(entry.key, entry.value);
      }

      // 5. Configs
      await saveDayNightScheduleConfig(bundle.dayNightSchedule);
      await saveLockScreenStyleConfig(bundle.lockScreenStyle);
      await saveParallaxEffectConfig(bundle.parallaxConfig);
      await saveParticleEffectConfig(bundle.particleConfig);
      await saveAuraPaletteConfig(bundle.auraConfig);
      await saveGestureControlConfig(bundle.gestureConfig);
      await saveStandbyDockConfig(bundle.standbyDockConfig);
      await saveAuroraSynthesizerConfig(bundle.auroraSynthesizerConfig);
      await saveBatteryTelemetryConfig(bundle.batteryTelemetry);
      await saveSmartFilterConfig(bundle.smartFilter);
      await saveWeatherAtmosphereConfig(bundle.weatherConfig);

      // 6. Preferences & AMOLED
      final Set<String> targetPreferences = mergeWithExisting
          ? (getUserPreferences()..addAll(bundle.userPreferences))
          : bundle.userPreferences;
      await saveUserPreferences(targetPreferences);
      await setAmoledSaverMode(bundle.isAmoledSaverModeEnabled);

      return true;
    } catch (_) {
      return false;
    }
  }

  /// Resets all user configurations, favorites, custom collections, and styles to factory defaults.
  Future<void> resetToFactoryDefaults() async {
    // 1. Clear favorites & custom collections
    await prefs.remove(_keyFavorites);
    await prefs.remove(_keyCustomCollections);

    // 2. Clear quotes & effects
    final quotes = getCustomQuotes();
    for (final id in quotes.keys) {
      await prefs.remove('$_keyCustomQuotesPrefix$id');
    }
    final effects = getCustomEffects();
    for (final id in effects.keys) {
      await resetCustomEffect(id);
    }

    // 3. Reset configs
    await resetDayNightScheduleConfig();
    await resetLockScreenStyleConfig();
    await resetParallaxEffectConfig();
    await resetParticleEffectConfig();
    await resetAuraPaletteConfig();
    await resetGestureControlConfig();
    await resetStandbyDockConfig();
    await resetAuroraSynthesizerConfig();
    await resetWeatherAtmosphereConfig();
    await resetBatteryTelemetryConfig();
    await resetSmartFilterConfig();

    // 4. Reset preferences & flags
    await saveUserPreferences({});
    await setAmoledSaverMode(false);

    // 5. Reset community blueprints & likes
    await prefs.remove(_keyPublishedBlueprints);
    await prefs.remove(_keyLikedBlueprintIds);
  }

  /// Fetches paginated cloud wallpapers proxied through the Wallaza API.
  Future<List<WallazaCloudWallpaper>> fetchCloudWallpapers({
    int page = 1,
    int limit = 20,
    String? category,
  }) async {
    return wallazaService.fetchWallpapers(
      page: page,
      limit: limit,
      category: category,
    );
  }

  /// Searches cloud wallpapers by query and resolution through the Wallaza API.
  Future<List<WallazaCloudWallpaper>> searchCloudWallpapers({
    required String query,
    String? resolution,
    int page = 1,
    int limit = 20,
  }) async {
    return wallazaService.searchWallpapers(
      query: query,
      resolution: resolution,
      page: page,
      limit: limit,
    );
  }

  /// Fetches detailed metadata for a single cloud wallpaper by ID.
  Future<WallazaCloudWallpaper?> getCloudWallpaper(String id) async {
    return wallazaService.getWallpaperById(id);
  }

  /// Imports a cloud wallpaper into local storage as a [MotivationalShort].
  Future<MotivationalShort> importCloudWallpaper(
    WallazaCloudWallpaper cloudItem,
  ) async {
    final short = cloudItem.toMotivationalShort();
    await saveCustomImportedWallpaper(short);
    return short;
  }
}
