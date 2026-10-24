import 'dart:convert';
import '../core/core.dart';
import '../models/aura_palette_config.dart';
import '../models/aurora_synthesizer_config.dart';
import '../models/battery_telemetry_config.dart';
import '../models/day_night_schedule_config.dart';
import '../models/gesture_control_config.dart';
import '../models/lock_screen_style_config.dart';
import '../models/parallax_effect_config.dart';
import '../models/particle_effect_config.dart';
import '../models/smart_filter_config.dart';
import '../models/standby_dock_config.dart';
import '../models/wallpaper_effect_config.dart';
import '../models/weather_atmosphere_config.dart';

/// Abstract contract for studio settings, lighting schedules, and aesthetic features.
/// Follows Dependency Inversion Principle (DIP).
abstract class StudioConfigRepository {
  factory StudioConfigRepository({required LocalCacheService cache}) =
      StudioConfigRepositoryImpl;

  AuraPaletteConfig getAuraPaletteConfig();
  Future<void> saveAuraPaletteConfig(AuraPaletteConfig config);
  Future<void> resetAuraPaletteConfig();

  GestureControlConfig getGestureControlConfig();
  Future<void> saveGestureControlConfig(GestureControlConfig config);
  Future<void> resetGestureControlConfig();

  StandbyDockConfig getStandbyDockConfig();
  Future<void> saveStandbyDockConfig(StandbyDockConfig config);
  Future<void> resetStandbyDockConfig();

  AuroraSynthesizerConfig getAuroraSynthesizerConfig();
  Future<void> saveAuroraSynthesizerConfig(AuroraSynthesizerConfig config);
  Future<void> resetAuroraSynthesizerConfig();

  WeatherAtmosphereConfig getWeatherAtmosphereConfig();
  Future<void> saveWeatherAtmosphereConfig(WeatherAtmosphereConfig config);
  Future<void> resetWeatherAtmosphereConfig();

  DayNightScheduleConfig getDayNightScheduleConfig();
  Future<void> saveDayNightScheduleConfig(DayNightScheduleConfig config);
  Future<void> resetDayNightScheduleConfig();

  LockScreenStyleConfig getLockScreenStyleConfig();
  Future<void> saveLockScreenStyleConfig(LockScreenStyleConfig config);
  Future<void> resetLockScreenStyleConfig();

  ParallaxEffectConfig getParallaxEffectConfig();
  Future<void> saveParallaxEffectConfig(ParallaxEffectConfig config);
  Future<void> resetParallaxEffectConfig();

  ParticleEffectConfig getParticleEffectConfig();
  Future<void> saveParticleEffectConfig(ParticleEffectConfig config);
  Future<void> resetParticleEffectConfig();

  SmartFilterConfig getSmartFilterConfig();
  Future<void> saveSmartFilterConfig(SmartFilterConfig config);
  Future<void> resetSmartFilterConfig();

  BatteryTelemetryConfig getBatteryTelemetryConfig();
  Future<void> saveBatteryTelemetryConfig(BatteryTelemetryConfig config);
  Future<void> resetBatteryTelemetryConfig();

  Map<String, String> getCustomQuotes();
  Future<void> saveCustomQuote(String shortId, String quote);
  Future<void> resetCustomQuote(String shortId);

  Map<String, WallpaperEffectConfig> getCustomEffects();
  Future<void> saveCustomEffects(String shortId, WallpaperEffectConfig config);
  Future<void> saveCustomEffect(String shortId, WallpaperEffectConfig config);
  Future<void> resetCustomEffects(String shortId);
  Future<void> resetCustomEffect(String shortId);

  bool isAmoledSaverModeEnabled();
  Future<void> setAmoledSaverModeEnabled(bool enabled);
  Future<void> setAmoledSaverMode(bool enabled);

  Set<String> getUserPreferences();
  Future<void> saveUserPreferences(Set<String> preferences);

  bool isTextOverlayEnabled();
  bool isTextOverlayEnabledByDefault();
  Future<void> setTextOverlayEnabled(bool enabled);

