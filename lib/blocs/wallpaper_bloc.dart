import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/aura_palette_config.dart';
import '../models/battery_telemetry_config.dart';
import '../models/day_night_schedule_config.dart';
import '../models/lock_screen_style_config.dart';
import '../models/motivational_short.dart';
import '../models/parallax_effect_config.dart';
import '../models/particle_effect_config.dart';
import '../models/smart_filter_config.dart';
import '../models/wallpaper_effect_config.dart';
import '../repositories/wallpaper_repository.dart';
import 'wallpaper_intent.dart';
import 'wallpaper_state.dart';

class WallpaperBloc extends Bloc<WallpaperIntent, WallpaperState> {
  final WallpaperRepository repository;

  WallpaperBloc({
    required this.repository,
    WallpaperState? initialState,
  }) : super(initialState ?? const WallpaperState()) {
    on<LoadFeedIntent>(_onLoadFeed);
    on<ChangeActiveShortIntent>(_onChangeActiveShort);
    on<ChangeNavigationTabIntent>(_onChangeNavigationTab);
    on<ToggleFeedMuteIntent>(_onToggleFeedMute);
    on<ToggleFavoriteIntent>(_onToggleFavorite);
    on<DownloadWallpaperIntent>(_onDownloadWallpaper);
    on<DeleteDownloadIntent>(_onDeleteDownload);
    on<ClearAllDownloadsIntent>(_onClearAllDownloads);
    on<SearchWallpapersIntent>(_onSearchWallpapers);
    on<FilterByCategoryIntent>(_onFilterByCategory);
    on<UpdateUserPreferencesIntent>(_onUpdateUserPreferences);
    on<ToggleTextOverlayVisibilityIntent>(_onToggleTextOverlayVisibility);
    on<UpdateCustomQuoteIntent>(_onUpdateCustomQuote);
    on<ResetCustomQuoteIntent>(_onResetCustomQuote);
    on<ApplyLiveWallpaperIntent>(_onApplyLiveWallpaper);
    on<ApplyStaticWallpaperIntent>(_onApplyStaticWallpaper);
    on<RecordWallpaperViewedIntent>(_onRecordWallpaperViewed);
    on<ReportWallpaperIntent>(_onReportWallpaper);
    on<ShareVideoIntent>(_onShareVideo);
    on<OpenPhotosIntent>(_onOpenPhotos);
    on<CheckWallpaperStatusIntent>(_onCheckWallpaperStatus);
    on<ClearStatusMessageIntent>(_onClearStatusMessage);
    on<CompleteOnboardingIntent>(_onCompleteOnboarding);
    on<ResetOnboardingIntent>(_onResetOnboarding);
    on<ToggleAutoRotationIntent>(_onToggleAutoRotation);
    on<UpdateAutoRotationIntervalIntent>(_onUpdateAutoRotationInterval);
    on<UpdateAutoRotationSourceIntent>(_onUpdateAutoRotationSource);
    on<UpdateAutoRotationWifiOnlyIntent>(_onUpdateAutoRotationWifiOnly);
    on<UpdateAutoRotationTargetIntent>(_onUpdateAutoRotationTarget);
    on<RotateWallpaperNowIntent>(_onRotateWallpaperNow);
    on<ImportCustomWallpaperIntent>(_onImportCustomWallpaper);
    on<CreateCustomCollectionIntent>(_onCreateCustomCollection);
    on<DeleteCustomCollectionIntent>(_onDeleteCustomCollection);
    on<ToggleWallpaperInCollectionIntent>(_onToggleWallpaperInCollection);
    on<ToggleAmoledSaverModeIntent>(_onToggleAmoledSaverMode);
    on<UpdateWallpaperEffectIntent>(_onUpdateWallpaperEffect);
    on<ResetWallpaperEffectIntent>(_onResetWallpaperEffect);
    on<UpdateDayNightScheduleIntent>(_onUpdateDayNightSchedule);
    on<ToggleDayNightScheduleIntent>(_onToggleDayNightSchedule);
    on<CheckDayNightTransitionIntent>(_onCheckDayNightTransition);
    on<UpdateLockScreenStyleIntent>(_onUpdateLockScreenStyle);
    on<ResetLockScreenStyleIntent>(_onResetLockScreenStyle);
    on<UpdateParallaxConfigIntent>(_onUpdateParallaxConfig);
    on<ToggleParallaxIntent>(_onToggleParallax);
    on<ResetParallaxConfigIntent>(_onResetParallaxConfig);
    on<UpdateSmartFilterIntent>(_onUpdateSmartFilter);
    on<ResetSmartFilterIntent>(_onResetSmartFilter);
    on<UpdateBatteryTelemetryIntent>(_onUpdateBatteryTelemetry);
    on<ToggleEcoModeIntent>(_onToggleEcoMode);
    on<ResetBatteryTelemetryIntent>(_onResetBatteryTelemetry);
    on<UpdateParticleConfigIntent>(_onUpdateParticleConfig);
    on<ToggleParticleEffectIntent>(_onToggleParticleEffect);
    on<ResetParticleConfigIntent>(_onResetParticleConfig);
    on<UpdateAuraPaletteIntent>(_onUpdateAuraPalette);
    on<SetAuraThemePresetIntent>(_onSetAuraThemePreset);
    on<ResetAuraPaletteIntent>(_onResetAuraPalette);
  }

