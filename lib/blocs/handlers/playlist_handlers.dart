import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/motivational_short.dart';
import '../../models/wallpaper_collection.dart';
import '../../repositories/wallpaper_repository.dart';
import '../wallpaper_intent.dart';
import '../wallpaper_state.dart';
import 'wallpaper_feed_filter.dart';

mixin PlaylistHandlers on Bloc<WallpaperIntent, WallpaperState> {
  WallpaperFacadeRepository get repository;

  Future<void> onToggleFavorite(
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

  Future<void> onImportCustomWallpaper(
    ImportCustomWallpaperIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.saveCustomImportedWallpaper(event.wallpaper);
    final updatedAll = <MotivationalShort>[
      event.wallpaper,
      ...state.allShorts.where((s) => s.id != event.wallpaper.id),
    ];
    final updatedFiltered = WallpaperFeedFilter.buildForYouList(
      updatedAll,
      state.userPreferences,
    );
    emit(state.copyWith(
      allShorts: updatedAll,
      filteredShorts: updatedFiltered,
      message: 'Imported "${event.wallpaper.title}" into your Wallora catalog.',
    ));
  }

  Future<void> onCreateCustomCollection(
    CreateCustomCollectionIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.saveCustomCollection(event.collection);
    final updated = <WallpaperCollection>[
      event.collection,
      ...state.customCollections.where((c) => c.id != event.collection.id),
    ];
    emit(state.copyWith(
      customCollections: updated,
      message: 'Created playlist "${event.collection.title}".',
    ));
  }

  Future<void> onDeleteCustomCollection(
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

  Future<void> onToggleWallpaperInCollection(
    ToggleWallpaperInCollectionIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    var updatedCol = await repository.toggleWallpaperInCollection(
      event.collectionId,
      event.wallpaperId,
    );
    if (updatedCol == null) {
      final matches =
          state.customCollections.where((c) => c.id == event.collectionId);
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
