import 'package:equatable/equatable.dart';
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
import '../models/wallora_screen_blueprint.dart';
import '../models/weather_atmosphere_config.dart';
import '../models/wallaza_cloud_wallpaper.dart';

enum WallpaperActionStatus {
  idle,
  loading,
  applying,
  appliedSuccess,
  downloading,
  downloadSuccess,
  error,
}

class WallpaperState extends Equatable {
  final List<MotivationalShort> allShorts;
  final List<MotivationalShort> filteredShorts;
  final List<WallpaperCollection> customCollections;
  final int activeIndex;
  final String selectedCategory;
  final Set<String> favoriteIds;
  final Set<String> downloadedIds;
  final List<String> recentlyViewedIds;
  final Set<String> reportedIds;
  final Map<String, String> customizedQuotes;
  final Map<String, WallpaperEffectConfig> customEffects;
  final DayNightScheduleConfig dayNightSchedule;
  final LockScreenStyleConfig lockScreenStyle;
  final ParallaxEffectConfig parallaxConfig;
  final ParticleEffectConfig particleConfig;
  final AuraPaletteConfig auraConfig;
  final GestureControlConfig gestureConfig;
  final StandbyDockConfig standbyDockConfig;
  final AuroraSynthesizerConfig auroraSynthesizerConfig;
  final SmartFilterConfig smartFilter;
  final BatteryTelemetryConfig batteryTelemetry;
  final WeatherAtmosphereConfig weatherConfig;
  final int deviceBatteryLevel;
  final bool isDeviceCharging;
  final bool isDevicePowerSaveMode;
  final bool isFeedMuted;
  final bool isLiveWallpaperActiveOnDevice;
  final String? activeWallpaperId;
  final WallpaperActionStatus actionStatus;
  final Set<String> userPreferences;
  final bool isTextOverlayVisible;
  final bool isCleanCanvasMode;
  final int currentNavigationTab;
  final String searchQuery;
  final int totalStorageUsedBytes;
  final bool hasSeenOnboarding;
  final bool isAutoRotationEnabled;
  final int autoRotationIntervalMinutes;
  final String autoRotationSource;
  final bool autoRotationWifiOnly;
  final String autoRotationTarget;
  final bool isAmoledSaverModeEnabled;
  final List<WalloraScreenBlueprint> communityBlueprints;
  final Set<String> likedBlueprintIds;
  final String communityTagFilter;
  final List<WallazaCloudWallpaper> cloudWallpapers;
  final bool isCloudLoading;
  final String? cloudErrorMessage;
  final String selectedCloudCategory;
  final String selectedCloudResolution;
  final String selectedCloudSort;
  final String? selectedCloudAuthor;
  final String cloudSearchQuery;
  final int cloudCurrentPage;
  final String? message;
  final String? errorMessage;

  const WallpaperState({
    this.allShorts = const [],
    this.filteredShorts = const [],
    this.customCollections = const [],
    this.activeIndex = 0,
    this.selectedCategory = 'For You',
    this.favoriteIds = const {},
    this.downloadedIds = const {},
    this.recentlyViewedIds = const [],
    this.reportedIds = const {},
    this.customizedQuotes = const {},
    this.customEffects = const {},
    this.dayNightSchedule = DayNightScheduleConfig.defaultConfig,
    this.lockScreenStyle = LockScreenStyleConfig.defaultConfig,
    this.parallaxConfig = ParallaxEffectConfig.defaultConfig,
    this.particleConfig = ParticleEffectConfig.defaultConfig,
    this.auraConfig = AuraPaletteConfig.defaultConfig,
    this.gestureConfig = GestureControlConfig.defaultConfig,
    this.standbyDockConfig = StandbyDockConfig.defaultConfig,
    this.auroraSynthesizerConfig = AuroraSynthesizerConfig.defaultConfig,
    this.smartFilter = SmartFilterConfig.defaultConfig,
    this.batteryTelemetry = BatteryTelemetryConfig.defaultConfig,
    this.weatherConfig = WeatherAtmosphereConfig.defaultConfig,
    this.deviceBatteryLevel = 100,
    this.isDeviceCharging = false,
    this.isDevicePowerSaveMode = false,
    this.isFeedMuted = true,
    this.isLiveWallpaperActiveOnDevice = false,
    this.activeWallpaperId,
    this.actionStatus = WallpaperActionStatus.idle,
    this.userPreferences = const {},
    this.isTextOverlayVisible = true,
    this.isCleanCanvasMode = false,
    this.currentNavigationTab = 0,
    this.searchQuery = '',
    this.totalStorageUsedBytes = 0,
    this.hasSeenOnboarding = true,
    this.isAutoRotationEnabled = false,
    this.autoRotationIntervalMinutes = 60,
    this.autoRotationSource = 'favorites',
    this.autoRotationWifiOnly = true,
    this.autoRotationTarget = 'both',
    this.isAmoledSaverModeEnabled = false,
    this.communityBlueprints = const [],
    this.likedBlueprintIds = const {},
    this.communityTagFilter = 'All',
    this.cloudWallpapers = const [],
    this.isCloudLoading = false,
    this.cloudErrorMessage,
    this.selectedCloudCategory = 'All',
    this.selectedCloudResolution = 'All',
    this.selectedCloudSort = 'curated',
    this.selectedCloudAuthor,
    this.cloudSearchQuery = '',
    this.cloudCurrentPage = 1,
    this.message,
    this.errorMessage,
  });

