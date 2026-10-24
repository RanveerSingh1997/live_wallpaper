import '../core/core.dart';
import '../models/wallora_backup_bundle.dart';
import 'playlist_repository.dart';
import 'studio_config_repository.dart';

/// Abstract contract for data portability: full JSON backup export, restoration, and factory reset.
/// Follows Dependency Inversion Principle (DIP).
abstract class DataPortabilityRepository {
  factory DataPortabilityRepository({
    required LocalCacheService cache,
    required PlaylistRepository playlistRepo,
    required StudioConfigRepository studioRepo,
  }) = DataPortabilityRepositoryImpl;

  /// Creates a complete [WalloraBackupBundle] capturing the user's setup.
  Future<WalloraBackupBundle> createBackupBundle();

  /// Restores setup from a [WalloraBackupBundle] with optional merge support.
  Future<bool> restoreBackupBundle(
    WalloraBackupBundle bundle, {
    bool mergeWithExisting = false,
  });

  /// Resets all settings, playlists, custom quotes, and effects to initial defaults.
  Future<void> factoryResetData();
}

/// Concrete implementation of [DataPortabilityRepository].
class DataPortabilityRepositoryImpl implements DataPortabilityRepository {
  final LocalCacheService cache;
  final PlaylistRepository playlistRepo;
  final StudioConfigRepository studioRepo;

  DataPortabilityRepositoryImpl({
    required this.cache,
    required this.playlistRepo,
    required this.studioRepo,
  });

  @override
  Future<WalloraBackupBundle> createBackupBundle() async {
    return WalloraBackupBundle(
      exportedAt: DateTime.now(),
      favoriteIds: playlistRepo.getFavorites(),
      customCollections: playlistRepo.getCustomCollections(),
      customizedQuotes: studioRepo.getCustomQuotes(),
      customEffects: studioRepo.getCustomEffects(),
      dayNightSchedule: studioRepo.getDayNightScheduleConfig(),
      lockScreenStyle: studioRepo.getLockScreenStyleConfig(),
      parallaxConfig: studioRepo.getParallaxEffectConfig(),
      particleConfig: studioRepo.getParticleEffectConfig(),
      auraConfig: studioRepo.getAuraPaletteConfig(),
      gestureConfig: studioRepo.getGestureControlConfig(),
      standbyDockConfig: studioRepo.getStandbyDockConfig(),
      auroraSynthesizerConfig: studioRepo.getAuroraSynthesizerConfig(),
      batteryTelemetry: studioRepo.getBatteryTelemetryConfig(),
      smartFilter: studioRepo.getSmartFilterConfig(),
      weatherConfig: studioRepo.getWeatherAtmosphereConfig(),
      userPreferences: studioRepo.getUserPreferences(),
      isAmoledSaverModeEnabled: studioRepo.isAmoledSaverModeEnabled(),
    );
  }

  @override
  Future<bool> restoreBackupBundle(
    WalloraBackupBundle bundle, {
    bool mergeWithExisting = false,
  }) async {
    try {
      // 1. Favorites
      final targetFavorites = mergeWithExisting
          ? (playlistRepo.getFavorites()..addAll(bundle.favoriteIds))
          : bundle.favoriteIds;
      await playlistRepo.setFavorites(targetFavorites);

      // 2. Custom Collections
      if (mergeWithExisting) {
        final existing = playlistRepo.getCustomCollections();
        final map = {for (final c in existing) c.id: c};
        for (final c in bundle.customCollections) {
          map[c.id] = c;
        }
        await playlistRepo.setCustomCollections(map.values.toList());
      } else {
        await playlistRepo.setCustomCollections(bundle.customCollections);
      }

      // 3. Custom Quotes
      if (!mergeWithExisting) {
        final existingQuotes = studioRepo.getCustomQuotes();
        for (final id in existingQuotes.keys) {
          await studioRepo.resetCustomQuote(id);
        }
      }
      for (final entry in bundle.customizedQuotes.entries) {
        await studioRepo.saveCustomQuote(entry.key, entry.value);
      }

      // 4. Custom Effects
      if (!mergeWithExisting) {
        final existingEffects = studioRepo.getCustomEffects();
        for (final id in existingEffects.keys) {
          await studioRepo.resetCustomEffect(id);
        }
      }
      for (final entry in bundle.customEffects.entries) {
        await studioRepo.saveCustomEffect(entry.key, entry.value);
      }

      // 5. Studio Configurations
      await studioRepo.saveDayNightScheduleConfig(bundle.dayNightSchedule);
      await studioRepo.saveLockScreenStyleConfig(bundle.lockScreenStyle);
      await studioRepo.saveParallaxEffectConfig(bundle.parallaxConfig);
      await studioRepo.saveParticleEffectConfig(bundle.particleConfig);
      await studioRepo.saveAuraPaletteConfig(bundle.auraConfig);
      await studioRepo.saveGestureControlConfig(bundle.gestureConfig);
      await studioRepo.saveStandbyDockConfig(bundle.standbyDockConfig);
      await studioRepo.saveAuroraSynthesizerConfig(bundle.auroraSynthesizerConfig);
      await studioRepo.saveBatteryTelemetryConfig(bundle.batteryTelemetry);
      await studioRepo.saveSmartFilterConfig(bundle.smartFilter);
      await studioRepo.saveWeatherAtmosphereConfig(bundle.weatherConfig);

      // 6. User Preferences & Modes
      final targetPrefs = mergeWithExisting
          ? (studioRepo.getUserPreferences()..addAll(bundle.userPreferences))
          : bundle.userPreferences;
      await studioRepo.saveUserPreferences(targetPrefs);
      await studioRepo.setAmoledSaverMode(bundle.isAmoledSaverModeEnabled);

      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> factoryResetData() async {
    await cache.remove(AppConstants.keyFavorites);
    await cache.remove(AppConstants.keyCustomCollections);
    await cache.remove(AppConstants.keyAmoledSaverMode);
    await cache.remove(AppConstants.keyDayNightSchedule);
    await cache.remove(AppConstants.keyLockScreenStyle);
    await cache.remove(AppConstants.keyParallaxConfig);
    await cache.remove(AppConstants.keyParticleConfig);
    await cache.remove(AppConstants.keyAuraPalette);
    await cache.remove(AppConstants.keyGestureControl);
    await cache.remove(AppConstants.keyStandbyDock);
    await cache.remove(AppConstants.keyAuroraSynthesizer);
    await cache.remove(AppConstants.keyWeatherAtmosphere);
    await cache.remove(AppConstants.keySmartFilter);
    await cache.remove(AppConstants.keyBatteryTelemetry);
    await cache.remove(AppConstants.keyAutoRotationEnabled);
    await cache.remove(AppConstants.keyAutoRotationIntervalMinutes);
    await cache.remove(AppConstants.keyAutoRotationSource);
    await cache.remove(AppConstants.keyUserPreferences);
    await cache.remove(AppConstants.keyRecentlyViewed);
    await cache.remove(AppConstants.keyReported);
    await cache.remove(AppConstants.keyPublishedBlueprints);
    await cache.remove(AppConstants.keyLikedBlueprintIds);

    // Clean custom quotes and effects
    final quoteKeys = cache.getKeys(prefix: AppConstants.keyCustomQuotesPrefix);
    for (final k in quoteKeys) {
      await cache.remove(k);
    }
    final effectKeys = cache.getKeys(prefix: AppConstants.keyCustomEffectsPrefix);
    for (final k in effectKeys) {
      await cache.remove(k);
    }
  }
}
