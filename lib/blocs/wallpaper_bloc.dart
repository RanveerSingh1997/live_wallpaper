import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/motivational_short.dart';
import '../repositories/wallpaper_repository.dart';
import 'wallpaper_intent.dart';
import 'wallpaper_state.dart';

class WallpaperBloc extends Bloc<WallpaperIntent, WallpaperState> {
  final WallpaperRepository repository;

  WallpaperBloc({required this.repository})
      : super(const WallpaperState()) {
    on<LoadFeedIntent>(_onLoadFeed);
    on<ChangeActiveShortIntent>(_onChangeActiveShort);
    on<ToggleFeedMuteIntent>(_onToggleFeedMute);
    on<ToggleFavoriteIntent>(_onToggleFavorite);
    on<FilterByCategoryIntent>(_onFilterByCategory);
    on<UpdateUserPreferencesIntent>(_onUpdateUserPreferences);
    on<ToggleTextOverlayVisibilityIntent>(_onToggleTextOverlayVisibility);
    on<UpdateCustomQuoteIntent>(_onUpdateCustomQuote);
    on<ResetCustomQuoteIntent>(_onResetCustomQuote);
    on<ApplyLiveWallpaperIntent>(_onApplyLiveWallpaper);
    on<ShareVideoIntent>(_onShareVideo);
    on<OpenPhotosIntent>(_onOpenPhotos);
    on<CheckWallpaperStatusIntent>(_onCheckWallpaperStatus);
    on<ClearStatusMessageIntent>(_onClearStatusMessage);
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
      final quotes = repository.getCustomQuotes();
      final activeId = repository.getActiveWallpaperId();
      final preferences = repository.getUserPreferences();
      final isTextOverlayVisible = repository.isTextOverlayEnabledByDefault();
      final isActiveOnDevice = await repository.isWallpaperActiveOnDevice();

      final forYouList = _buildForYouList(shorts, preferences);

      emit(state.copyWith(
        allShorts: shorts,
        filteredShorts: forYouList,
        activeIndex: 0,
        selectedCategory: 'For You',
        favoriteIds: favorites,
        customizedQuotes: quotes,
        activeWallpaperId: activeId,
        userPreferences: preferences,
        isTextOverlayVisible: isTextOverlayVisible,
        isLiveWallpaperActiveOnDevice: isActiveOnDevice,
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
      emit(state.copyWith(favoriteIds: updatedFavorites));
    } catch (_) {}
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
}
