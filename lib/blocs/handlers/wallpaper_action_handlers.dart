import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/battery_telemetry_config.dart';
import '../../repositories/wallpaper_repository.dart';
import '../wallpaper_intent.dart';
import '../wallpaper_state.dart';
import 'wallpaper_feed_filter.dart';

mixin WallpaperActionHandlers on Bloc<WallpaperIntent, WallpaperState> {
  WallpaperFacadeRepository get repository;

  Future<void> onDownloadWallpaper(
    DownloadWallpaperIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    emit(state.copyWith(actionStatus: WallpaperActionStatus.downloading));
    try {
      final success = await repository.downloadWallpaper(event.short);
      if (success) {
        final all = repository.getCuratedShorts();
        final updatedFiltered = WallpaperFeedFilter.filterShorts(
          allShorts: all,
          category: state.selectedCategory,
          preferences: state.userPreferences,
          smartFilter: state.smartFilter,
        );
        final updatedDownloads = repository.getDownloads();
        final totalStorage = await repository.getTotalDownloadSizeBytes();
        emit(state.copyWith(
          allShorts: all,
          filteredShorts: updatedFiltered,
          downloadedIds: updatedDownloads,
          totalStorageUsedBytes: totalStorage,
          actionStatus: WallpaperActionStatus.downloadSuccess,
          message:
              'Downloaded "${event.short.title}" for offline use! (${event.short.fileSizeFormatted})',
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

  Future<void> onDeleteDownload(
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

  Future<void> onClearAllDownloads(
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

  Future<void> onToggleTextOverlayVisibility(
    ToggleTextOverlayVisibilityIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    final nextState = !state.isTextOverlayVisible;
    await repository.setTextOverlayEnabled(nextState);
    emit(state.copyWith(
      isTextOverlayVisible: nextState,
      message:
          nextState ? 'Text overlay visible' : 'Pure video mode (text hidden)',
    ));
  }

  Future<void> onUpdateCustomQuote(
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

  Future<void> onResetCustomQuote(
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

  Future<void> onApplyLiveWallpaper(
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
      } else if (status == 'opened_chooser' ||
          status == 'opened_chooser_fallback') {
        emit(state.copyWith(
          actionStatus: WallpaperActionStatus.appliedSuccess,
          activeWallpaperId: event.short.id,
          message:
              'Opening system wallpaper chooser. Select "Home and Lock Screen"!',
        ));
      } else if (status == 'saved_to_photos') {
        emit(state.copyWith(
          actionStatus: WallpaperActionStatus.appliedSuccess,
          activeWallpaperId: event.short.id,
          message:
              'Saved to iPad Photos! Set via iPad Settings > Wallpaper or Photos Share Sheet.',
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

  Future<void> onApplyStaticWallpaper(
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
            : (event.targetScreen == 'lock'
                ? 'Lock Screen'
                : 'Home & Lock Screen');
        emit(state.copyWith(
          actionStatus: WallpaperActionStatus.appliedSuccess,
          activeWallpaperId: event.short.id,
          message: '✨ Ultra-HD static wallpaper applied to $screenLabel!',
        ));
      } else if (status == 'shared_ios') {
        emit(state.copyWith(
          actionStatus: WallpaperActionStatus.appliedSuccess,
          activeWallpaperId: event.short.id,
          message:
              'Wallpaper generated! Select "Use as Wallpaper" in the share sheet.',
        ));
      } else {
        emit(state.copyWith(
          actionStatus: WallpaperActionStatus.error,
          errorMessage:
              result['error']?.toString() ?? 'Failed to apply static wallpaper',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        actionStatus: WallpaperActionStatus.error,
        errorMessage: 'Error applying static wallpaper: $e',
      ));
    }
  }

  Future<void> onRecordWallpaperViewed(
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

  Future<void> onReportWallpaper(
    ReportWallpaperIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    final reported = Set<String>.from(state.reportedIds)..add(event.wallpaperId);
    await repository.reportWallpaper(event.wallpaperId, event.reason);
    emit(state.copyWith(
      reportedIds: reported,
      message:
          'Thank you for reporting. This wallpaper has been flagged for review.',
    ));
  }

  Future<void> onShareVideo(
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

  Future<void> onOpenPhotos(
    OpenPhotosIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    try {
      await repository.openPhotos();
    } catch (_) {}
  }

  Future<void> onCheckWallpaperStatus(
    CheckWallpaperStatusIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    final isActive = await repository.isWallpaperActiveOnDevice();
    emit(state.copyWith(isLiveWallpaperActiveOnDevice: isActive));
    add(const SyncHardwareBatteryIntent());
  }

  Future<void> onSyncHardwareBattery(
    SyncHardwareBatteryIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    try {
      final info = await repository.getHardwareBatteryInfo();
      final batteryPercent = (info['batteryPercent'] as num?)?.toInt() ?? 100;
      final isCharging = info['isCharging'] as bool? ?? false;
      final isPowerSave = info['isPowerSaveMode'] as bool? ?? false;

      BatteryTelemetryConfig telemetry = state.batteryTelemetry;
      if (telemetry.targetFps == TargetFpsMode.fpsAuto) {
        final shouldThrottle =
            (batteryPercent < 20 && !isCharging) || isPowerSave;
        if (telemetry.isEcoModeEnabled != shouldThrottle) {
          telemetry = telemetry.copyWith(isEcoModeEnabled: shouldThrottle);
          await repository.saveBatteryTelemetryConfig(telemetry);
        }
      }

      emit(state.copyWith(
        deviceBatteryLevel: batteryPercent,
        isDeviceCharging: isCharging,
        isDevicePowerSaveMode: isPowerSave,
        batteryTelemetry: telemetry,
      ));
    } catch (_) {}
  }
}
