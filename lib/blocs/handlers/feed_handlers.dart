import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/wallaza_cloud_wallpaper.dart';
import '../../repositories/wallpaper_repository.dart';
import '../wallpaper_intent.dart';
import '../wallpaper_state.dart';
import 'wallpaper_feed_filter.dart';

mixin FeedHandlers on Bloc<WallpaperIntent, WallpaperState> {
  WallpaperFacadeRepository get repository;

  Future<void> onLoadFeed(
    LoadFeedIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    emit(state.copyWith(actionStatus: WallpaperActionStatus.loading));
    try {
      final shorts = repository.getCuratedShorts();
      final favorites = repository.getFavorites();
      final downloads = repository.getDownloads();
      final customCollections = repository.getCustomCollections();
      final quotes = repository.getCustomQuotes();
      final activeId = repository.getActiveWallpaperId();
      final preferences = repository.getUserPreferences();
      final isTextOverlayVisible = repository.isTextOverlayEnabledByDefault();
      final isActiveOnDevice = await repository.isWallpaperActiveOnDevice();
      final totalStorage = await repository.getTotalDownloadSizeBytes();
      final recentlyViewed = repository.getRecentlyViewed();
      final reported = repository.getReportedIds();
      final hasSeenOnboarding = repository.hasSeenOnboarding();
      final isAutoRotationEnabled = repository.isAutoRotationEnabled();
      final autoRotationInterval = repository.getAutoRotationIntervalMinutes();
      final autoRotationSource = repository.getAutoRotationSource();
      final autoRotationWifiOnly = repository.isAutoRotationWifiOnly();
      final autoRotationTarget = repository.getAutoRotationTarget();
      final isAmoledSaver = repository.isAmoledSaverModeEnabled();
      final effects = repository.getCustomEffects();
      final dayNightSchedule = repository.getDayNightScheduleConfig();
      final lockScreenStyle = repository.getLockScreenStyleConfig();
      final parallaxConfig = repository.getParallaxEffectConfig();
      final particleConfig = repository.getParticleEffectConfig();
      final auraConfig = repository.getAuraPaletteConfig();
      final gestureConfig = repository.getGestureControlConfig();
      final standbyDock = repository.getStandbyDockConfig();
      final auroraSynthesizer = repository.getAuroraSynthesizerConfig();
      final smartFilter = repository.getSmartFilterConfig();
      final batteryTelemetry = repository.getBatteryTelemetryConfig();
      final weatherConfig = repository.getWeatherAtmosphereConfig();
      final communityBlueprints = repository.getCommunityBlueprints();
      final likedBlueprintIds = repository.getLikedBlueprintIds();

      List<WallazaCloudWallpaper> initialCloud = const [];
      try {
        initialCloud = await repository.fetchCloudWallpapers();
      } catch (_) {}

      final forYouList = WallpaperFeedFilter.filterShorts(
        allShorts: shorts,
        category: 'For You',
        preferences: preferences,
        smartFilter: smartFilter,
      );

      emit(state.copyWith(
        allShorts: shorts,
        filteredShorts: forYouList,
        customCollections: customCollections,
        activeIndex: 0,
        selectedCategory: 'For You',
        favoriteIds: favorites,
        downloadedIds: downloads,
        recentlyViewedIds: recentlyViewed,
        reportedIds: reported,
        customizedQuotes: quotes,
        customEffects: effects,
        dayNightSchedule: dayNightSchedule,
        lockScreenStyle: lockScreenStyle,
        parallaxConfig: parallaxConfig,
        particleConfig: particleConfig,
        auraConfig: auraConfig,
        gestureConfig: gestureConfig,
        standbyDockConfig: standbyDock,
        auroraSynthesizerConfig: auroraSynthesizer,
        smartFilter: smartFilter,
        batteryTelemetry: batteryTelemetry,
        weatherConfig: weatherConfig,
        communityBlueprints: communityBlueprints,
        likedBlueprintIds: likedBlueprintIds,
        cloudWallpapers: initialCloud,
        activeWallpaperId: activeId,
        userPreferences: preferences,
        isTextOverlayVisible: isTextOverlayVisible,
        isLiveWallpaperActiveOnDevice: isActiveOnDevice,
        totalStorageUsedBytes: totalStorage,
        hasSeenOnboarding: hasSeenOnboarding,
        isAutoRotationEnabled: isAutoRotationEnabled,
        autoRotationIntervalMinutes: autoRotationInterval,
        autoRotationSource: autoRotationSource,
        autoRotationWifiOnly: autoRotationWifiOnly,
        autoRotationTarget: autoRotationTarget,
        isAmoledSaverModeEnabled: isAmoledSaver,
        actionStatus: WallpaperActionStatus.idle,
      ));
    } catch (e) {
      emit(state.copyWith(
        actionStatus: WallpaperActionStatus.error,
        errorMessage: 'Failed to load live wallpaper feed: $e',
      ));
    }
  }

  void onChangeActiveShort(
    ChangeActiveShortIntent event,
    Emitter<WallpaperState> emit,
  ) {
    if (event.index >= 0 && event.index < state.filteredShorts.length) {
      emit(state.copyWith(activeIndex: event.index));
    }
  }

  void onChangeNavigationTab(
    ChangeNavigationTabIntent event,
    Emitter<WallpaperState> emit,
  ) {
    emit(state.copyWith(currentNavigationTab: event.tabIndex));
  }

  void onToggleFeedMute(
    ToggleFeedMuteIntent event,
    Emitter<WallpaperState> emit,
  ) {
    emit(state.copyWith(isFeedMuted: !state.isFeedMuted));
  }

  void onSearchWallpapers(
    SearchWallpapersIntent event,
    Emitter<WallpaperState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void onFilterByCategory(
    FilterByCategoryIntent event,
    Emitter<WallpaperState> emit,
  ) {
    final filtered = WallpaperFeedFilter.filterShorts(
      allShorts: state.allShorts,
      category: event.category,
      preferences: state.userPreferences,
      smartFilter: state.smartFilter,
    );

    emit(state.copyWith(
      selectedCategory: event.category,
      filteredShorts: filtered,
      activeIndex: 0,
    ));
  }

  Future<void> onToggleAmoledSaverMode(
    ToggleAmoledSaverModeIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    final newMode = !state.isAmoledSaverModeEnabled;
    await repository.setAmoledSaverMode(newMode);
    emit(state.copyWith(
      isAmoledSaverModeEnabled: newMode,
      message: newMode
          ? 'AMOLED Battery Saver active. Zero subpixel drain on black pixels.'
          : 'Standard display mode active.',
    ));
  }

  Future<void> onUpdateUserPreferences(
    UpdateUserPreferencesIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    try {
      await repository.saveUserPreferences(event.preferences);
      final filtered = WallpaperFeedFilter.filterShorts(
        allShorts: state.allShorts,
        category: state.selectedCategory,
        preferences: event.preferences,
        smartFilter: state.smartFilter,
      );

      emit(state.copyWith(
        userPreferences: event.preferences,
        filteredShorts: filtered,
        message: 'Wallpaper preferences updated! Feed personalized.',
      ));
    } catch (e) {
      emit(state.copyWith(
        actionStatus: WallpaperActionStatus.error,
        errorMessage: 'Failed to update preferences: $e',
      ));
    }
  }

  void onClearStatusMessage(
    ClearStatusMessageIntent event,
    Emitter<WallpaperState> emit,
  ) {
    emit(state.copyWith(
      actionStatus: WallpaperActionStatus.idle,
      message: null,
      errorMessage: null,
    ));
  }

  Future<void> onCompleteOnboarding(
    CompleteOnboardingIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.saveUserPreferences(event.selectedPreferences);
    await repository.setHasSeenOnboarding(true);
    final forYouList = WallpaperFeedFilter.buildForYouList(
      state.allShorts,
      event.selectedPreferences,
    );
    emit(state.copyWith(
      hasSeenOnboarding: true,
      userPreferences: event.selectedPreferences,
      filteredShorts: forYouList,
      message: 'Welcome to Wallora! Your feed is personalized.',
    ));
  }

  Future<void> onResetOnboarding(
    ResetOnboardingIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.setHasSeenOnboarding(false);
    emit(state.copyWith(hasSeenOnboarding: false));
  }
}
