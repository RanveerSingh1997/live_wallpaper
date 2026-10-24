import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/core.dart';
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
import '../models/wallaza_cloud_wallpaper.dart';
import '../models/wallora_backup_bundle.dart';
import '../models/wallora_screen_blueprint.dart';
import '../models/wallpaper_collection.dart';
import '../models/wallpaper_effect_config.dart';
import '../models/weather_atmosphere_config.dart';
import '../services/wallaza_api_service.dart';
import '../services/wallpaper_renderer_service.dart';
import '../services/wallpaper_service_bridge.dart';
import 'catalog_repository.dart';
import 'community_blueprint_repository.dart';
import 'data_portability_repository.dart';
import 'download_repository.dart';
import 'playlist_repository.dart';
import 'studio_config_repository.dart';

/// Abstract contract for the unified Wallpaper repository facade.
/// Follows Dependency Inversion Principle (DIP) and Facade Pattern.
abstract class WallpaperFacadeRepository {
  // Studio settings
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

  BatteryTelemetryConfig getBatteryTelemetryConfig();
  Future<void> saveBatteryTelemetryConfig(BatteryTelemetryConfig config);
  Future<void> resetBatteryTelemetryConfig();

  ParticleEffectConfig getParticleEffectConfig();
  Future<void> saveParticleEffectConfig(ParticleEffectConfig config);
  Future<void> resetParticleEffectConfig();

  SmartFilterConfig getSmartFilterConfig();
  Future<void> saveSmartFilterConfig(SmartFilterConfig config);
  Future<void> resetSmartFilterConfig();

  ParallaxEffectConfig getParallaxEffectConfig();
  Future<void> saveParallaxEffectConfig(ParallaxEffectConfig config);
  Future<void> resetParallaxEffectConfig();

  LockScreenStyleConfig getLockScreenStyleConfig();
  Future<void> saveLockScreenStyleConfig(LockScreenStyleConfig config);
  Future<void> resetLockScreenStyleConfig();

  DayNightScheduleConfig getDayNightScheduleConfig();
  Future<void> saveDayNightScheduleConfig(DayNightScheduleConfig config);
  Future<void> resetDayNightScheduleConfig();

  bool isAmoledSaverModeEnabled();
  Future<void> setAmoledSaverMode(bool enabled);

  bool hasSeenOnboarding();
  Future<void> setHasSeenOnboarding(bool seen);

  Set<String> getUserPreferences();
  Future<void> saveUserPreferences(Set<String> preferences);

  bool isTextOverlayEnabledByDefault();
  Future<void> setTextOverlayEnabled(bool enabled);

  Map<String, String> getCustomQuotes();
  Future<void> saveCustomQuote(String shortId, String quote);

  Map<String, WallpaperEffectConfig> getCustomEffects();
  Future<void> saveCustomEffect(String wallpaperId, WallpaperEffectConfig config);
  Future<void> resetCustomEffect(String wallpaperId);

  List<String> getRecentlyViewed();
  Future<void> recordRecentlyViewed(String id);

  Set<String> getReportedIds();
  Future<void> reportWallpaper(String id, String reason);

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

  // Playlists & Favorites
  Set<String> getFavorites();
  Future<Set<String>> toggleFavorite(String shortId);
  List<WallpaperCollection> getCustomCollections();
  Future<void> saveCustomCollection(WallpaperCollection collection);
  Future<void> deleteCustomCollection(String collectionId);
  Future<WallpaperCollection?> toggleWallpaperInCollection(
    String collectionId,
    String wallpaperId,
  );

  // Catalog & Wallpapers
  List<MotivationalShort> getCuratedShorts();
  List<MotivationalShort> getCustomImportedWallpapers();
  Future<void> saveCustomImportedWallpaper(MotivationalShort short);
  String? getActiveWallpaperId();
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
  Future<String> prepareVideoFile(MotivationalShort short);
  Future<File> renderStaticWallpaperFile({
    required MotivationalShort short,
    String? customQuote,
    WallpaperEffectConfig? effectConfig,
  });

