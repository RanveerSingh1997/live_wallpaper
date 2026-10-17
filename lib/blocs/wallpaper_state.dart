import 'package:equatable/equatable.dart';
import '../models/motivational_short.dart';

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
  final int activeIndex;
  final String selectedCategory;
  final Set<String> favoriteIds;
  final Set<String> downloadedIds;
  final Map<String, String> customizedQuotes;
  final bool isFeedMuted;
  final bool isLiveWallpaperActiveOnDevice;
  final String? activeWallpaperId;
  final WallpaperActionStatus actionStatus;
  final Set<String> userPreferences;
  final bool isTextOverlayVisible;
  final int currentNavigationTab;
  final String searchQuery;
  final int totalStorageUsedBytes;
  final String? message;
  final String? errorMessage;

  const WallpaperState({
    this.allShorts = const [],
    this.filteredShorts = const [],
    this.activeIndex = 0,
    this.selectedCategory = 'For You',
    this.favoriteIds = const {},
    this.downloadedIds = const {},
    this.customizedQuotes = const {},
    this.isFeedMuted = true,
    this.isLiveWallpaperActiveOnDevice = false,
    this.activeWallpaperId,
    this.actionStatus = WallpaperActionStatus.idle,
    this.userPreferences = const {},
    this.isTextOverlayVisible = true,
    this.currentNavigationTab = 0,
    this.searchQuery = '',
    this.totalStorageUsedBytes = 0,
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

  /// Get the effective quote for any short (either user customized or default).
  String getEffectiveQuote(MotivationalShort short) {
    return customizedQuotes[short.id] ?? short.quote;
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

  /// Formatted storage string (e.g. "12.4 MB").
  String get storageFormatted {
    if (totalStorageUsedBytes < 1024 * 1024) {
      return '${(totalStorageUsedBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(totalStorageUsedBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  WallpaperState copyWith({
    List<MotivationalShort>? allShorts,
    List<MotivationalShort>? filteredShorts,
    int? activeIndex,
    String? selectedCategory,
    Set<String>? favoriteIds,
    Set<String>? downloadedIds,
    Map<String, String>? customizedQuotes,
    bool? isFeedMuted,
    bool? isLiveWallpaperActiveOnDevice,
    String? activeWallpaperId,
    WallpaperActionStatus? actionStatus,
    Set<String>? userPreferences,
    bool? isTextOverlayVisible,
    int? currentNavigationTab,
    String? searchQuery,
    int? totalStorageUsedBytes,
    String? message,
    String? errorMessage,
  }) {
    return WallpaperState(
      allShorts: allShorts ?? this.allShorts,
      filteredShorts: filteredShorts ?? this.filteredShorts,
      activeIndex: activeIndex ?? this.activeIndex,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      downloadedIds: downloadedIds ?? this.downloadedIds,
      customizedQuotes: customizedQuotes ?? this.customizedQuotes,
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
      message: message,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        allShorts,
        filteredShorts,
        activeIndex,
        selectedCategory,
        favoriteIds,
        downloadedIds,
        customizedQuotes,
        isFeedMuted,
        isLiveWallpaperActiveOnDevice,
        activeWallpaperId,
        actionStatus,
        userPreferences,
        isTextOverlayVisible,
        currentNavigationTab,
        searchQuery,
        totalStorageUsedBytes,
        message,
        errorMessage,
      ];
}