  bool isAutoRotationEnabled();
  Future<void> setAutoRotationEnabled(bool enabled);
  int getAutoRotationIntervalMinutes();
  Future<void> setAutoRotationIntervalMinutes(int minutes);
  String getAutoRotationSource();
  Future<void> setAutoRotationSource(String source);
  bool isAutoRotationWifiOnly();
  Future<void> setAutoRotationWifiOnly(bool wifiOnly);
  String getAutoRotationTarget();
  Future<void> setAutoRotationTarget(String target);

  List<String> getRecentlyViewed();
  Future<void> recordRecentlyViewed(String wallpaperId);

  Set<String> getReportedWallpaperIds();
  Set<String> getReportedIds();
  Future<void> reportWallpaper(String shortId, [String? reason]);

  bool hasSeenOnboarding();
  Future<void> setHasSeenOnboarding(bool seen);
}

/// Concrete implementation of [StudioConfigRepository].
class StudioConfigRepositoryImpl implements StudioConfigRepository {
  final LocalCacheService cache;

  StudioConfigRepositoryImpl({required this.cache});

  // --- Aura Chromatic Harmonizer ---
  @override
  AuraPaletteConfig getAuraPaletteConfig() {
    return cache.getObject<AuraPaletteConfig>(
          AppConstants.keyAuraPalette,
          AuraPaletteConfig.fromJson,
          fallback: AuraPaletteConfig.defaultConfig,
        ) ??
        AuraPaletteConfig.defaultConfig;
  }

  @override
  Future<void> saveAuraPaletteConfig(AuraPaletteConfig config) async {
    await cache.setObject(
      AppConstants.keyAuraPalette,
      (c) => c.toJson(),
      config,
    );
  }

  @override
  Future<void> resetAuraPaletteConfig() async {
    await cache.remove(AppConstants.keyAuraPalette);
  }

  // --- Gesture Controls & Dynamic Haptics ---
  @override
  GestureControlConfig getGestureControlConfig() {
    return cache.getObject<GestureControlConfig>(
          AppConstants.keyGestureControl,
          GestureControlConfig.fromJson,
          fallback: GestureControlConfig.defaultConfig,
        ) ??
        GestureControlConfig.defaultConfig;
  }

  @override
  Future<void> saveGestureControlConfig(GestureControlConfig config) async {
    await cache.setObject(
      AppConstants.keyGestureControl,
      (c) => c.toJson(),
      config,
    );
  }

  @override
  Future<void> resetGestureControlConfig() async {
    await cache.remove(AppConstants.keyGestureControl);
  }

  // --- Standby Desk Dock ---
  @override
  StandbyDockConfig getStandbyDockConfig() {
    return cache.getObject<StandbyDockConfig>(
          AppConstants.keyStandbyDock,
          StandbyDockConfig.fromJson,
          fallback: StandbyDockConfig.defaultConfig,
        ) ??
        StandbyDockConfig.defaultConfig;
  }

  @override
  Future<void> saveStandbyDockConfig(StandbyDockConfig config) async {
    await cache.setObject(
      AppConstants.keyStandbyDock,
      (c) => c.toJson(),
      config,
    );
  }

  @override
  Future<void> resetStandbyDockConfig() async {
    await cache.remove(AppConstants.keyStandbyDock);
  }

  // --- Aurora Wave Synthesizer ---
  @override
  AuroraSynthesizerConfig getAuroraSynthesizerConfig() {
    return cache.getObject<AuroraSynthesizerConfig>(
          AppConstants.keyAuroraSynthesizer,
          AuroraSynthesizerConfig.fromJson,
          fallback: AuroraSynthesizerConfig.defaultConfig,
        ) ??
        AuroraSynthesizerConfig.defaultConfig;
  }

  @override
  Future<void> saveAuroraSynthesizerConfig(
      AuroraSynthesizerConfig config) async {
    await cache.setObject(
      AppConstants.keyAuroraSynthesizer,
      (c) => c.toJson(),
      config,
    );
  }

  @override
  Future<void> resetAuroraSynthesizerConfig() async {
    await cache.remove(AppConstants.keyAuroraSynthesizer);
  }