  // Downloads & Cache
  Set<String> getDownloads();
  Future<bool> downloadWallpaper(MotivationalShort short);
  Future<bool> deleteDownload(String shortId);
  Future<void> clearAllDownloads();
  Future<int> getTotalDownloadSizeBytes();
  void prefetchFeed({
    required int currentIndex,
    required List<MotivationalShort> shorts,
    bool wifiOnly = false,
  });

  // Community Blueprints
  List<WalloraScreenBlueprint> getCommunityBlueprints();
  Future<void> savePublishedBlueprint(WalloraScreenBlueprint blueprint);
  Set<String> getLikedBlueprintIds();
  Future<Set<String>> toggleBlueprintLike(String blueprintId);

  // Data Portability
  Future<WalloraBackupBundle> createBackupBundle();
  Future<bool> restoreBackupBundle(
    WalloraBackupBundle bundle, {
    bool mergeWithExisting = false,
  });
  Future<void> resetToFactoryDefaults();

  // Cloud APIs
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
  Future<MotivationalShort> importCloudWallpaper(
    WallazaCloudWallpaper cloudItem,
  );

  // Device Bridge
  Future<bool> isWallpaperActiveOnDevice();
  Future<void> shareVideo(MotivationalShort short);
  Future<void> openPhotos();
  Future<void> setWallpaperAudioMuted(bool isMuted);
  Future<void> openChooser();
  Future<String?> getInitialDeepLink();
  Stream<String> get onDeepLinkReceived;
  Future<Map<String, dynamic>> getHardwareBatteryInfo();
}

/// Unified aggregate facade coordinating domain sub-repositories.
/// Adheres strictly to SOLID principles:
/// - Single Responsibility Principle (SRP): Delegates to domain-specific repositories.
/// - Open/Closed Principle (OCP): Sub-repositories can be swapped or extended without editing the facade.
/// - Liskov Substitution Principle (LSP): Fully substitutable by test fakes.
/// - Interface Segregation Principle (ISP): Sub-repositories expose focused interfaces.
/// - Dependency Inversion Principle (DIP): Depends on abstract repository and cache contracts.
class WallpaperRepository implements WallpaperFacadeRepository {
  final WallpaperServiceBridge _bridge;
  final SharedPreferences prefs;
  final WallazaApiService wallazaService;

  final LocalCacheService cache;
  final LruStorageManager lruManager;
  final NetworkConnectivityService connectivity;
  final FeedPrefetchManager feedPrefetchManager;
  final CatalogRepository catalog;
  final PlaylistRepository playlist;
  final DownloadRepository download;
  final StudioConfigRepository studio;
  final CommunityBlueprintRepository community;
  final DataPortabilityRepository portability;

