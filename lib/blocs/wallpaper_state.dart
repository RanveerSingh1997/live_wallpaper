import 'package:equatable/equatable.dart';
import '../data/curated_shorts_data.dart';
import '../models/battery_telemetry_config.dart';
import '../models/day_night_schedule_config.dart';
import '../models/lock_screen_style_config.dart';
import '../models/motivational_short.dart';
import '../models/parallax_effect_config.dart';
import '../models/smart_filter_config.dart';
import '../models/wallpaper_collection.dart';
import '../models/wallpaper_effect_config.dart';

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
  final SmartFilterConfig smartFilter;
  final BatteryTelemetryConfig batteryTelemetry;
  final bool isFeedMuted;
  final bool isLiveWallpaperActiveOnDevice;
  final String? activeWallpaperId;
  final WallpaperActionStatus actionStatus;
  final Set<String> userPreferences;
  final bool isTextOverlayVisible;
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
    this.smartFilter = SmartFilterConfig.defaultConfig,
    this.batteryTelemetry = BatteryTelemetryConfig.defaultConfig,
    this.isFeedMuted = true,
    this.isLiveWallpaperActiveOnDevice = false,
    this.activeWallpaperId,
    this.actionStatus = WallpaperActionStatus.idle,
    this.userPreferences = const {},
    this.isTextOverlayVisible = true,
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

  /// All collections (user custom collections merged with curated editorial collections).
  List<WallpaperCollection> get allCollections =>
      [...customCollections, ...CuratedShortsData.collections];

  /// Returns the pool of wallpapers available for auto-rotation based on the source setting.
  List<MotivationalShort> get rotationPoolShorts {
    if (autoRotationSource == 'favorites') {
      return favoriteShorts.isNotEmpty ? favoriteShorts : allShorts;
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
    SmartFilterConfig? smartFilter,
    BatteryTelemetryConfig? batteryTelemetry,
    bool? isFeedMuted,
    bool? isLiveWallpaperActiveOnDevice,
    String? activeWallpaperId,
    WallpaperActionStatus? actionStatus,
    Set<String>? userPreferences,
    bool? isTextOverlayVisible,
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
      smartFilter: smartFilter ?? this.smartFilter,
      batteryTelemetry: batteryTelemetry ?? this.batteryTelemetry,
      isFeedMuted: isFeedMuted ?? this.isFeedMuted,
      isLiveWallpaperActiveOnDevice:
          isLiveWallpaperActiveOnDevice ?? this.isLiveWallpaperActiveOnDevice,
      activeWallpaperId: activeWallpaperId ?? this.activeWallpaperId,
      actionStatus: actionStatus ?? this.actionStatus,
      userPreferences: userPreferences ?? this.userPreferences,
      isTextOverlayVisible: isTextOverlayVisible ?? this.isTextOverlayVisible,
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
        smartFilter,
        batteryTelemetry,
        isFeedMuted,
        isLiveWallpaperActiveOnDevice,
        activeWallpaperId,
        actionStatus,
        userPreferences,
        isTextOverlayVisible,
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
        message,
        errorMessage,
      ];
}