  /// The short currently active on screen in the vertical feed.
  MotivationalShort? get currentShort {
    if (filteredShorts.isEmpty || activeIndex < 0 || activeIndex >= filteredShorts.length) {
      return null;
    }
    return filteredShorts[activeIndex];
  }

  /// Returns the current active solar slot based on system clock.
  DayNightSlot get activeScheduleSlot =>
      dayNightSchedule.getSlotForTime(DateTime.now());

  /// Returns the wallpaper assigned to the current active solar slot.
  MotivationalShort? get currentScheduledWallpaper {
    final targetId = dayNightSchedule.getWallpaperIdForTime(DateTime.now());
    return allShorts.cast<MotivationalShort?>().firstWhere(
          (s) => s?.id == targetId,
          orElse: () => null,
        );
  }

  /// Get the effective quote for any short (either user customized or default).
  String getEffectiveQuote(MotivationalShort short) {
    return customizedQuotes[short.id] ?? short.quote;
  }

  /// Get the effective visual effects for any short (either user customized or default).
  WallpaperEffectConfig getEffectiveEffects(String wallpaperId) {
    return customEffects[wallpaperId] ?? WallpaperEffectConfig.defaultPreset;
  }

  /// True if current short is marked as a favorite.
  bool get isCurrentFavorite {
    final cur = currentShort;
    return cur != null && favoriteIds.contains(cur.id);
  }

  /// True if current short is downloaded offline.
  bool get isCurrentDownloaded {
    final cur = currentShort;
    return cur != null && downloadedIds.contains(cur.id);
  }

  /// True if current short is currently applied as the device wallpaper.
  bool get isCurrentActiveWallpaper {
    final cur = currentShort;
    return cur != null && activeWallpaperId == cur.id && isLiveWallpaperActiveOnDevice;
  }

  /// List of favorited wallpapers.
  List<MotivationalShort> get favoriteShorts {
    return allShorts.where((s) => favoriteIds.contains(s.id)).toList();
  }

  /// List of offline downloaded wallpapers.
  List<MotivationalShort> get downloadedShorts {
    return allShorts.where((s) => downloadedIds.contains(s.id)).toList();
  }

  /// List of recently viewed wallpapers in MRU order.
  List<MotivationalShort> get recentlyViewedShorts {
    final Map<String, MotivationalShort> map = {for (var s in allShorts) s.id: s};
    return recentlyViewedIds
        .map((id) => map[id])
        .whereType<MotivationalShort>()
        .toList();
  }

  /// All live wallpapers.
  List<MotivationalShort> get liveShorts {
    return allShorts.where((s) => s.isLive).toList();
  }

  /// All static wallpapers.
  List<MotivationalShort> get staticShorts {
    return allShorts.where((s) => !s.isLive).toList();
  }

  /// Wallpapers filtered by the active search query.
  List<MotivationalShort> get searchResults {
    if (searchQuery.trim().isEmpty) return allShorts;
    final q = searchQuery.toLowerCase().trim();
    return allShorts.where((s) {
      return s.title.toLowerCase().contains(q) ||
          s.category.toLowerCase().contains(q) ||
          s.mood.toLowerCase().contains(q) ||
          s.tags.toLowerCase().contains(q) ||
          s.author.toLowerCase().contains(q) ||
          s.quote.toLowerCase().contains(q);
    }).toList();
  }