  WallpaperRepository({
    required this.prefs,
    WallpaperServiceBridge? bridge,
    WallazaApiService? wallazaService,
    LocalCacheService? cache,
    LruStorageManager? lruManager,
    NetworkConnectivityService? connectivity,
    FeedPrefetchManager? feedPrefetchManager,
    CatalogRepository? catalog,
    PlaylistRepository? playlist,
    DownloadRepository? download,
    StudioConfigRepository? studio,
    CommunityBlueprintRepository? community,
    DataPortabilityRepository? portability,
  })  : _bridge = bridge ?? WallpaperServiceBridge(),
        wallazaService = wallazaService ?? WallazaApiService(),
        cache = cache ?? SharedPreferencesCacheService(prefs: prefs),
        lruManager = lruManager ??
            LruStorageManager(
              cache: cache ?? SharedPreferencesCacheService(prefs: prefs),
            ),
        connectivity = connectivity ?? DefaultNetworkConnectivityService(),
        feedPrefetchManager = feedPrefetchManager ??
            FeedPrefetchManager(
              cache: cache ?? SharedPreferencesCacheService(prefs: prefs),
              lruManager: lruManager ??
                  LruStorageManager(
                    cache: cache ?? SharedPreferencesCacheService(prefs: prefs),
                  ),
              apiService: wallazaService ?? WallazaApiService(),
              connectivity: connectivity ?? DefaultNetworkConnectivityService(),
            ),
        catalog = catalog ??
            CatalogRepository(
              cache: cache ?? SharedPreferencesCacheService(prefs: prefs),
              bridge: bridge ?? WallpaperServiceBridge(),
              wallazaService: wallazaService ?? WallazaApiService(),
            ),
        playlist = playlist ??
            PlaylistRepository(
              cache: cache ?? SharedPreferencesCacheService(prefs: prefs),
            ),
        download = download ??
            DownloadRepository(
              cache: cache ?? SharedPreferencesCacheService(prefs: prefs),
              wallazaService: wallazaService ?? WallazaApiService(),
              lruManager: lruManager ??
                  LruStorageManager(
                    cache: cache ?? SharedPreferencesCacheService(prefs: prefs),
                  ),
            ),
        studio = studio ??
            StudioConfigRepository(
              cache: cache ?? SharedPreferencesCacheService(prefs: prefs),
            ),
        community = community ??
            CommunityBlueprintRepository(
              cache: cache ?? SharedPreferencesCacheService(prefs: prefs),
            ),
        portability = portability ??
            DataPortabilityRepository(
              cache: cache ?? SharedPreferencesCacheService(prefs: prefs),
              playlistRepo: playlist ??
                  PlaylistRepository(
                    cache: cache ?? SharedPreferencesCacheService(prefs: prefs),
                  ),
              studioRepo: studio ??
                  StudioConfigRepository(
                    cache: cache ?? SharedPreferencesCacheService(prefs: prefs),
                  ),
            );

  // ==========================================
  // Studio Configurations & Schedules
  // ==========================================

  @override
  AuraPaletteConfig getAuraPaletteConfig() => studio.getAuraPaletteConfig();

  @override
  Future<void> saveAuraPaletteConfig(AuraPaletteConfig config) =>
      studio.saveAuraPaletteConfig(config);

  @override
  Future<void> resetAuraPaletteConfig() => studio.resetAuraPaletteConfig();

  @override
  GestureControlConfig getGestureControlConfig() =>
      studio.getGestureControlConfig();

  @override
  Future<void> saveGestureControlConfig(GestureControlConfig config) =>
      studio.saveGestureControlConfig(config);

  @override
  Future<void> resetGestureControlConfig() =>
      studio.resetGestureControlConfig();

  @override
  StandbyDockConfig getStandbyDockConfig() => studio.getStandbyDockConfig();

  @override
  Future<void> saveStandbyDockConfig(StandbyDockConfig config) =>
      studio.saveStandbyDockConfig(config);

  @override
  Future<void> resetStandbyDockConfig() => studio.resetStandbyDockConfig();

  @override
  AuroraSynthesizerConfig getAuroraSynthesizerConfig() =>
      studio.getAuroraSynthesizerConfig();

  @override
  Future<void> saveAuroraSynthesizerConfig(AuroraSynthesizerConfig config) =>
      studio.saveAuroraSynthesizerConfig(config);

  @override
  Future<void> resetAuroraSynthesizerConfig() =>
      studio.resetAuroraSynthesizerConfig();

  @override
  WeatherAtmosphereConfig getWeatherAtmosphereConfig() =>
      studio.getWeatherAtmosphereConfig();

  @override
  Future<void> saveWeatherAtmosphereConfig(WeatherAtmosphereConfig config) =>
      studio.saveWeatherAtmosphereConfig(config);

  @override
  Future<void> resetWeatherAtmosphereConfig() =>
      studio.resetWeatherAtmosphereConfig();

  @override
  BatteryTelemetryConfig getBatteryTelemetryConfig() =>
      studio.getBatteryTelemetryConfig();

  @override
  Future<void> saveBatteryTelemetryConfig(BatteryTelemetryConfig config) =>
      studio.saveBatteryTelemetryConfig(config);

  @override
  Future<void> resetBatteryTelemetryConfig() =>
      studio.resetBatteryTelemetryConfig();

  @override
  ParticleEffectConfig getParticleEffectConfig() =>
      studio.getParticleEffectConfig();

