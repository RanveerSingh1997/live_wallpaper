import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/aura_palette_config.dart';
import '../../models/aurora_synthesizer_config.dart';
import '../../models/battery_telemetry_config.dart';
import '../../models/day_night_schedule_config.dart';
import '../../models/gesture_control_config.dart';
import '../../models/lock_screen_style_config.dart';
import '../../models/parallax_effect_config.dart';
import '../../models/particle_effect_config.dart';
import '../../models/smart_filter_config.dart';
import '../../models/standby_dock_config.dart';
import '../../models/wallpaper_effect_config.dart';
import '../../models/weather_atmosphere_config.dart';
import '../../repositories/wallpaper_repository.dart';
import '../wallpaper_intent.dart';
import '../wallpaper_state.dart';
import 'wallpaper_feed_filter.dart';

mixin StudioHandlers on Bloc<WallpaperIntent, WallpaperState> {
  WallpaperFacadeRepository get repository;

  Future<void> onUpdateWallpaperEffect(
    UpdateWallpaperEffectIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.saveCustomEffect(event.wallpaperId, event.effectConfig);
    final updatedEffects =
        Map<String, WallpaperEffectConfig>.from(state.customEffects);
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

  Future<void> onResetWallpaperEffect(
    ResetWallpaperEffectIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.resetCustomEffect(event.wallpaperId);
    final updatedEffects =
        Map<String, WallpaperEffectConfig>.from(state.customEffects)
          ..remove(event.wallpaperId);
    emit(state.copyWith(
      customEffects: updatedEffects,
      message: 'Visual canvas effects reset to default.',
    ));
  }

  Future<void> onUpdateDayNightSchedule(
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

  Future<void> onToggleDayNightSchedule(
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

  Future<void> onCheckDayNightTransition(
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
            message:
                'Solar schedule (${slot.label}) transitioned to "${targetWallpaper.title}".',
          ));
        } else {
          emit(state.copyWith(
            actionStatus: WallpaperActionStatus.idle,
            message:
                'Solar schedule (${slot.label}) active: "${targetWallpaper.title}".',
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
          message:
              'Solar schedule (${slot.label}) transitioned to "${targetWallpaper.title}".',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        actionStatus: WallpaperActionStatus.error,
        errorMessage: 'Failed to apply scheduled solar wallpaper: $e',
      ));
    }
  }

  Future<void> onUpdateLockScreenStyle(
    UpdateLockScreenStyleIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.saveLockScreenStyleConfig(event.config);
    emit(state.copyWith(
      lockScreenStyle: event.config,
      message: 'Lock screen simulation aesthetic updated.',
    ));
  }

  Future<void> onResetLockScreenStyle(
    ResetLockScreenStyleIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.resetLockScreenStyleConfig();
    emit(state.copyWith(
      lockScreenStyle: LockScreenStyleConfig.defaultConfig,
      message: 'Lock screen aesthetic reset to default.',
    ));
  }

  Future<void> onUpdateParallaxConfig(
    UpdateParallaxConfigIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.saveParallaxEffectConfig(event.config);
    emit(state.copyWith(
      parallaxConfig: event.config,
      message: '3D Spatial Parallax motion updated.',
    ));
  }

  Future<void> onToggleParallax(
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

  Future<void> onResetParallaxConfig(
    ResetParallaxConfigIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.resetParallaxEffectConfig();
    emit(state.copyWith(
      parallaxConfig: ParallaxEffectConfig.defaultConfig,
      message: '3D Spatial Parallax reset to default.',
    ));
  }

  Future<void> onUpdateSmartFilter(
    UpdateSmartFilterIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.saveSmartFilterConfig(event.config);
    final filtered = WallpaperFeedFilter.filterShorts(
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

  Future<void> onResetSmartFilter(
    ResetSmartFilterIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.resetSmartFilterConfig();
    final defaultConfig = SmartFilterConfig.defaultConfig;
    final filtered = WallpaperFeedFilter.filterShorts(
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

  Future<void> onUpdateBatteryTelemetry(
    UpdateBatteryTelemetryIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.saveBatteryTelemetryConfig(event.config);
    emit(state.copyWith(
      batteryTelemetry: event.config,
      message: 'Battery & display telemetry updated.',
    ));
  }

  Future<void> onToggleEcoMode(
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

  Future<void> onResetBatteryTelemetry(
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

  Future<void> onUpdateParticleConfig(
    UpdateParticleConfigIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.saveParticleEffectConfig(event.config);
    emit(state.copyWith(
      particleConfig: event.config,
      message: 'Interactive Particle FX updated (${event.config.preset.label}).',
    ));
  }

  Future<void> onToggleParticleEffect(
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

  Future<void> onResetParticleConfig(
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

  Future<void> onUpdateAuraPalette(
    UpdateAuraPaletteIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.saveAuraPaletteConfig(event.config);
    emit(state.copyWith(
      auraConfig: event.config,
      message: 'Aura theme updated (${event.config.preset.displayName}).',
    ));
  }

  Future<void> onSetAuraThemePreset(
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

  Future<void> onResetAuraPalette(
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

  Future<void> onUpdateGestureControl(
    UpdateGestureControlIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.saveGestureControlConfig(event.config);
    emit(state.copyWith(
      gestureConfig: event.config,
      message: 'Gesture controls updated.',
    ));
  }

  Future<void> onResetGestureControl(
    ResetGestureControlIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.resetGestureControlConfig();
    emit(state.copyWith(
      gestureConfig: GestureControlConfig.defaultConfig,
      message: 'Gesture controls reset to defaults.',
    ));
  }

  void onToggleCleanCanvas(
    ToggleCleanCanvasIntent event,
    Emitter<WallpaperState> emit,
  ) {
    final nextClean = !state.isCleanCanvasMode;
    emit(state.copyWith(
      isCleanCanvasMode: nextClean,
      message: nextClean
          ? 'Clean Canvas (Zen View) activated.'
          : 'Standard view restored.',
    ));
  }

  Future<void> onExecuteGestureAction(
    ExecuteGestureActionIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    if (!state.gestureConfig.isGesturesEnabled) return;

    switch (event.action) {
      case GestureAction.nextWallpaper:
        if (state.filteredShorts.isNotEmpty) {
          final nextIndex =
              (state.activeIndex + 1) % state.filteredShorts.length;
          emit(state.copyWith(
            activeIndex: nextIndex,
            message: 'Switched to next wallpaper.',
          ));
        }
        break;

      case GestureAction.toggleFavorite:
        final current = state.currentShort;
        if (current != null) {
          final updated = await repository.toggleFavorite(current.id);
          final isFav = updated.contains(current.id);
          emit(state.copyWith(
            favoriteIds: updated,
            message: isFav ? 'Added to Favorites ❤️' : 'Removed from Favorites',
          ));
        }
        break;

      case GestureAction.toggleQuote:
        final nextVis = !state.isTextOverlayVisible;
        await repository.setTextOverlayEnabled(nextVis);
        emit(state.copyWith(
          isTextOverlayVisible: nextVis,
          message:
              nextVis ? 'Quote overlay enabled.' : 'Quote overlay hidden.',
        ));
        break;

      case GestureAction.toggleEffects:
        final current = state.currentShort;
        if (current != null) {
          final currentFx = state.getEffectiveEffects(current.id);
          final isNoir = currentFx.colorFilterPreset == 'noir';
          final newFx = isNoir
              ? WallpaperEffectConfig.defaultPreset
              : WallpaperEffectConfig.noirPreset;
          await repository.saveCustomEffect(current.id, newFx);
          final updatedMap =
              Map<String, WallpaperEffectConfig>.from(state.customEffects)
                ..[current.id] = newFx;
          emit(state.copyWith(
            customEffects: updatedMap,
            message: isNoir
                ? 'Standard colors restored.'
                : 'Noir monochrome effect enabled.',
          ));
        }
        break;

      case GestureAction.cycleAuraPalette:
        final allPresets = AuraThemePreset.values;
        final curIndex = allPresets.indexOf(state.auraConfig.preset);
        final nextPreset = allPresets[(curIndex + 1) % allPresets.length];
        final newAura = state.auraConfig.copyWith(preset: nextPreset);
        await repository.saveAuraPaletteConfig(newAura);
        emit(state.copyWith(
          auraConfig: newAura,
          message: 'Aura Palette: ${nextPreset.displayName}',
        ));
        break;

      case GestureAction.toggleCleanCanvas:
        final nextClean = !state.isCleanCanvasMode;
        emit(state.copyWith(
          isCleanCanvasMode: nextClean,
          message: nextClean
              ? 'Clean Canvas (Zen View) activated.'
              : 'Standard view restored.',
        ));
        break;

      case GestureAction.pauseResume:
        final nextMute = !state.isFeedMuted;
        emit(state.copyWith(
          isFeedMuted: nextMute,
          message:
              nextMute ? 'Live audio muted.' : 'Live audio unmuted.',
        ));
        break;

      case GestureAction.openStudio:
        emit(state.copyWith(
          message: 'Open Wallora Studio from settings to customize.',
        ));
        break;

      case GestureAction.none:
        break;
    }
  }

  Future<void> onUpdateStandbyDock(
    UpdateStandbyDockIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.saveStandbyDockConfig(event.config);
    emit(state.copyWith(
      standbyDockConfig: event.config,
      message: 'Standby dock settings updated.',
    ));
  }

  Future<void> onResetStandbyDock(
    ResetStandbyDockIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.resetStandbyDockConfig();
    emit(state.copyWith(
      standbyDockConfig: StandbyDockConfig.defaultConfig,
      message: 'Standby dock settings reset to defaults.',
    ));
  }

  Future<void> onToggleNightStandbyMode(
    ToggleNightStandbyModeIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    final updated = state.standbyDockConfig.copyWith(
      isNightModeEnabled: !state.standbyDockConfig.isNightModeEnabled,
    );
    await repository.saveStandbyDockConfig(updated);
    emit(state.copyWith(
      standbyDockConfig: updated,
      message: updated.isNightModeEnabled
          ? 'Night Standby (OLED Pure Red) enabled.'
          : 'Standard Horizon Standby enabled.',
    ));
  }

  Future<void> onUpdateAuroraSynthesizer(
    UpdateAuroraSynthesizerIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.saveAuroraSynthesizerConfig(event.config);
    emit(state.copyWith(
      auroraSynthesizerConfig: event.config,
      message: 'Aurora wave settings updated.',
    ));
  }

  Future<void> onResetAuroraSynthesizer(
    ResetAuroraSynthesizerIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.resetAuroraSynthesizerConfig();
    emit(state.copyWith(
      auroraSynthesizerConfig: AuroraSynthesizerConfig.defaultConfig,
      message: 'Aurora wave settings reset to defaults.',
    ));
  }

  Future<void> onToggleAuroraSynthesizer(
    ToggleAuroraSynthesizerIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    final updated = state.auroraSynthesizerConfig.copyWith(
      isEnabled: !state.auroraSynthesizerConfig.isEnabled,
    );
    await repository.saveAuroraSynthesizerConfig(updated);
    emit(state.copyWith(
      auroraSynthesizerConfig: updated,
      message: updated.isEnabled
          ? 'Procedural Aurora Wave Synthesizer active.'
          : 'Procedural Aurora Wave Synthesizer paused.',
    ));
  }

  Future<void> onUpdateWeatherAtmosphere(
    UpdateWeatherAtmosphereIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.saveWeatherAtmosphereConfig(event.config);
    emit(state.copyWith(
      weatherConfig: event.config,
      message: 'Weather & Atmosphere FX updated.',
    ));
  }

  Future<void> onResetWeatherAtmosphere(
    ResetWeatherAtmosphereIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.resetWeatherAtmosphereConfig();
    emit(state.copyWith(
      weatherConfig: WeatherAtmosphereConfig.defaultConfig,
      message: 'Weather & Atmosphere FX reset to defaults.',
    ));
  }

  Future<void> onToggleWeatherAtmosphere(
    ToggleWeatherAtmosphereIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    final isCurrentlyOn = state.weatherConfig.isEnabled;
    final updated = state.weatherConfig.copyWith(
      effectType:
          isCurrentlyOn ? WeatherEffectType.none : WeatherEffectType.cyberRain,
    );
    await repository.saveWeatherAtmosphereConfig(updated);
    emit(state.copyWith(
      weatherConfig: updated,
      message: !isCurrentlyOn
          ? 'Atmospheric Weather FX activated.'
          : 'Atmospheric Weather FX disabled.',
    ));
  }

  Future<void> onSetWeatherEffectPreset(
    SetWeatherEffectPresetIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    final updated = state.weatherConfig.copyWith(
      effectType: event.effectType,
    );
    await repository.saveWeatherAtmosphereConfig(updated);
    emit(state.copyWith(
      weatherConfig: updated,
      message: 'Applied ${event.effectType.displayName} effect.',
    ));
  }
}
