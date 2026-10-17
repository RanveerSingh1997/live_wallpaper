import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/motivational_short.dart';
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

      final forYouList = _buildForYouList(shorts, preferences);

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
    List<MotivationalShort> filtered;
    if (event.category == 'All') {
      filtered = state.allShorts;
    } else if (event.category == 'For You') {
      filtered = _buildForYouList(state.allShorts, state.userPreferences);
    } else if (event.category == 'Live Wallpapers') {
      filtered = state.allShorts.where((s) => s.isLive).toList();
    } else if (event.category == 'Static Wallpapers') {
      filtered = state.allShorts.where((s) => !s.isLive).toList();
    } else {
      filtered = state.allShorts.where((s) => s.category == event.category).toList();
    }

    emit(state.copyWith(
      selectedCategory: event.category,
      filteredShorts: filtered,
      activeIndex: 0,
    ));
  }

  Future<void> _onUpdateUserPreferences(
    UpdateUserPreferencesIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    try {
      await repository.saveUserPreferences(event.preferences);
      final forYouList = _buildForYouList(state.allShorts, event.preferences);

      emit(state.copyWith(
        userPreferences: event.preferences,
        filteredShorts: state.selectedCategory == 'For You' ? forYouList : state.filteredShorts,
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
}