  @override
  Future<void> saveParticleEffectConfig(ParticleEffectConfig config) =>
      studio.saveParticleEffectConfig(config);

  @override
  Future<void> resetParticleEffectConfig() =>
      studio.resetParticleEffectConfig();

  @override
  SmartFilterConfig getSmartFilterConfig() => studio.getSmartFilterConfig();

  @override
  Future<void> saveSmartFilterConfig(SmartFilterConfig config) =>
      studio.saveSmartFilterConfig(config);

  @override
  Future<void> resetSmartFilterConfig() => studio.resetSmartFilterConfig();

  @override
  ParallaxEffectConfig getParallaxEffectConfig() =>
      studio.getParallaxEffectConfig();

  @override
  Future<void> saveParallaxEffectConfig(ParallaxEffectConfig config) =>
      studio.saveParallaxEffectConfig(config);

  @override
  Future<void> resetParallaxEffectConfig() =>
      studio.resetParallaxEffectConfig();

  @override
  LockScreenStyleConfig getLockScreenStyleConfig() =>
      studio.getLockScreenStyleConfig();

  @override
  Future<void> saveLockScreenStyleConfig(LockScreenStyleConfig config) =>
      studio.saveLockScreenStyleConfig(config);

  @override
  Future<void> resetLockScreenStyleConfig() =>
      studio.resetLockScreenStyleConfig();

  @override
  DayNightScheduleConfig getDayNightScheduleConfig() =>
      studio.getDayNightScheduleConfig();

  @override
  Future<void> saveDayNightScheduleConfig(DayNightScheduleConfig config) =>
      studio.saveDayNightScheduleConfig(config);

  @override
  Future<void> resetDayNightScheduleConfig() =>
      studio.resetDayNightScheduleConfig();

  @override
  bool isAmoledSaverModeEnabled() => studio.isAmoledSaverModeEnabled();

  @override
  Future<void> setAmoledSaverMode(bool enabled) =>
      studio.setAmoledSaverMode(enabled);

  @override
  bool hasSeenOnboarding() => studio.hasSeenOnboarding();

  @override
  Future<void> setHasSeenOnboarding(bool seen) =>
      studio.setHasSeenOnboarding(seen);

  @override
  Set<String> getUserPreferences() => studio.getUserPreferences();

  @override
  Future<void> saveUserPreferences(Set<String> preferences) =>
      studio.saveUserPreferences(preferences);

  @override
  bool isTextOverlayEnabledByDefault() =>
      studio.isTextOverlayEnabledByDefault();

  @override
  Future<void> setTextOverlayEnabled(bool enabled) =>
      studio.setTextOverlayEnabled(enabled);

  @override
  Map<String, String> getCustomQuotes() => studio.getCustomQuotes();

  @override
  Future<void> saveCustomQuote(String shortId, String quote) =>
      studio.saveCustomQuote(shortId, quote);

  @override
  Map<String, WallpaperEffectConfig> getCustomEffects() =>
      studio.getCustomEffects();

  @override
  Future<void> saveCustomEffect(
    String wallpaperId,
    WallpaperEffectConfig config,
  ) =>
      studio.saveCustomEffect(wallpaperId, config);

  @override
  Future<void> resetCustomEffect(String wallpaperId) =>
      studio.resetCustomEffect(wallpaperId);

  @override
  List<String> getRecentlyViewed() => studio.getRecentlyViewed();

  @override
  Future<void> recordRecentlyViewed(String id) =>
      studio.recordRecentlyViewed(id);

  @override
  Set<String> getReportedIds() => studio.getReportedIds();

  @override
  Future<void> reportWallpaper(String id, String reason) =>
      studio.reportWallpaper(id, reason);

  @override
  bool isAutoRotationEnabled() => studio.isAutoRotationEnabled();

  @override
  Future<void> setAutoRotationEnabled(bool enabled) =>
      studio.setAutoRotationEnabled(enabled);

  @override
  int getAutoRotationIntervalMinutes() =>
      studio.getAutoRotationIntervalMinutes();

  @override
  Future<void> setAutoRotationIntervalMinutes(int minutes) =>
      studio.setAutoRotationIntervalMinutes(minutes);