  // --- Atmospheric Weather Studio ---
  @override
  WeatherAtmosphereConfig getWeatherAtmosphereConfig() {
    return cache.getObject<WeatherAtmosphereConfig>(
          AppConstants.keyWeatherAtmosphere,
          WeatherAtmosphereConfig.fromJson,
          fallback: WeatherAtmosphereConfig.defaultConfig,
        ) ??
        WeatherAtmosphereConfig.defaultConfig;
  }

  @override
  Future<void> saveWeatherAtmosphereConfig(
      WeatherAtmosphereConfig config) async {
    await cache.setObject(
      AppConstants.keyWeatherAtmosphere,
      (c) => c.toJson(),
      config,
    );
  }

  @override
  Future<void> resetWeatherAtmosphereConfig() async {
    await cache.remove(AppConstants.keyWeatherAtmosphere);
  }

  // --- Day & Night Lighting Schedule ---
  @override
  DayNightScheduleConfig getDayNightScheduleConfig() {
    return cache.getObject<DayNightScheduleConfig>(
          AppConstants.keyDayNightSchedule,
          DayNightScheduleConfig.fromJson,
          fallback: DayNightScheduleConfig.defaultConfig,
        ) ??
        DayNightScheduleConfig.defaultConfig;
  }

  @override
  Future<void> saveDayNightScheduleConfig(DayNightScheduleConfig config) async {
    await cache.setObject(
      AppConstants.keyDayNightSchedule,
      (c) => c.toJson(),
      config,
    );
  }

  @override
  Future<void> resetDayNightScheduleConfig() async {
    await cache.remove(AppConstants.keyDayNightSchedule);
  }

  // --- Lock Screen Typography & Clock ---
  @override
  LockScreenStyleConfig getLockScreenStyleConfig() {
    return cache.getObject<LockScreenStyleConfig>(
          AppConstants.keyLockScreenStyle,
          LockScreenStyleConfig.fromJson,
          fallback: LockScreenStyleConfig.defaultConfig,
        ) ??
        LockScreenStyleConfig.defaultConfig;
  }

  @override
  Future<void> saveLockScreenStyleConfig(LockScreenStyleConfig config) async {
    await cache.setObject(
      AppConstants.keyLockScreenStyle,
      (c) => c.toJson(),
      config,
    );
  }

  @override
  Future<void> resetLockScreenStyleConfig() async {
    await cache.remove(AppConstants.keyLockScreenStyle);
  }

  // --- 3D Spatial Parallax Effect ---
  @override
  ParallaxEffectConfig getParallaxEffectConfig() {
    return cache.getObject<ParallaxEffectConfig>(
          AppConstants.keyParallaxConfig,
          ParallaxEffectConfig.fromJson,
          fallback: ParallaxEffectConfig.defaultConfig,
        ) ??
        ParallaxEffectConfig.defaultConfig;
  }

  @override
  Future<void> saveParallaxEffectConfig(ParallaxEffectConfig config) async {
    await cache.setObject(
      AppConstants.keyParallaxConfig,
      (c) => c.toJson(),
      config,
    );
  }

  @override
  Future<void> resetParallaxEffectConfig() async {
    await cache.remove(AppConstants.keyParallaxConfig);
  }

  // --- Reactive Particle Effect System ---
  @override
  ParticleEffectConfig getParticleEffectConfig() {
    return cache.getObject<ParticleEffectConfig>(
          AppConstants.keyParticleConfig,
          ParticleEffectConfig.fromJson,
          fallback: ParticleEffectConfig.defaultConfig,
        ) ??
        ParticleEffectConfig.defaultConfig;
  }

  @override
  Future<void> saveParticleEffectConfig(ParticleEffectConfig config) async {
    await cache.setObject(
      AppConstants.keyParticleConfig,
      (c) => c.toJson(),
      config,
    );
  }

  @override
  Future<void> resetParticleEffectConfig() async {
    await cache.remove(AppConstants.keyParticleConfig);
  }

  // --- Smart Filter & Discovery ---
  @override
  SmartFilterConfig getSmartFilterConfig() {
    return cache.getObject<SmartFilterConfig>(
          AppConstants.keySmartFilter,
          SmartFilterConfig.fromJson,
          fallback: SmartFilterConfig.defaultConfig,
        ) ??
        SmartFilterConfig.defaultConfig;
  }

