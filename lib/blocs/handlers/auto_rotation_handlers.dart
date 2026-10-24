import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/motivational_short.dart';
import '../../repositories/wallpaper_repository.dart';
import '../wallpaper_intent.dart';
import '../wallpaper_state.dart';
import 'wallpaper_feed_filter.dart';

mixin AutoRotationHandlers on Bloc<WallpaperIntent, WallpaperState> {
  WallpaperFacadeRepository get repository;

  Future<void> onToggleAutoRotation(
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

  Future<void> onUpdateAutoRotationInterval(
    UpdateAutoRotationIntervalIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.setAutoRotationIntervalMinutes(event.minutes);
    emit(state.copyWith(
      autoRotationIntervalMinutes: event.minutes,
      message:
          'Rotation frequency set to ${event.minutes >= 60 ? "${event.minutes ~/ 60} hour(s)" : "${event.minutes} min"}',
    ));
  }

  Future<void> onUpdateAutoRotationSource(
    UpdateAutoRotationSourceIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.setAutoRotationSource(event.source);
    emit(state.copyWith(
      autoRotationSource: event.source,
      message: 'Rotation playlist updated.',
    ));

    if (event.source == 'wallaza_cloud' ||
        event.source.startsWith('cloud_cat_')) {
      final String? cat = event.source.startsWith('cloud_cat_')
          ? event.source.replaceFirst('cloud_cat_', '')
          : null;
      if (state.cloudWallpapers.isEmpty) {
        try {
          final items = await repository.fetchCloudWallpapers(category: cat);
          emit(state.copyWith(cloudWallpapers: items));
        } catch (_) {}
      }
    }
  }

  Future<void> onUpdateAutoRotationWifiOnly(
    UpdateAutoRotationWifiOnlyIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.setAutoRotationWifiOnly(event.wifiOnly);
    emit(state.copyWith(
      autoRotationWifiOnly: event.wifiOnly,
    ));
  }

  Future<void> onUpdateAutoRotationTarget(
    UpdateAutoRotationTargetIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.setAutoRotationTarget(event.target);
    emit(state.copyWith(
      autoRotationTarget: event.target,
    ));
  }

  Future<void> onRotateWallpaperNow(
    RotateWallpaperNowIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    final pool = state.rotationPoolShorts;
    if (pool.isEmpty) {
      emit(state.copyWith(
        errorMessage:
            'Rotation pool is empty. Add wallpapers to favorites or select another playlist.',
      ));
      return;
    }

    emit(state.copyWith(actionStatus: WallpaperActionStatus.applying));

    MotivationalShort nextWallpaper;
    if (pool.length == 1) {
      nextWallpaper = pool.first;
    } else {
      final candidates =
          pool.where((s) => s.id != state.activeWallpaperId).toList();
      nextWallpaper = candidates.isNotEmpty
          ? candidates[DateTime.now().millisecond % candidates.length]
          : pool.first;
    }

    try {
      if (nextWallpaper.isLive) {
        if (nextWallpaper.id.startsWith('cloud_')) {
          await repository.saveCustomImportedWallpaper(nextWallpaper);
        }
        final res = await repository.applyAsLiveWallpaper(
          short: nextWallpaper,
          isMuted: true,
        );
        final all = repository.getCuratedShorts();
        final updatedFiltered = WallpaperFeedFilter.filterShorts(
          allShorts: all,
          category: state.selectedCategory,
          preferences: state.userPreferences,
          smartFilter: state.smartFilter,
        );
        if (res['status'] == 'service_started' ||
            res['status'] == 'applied_mock' ||
            res['status'] == 'updated_active' ||
            res['status'] == 'opened_chooser') {
          emit(state.copyWith(
            allShorts: all,
            filteredShorts: updatedFiltered,
            activeWallpaperId: nextWallpaper.id,
            isLiveWallpaperActiveOnDevice: true,
            actionStatus: WallpaperActionStatus.appliedSuccess,
            message: nextWallpaper.id.startsWith('cloud_')
                ? 'Rotated to Wallaza 4K: "${nextWallpaper.title}"'
                : 'Rotated to "${nextWallpaper.title}"',
          ));
        } else {
          emit(state.copyWith(
            allShorts: all,
            filteredShorts: updatedFiltered,
            actionStatus: WallpaperActionStatus.idle,
            message:
                'Opened wallpaper rotation chooser for "${nextWallpaper.title}"',
          ));
        }
      } else {
        if (nextWallpaper.id.startsWith('cloud_')) {
          await repository.saveCustomImportedWallpaper(nextWallpaper);
        }
        final res = await repository.applyStaticWallpaper(
          short: nextWallpaper,
          targetScreen: state.autoRotationTarget,
          customQuote: state.getEffectiveQuote(nextWallpaper),
        );
        final all = repository.getCuratedShorts();
        final updatedFiltered = WallpaperFeedFilter.filterShorts(
          allShorts: all,
          category: state.selectedCategory,
          preferences: state.userPreferences,
          smartFilter: state.smartFilter,
        );
        if (res['status'] == 'applied_static' ||
            res['status'] == 'shared_ios') {
          emit(state.copyWith(
            allShorts: all,
            filteredShorts: updatedFiltered,
            activeWallpaperId: nextWallpaper.id,
            actionStatus: WallpaperActionStatus.appliedSuccess,
            message: nextWallpaper.id.startsWith('cloud_')
                ? 'Rotated to Wallaza 4K: "${nextWallpaper.title}"'
                : 'Rotated to "${nextWallpaper.title}"',
          ));
        } else {
          emit(state.copyWith(
            allShorts: all,
            filteredShorts: updatedFiltered,
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
}