  @override
  String getAutoRotationSource() => studio.getAutoRotationSource();

  @override
  Future<void> setAutoRotationSource(String source) =>
      studio.setAutoRotationSource(source);

  @override
  bool isAutoRotationWifiOnly() => studio.isAutoRotationWifiOnly();

  @override
  Future<void> setAutoRotationWifiOnly(bool wifiOnly) =>
      studio.setAutoRotationWifiOnly(wifiOnly);

  @override
  String getAutoRotationTarget() => studio.getAutoRotationTarget();

  @override
  Future<void> setAutoRotationTarget(String target) =>
      studio.setAutoRotationTarget(target);

  // ==========================================
  // Playlists, Favorites, and Collections
  // ==========================================

  @override
  Set<String> getFavorites() => playlist.getFavorites();

  @override
  Future<Set<String>> toggleFavorite(String shortId) async {
    await playlist.toggleFavorite(shortId);
    return playlist.getFavorites();
  }

  @override
  List<WallpaperCollection> getCustomCollections() =>
      playlist.getCustomCollections();

  @override
  Future<void> saveCustomCollection(WallpaperCollection collection) =>
      playlist.saveCollection(collection);

  @override
  Future<void> deleteCustomCollection(String collectionId) =>
      playlist.deleteCollection(collectionId);

  @override
  Future<WallpaperCollection?> toggleWallpaperInCollection(
    String collectionId,
    String wallpaperId,
  ) async {
    final success = await playlist.toggleWallpaperInCollection(
      collectionId,
      wallpaperId,
    );
    if (!success) {
      // Check if collection exists
      final match = playlist
          .getCustomCollections()
          .where((c) => c.id == collectionId);
      if (match.isEmpty) return null;
      return match.first;
    }
    final match = playlist
        .getCustomCollections()
        .where((c) => c.id == collectionId);
    return match.isNotEmpty ? match.first : null;
  }

  // ==========================================
  // Wallpaper Catalog & Dynamic Rendering
  // ==========================================

  @override
  List<MotivationalShort> getCuratedShorts() => catalog.getCuratedShorts();

  @override
  List<MotivationalShort> getCustomImportedWallpapers() =>
      catalog.getCustomImportedWallpapers();

  @override
  Future<void> saveCustomImportedWallpaper(MotivationalShort short) =>
      catalog.saveCustomImportedWallpaper(short);

  Future<void> deleteCustomImportedWallpaper(String id) =>
      catalog.deleteCustomImportedWallpaper(id);

  @override
  String? getActiveWallpaperId() => catalog.getActiveWallpaperId();

  @override
  Future<Map<String, dynamic>> applyAsLiveWallpaper({
    required MotivationalShort short,
    bool isMuted = true,
  }) =>
      catalog.applyAsLiveWallpaper(short: short, isMuted: isMuted);

  @override
  Future<Map<String, dynamic>> applyStaticWallpaper({
    required MotivationalShort short,
    String targetScreen = 'both',
    String? customQuote,
    WallpaperEffectConfig? effectConfig,
  }) =>
      catalog.applyStaticWallpaper(
        short: short,
        targetScreen: targetScreen,
        customQuote: customQuote,
        effectConfig: effectConfig,
      );

  @override
  Future<String> prepareVideoFile(MotivationalShort short) async {
    final file = await catalog.prepareVideoFile(short);
    return file?.path ?? '';
  }

  @override
  Future<File> renderStaticWallpaperFile({
    required MotivationalShort short,
    String? customQuote,
    WallpaperEffectConfig? effectConfig,
  }) =>
      WallpaperRendererService.renderWallpaperToFile(
        wallpaper: short,
        quoteOverride: customQuote,
        effectConfig: effectConfig,
      );

  // ==========================================
  // Offline Downloads & Cache Management
  // ==========================================

  @override
  Set<String> getDownloads() => download.getDownloads();

  @override
  Future<bool> downloadWallpaper(MotivationalShort short) =>
      download.downloadWallpaper(short);

  @override
  Future<bool> deleteDownload(String shortId) =>
      download.deleteDownload(shortId);