  List<MotivationalShort> _buildForYouList(
    List<MotivationalShort> all,
    Set<String> preferences,
  ) {
    if (preferences.isEmpty) return all;
    final preferred = all.where((s) => preferences.contains(s.category)).toList();
    final others = all.where((s) => !preferences.contains(s.category)).toList();
    return [...preferred, ...others];
  }

  List<MotivationalShort> _filterShorts({
    required List<MotivationalShort> allShorts,
    required String category,
    required Set<String> preferences,
    required SmartFilterConfig smartFilter,
  }) {
    List<MotivationalShort> base;
    if (category == 'All') {
      base = allShorts;
    } else if (category == 'For You') {
      base = _buildForYouList(allShorts, preferences);
    } else if (category == 'Live Wallpapers') {
      base = allShorts.where((s) => s.isLive).toList();
    } else if (category == 'Static Wallpapers') {
      base = allShorts.where((s) => !s.isLive).toList();
    } else if (category == 'AMOLED True-Black') {
      base = allShorts.where((s) => s.isAmoledCertified).toList();
    } else {
      base = allShorts.where((s) => s.category == category).toList();
    }

    if (smartFilter.hasActiveFilters) {
      base = base.where((s) => smartFilter.matches(s)).toList();
    }
    return base;
  }

  Future<void> _onLoadFeed(
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
      final smartFilter = repository.getSmartFilterConfig();
      final batteryTelemetry = repository.getBatteryTelemetryConfig();

      final forYouList = _filterShorts(
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
        smartFilter: smartFilter,
        batteryTelemetry: batteryTelemetry,
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

  void _onChangeActiveShort(
    ChangeActiveShortIntent event,
    Emitter<WallpaperState> emit,
  ) {
    if (event.index >= 0 && event.index < state.filteredShorts.length) {
      emit(state.copyWith(activeIndex: event.index));
    }
  }

  void _onChangeNavigationTab(
    ChangeNavigationTabIntent event,
    Emitter<WallpaperState> emit,
  ) {
    emit(state.copyWith(currentNavigationTab: event.tabIndex));
  }

  void _onToggleFeedMute(
    ToggleFeedMuteIntent event,
    Emitter<WallpaperState> emit,
  ) {
    emit(state.copyWith(isFeedMuted: !state.isFeedMuted));
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    try {
      final updatedFavorites = await repository.toggleFavorite(event.shortId);
      final isNowFav = updatedFavorites.contains(event.shortId);
      emit(state.copyWith(
        favoriteIds: updatedFavorites,
        message: isNowFav ? 'Added to Favorites ❤️' : 'Removed from Favorites',
      ));
    } catch (_) {}
  }

  Future<void> _onDownloadWallpaper(
    DownloadWallpaperIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    emit(state.copyWith(actionStatus: WallpaperActionStatus.downloading));
    try {
      final success = await repository.downloadWallpaper(event.short);
      if (success) {
        final updatedDownloads = repository.getDownloads();
        final totalStorage = await repository.getTotalDownloadSizeBytes();
        emit(state.copyWith(
          downloadedIds: updatedDownloads,
          totalStorageUsedBytes: totalStorage,
          actionStatus: WallpaperActionStatus.downloadSuccess,
          message: 'Downloaded for offline use! (${event.short.fileSizeFormatted})',
        ));
      } else {
        emit(state.copyWith(
          actionStatus: WallpaperActionStatus.error,
          errorMessage: 'Failed to save wallpaper offline',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        actionStatus: WallpaperActionStatus.error,
        errorMessage: 'Download error: $e',
      ));
    }
  }

  Future<void> _onDeleteDownload(
    DeleteDownloadIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    try {
      await repository.deleteDownload(event.shortId);
      final updatedDownloads = repository.getDownloads();
      final totalStorage = await repository.getTotalDownloadSizeBytes();
      emit(state.copyWith(
        downloadedIds: updatedDownloads,
        totalStorageUsedBytes: totalStorage,
        message: 'Wallpaper removed from device storage',
      ));
    } catch (_) {}
  }

  Future<void> _onClearAllDownloads(
    ClearAllDownloadsIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    try {
      await repository.clearAllDownloads();
      emit(state.copyWith(
        downloadedIds: const {},
        totalStorageUsedBytes: 0,
        message: 'All offline downloads cleared! Storage reclaimed.',
      ));
    } catch (_) {}
  }

  void _onSearchWallpapers(
    SearchWallpapersIntent event,
    Emitter<WallpaperState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onFilterByCategory(
    FilterByCategoryIntent event,
    Emitter<WallpaperState> emit,
  ) {
    final filtered = _filterShorts(
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

  Future<void> _onToggleAmoledSaverMode(
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

  Future<void> _onUpdateUserPreferences(
    UpdateUserPreferencesIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    try {
      await repository.saveUserPreferences(event.preferences);
      final filtered = _filterShorts(
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

  Future<void> _onToggleTextOverlayVisibility(
    ToggleTextOverlayVisibilityIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    final nextState = !state.isTextOverlayVisible;
    await repository.setTextOverlayEnabled(nextState);
    emit(state.copyWith(
      isTextOverlayVisible: nextState,
      message: nextState ? 'Text overlay visible' : 'Pure video mode (text hidden)',
    ));
  }

  Future<void> _onUpdateCustomQuote(
    UpdateCustomQuoteIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    try {
      await repository.saveCustomQuote(event.shortId, event.newQuote);
      final updatedQuotes = Map<String, String>.from(state.customizedQuotes);
      updatedQuotes[event.shortId] = event.newQuote;

      emit(state.copyWith(
        customizedQuotes: updatedQuotes,
        actionStatus: WallpaperActionStatus.idle,
        message: 'Wallpaper text updated!',
      ));
    } catch (e) {
      emit(state.copyWith(
        actionStatus: WallpaperActionStatus.error,
        errorMessage: 'Failed to save customized text: $e',
      ));
    }
  }

  Future<void> _onResetCustomQuote(
    ResetCustomQuoteIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    try {
      await repository.saveCustomQuote(event.shortId, '');
      final updatedQuotes = Map<String, String>.from(state.customizedQuotes);
      updatedQuotes.remove(event.shortId);

      emit(state.copyWith(
        customizedQuotes: updatedQuotes,
        actionStatus: WallpaperActionStatus.idle,
        message: 'Text reset to original default',
      ));
    } catch (e) {
      emit(state.copyWith(
        actionStatus: WallpaperActionStatus.error,
        errorMessage: 'Failed to reset text: $e',
      ));
    }
  }

  Future<void> _onApplyLiveWallpaper(
    ApplyLiveWallpaperIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    emit(state.copyWith(actionStatus: WallpaperActionStatus.applying));
    try {
      final result = await repository.applyAsLiveWallpaper(
        short: event.short,
        isMuted: event.isMuted,
      );

      final String status = result['status']?.toString() ?? 'unknown';

      if (status == 'updated_active') {
        emit(state.copyWith(
          actionStatus: WallpaperActionStatus.appliedSuccess,
          activeWallpaperId: event.short.id,
          isLiveWallpaperActiveOnDevice: true,
          message: '⚡ Live wallpaper switched instantly on Home & Lock Screen!',
        ));
      } else if (status == 'opened_chooser' || status == 'opened_chooser_fallback') {
        emit(state.copyWith(
          actionStatus: WallpaperActionStatus.appliedSuccess,
          activeWallpaperId: event.short.id,
          message: 'Opening system wallpaper chooser. Select "Home and Lock Screen"!',
        ));
      } else if (status == 'saved_to_photos') {
        emit(state.copyWith(
          actionStatus: WallpaperActionStatus.appliedSuccess,
          activeWallpaperId: event.short.id,
          message: 'Saved to iPad Photos! Set via iPad Settings > Wallpaper or Photos Share Sheet.',
        ));
      } else if (status == 'unsupported_platform') {
        emit(state.copyWith(
          actionStatus: WallpaperActionStatus.error,
          errorMessage: result['message']?.toString() ?? 'Unsupported platform',
        ));
      } else {
        emit(state.copyWith(
          actionStatus: WallpaperActionStatus.error,
          errorMessage: result['error']?.toString() ?? 'Failed to apply wallpaper',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        actionStatus: WallpaperActionStatus.error,
        errorMessage: 'Error applying live wallpaper: $e',
      ));
    }
  }

  Future<void> _onApplyStaticWallpaper(
    ApplyStaticWallpaperIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    emit(state.copyWith(actionStatus: WallpaperActionStatus.applying));
    try {
      final result = await repository.applyStaticWallpaper(
        short: event.short,
        targetScreen: event.targetScreen,
        customQuote: event.customQuote,
        effectConfig: state.getEffectiveEffects(event.short.id),
      );

      final status = result['status']?.toString();
      if (status == 'applied_static') {
        final screenLabel = event.targetScreen == 'home'
            ? 'Home Screen'
            : (event.targetScreen == 'lock' ? 'Lock Screen' : 'Home & Lock Screen');
        emit(state.copyWith(
          actionStatus: WallpaperActionStatus.appliedSuccess,
          activeWallpaperId: event.short.id,
          message: '✨ Ultra-HD static wallpaper applied to $screenLabel!',
        ));
      } else if (status == 'shared_ios') {
        emit(state.copyWith(
          actionStatus: WallpaperActionStatus.appliedSuccess,
          activeWallpaperId: event.short.id,
          message: 'Wallpaper generated! Select "Use as Wallpaper" in the share sheet.',
        ));
      } else {
        emit(state.copyWith(
          actionStatus: WallpaperActionStatus.error,
          errorMessage: result['error']?.toString() ?? 'Failed to apply static wallpaper',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        actionStatus: WallpaperActionStatus.error,
        errorMessage: 'Error applying static wallpaper: $e',
      ));
    }
  }

  Future<void> _onRecordWallpaperViewed(
    RecordWallpaperViewedIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    final list = List<String>.from(state.recentlyViewedIds);
    list.remove(event.wallpaperId);
    list.insert(0, event.wallpaperId);
    if (list.length > 20) {
      list.removeRange(20, list.length);
    }
    emit(state.copyWith(recentlyViewedIds: list));
    await repository.recordRecentlyViewed(event.wallpaperId);
  }

  Future<void> _onReportWallpaper(
    ReportWallpaperIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    final reported = Set<String>.from(state.reportedIds)..add(event.wallpaperId);
    await repository.reportWallpaper(event.wallpaperId, event.reason);
    emit(state.copyWith(
      reportedIds: reported,
      message: 'Thank you for reporting. This wallpaper has been flagged for review.',
    ));
  }

  Future<void> _onShareVideo(
    ShareVideoIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    try {
      await repository.shareVideo(event.short);
    } catch (e) {
      emit(state.copyWith(
        actionStatus: WallpaperActionStatus.error,
        errorMessage: 'Failed to open share sheet: $e',
      ));
    }
  }

  Future<void> _onOpenPhotos(
    OpenPhotosIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    try {
      await repository.openPhotos();
    } catch (_) {}
  }

  Future<void> _onCheckWallpaperStatus(
    CheckWallpaperStatusIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    final isActive = await repository.isWallpaperActiveOnDevice();
    emit(state.copyWith(isLiveWallpaperActiveOnDevice: isActive));
  }

  void _onClearStatusMessage(
    ClearStatusMessageIntent event,
    Emitter<WallpaperState> emit,
  ) {
    emit(state.copyWith(
      actionStatus: WallpaperActionStatus.idle,
      message: null,
      errorMessage: null,
    ));
  }

  Future<void> _onCompleteOnboarding(
    CompleteOnboardingIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.saveUserPreferences(event.selectedPreferences);
    await repository.setHasSeenOnboarding(true);
    final forYouList = _buildForYouList(state.allShorts, event.selectedPreferences);
    emit(state.copyWith(
      hasSeenOnboarding: true,
      userPreferences: event.selectedPreferences,
      filteredShorts: forYouList,
      message: 'Welcome to Wallora! Your feed is personalized.',
    ));
  }

  Future<void> _onResetOnboarding(
    ResetOnboardingIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.setHasSeenOnboarding(false);
    emit(state.copyWith(hasSeenOnboarding: false));
  }

  Future<void> _onToggleAutoRotation(
    ToggleAutoRotationIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.setAutoRotationEnabled(event.enabled);
    emit(state.copyWith(
      isAutoRotationEnabled: event.enabled,
      message: event.enabled
          ? 'Aurora Auto-Rotation activated.'
          : 'Aurora Auto-Rotation paused.',
    ));
  }

  Future<void> _onUpdateAutoRotationInterval(
    UpdateAutoRotationIntervalIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.setAutoRotationIntervalMinutes(event.minutes);
    emit(state.copyWith(
      autoRotationIntervalMinutes: event.minutes,
      message: 'Rotation frequency set to ${event.minutes >= 60 ? "${event.minutes ~/ 60} hour(s)" : "${event.minutes} min"}',
    ));
  }

  Future<void> _onUpdateAutoRotationSource(
    UpdateAutoRotationSourceIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.setAutoRotationSource(event.source);
    emit(state.copyWith(
      autoRotationSource: event.source,
      message: 'Rotation playlist updated.',
    ));
  }

  Future<void> _onUpdateAutoRotationWifiOnly(
    UpdateAutoRotationWifiOnlyIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.setAutoRotationWifiOnly(event.wifiOnly);
    emit(state.copyWith(
      autoRotationWifiOnly: event.wifiOnly,
    ));
  }

  Future<void> _onUpdateAutoRotationTarget(
    UpdateAutoRotationTargetIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.setAutoRotationTarget(event.target);
    emit(state.copyWith(
      autoRotationTarget: event.target,
    ));
  }

  Future<void> _onRotateWallpaperNow(
    RotateWallpaperNowIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    final pool = state.rotationPoolShorts;
    if (pool.isEmpty) {
      emit(state.copyWith(
        errorMessage: 'Rotation pool is empty. Add wallpapers to favorites or select another playlist.',
      ));
      return;
    }

    emit(state.copyWith(actionStatus: WallpaperActionStatus.applying));

    MotivationalShort nextWallpaper;
    if (pool.length == 1) {
      nextWallpaper = pool.first;
    } else {
      final candidates = pool.where((s) => s.id != state.activeWallpaperId).toList();
      nextWallpaper = candidates.isNotEmpty
          ? candidates[DateTime.now().millisecond % candidates.length]
          : pool.first;
    }

    try {
      if (nextWallpaper.isLive) {
        final res = await repository.applyAsLiveWallpaper(
          short: nextWallpaper,
          isMuted: true,
        );
        if (res['status'] == 'service_started' ||
            res['status'] == 'applied_mock' ||
            res['status'] == 'updated_active' ||
            res['status'] == 'opened_chooser') {
          emit(state.copyWith(
            activeWallpaperId: nextWallpaper.id,
            isLiveWallpaperActiveOnDevice: true,
            actionStatus: WallpaperActionStatus.appliedSuccess,
            message: 'Rotated to "${nextWallpaper.title}"',
          ));
        } else {
          emit(state.copyWith(
            actionStatus: WallpaperActionStatus.idle,
            message: 'Opened wallpaper rotation chooser for "${nextWallpaper.title}"',
          ));
        }
      } else {
        final res = await repository.applyStaticWallpaper(
          short: nextWallpaper,
          targetScreen: state.autoRotationTarget,
          customQuote: state.getEffectiveQuote(nextWallpaper),
        );
        if (res['status'] == 'applied_static' || res['status'] == 'shared_ios') {
          emit(state.copyWith(
            activeWallpaperId: nextWallpaper.id,
            actionStatus: WallpaperActionStatus.appliedSuccess,
            message: 'Rotated to "${nextWallpaper.title}"',
          ));
        } else {
          emit(state.copyWith(
            actionStatus: WallpaperActionStatus.idle,
            message: 'Rotated to "${nextWallpaper.title}"',
          ));
        }
      }
    } catch (e) {
      emit(state.copyWith(
        actionStatus: WallpaperActionStatus.error,
        errorMessage: 'Failed to rotate wallpaper: $e',
      ));
    }
  }

  Future<void> _onImportCustomWallpaper(
    ImportCustomWallpaperIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.saveCustomImportedWallpaper(event.wallpaper);
    final updatedAll = [
      event.wallpaper,
      ...state.allShorts.where((s) => s.id != event.wallpaper.id),
    ];
    final updatedFiltered = _buildForYouList(updatedAll, state.userPreferences);
    emit(state.copyWith(
      allShorts: updatedAll,
      filteredShorts: updatedFiltered,
      message: 'Imported "${event.wallpaper.title}" into your Wallora catalog.',
    ));
  }

  Future<void> _onCreateCustomCollection(
    CreateCustomCollectionIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.saveCustomCollection(event.collection);
    final updated = [
      event.collection,
      ...state.customCollections.where((c) => c.id != event.collection.id),
    ];
    emit(state.copyWith(
      customCollections: updated,
      message: 'Created playlist "${event.collection.title}".',
    ));
  }

  Future<void> _onDeleteCustomCollection(
    DeleteCustomCollectionIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.deleteCustomCollection(event.collectionId);
    final updated =
        state.customCollections.where((c) => c.id != event.collectionId).toList();
    emit(state.copyWith(
      customCollections: updated,
      autoRotationSource: state.autoRotationSource == event.collectionId
          ? 'favorites'
          : state.autoRotationSource,
      message: 'Playlist deleted.',
    ));
  }

  Future<void> _onToggleWallpaperInCollection(
    ToggleWallpaperInCollectionIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    var updatedCol = await repository.toggleWallpaperInCollection(
      event.collectionId,
      event.wallpaperId,
    );
    if (updatedCol == null) {
      final matches = state.customCollections.where((c) => c.id == event.collectionId);
      if (matches.isNotEmpty) {
        await repository.saveCustomCollection(matches.first);
        updatedCol = await repository.toggleWallpaperInCollection(
          event.collectionId,
          event.wallpaperId,
        );
      }
    }

    if (updatedCol != null) {
      final updatedList = state.customCollections
          .map((c) => c.id == updatedCol!.id ? updatedCol : c)
          .toList();
      final isInCol = updatedCol.wallpaperIds.contains(event.wallpaperId);
      emit(state.copyWith(
        customCollections: updatedList,
        message: isInCol
            ? 'Added to "${updatedCol.title}".'
            : 'Removed from "${updatedCol.title}".',
      ));
    }
  }

  Future<void> _onUpdateWallpaperEffect(
    UpdateWallpaperEffectIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.saveCustomEffect(event.wallpaperId, event.effectConfig);
    final updatedEffects = Map<String, WallpaperEffectConfig>.from(state.customEffects);
    if (event.effectConfig.isDefault) {
      updatedEffects.remove(event.wallpaperId);
    } else {
      updatedEffects[event.wallpaperId] = event.effectConfig;
    }
    emit(state.copyWith(
      customEffects: updatedEffects,
      message: 'Visual canvas effects saved.',
    ));
  }

  Future<void> _onResetWallpaperEffect(
    ResetWallpaperEffectIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.resetCustomEffect(event.wallpaperId);
    final updatedEffects = Map<String, WallpaperEffectConfig>.from(state.customEffects)
      ..remove(event.wallpaperId);
    emit(state.copyWith(
      customEffects: updatedEffects,
      message: 'Visual canvas effects reset to default.',
    ));
  }

  Future<void> _onUpdateDayNightSchedule(
    UpdateDayNightScheduleIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.saveDayNightScheduleConfig(event.config);
    emit(state.copyWith(
      dayNightSchedule: event.config,
      message: 'Solar Day & Night schedule updated.',
    ));
    if (event.config.isEnabled) {
      add(const CheckDayNightTransitionIntent());
    }
  }

  Future<void> _onToggleDayNightSchedule(
    ToggleDayNightScheduleIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    final updatedConfig = state.dayNightSchedule.copyWith(
      isEnabled: !state.dayNightSchedule.isEnabled,
    );
    await repository.saveDayNightScheduleConfig(updatedConfig);
    emit(state.copyWith(
      dayNightSchedule: updatedConfig,
      message: updatedConfig.isEnabled
          ? 'Day & Night Solar Schedule enabled.'
          : 'Day & Night Solar Schedule paused.',
    ));
    if (updatedConfig.isEnabled) {
      add(const CheckDayNightTransitionIntent());
    }
  }

  Future<void> _onCheckDayNightTransition(
    CheckDayNightTransitionIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    if (!state.dayNightSchedule.isEnabled) return;

    final now = event.currentTime ?? DateTime.now();
    final slot = state.dayNightSchedule.getSlotForTime(now);
    final targetId = state.dayNightSchedule.getWallpaperIdForTime(now);

    if (state.activeWallpaperId == targetId) return;

    final matches = state.allShorts.where((s) => s.id == targetId);
    if (matches.isEmpty) return;
    final targetWallpaper = matches.first;

    emit(state.copyWith(actionStatus: WallpaperActionStatus.applying));

    try {
      if (slot == DayNightSlot.night &&
          state.dayNightSchedule.autoAmoledAtNight &&
          !state.isAmoledSaverModeEnabled) {
        await repository.setAmoledSaverMode(true);
        emit(state.copyWith(isAmoledSaverModeEnabled: true));
      }

      if (targetWallpaper.isLive) {
        final res = await repository.applyAsLiveWallpaper(
          short: targetWallpaper,
          isMuted: true,
        );
        if (res['status'] == 'service_started' ||
            res['status'] == 'applied_mock' ||
            res['status'] == 'updated_active' ||
            res['status'] == 'opened_chooser') {
          emit(state.copyWith(
            activeWallpaperId: targetWallpaper.id,
            isLiveWallpaperActiveOnDevice: true,
            actionStatus: WallpaperActionStatus.appliedSuccess,
            message: 'Solar schedule (${slot.label}) transitioned to "${targetWallpaper.title}".',
          ));
        } else {
          emit(state.copyWith(
            actionStatus: WallpaperActionStatus.idle,
            message: 'Solar schedule (${slot.label}) active: "${targetWallpaper.title}".',
          ));
        }
      } else {
        await repository.applyStaticWallpaper(
          short: targetWallpaper,
          targetScreen: state.autoRotationTarget,
          customQuote: state.getEffectiveQuote(targetWallpaper),
        );
        emit(state.copyWith(
          activeWallpaperId: targetWallpaper.id,
          actionStatus: WallpaperActionStatus.appliedSuccess,
          message: 'Solar schedule (${slot.label}) transitioned to "${targetWallpaper.title}".',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        actionStatus: WallpaperActionStatus.error,
        errorMessage: 'Failed to apply scheduled solar wallpaper: $e',
      ));
    }
  }

  Future<void> _onUpdateLockScreenStyle(
    UpdateLockScreenStyleIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.saveLockScreenStyleConfig(event.config);
    emit(state.copyWith(
      lockScreenStyle: event.config,
      message: 'Lock screen simulation aesthetic updated.',
    ));
  }

  Future<void> _onResetLockScreenStyle(
    ResetLockScreenStyleIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.resetLockScreenStyleConfig();
    emit(state.copyWith(
      lockScreenStyle: LockScreenStyleConfig.defaultConfig,
      message: 'Lock screen aesthetic reset to default.',
    ));
  }

  Future<void> _onUpdateParallaxConfig(
    UpdateParallaxConfigIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.saveParallaxEffectConfig(event.config);
    emit(state.copyWith(
      parallaxConfig: event.config,
      message: '3D Spatial Parallax motion updated.',
    ));
  }

  Future<void> _onToggleParallax(
    ToggleParallaxIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    final updated = state.parallaxConfig.copyWith(
      isEnabled: !state.parallaxConfig.isEnabled,
    );
    await repository.saveParallaxEffectConfig(updated);
    emit(state.copyWith(
      parallaxConfig: updated,
      message: updated.isEnabled
          ? '3D Spatial Parallax active.'
          : '3D Spatial Parallax paused.',
    ));
  }

  Future<void> _onResetParallaxConfig(
    ResetParallaxConfigIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.resetParallaxEffectConfig();
    emit(state.copyWith(
      parallaxConfig: ParallaxEffectConfig.defaultConfig,
      message: '3D Spatial Parallax reset to default.',
    ));
  }

  Future<void> _onUpdateSmartFilter(
    UpdateSmartFilterIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.saveSmartFilterConfig(event.config);
    final filtered = _filterShorts(
      allShorts: state.allShorts,
      category: state.selectedCategory,
      preferences: state.userPreferences,
      smartFilter: event.config,
    );
    emit(state.copyWith(
      smartFilter: event.config,
      filteredShorts: filtered,
      activeIndex: 0,
      message: event.config.hasActiveFilters
          ? 'Smart discovery filter applied (${event.config.activeFilterCount} active).'
          : 'Smart discovery filter cleared.',
    ));
  }

  Future<void> _onResetSmartFilter(
    ResetSmartFilterIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.resetSmartFilterConfig();
    final defaultConfig = SmartFilterConfig.defaultConfig;
    final filtered = _filterShorts(
      allShorts: state.allShorts,
      category: state.selectedCategory,
      preferences: state.userPreferences,
      smartFilter: defaultConfig,
    );
    emit(state.copyWith(
      smartFilter: defaultConfig,
      filteredShorts: filtered,
      activeIndex: 0,
      message: 'Smart discovery filters reset.',
    ));
  }

  Future<void> _onUpdateBatteryTelemetry(
    UpdateBatteryTelemetryIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.saveBatteryTelemetryConfig(event.config);
    emit(state.copyWith(
      batteryTelemetry: event.config,
      message: 'Battery & display telemetry updated.',
    ));
  }

  Future<void> _onToggleEcoMode(
    ToggleEcoModeIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    final updated = state.batteryTelemetry.copyWith(
      isEcoModeEnabled: !state.batteryTelemetry.isEcoModeEnabled,
    );
    await repository.saveBatteryTelemetryConfig(updated);
    emit(state.copyWith(
      batteryTelemetry: updated,
      message: updated.isEcoModeEnabled
          ? 'Adaptive Eco Scaling enabled (<20% battery throttle).'
          : 'Adaptive Eco Scaling disabled.',
    ));
  }

  Future<void> _onResetBatteryTelemetry(
    ResetBatteryTelemetryIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.resetBatteryTelemetryConfig();
    final defaultConfig = BatteryTelemetryConfig.defaultConfig;
    emit(state.copyWith(
      batteryTelemetry: defaultConfig,
      message: 'Battery & display telemetry reset to defaults.',
    ));
  }

  Future<void> _onUpdateParticleConfig(
    UpdateParticleConfigIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.saveParticleEffectConfig(event.config);
    emit(state.copyWith(
      particleConfig: event.config,
      message: 'Interactive Particle FX updated (${event.config.preset.label}).',
    ));
  }

  Future<void> _onToggleParticleEffect(
    ToggleParticleEffectIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    final newPreset = state.particleConfig.isEnabled
        ? ParticlePreset.none
        : ParticlePreset.neonStardust;
    final updated = state.particleConfig.copyWith(preset: newPreset);
    await repository.saveParticleEffectConfig(updated);
    emit(state.copyWith(
      particleConfig: updated,
      message: updated.isEnabled
          ? 'Interactive Particle FX enabled.'
          : 'Interactive Particle FX disabled.',
    ));
  }

  Future<void> _onResetParticleConfig(
    ResetParticleConfigIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.resetParticleEffectConfig();
    final defaultConfig = ParticleEffectConfig.defaultConfig;
    emit(state.copyWith(
      particleConfig: defaultConfig,
      message: 'Interactive Particle FX reset to defaults.',
    ));
  }

  Future<void> _onUpdateAuraPalette(
    UpdateAuraPaletteIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.saveAuraPaletteConfig(event.config);
    emit(state.copyWith(
      auraConfig: event.config,
      message: 'Aura theme updated (${event.config.preset.displayName}).',
    ));
  }

  Future<void> _onSetAuraThemePreset(
    SetAuraThemePresetIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    final updated = state.auraConfig.copyWith(preset: event.preset);
    await repository.saveAuraPaletteConfig(updated);
    emit(state.copyWith(
      auraConfig: updated,
      message: 'Aura preset switched to ${event.preset.displayName}.',
    ));
  }

  Future<void> _onResetAuraPalette(
    ResetAuraPaletteIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.resetAuraPaletteConfig();
    final defaultConfig = AuraPaletteConfig.defaultConfig;
    emit(state.copyWith(
      auraConfig: defaultConfig,
      message: 'Aura Chromatic Harmonizer reset to defaults.',
    ));
  }
}