  @override
  Future<void> saveSmartFilterConfig(SmartFilterConfig config) async {
    await cache.setObject(
      AppConstants.keySmartFilter,
      (c) => c.toJson(),
      config,
    );
  }

  @override
  Future<void> resetSmartFilterConfig() async {
    await cache.remove(AppConstants.keySmartFilter);
  }

  // --- Battery Telemetry & Adaptive Rate ---
  @override
  BatteryTelemetryConfig getBatteryTelemetryConfig() {
    return cache.getObject<BatteryTelemetryConfig>(
          AppConstants.keyBatteryTelemetry,
          BatteryTelemetryConfig.fromJson,
          fallback: BatteryTelemetryConfig.defaultConfig,
        ) ??
        BatteryTelemetryConfig.defaultConfig;
  }

  @override
  Future<void> saveBatteryTelemetryConfig(
      BatteryTelemetryConfig config) async {
    await cache.setObject(
      AppConstants.keyBatteryTelemetry,
      (c) => c.toJson(),
      config,
    );
  }

  @override
  Future<void> resetBatteryTelemetryConfig() async {
    await cache.remove(AppConstants.keyBatteryTelemetry);
  }

  // --- Custom Quotes per Wallpaper ---
  @override
  Map<String, String> getCustomQuotes() {
    final result = <String, String>{};
    final keys = cache.getKeys(prefix: AppConstants.keyCustomQuotesPrefix);
    for (final key in keys) {
      final shortId = key.substring(AppConstants.keyCustomQuotesPrefix.length);
      final quote = cache.getString(key);
      if (quote != null) {
        result[shortId] = quote;
      }
    }
    return result;
  }

  @override
  Future<void> saveCustomQuote(String shortId, String quote) async {
    await cache.setString(
        '${AppConstants.keyCustomQuotesPrefix}$shortId', quote);
  }

  @override
  Future<void> resetCustomQuote(String shortId) async {
    await cache.remove('${AppConstants.keyCustomQuotesPrefix}$shortId');
  }

  // --- Custom Effects & Visual Filters ---
  @override
  Map<String, WallpaperEffectConfig> getCustomEffects() {
    final result = <String, WallpaperEffectConfig>{};
    final keys = cache.getKeys(prefix: AppConstants.keyCustomEffectsPrefix);
    for (final key in keys) {
      final shortId = key.substring(AppConstants.keyCustomEffectsPrefix.length);
      final raw = cache.getString(key);
      if (raw != null) {
        try {
          final json = jsonDecode(raw) as Map<String, dynamic>;
          result[shortId] = WallpaperEffectConfig.fromJson(json);
        } catch (_) {}
      }
    }
    return result;
  }

  @override
  Future<void> saveCustomEffects(
      String shortId, WallpaperEffectConfig config) async {
    await saveCustomEffect(shortId, config);
  }

  @override
  Future<void> saveCustomEffect(
      String shortId, WallpaperEffectConfig config) async {
    if (config.isDefault) {
      await cache.remove('${AppConstants.keyCustomEffectsPrefix}$shortId');
    } else {
      await cache.setString(
        '${AppConstants.keyCustomEffectsPrefix}$shortId',
        jsonEncode(config.toJson()),
      );
    }
  }

  @override
  Future<void> resetCustomEffects(String shortId) async {
    await resetCustomEffect(shortId);
  }

  @override
  Future<void> resetCustomEffect(String shortId) async {
    await cache.remove('${AppConstants.keyCustomEffectsPrefix}$shortId');
  }

  // --- AMOLED Saver Mode ---
  @override
  bool isAmoledSaverModeEnabled() {
    return cache.getBool(AppConstants.keyAmoledSaverMode,
            defaultValue: false) ??
        false;
  }

  @override
  Future<void> setAmoledSaverModeEnabled(bool enabled) async {
    await cache.setBool(AppConstants.keyAmoledSaverMode, enabled);
  }

  @override
  Future<void> setAmoledSaverMode(bool enabled) =>
      setAmoledSaverModeEnabled(enabled);