  @override
  Future<void> clearAllDownloads() => download.clearAllDownloads();

  @override
  Future<int> getTotalDownloadSizeBytes() => download.getCacheSizeInBytes();

  @override
  void prefetchFeed({
    required int currentIndex,
    required List<MotivationalShort> shorts,
    bool wifiOnly = false,
  }) {
    unawaited(feedPrefetchManager.onFeedIndexChanged(
      currentIndex: currentIndex,
      shorts: shorts,
      wifiOnly: wifiOnly,
    ));
  }

  // ==========================================
  // Aesthetic Screen Blueprints & Community
  // ==========================================

  @override
  List<WalloraScreenBlueprint> getCommunityBlueprints() {
    final published = community.getPublishedBlueprints();
    final likedIds = community.getLikedBlueprintIds();
    final all = [...published, ...WalloraScreenBlueprint.curatedBlueprints];

    return all.map((bp) {
      if (likedIds.contains(bp.id)) {
        return bp.copyWith(likesCount: bp.likesCount + 1);
      }
      return bp;
    }).toList();
  }

  @override
  Future<void> savePublishedBlueprint(WalloraScreenBlueprint blueprint) =>
      community.publishBlueprint(blueprint);

  @override
  Set<String> getLikedBlueprintIds() => community.getLikedBlueprintIds();

  @override
  Future<Set<String>> toggleBlueprintLike(String blueprintId) async {
    await community.likeBlueprint(blueprintId);
    return community.getLikedBlueprintIds();
  }

  // ==========================================
  // Data Portability & Factory Reset
  // ==========================================

  @override
  Future<WalloraBackupBundle> createBackupBundle() =>
      portability.createBackupBundle();

  @override
  Future<bool> restoreBackupBundle(
    WalloraBackupBundle bundle, {
    bool mergeWithExisting = false,
  }) =>
      portability.restoreBackupBundle(bundle, mergeWithExisting: mergeWithExisting);

  @override
  Future<void> resetToFactoryDefaults() => portability.factoryResetData();

  // ==========================================
  // Wallaza Cloud Repository Integration
  // ==========================================

  @override
  Future<List<WallazaCloudWallpaper>> fetchCloudWallpapers({
    int page = 1,
    int limit = 20,
    String? category,
  }) =>
      wallazaService.fetchWallpapers(
        page: page,
        limit: limit,
        category: category,
      );

  @override
  Future<List<WallazaCloudWallpaper>> searchCloudWallpapers({
    required String query,
    String? resolution,
    int page = 1,
    int limit = 20,
  }) =>
      wallazaService.searchWallpapers(
        query: query,
        resolution: resolution,
        page: page,
        limit: limit,
      );

  @override
  Future<WallazaCloudWallpaper?> getCloudWallpaper(String id) =>
      wallazaService.getWallpaperById(id);

  @override
  Future<MotivationalShort> importCloudWallpaper(
    WallazaCloudWallpaper cloudItem,
  ) async {
    final short = cloudItem.toMotivationalShort();
    await saveCustomImportedWallpaper(short);
    return short;
  }

  // ==========================================
  // Native Platform Bridge Controls
  // ==========================================

  @override
  Future<bool> isWallpaperActiveOnDevice() => _bridge.isWallpaperActive();

  @override
  Future<void> shareVideo(MotivationalShort short) async {
    final String localVideoPath = await prepareVideoFile(short);
    await _bridge.shareVideo(localVideoPath);
  }

  @override
  Future<void> openPhotos() => _bridge.openPhotos();

  @override
  Future<void> setWallpaperAudioMuted(bool isMuted) =>
      _bridge.setAudioMuted(isMuted);

  @override
  Future<void> openChooser() => _bridge.openChooser();

  @override
  Future<String?> getInitialDeepLink() => _bridge.getInitialDeepLink();

  @override
  Stream<String> get onDeepLinkReceived => _bridge.onDeepLinkReceived;

  @override
  Future<Map<String, dynamic>> getHardwareBatteryInfo() =>
      _bridge.getHardwareBatteryInfo();
}