  /// Wallpapers matching both the active search query and smart discovery filters.
  List<MotivationalShort> get discoveredShorts {
    final list = searchResults;
    if (!smartFilter.hasActiveFilters) return list;
    return list.where((s) => smartFilter.matches(s)).toList();
  }

  /// Formatted storage string (e.g. "12.4 MB").
  String get storageFormatted {
    if (totalStorageUsedBytes < 1024 * 1024) {
      return '${(totalStorageUsedBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(totalStorageUsedBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Returns cloud wallpapers optionally filtered by author and sorted by `selectedCloudSort`.
  List<WallazaCloudWallpaper> get sortedCloudWallpapers {
    var list = cloudWallpapers;
    if (selectedCloudAuthor != null && selectedCloudAuthor!.trim().isNotEmpty) {
      final a = selectedCloudAuthor!.toLowerCase().trim();
      list = list.where((item) {
        final name = item.authorName?.toLowerCase() ?? '';
        final username = item.authorUsername?.toLowerCase() ?? '';
        return name.contains(a) || username.contains(a);
      }).toList();
    } else {
      list = List.of(list);
    }

    switch (selectedCloudSort) {
      case 'popular':
        list.sort((a, b) => b.downloads.compareTo(a.downloads));
        break;
      case 'trending':
        list.sort((a, b) => b.favorites.compareTo(a.favorites));
        break;
      case 'newest':
        list.sort((a, b) {
          final da = a.createdAt ?? DateTime(2020);
          final db = b.createdAt ?? DateTime(2020);
          return db.compareTo(da);
        });
        break;
      case 'quality':
        list.sort((a, b) => b.fileSizeBytes.compareTo(a.fileSizeBytes));
        break;
      case 'curated':
      default:
        // Preserves incoming API / editorial sequence
        break;
    }
    return list;
  }

  /// All collections (user custom collections merged with curated editorial collections).
  List<WallpaperCollection> get allCollections =>
      [...customCollections, ...CuratedShortsData.collections];

  /// Returns the pool of wallpapers available for auto-rotation based on the source setting.
  List<MotivationalShort> get rotationPoolShorts {
    if (autoRotationSource == 'favorites') {
      return favoriteShorts.isNotEmpty ? favoriteShorts : allShorts;
    } else if (autoRotationSource == 'wallaza_cloud') {
      final source = cloudWallpapers.isNotEmpty
          ? cloudWallpapers
          : WallazaCloudWallpaper.curatedCloudLibrary;
      return source.map((c) => c.toMotivationalShort()).toList();
    } else if (autoRotationSource.startsWith('cloud_cat_')) {
      final cat = autoRotationSource.replaceFirst('cloud_cat_', '').toLowerCase();
      final source = cloudWallpapers.isNotEmpty
          ? cloudWallpapers
          : WallazaCloudWallpaper.curatedCloudLibrary;
      final filtered = source
          .where((c) => c.category.toLowerCase() == cat)
          .map((c) => c.toMotivationalShort())
          .toList();
      return filtered.isNotEmpty
          ? filtered
          : source.map((c) => c.toMotivationalShort()).toList();
    } else if (autoRotationSource.startsWith('col_') || autoRotationSource.startsWith('custom_col_')) {
      final col = allCollections.cast<WallpaperCollection?>().firstWhere(
        (c) => c?.id == autoRotationSource,
        orElse: () => null,
      );
      if (col != null) {
        final list = allShorts.where((s) => col.wallpaperIds.contains(s.id)).toList();
        if (list.isNotEmpty) return list;
      }
    }
    return allShorts;
  }

  /// Community blueprints filtered by the active tag filter or query.
  List<WalloraScreenBlueprint> get filteredBlueprints {
    if (communityTagFilter.isEmpty || communityTagFilter == 'All') {
      return communityBlueprints;
    }
    final q = communityTagFilter.toLowerCase().trim();
    return communityBlueprints.where((b) {
      final tagMatch = b.tags.any((t) => t.toLowerCase() == q || '#${t.toLowerCase()}' == q);
      final titleMatch = b.title.toLowerCase().contains(q);
      final creatorMatch = b.creatorName.toLowerCase().contains(q);
      return tagMatch || titleMatch || creatorMatch;
    }).toList();
  }

  WallpaperState copyWith({
    List<MotivationalShort>? allShorts,
    List<MotivationalShort>? filteredShorts,
    List<WallpaperCollection>? customCollections,
    int? activeIndex,
    String? selectedCategory,
    Set<String>? favoriteIds,
    Set<String>? downloadedIds,
    List<String>? recentlyViewedIds,
    Set<String>? reportedIds,
    Map<String, String>? customizedQuotes,
    Map<String, WallpaperEffectConfig>? customEffects,
    DayNightScheduleConfig? dayNightSchedule,
    LockScreenStyleConfig? lockScreenStyle,
    ParallaxEffectConfig? parallaxConfig,
    ParticleEffectConfig? particleConfig,
    AuraPaletteConfig? auraConfig,
    GestureControlConfig? gestureConfig,
    StandbyDockConfig? standbyDockConfig,
    AuroraSynthesizerConfig? auroraSynthesizerConfig,
    SmartFilterConfig? smartFilter,
    BatteryTelemetryConfig? batteryTelemetry,
    WeatherAtmosphereConfig? weatherConfig,
    int? deviceBatteryLevel,
    bool? isDeviceCharging,
    bool? isDevicePowerSaveMode,
    bool? isFeedMuted,
    bool? isLiveWallpaperActiveOnDevice,
    String? activeWallpaperId,
    WallpaperActionStatus? actionStatus,
    Set<String>? userPreferences,
    bool? isTextOverlayVisible,
    bool? isCleanCanvasMode,
    int? currentNavigationTab,
    String? searchQuery,
    int? totalStorageUsedBytes,
    bool? hasSeenOnboarding,
    bool? isAutoRotationEnabled,
    int? autoRotationIntervalMinutes,
    String? autoRotationSource,
    bool? autoRotationWifiOnly,
    String? autoRotationTarget,
    bool? isAmoledSaverModeEnabled,
    List<WalloraScreenBlueprint>? communityBlueprints,
    Set<String>? likedBlueprintIds,
    String? communityTagFilter,
    List<WallazaCloudWallpaper>? cloudWallpapers,
    bool? isCloudLoading,
    String? cloudErrorMessage,
    String? selectedCloudCategory,
    String? selectedCloudResolution,
    String? selectedCloudSort,
    String? selectedCloudAuthor,
    bool clearCloudAuthor = false,
    String? cloudSearchQuery,
    int? cloudCurrentPage,
    String? message,
    String? errorMessage,
  }) {
    return WallpaperState(
      allShorts: allShorts ?? this.allShorts,
      filteredShorts: filteredShorts ?? this.filteredShorts,
      customCollections: customCollections ?? this.customCollections,
      activeIndex: activeIndex ?? this.activeIndex,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      downloadedIds: downloadedIds ?? this.downloadedIds,
      recentlyViewedIds: recentlyViewedIds ?? this.recentlyViewedIds,
      reportedIds: reportedIds ?? this.reportedIds,
      customizedQuotes: customizedQuotes ?? this.customizedQuotes,
      customEffects: customEffects ?? this.customEffects,
      dayNightSchedule: dayNightSchedule ?? this.dayNightSchedule,
      lockScreenStyle: lockScreenStyle ?? this.lockScreenStyle,
      parallaxConfig: parallaxConfig ?? this.parallaxConfig,
      particleConfig: particleConfig ?? this.particleConfig,
      auraConfig: auraConfig ?? this.auraConfig,
      gestureConfig: gestureConfig ?? this.gestureConfig,
      standbyDockConfig: standbyDockConfig ?? this.standbyDockConfig,
      auroraSynthesizerConfig:
          auroraSynthesizerConfig ?? this.auroraSynthesizerConfig,
      smartFilter: smartFilter ?? this.smartFilter,
      batteryTelemetry: batteryTelemetry ?? this.batteryTelemetry,
      weatherConfig: weatherConfig ?? this.weatherConfig,
      deviceBatteryLevel: deviceBatteryLevel ?? this.deviceBatteryLevel,
      isDeviceCharging: isDeviceCharging ?? this.isDeviceCharging,
      isDevicePowerSaveMode:
          isDevicePowerSaveMode ?? this.isDevicePowerSaveMode,
      isFeedMuted: isFeedMuted ?? this.isFeedMuted,
      isLiveWallpaperActiveOnDevice:
          isLiveWallpaperActiveOnDevice ?? this.isLiveWallpaperActiveOnDevice,
      activeWallpaperId: activeWallpaperId ?? this.activeWallpaperId,
      actionStatus: actionStatus ?? this.actionStatus,
      userPreferences: userPreferences ?? this.userPreferences,
      isTextOverlayVisible: isTextOverlayVisible ?? this.isTextOverlayVisible,
      isCleanCanvasMode: isCleanCanvasMode ?? this.isCleanCanvasMode,
      currentNavigationTab: currentNavigationTab ?? this.currentNavigationTab,
      searchQuery: searchQuery ?? this.searchQuery,
      totalStorageUsedBytes: totalStorageUsedBytes ?? this.totalStorageUsedBytes,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      isAutoRotationEnabled: isAutoRotationEnabled ?? this.isAutoRotationEnabled,
      autoRotationIntervalMinutes:
          autoRotationIntervalMinutes ?? this.autoRotationIntervalMinutes,
      autoRotationSource: autoRotationSource ?? this.autoRotationSource,
      autoRotationWifiOnly: autoRotationWifiOnly ?? this.autoRotationWifiOnly,
      autoRotationTarget: autoRotationTarget ?? this.autoRotationTarget,
      isAmoledSaverModeEnabled:
          isAmoledSaverModeEnabled ?? this.isAmoledSaverModeEnabled,
      communityBlueprints: communityBlueprints ?? this.communityBlueprints,
      likedBlueprintIds: likedBlueprintIds ?? this.likedBlueprintIds,
      communityTagFilter: communityTagFilter ?? this.communityTagFilter,
      cloudWallpapers: cloudWallpapers ?? this.cloudWallpapers,
      isCloudLoading: isCloudLoading ?? this.isCloudLoading,
      cloudErrorMessage: cloudErrorMessage,
      selectedCloudCategory:
          selectedCloudCategory ?? this.selectedCloudCategory,
      selectedCloudResolution:
          selectedCloudResolution ?? this.selectedCloudResolution,
      selectedCloudSort: selectedCloudSort ?? this.selectedCloudSort,
      selectedCloudAuthor: clearCloudAuthor
          ? null
          : (selectedCloudAuthor ?? this.selectedCloudAuthor),
      cloudSearchQuery: cloudSearchQuery ?? this.cloudSearchQuery,
      cloudCurrentPage: cloudCurrentPage ?? this.cloudCurrentPage,
      message: message,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        allShorts,
        filteredShorts,
        customCollections,
        activeIndex,
        selectedCategory,
        favoriteIds,
        downloadedIds,
        recentlyViewedIds,
        reportedIds,
        customizedQuotes,
        customEffects,
        dayNightSchedule,
        lockScreenStyle,
        parallaxConfig,
        particleConfig,
        auraConfig,
        gestureConfig,
        standbyDockConfig,
        auroraSynthesizerConfig,
        smartFilter,
        batteryTelemetry,
        weatherConfig,
        deviceBatteryLevel,
        isDeviceCharging,
        isDevicePowerSaveMode,
        isFeedMuted,
        isLiveWallpaperActiveOnDevice,
        activeWallpaperId,
        actionStatus,
        userPreferences,
        isTextOverlayVisible,
        isCleanCanvasMode,
        currentNavigationTab,
        searchQuery,
        totalStorageUsedBytes,
        hasSeenOnboarding,
        isAutoRotationEnabled,
        autoRotationIntervalMinutes,
        autoRotationSource,
        autoRotationWifiOnly,
        autoRotationTarget,
        isAmoledSaverModeEnabled,
        communityBlueprints,
        likedBlueprintIds,
        communityTagFilter,
        cloudWallpapers,
        isCloudLoading,
        cloudErrorMessage,
        selectedCloudCategory,
        selectedCloudResolution,
        selectedCloudSort,
        selectedCloudAuthor,
        cloudSearchQuery,
        cloudCurrentPage,
        message,
        errorMessage,
      ];
}
