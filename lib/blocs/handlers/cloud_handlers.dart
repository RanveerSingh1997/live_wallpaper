import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/wallpaper_repository.dart';
import '../wallpaper_intent.dart';
import '../wallpaper_state.dart';
import 'wallpaper_feed_filter.dart';

mixin CloudHandlers on Bloc<WallpaperIntent, WallpaperState> {
  WallpaperFacadeRepository get repository;

  Future<void> onFetchCloudWallpapers(
    FetchCloudWallpapersIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    final cat = event.category ?? state.selectedCloudCategory;
    emit(state.copyWith(
      isCloudLoading: true,
      cloudErrorMessage: null,
      selectedCloudCategory: cat,
      cloudCurrentPage: event.page,
    ));
    try {
      final items = await repository.fetchCloudWallpapers(
        page: event.page,
        category: cat,
      );
      final existingIds = state.allShorts.map((s) => s.id).toSet();
      final newShorts = items
          .map((w) => w.toMotivationalShort())
          .where((s) => !existingIds.contains(s.id))
          .toList();
      final updatedAll = [...state.allShorts, ...newShorts];
      final updatedFiltered = WallpaperFeedFilter.filterShorts(
        allShorts: updatedAll,
        category: state.selectedCategory,
        preferences: state.userPreferences,
        smartFilter: state.smartFilter,
      );
      emit(state.copyWith(
        isCloudLoading: false,
        cloudWallpapers: items,
        allShorts: updatedAll,
        filteredShorts: updatedFiltered,
      ));
    } catch (e) {
      emit(state.copyWith(
        isCloudLoading: false,
        cloudErrorMessage: 'Failed to load cloud wallpapers: $e',
      ));
    }
  }

  Future<void> onSearchCloudWallpapers(
    SearchCloudWallpapersIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    final res = event.resolution ?? state.selectedCloudResolution;
    emit(state.copyWith(
      isCloudLoading: true,
      cloudErrorMessage: null,
      cloudSearchQuery: event.query,
      selectedCloudResolution: res,
      cloudCurrentPage: event.page,
    ));
    try {
      final items = await repository.searchCloudWallpapers(
        query: event.query,
        resolution: res,
        page: event.page,
      );
      final existingIds = state.allShorts.map((s) => s.id).toSet();
      final newShorts = items
          .map((w) => w.toMotivationalShort())
          .where((s) => !existingIds.contains(s.id))
          .toList();
      final updatedAll = [...state.allShorts, ...newShorts];
      final updatedFiltered = WallpaperFeedFilter.filterShorts(
        allShorts: updatedAll,
        category: state.selectedCategory,
        preferences: state.userPreferences,
        smartFilter: state.smartFilter,
      );
      emit(state.copyWith(
        isCloudLoading: false,
        cloudWallpapers: items,
        allShorts: updatedAll,
        filteredShorts: updatedFiltered,
      ));
    } catch (e) {
      emit(state.copyWith(
        isCloudLoading: false,
        cloudErrorMessage: 'Cloud search failed: $e',
      ));
    }
  }

  Future<void> onImportCloudWallpaper(
    ImportCloudWallpaperIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    try {
      final imported = await repository.importCloudWallpaper(event.wallpaper);
      final existing =
          state.allShorts.where((s) => s.id != imported.id).toList();
      final all = [imported, ...existing];
      final updatedFiltered = WallpaperFeedFilter.filterShorts(
        allShorts: all,
        category: state.selectedCategory,
        preferences: state.userPreferences,
        smartFilter: state.smartFilter,
      );

      if (event.setAsActive) {
        if (imported.isLive) {
          final result = await repository.applyAsLiveWallpaper(
            short: imported,
            isMuted: state.isFeedMuted,
          );
          final status = result['status']?.toString();
          emit(state.copyWith(
            allShorts: all,
            filteredShorts: updatedFiltered,
            activeWallpaperId: imported.id,
            actionStatus: WallpaperActionStatus.appliedSuccess,
            isLiveWallpaperActiveOnDevice:
                status == 'updated_active' || state.isLiveWallpaperActiveOnDevice,
            message: status == 'updated_active'
                ? '⚡ Live wallpaper switched instantly on Home & Lock Screen!'
                : '🎬 Wallaza Cloud Live Motion set for "${imported.title}"!',
          ));
        } else {
          final result = await repository.applyStaticWallpaper(
            short: imported,
            targetScreen: 'both',
            customQuote: imported.quote,
            effectConfig: state.getEffectiveEffects(imported.id),
          );
          final status = result['status']?.toString();
          emit(state.copyWith(
            allShorts: all,
            filteredShorts: updatedFiltered,
            activeWallpaperId: imported.id,
            actionStatus: WallpaperActionStatus.appliedSuccess,
            message: status == 'applied_static'
                ? '✨ Applied "${imported.title}" to Home & Lock Screen!'
                : 'Imported & configured "${imported.title}"!',
          ));
        }
      } else {
        emit(state.copyWith(
          allShorts: all,
          filteredShorts: updatedFiltered,
          message: 'Imported "${imported.title}" into Wallora library!',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to import wallpaper: $e',
      ));
    }
  }

  Future<void> onClearCloudSearch(
    ClearCloudSearchIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    emit(state.copyWith(
      cloudSearchQuery: '',
      selectedCloudResolution: 'All',
      clearCloudAuthor: true,
      selectedCloudSort: 'curated',
      isCloudLoading: true,
      cloudErrorMessage: null,
    ));
    try {
      final items = await repository.fetchCloudWallpapers(
        page: 1,
        category: state.selectedCloudCategory,
      );
      emit(state.copyWith(
        isCloudLoading: false,
        cloudWallpapers: items,
      ));
    } catch (e) {
      emit(state.copyWith(
        isCloudLoading: false,
        cloudErrorMessage: 'Failed to restore cloud wallpapers: $e',
      ));
    }
  }

  void onUpdateCloudSort(
    UpdateCloudSortIntent event,
    Emitter<WallpaperState> emit,
  ) {
    emit(state.copyWith(selectedCloudSort: event.sort));
  }

  void onFilterCloudByAuthor(
    FilterCloudByAuthorIntent event,
    Emitter<WallpaperState> emit,
  ) {
    emit(state.copyWith(
      selectedCloudAuthor: event.author,
      clearCloudAuthor: event.author == null,
    ));
  }
}
