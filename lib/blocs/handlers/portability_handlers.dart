import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/audio_visualizer_config.dart';
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
import '../../models/weather_atmosphere_config.dart';
import '../../repositories/wallpaper_repository.dart';
import '../wallpaper_intent.dart';
import '../wallpaper_state.dart';
import 'wallpaper_feed_filter.dart';

mixin PortabilityHandlers on Bloc<WallpaperIntent, WallpaperState> {
  WallpaperFacadeRepository get repository;

  Future<void> onRestoreBackup(
    RestoreBackupIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    final success = await repository.restoreBackupBundle(
      event.bundle,
      mergeWithExisting: event.mergeWithExisting,
    );
    if (success) {
      final favorites = repository.getFavorites();
      final collections = repository.getCustomCollections();
      final quotes = repository.getCustomQuotes();
      final effects = repository.getCustomEffects();
      final dayNight = repository.getDayNightScheduleConfig();
      final lockScreen = repository.getLockScreenStyleConfig();
      final parallax = repository.getParallaxEffectConfig();
      final particle = repository.getParticleEffectConfig();
      final aura = repository.getAuraPaletteConfig();
      final gesture = repository.getGestureControlConfig();
      final standbyDock = repository.getStandbyDockConfig();
      final auroraSynthesizer = repository.getAuroraSynthesizerConfig();
      final audioVisualizer = repository.getAudioVisualizerConfig();
      final telemetry = repository.getBatteryTelemetryConfig();
      final smartFilter = repository.getSmartFilterConfig();
      final weatherConfig = repository.getWeatherAtmosphereConfig();
      final preferences = repository.getUserPreferences();
      final amoled = repository.isAmoledSaverModeEnabled();

      final forYouList = WallpaperFeedFilter.filterShorts(
        allShorts: state.allShorts,
        category: state.selectedCategory,
        preferences: preferences,
        smartFilter: smartFilter,
      );

      emit(state.copyWith(
        filteredShorts: forYouList,
        favoriteIds: favorites,
        customCollections: collections,
        customizedQuotes: quotes,
        customEffects: effects,
        dayNightSchedule: dayNight,
        lockScreenStyle: lockScreen,
        parallaxConfig: parallax,
        particleConfig: particle,
        auraConfig: aura,
        gestureConfig: gesture,
        standbyDockConfig: standbyDock,
        auroraSynthesizerConfig: auroraSynthesizer,
        audioVisualizerConfig: audioVisualizer,
        batteryTelemetry: telemetry,
        smartFilter: smartFilter,
        weatherConfig: weatherConfig,
        userPreferences: preferences,
        isAmoledSaverModeEnabled: amoled,
        message: 'Successfully restored backup (${event.bundle.summary}).',
      ));
    } else {
      emit(state.copyWith(
        errorMessage: 'Failed to restore Wallora backup archive.',
      ));
    }
  }

  Future<void> onResetFactoryDefaults(
    ResetFactoryDefaultsIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.resetToFactoryDefaults();
    final forYouList = WallpaperFeedFilter.filterShorts(
      allShorts: state.allShorts,
      category: 'For You',
      preferences: {},
      smartFilter: SmartFilterConfig.defaultConfig,
    );

    emit(state.copyWith(
      filteredShorts: forYouList,
      favoriteIds: {},
      customCollections: [],
      customizedQuotes: {},
      customEffects: {},
      dayNightSchedule: DayNightScheduleConfig.defaultConfig,
      lockScreenStyle: LockScreenStyleConfig.defaultConfig,
      parallaxConfig: ParallaxEffectConfig.defaultConfig,
      particleConfig: ParticleEffectConfig.defaultConfig,
      auraConfig: AuraPaletteConfig.defaultConfig,
      gestureConfig: GestureControlConfig.defaultConfig,
      standbyDockConfig: StandbyDockConfig.defaultConfig,
      auroraSynthesizerConfig: AuroraSynthesizerConfig.defaultConfig,
      audioVisualizerConfig: AudioVisualizerConfig.defaultConfig,
      batteryTelemetry: BatteryTelemetryConfig.defaultConfig,
      smartFilter: SmartFilterConfig.defaultConfig,
      weatherConfig: WeatherAtmosphereConfig.defaultConfig,
      userPreferences: {},
      isAmoledSaverModeEnabled: false,
      isCleanCanvasMode: false,
      communityBlueprints: repository.getCommunityBlueprints(),
      likedBlueprintIds: {},
      communityTagFilter: 'All',
      message: 'Wallora reset to factory defaults.',
    ));
  }
}
