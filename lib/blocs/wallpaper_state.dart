import 'package:equatable/equatable.dart';
import '../models/motivational_short.dart';

enum WallpaperActionStatus {
  idle,
  loading,
  applying,
  appliedSuccess,
  error,
}

class WallpaperState extends Equatable {
  final List<MotivationalShort> allShorts;
  final List<MotivationalShort> filteredShorts;
  final int activeIndex;
  final String selectedCategory;
  final Set<String> favoriteIds;
  final Map<String, String> customizedQuotes;
  final bool isFeedMuted;
  final bool isLiveWallpaperActiveOnDevice;
  final String? activeWallpaperId;
  final WallpaperActionStatus actionStatus;
  final String? message;
  final String? errorMessage;

  const WallpaperState({
    this.allShorts = const [],
    this.filteredShorts = const [],
    this.activeIndex = 0,
    this.selectedCategory = 'All',
    this.favoriteIds = const {},
    this.customizedQuotes = const {},
    this.isFeedMuted = true,
    this.isLiveWallpaperActiveOnDevice = false,
    this.activeWallpaperId,
    this.actionStatus = WallpaperActionStatus.idle,
    this.message,
    this.errorMessage,
  });

  /// The short currently active on screen.
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

  /// True if current short is currently applied as the device wallpaper.
  bool get isCurrentActiveWallpaper {
    final cur = currentShort;
    return cur != null && activeWallpaperId == cur.id && isLiveWallpaperActiveOnDevice;
  }

  WallpaperState copyWith({
    List<MotivationalShort>? allShorts,
    List<MotivationalShort>? filteredShorts,
    int? activeIndex,
    String? selectedCategory,
    Set<String>? favoriteIds,
    Map<String, String>? customizedQuotes,
    bool? isFeedMuted,
    bool? isLiveWallpaperActiveOnDevice,
    String? activeWallpaperId,
    WallpaperActionStatus? actionStatus,
    String? message,
    String? errorMessage,
  }) {
    return WallpaperState(
      allShorts: allShorts ?? this.allShorts,
      filteredShorts: filteredShorts ?? this.filteredShorts,
      activeIndex: activeIndex ?? this.activeIndex,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      customizedQuotes: customizedQuotes ?? this.customizedQuotes,
      isFeedMuted: isFeedMuted ?? this.isFeedMuted,
      isLiveWallpaperActiveOnDevice:
          isLiveWallpaperActiveOnDevice ?? this.isLiveWallpaperActiveOnDevice,
      activeWallpaperId: activeWallpaperId ?? this.activeWallpaperId,
      actionStatus: actionStatus ?? this.actionStatus,
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
        customizedQuotes,
        isFeedMuted,
        isLiveWallpaperActiveOnDevice,
        activeWallpaperId,
        actionStatus,
        message,
        errorMessage,
      ];
}