  // --- User Preferred Categories ---
  @override
  Set<String> getUserPreferences() {
    final list = cache.getStringList(AppConstants.keyUserPreferences);
    if (list == null || list.isEmpty) {
      return {
        'Anime & Gaming',
        'Nature & Scenery',
        'Motivation & Mindset',
      };
    }
    return list.toSet();
  }

  @override
  Future<void> saveUserPreferences(Set<String> preferences) async {
    await cache.setStringList(
        AppConstants.keyUserPreferences, preferences.toList());
  }

  // --- Text Overlay Visibility ---
  @override
  bool isTextOverlayEnabled() {
    return cache.getBool(AppConstants.keyTextOverlayEnabled,
            defaultValue: true) ??
        true;
  }

  @override
  bool isTextOverlayEnabledByDefault() => isTextOverlayEnabled();

  @override
  Future<void> setTextOverlayEnabled(bool enabled) async {
    await cache.setBool(AppConstants.keyTextOverlayEnabled, enabled);
  }

  // --- Auto-Rotation Engine ---
  @override
  bool isAutoRotationEnabled() {
    return cache.getBool(AppConstants.keyAutoRotationEnabled,
            defaultValue: false) ??
        false;
  }

  @override
  Future<void> setAutoRotationEnabled(bool enabled) async {
    await cache.setBool(AppConstants.keyAutoRotationEnabled, enabled);
  }

  @override
  int getAutoRotationIntervalMinutes() {
    return cache.getInt(
          AppConstants.keyAutoRotationIntervalMinutes,
          defaultValue: AppConstants.defaultRotationIntervalMinutes,
        ) ??
        AppConstants.defaultRotationIntervalMinutes;
  }

  @override
  Future<void> setAutoRotationIntervalMinutes(int minutes) async {
    await cache.setInt(AppConstants.keyAutoRotationIntervalMinutes, minutes);
  }

  @override
  String getAutoRotationSource() {
    return cache.getString(AppConstants.keyAutoRotationSource) ?? 'favorites';
  }

  @override
  Future<void> setAutoRotationSource(String source) async {
    await cache.setString(AppConstants.keyAutoRotationSource, source);
  }

  @override
  bool isAutoRotationWifiOnly() {
    return cache.getBool(AppConstants.keyAutoRotationWifiOnly,
            defaultValue: true) ??
        true;
  }

  @override
  Future<void> setAutoRotationWifiOnly(bool wifiOnly) async {
    await cache.setBool(AppConstants.keyAutoRotationWifiOnly, wifiOnly);
  }

  @override
  String getAutoRotationTarget() {
    return cache.getString(AppConstants.keyAutoRotationTarget) ?? 'both';
  }

  @override
  Future<void> setAutoRotationTarget(String target) async {
    await cache.setString(AppConstants.keyAutoRotationTarget, target);
  }

  // --- Recently Viewed ---
  @override
  List<String> getRecentlyViewed() {
    return cache.getStringList(AppConstants.keyRecentlyViewed) ?? [];
  }

  @override
  Future<void> recordRecentlyViewed(String wallpaperId) async {
    final list = getRecentlyViewed().toList();
    list.remove(wallpaperId);
    list.insert(0, wallpaperId);
    if (list.length > AppConstants.maxRecentlyViewedHistory) {
      list.removeRange(AppConstants.maxRecentlyViewedHistory, list.length);
    }
    await cache.setStringList(AppConstants.keyRecentlyViewed, list);
  }

  // --- Reported Wallpapers ---
  @override
  Set<String> getReportedWallpaperIds() {
    final list = cache.getStringList(AppConstants.keyReported) ?? [];
    return list.toSet();
  }

  @override
  Set<String> getReportedIds() => getReportedWallpaperIds();

  @override
  Future<void> reportWallpaper(String shortId, [String? reason]) async {
    final current = getReportedWallpaperIds();
    current.add(shortId);
    await cache.setStringList(AppConstants.keyReported, current.toList());
  }

  // --- Onboarding ---
  @override
  bool hasSeenOnboarding() {
    return cache.getBool(AppConstants.keyHasSeenOnboarding,
            defaultValue: false) ??
        false;
  }

  @override
  Future<void> setHasSeenOnboarding(bool seen) async {
    await cache.setBool(AppConstants.keyHasSeenOnboarding, seen);
  }
}
