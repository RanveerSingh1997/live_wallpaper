import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/models/aura_palette_config.dart';
import 'package:live_wallpaper/models/battery_telemetry_config.dart';
import 'package:live_wallpaper/models/day_night_schedule_config.dart';
import 'package:live_wallpaper/models/gesture_control_config.dart';
import 'package:live_wallpaper/models/lock_screen_style_config.dart';
import 'package:live_wallpaper/models/motivational_short.dart';
import 'package:live_wallpaper/models/parallax_effect_config.dart';
import 'package:live_wallpaper/models/particle_effect_config.dart';
import 'package:live_wallpaper/models/smart_filter_config.dart';
import 'package:live_wallpaper/models/standby_dock_config.dart';
import 'package:live_wallpaper/models/wallpaper_collection.dart';
import 'package:live_wallpaper/models/wallpaper_effect_config.dart';
import 'package:live_wallpaper/models/wallora_backup_bundle.dart';
import 'package:live_wallpaper/repositories/wallpaper_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late WallpaperRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'favorite_short_ids': ['ippo_hard_work'],
      'custom_quote_ippo_hard_work': 'Custom quote test',
      'user_preferred_categories': ['Anime & Gaming', 'Minimal & AMOLED'],
      'has_seen_onboarding': true,
      'auto_rotation_interval_minutes': 180,
      'auto_rotation_source': 'favorites',
      'auto_rotation_target': 'both',
    });
    final prefs = await SharedPreferences.getInstance();
    repository = WallpaperRepository(prefs: prefs);
  });

  group('WallpaperRepository Unit Tests', () {
    test('AMOLED saver mode persists and reads properly', () async {
      expect(repository.isAmoledSaverModeEnabled(), isFalse);

      await repository.setAmoledSaverMode(true);
      expect(repository.isAmoledSaverModeEnabled(), isTrue);

      await repository.setAmoledSaverMode(false);
      expect(repository.isAmoledSaverModeEnabled(), isFalse);
    });

    test('Onboarding status persists and reads properly', () async {
      expect(repository.hasSeenOnboarding(), isTrue);

      await repository.setHasSeenOnboarding(false);
      expect(repository.hasSeenOnboarding(), isFalse);
    });

    test('Favorites CRUD and toggle behavior', () async {
      final initialFavorites = repository.getFavorites();
      expect(initialFavorites.contains('ippo_hard_work'), isTrue);

      // Toggle off
      final afterRemove = await repository.toggleFavorite('ippo_hard_work');
      expect(afterRemove.contains('ippo_hard_work'), isFalse);
      expect(repository.getFavorites().contains('ippo_hard_work'), isFalse);

      // Toggle on
      final afterAdd = await repository.toggleFavorite('ippo_hard_work');
      expect(afterAdd.contains('ippo_hard_work'), isTrue);
      expect(repository.getFavorites().contains('ippo_hard_work'), isTrue);
    });

    test('Custom quotes CRUD and mapping', () async {
      final quotes = repository.getCustomQuotes();
      expect(quotes['ippo_hard_work'], 'Custom quote test');

      await repository.saveCustomQuote('solo_shadow_monarch', 'Arise.');
      final updated = repository.getCustomQuotes();
      expect(updated['solo_shadow_monarch'], 'Arise.');
    });

    test('Custom effects CRUD and reset', () async {
      expect(repository.getCustomEffects(), isEmpty);

      const effect = WallpaperEffectConfig(
        blurSigma: 6.0,
        vignetteStrength: 0.4,
        colorFilterPreset: 'cyber_cyan',
      );

      await repository.saveCustomEffect('ippo_hard_work', effect);
      final savedMap = repository.getCustomEffects();
      expect(savedMap['ippo_hard_work'], equals(effect));

      // Resetting back to default
      await repository.resetCustomEffect('ippo_hard_work');
      expect(repository.getCustomEffects().containsKey('ippo_hard_work'), isFalse);
    });

    test('User preferred categories CRUD and default fallback', () async {
      final prefs = repository.getUserPreferences();
      expect(prefs.contains('Anime & Gaming'), isTrue);
      expect(prefs.contains('Minimal & AMOLED'), isTrue);

      await repository.saveUserPreferences({'Fitness & Grind'});
      expect(repository.getUserPreferences(), equals({'Fitness & Grind'}));
    });

    test('Text overlay default preference toggle', () async {
      expect(repository.isTextOverlayEnabledByDefault(), isTrue);

      await repository.setTextOverlayEnabled(false);
      expect(repository.isTextOverlayEnabledByDefault(), isFalse);

      await repository.setTextOverlayEnabled(true);
      expect(repository.isTextOverlayEnabledByDefault(), isTrue);
    });

    test('Recently viewed items tracking with 20 item truncation and MRU order', () async {
      for (int i = 1; i <= 25; i++) {
        await repository.recordRecentlyViewed('item_$i');
      }

      final recent = repository.getRecentlyViewed();
      expect(recent.length, 20);
      expect(recent.first, 'item_25');
      expect(recent.contains('item_1'), isFalse); // oldest evicted

      // Viewing an existing item moves it to front
      await repository.recordRecentlyViewed('item_10');
      final updated = repository.getRecentlyViewed();
      expect(updated.first, 'item_10');
      expect(updated.length, 20);
    });

    test('Reported wallpaper IDs tracking and deduplication', () async {
      expect(repository.getReportedIds(), isEmpty);

      await repository.reportWallpaper('offensive_wall_1', 'Inappropriate content');
      expect(repository.getReportedIds().contains('offensive_wall_1'), isTrue);

      // Reporting same ID again should not duplicate
      await repository.reportWallpaper('offensive_wall_1', 'Duplicate report');
      expect(repository.getReportedIds().length, 1);
    });

    test('Auto rotation preferences and intervals', () async {
      expect(repository.isAutoRotationEnabled(), isFalse);
      await repository.setAutoRotationEnabled(true);
      expect(repository.isAutoRotationEnabled(), isTrue);

      expect(repository.getAutoRotationIntervalMinutes(), 180);
      await repository.setAutoRotationIntervalMinutes(60);
      expect(repository.getAutoRotationIntervalMinutes(), 60);

      expect(repository.getAutoRotationSource(), 'favorites');
      await repository.setAutoRotationSource('all');
      expect(repository.getAutoRotationSource(), 'all');

      expect(repository.isAutoRotationWifiOnly(), isTrue);
      await repository.setAutoRotationWifiOnly(false);
      expect(repository.isAutoRotationWifiOnly(), isFalse);

      expect(repository.getAutoRotationTarget(), 'both');
      await repository.setAutoRotationTarget('home');
      expect(repository.getAutoRotationTarget(), 'home');
    });

    test('Custom collections CRUD and membership toggling', () async {
      expect(repository.getCustomCollections(), isEmpty);

      const playlist = WallpaperCollection(
        id: 'repo_col_test',
        title: 'Cyber Deck',
        subtitle: 'Synth & Neon',
        badge: 'CYBER',
        icon: Icons.computer_rounded,
        wallpaperIds: ['wall_cyber_1'],
        gradientColors: [Color(0xFF00E5FF), Colors.black],
        isUserCreated: true,
      );

      // Save collection
      await repository.saveCustomCollection(playlist);
      final loaded = repository.getCustomCollections();
      expect(loaded.length, 1);
      expect(loaded.first.id, 'repo_col_test');

      // Toggle wallpaper in collection (add)
      final afterAdd = await repository.toggleWallpaperInCollection('repo_col_test', 'wall_cyber_2');
      expect(afterAdd?.wallpaperIds.contains('wall_cyber_2'), isTrue);

      // Toggle wallpaper in collection (remove)
      final afterRemove = await repository.toggleWallpaperInCollection('repo_col_test', 'wall_cyber_2');
      expect(afterRemove?.wallpaperIds.contains('wall_cyber_2'), isFalse);

      // Delete collection
      await repository.deleteCustomCollection('repo_col_test');
      expect(repository.getCustomCollections(), isEmpty);
    });

    test('Custom imported creator wallpapers CRUD', () async {
      expect(repository.getCustomImportedWallpapers(), isEmpty);

      const customShort = MotivationalShort(
        id: 'custom_creator_1',
        title: 'Local MP4 Live',
        quote: 'My Own Philosophy',
        author: 'Creator',
        category: 'Custom Uploads',
        videoAssetPath: '/data/user/local.mp4',
        accentColor: Colors.purple,
        tags: 'local, custom',
      );

      await repository.saveCustomImportedWallpaper(customShort);
      final imported = repository.getCustomImportedWallpapers();
      expect(imported.length, 1);
      expect(imported.first.id, 'custom_creator_1');

      // Curated shorts include custom imported shorts at front
      final all = repository.getCuratedShorts();
      expect(all.first.id, 'custom_creator_1');
    });

    test('Day & Night schedule config CRUD', () async {
      // Default fallback
      final defaultConfig = repository.getDayNightScheduleConfig();
      expect(defaultConfig.isEnabled, isFalse);
      expect(defaultConfig.morningHour, 6);

      // Save and read back
      const customConfig = DayNightScheduleConfig(
        isEnabled: true,
        morningHour: 7,
        morningWallpaperId: 'custom_dawn_wall',
        autoAmoledAtNight: true,
      );
      await repository.saveDayNightScheduleConfig(customConfig);

      final loaded = repository.getDayNightScheduleConfig();
      expect(loaded.isEnabled, isTrue);
      expect(loaded.morningHour, 7);
      expect(loaded.morningWallpaperId, 'custom_dawn_wall');
      expect(loaded.autoAmoledAtNight, isTrue);
    });

    test('Lock screen style config CRUD and reset', () async {
      // Default fallback
      final defaultConfig = repository.getLockScreenStyleConfig();
      expect(defaultConfig.clockFont, LockScreenClockFont.modern);
      expect(defaultConfig.clockLayout, LockScreenClockLayout.horizontal);

      // Save custom config
      const customConfig = LockScreenStyleConfig(
        clockFont: LockScreenClockFont.cyber,
        clockLayout: LockScreenClockLayout.stacked,
        widgetType: LockScreenWidgetType.batteryGlance,
        useWallpaperAccentColor: false,
        customColor: Color(0xFF00E676),
        clockSize: 90.0,
      );
      await repository.saveLockScreenStyleConfig(customConfig);

      final loaded = repository.getLockScreenStyleConfig();
      expect(loaded.clockFont, LockScreenClockFont.cyber);
      expect(loaded.clockLayout, LockScreenClockLayout.stacked);
      expect(loaded.widgetType, LockScreenWidgetType.batteryGlance);
      expect(loaded.useWallpaperAccentColor, isFalse);
      expect(loaded.customColor.toARGB32(), const Color(0xFF00E676).toARGB32());
      expect(loaded.clockSize, 90.0);

      // Reset
      await repository.resetLockScreenStyleConfig();
      final resetConfig = repository.getLockScreenStyleConfig();
      expect(resetConfig, LockScreenStyleConfig.defaultConfig);
    });

    test('3D Spatial Parallax config CRUD and reset', () async {
      // Default fallback
      final defaultConfig = repository.getParallaxEffectConfig();
      expect(defaultConfig.isEnabled, isTrue);
      expect(defaultConfig.preset, ParallaxPreset.cinematic3D);

      // Save custom config
      const customConfig = ParallaxEffectConfig(
        isEnabled: true,
        sensitivity: 2.2,
        maxAngleDegrees: 20.0,
        invertPitch: true,
        invertRoll: true,
        depthZoomScale: 1.15,
        preset: ParallaxPreset.hyperFloat,
      );
      await repository.saveParallaxEffectConfig(customConfig);

      final loaded = repository.getParallaxEffectConfig();
      expect(loaded.isEnabled, isTrue);
      expect(loaded.sensitivity, 2.2);
      expect(loaded.maxAngleDegrees, 20.0);
      expect(loaded.invertPitch, isTrue);
      expect(loaded.invertRoll, isTrue);
      expect(loaded.depthZoomScale, 1.15);
      expect(loaded.preset, ParallaxPreset.hyperFloat);

      // Reset
      await repository.resetParallaxEffectConfig();
      final resetConfig = repository.getParallaxEffectConfig();
      expect(resetConfig, ParallaxEffectConfig.defaultConfig);
    });

    test('SmartFilterConfig CRUD and reset persistence', () async {
      // Default fallback
      final initial = repository.getSmartFilterConfig();
      expect(initial, equals(SmartFilterConfig.defaultConfig));

      // Save custom config
      const custom = SmartFilterConfig(
        mediaType: SmartMediaType.liveOnly,
        mood: SmartMood.fighterSpirit,
        paletteColor: SmartPaletteColor.neonCyan,
        amoledCertifiedOnly: true,
        hasTextOverlayOnly: true,
      );
      await repository.saveSmartFilterConfig(custom);

      final loaded = repository.getSmartFilterConfig();
      expect(loaded, equals(custom));
      expect(loaded.mediaType, equals(SmartMediaType.liveOnly));
      expect(loaded.mood, equals(SmartMood.fighterSpirit));
      expect(loaded.paletteColor, equals(SmartPaletteColor.neonCyan));
      expect(loaded.amoledCertifiedOnly, isTrue);
      expect(loaded.hasTextOverlayOnly, isTrue);

      // Reset
      await repository.resetSmartFilterConfig();
      final reset = repository.getSmartFilterConfig();
      expect(reset, equals(SmartFilterConfig.defaultConfig));
    });

    test('BatteryTelemetryConfig CRUD and reset persistence', () async {
      // Default fallback
      final initial = repository.getBatteryTelemetryConfig();
      expect(initial, equals(BatteryTelemetryConfig.defaultConfig));

      // Save custom config
      const custom = BatteryTelemetryConfig(
        targetFps: TargetFpsMode.fps30,
        isEcoModeEnabled: true,
        isPixelShiftEnabled: false,
        isHardwareDecodingPreferred: false,
        isBackgroundZeroSleepVerified: true,
      );
      await repository.saveBatteryTelemetryConfig(custom);

      final loaded = repository.getBatteryTelemetryConfig();
      expect(loaded, equals(custom));
      expect(loaded.targetFps, equals(TargetFpsMode.fps30));
      expect(loaded.isEcoModeEnabled, isTrue);
      expect(loaded.isPixelShiftEnabled, isFalse);
      expect(loaded.isHardwareDecodingPreferred, isFalse);

      // Reset
      await repository.resetBatteryTelemetryConfig();
      final reset = repository.getBatteryTelemetryConfig();
      expect(reset, equals(BatteryTelemetryConfig.defaultConfig));
    });

    test('ParticleEffectConfig CRUD and reset persistence', () async {
      // Default fallback
      final initial = repository.getParticleEffectConfig();
      expect(initial, equals(ParticleEffectConfig.defaultConfig));

      // Save custom config
      const custom = ParticleEffectConfig(
        preset: ParticlePreset.electricSparks,
        particleCount: 75,
        speedMultiplier: 1.8,
        lifespanSeconds: 3.2,
        glowIntensity: 0.9,
        isHapticsEnabled: false,
        isBatteryGuardEnabled: false,
      );
      await repository.saveParticleEffectConfig(custom);

      final loaded = repository.getParticleEffectConfig();
      expect(loaded, equals(custom));
      expect(loaded.preset, equals(ParticlePreset.electricSparks));
      expect(loaded.particleCount, equals(75));
      expect(loaded.speedMultiplier, equals(1.8));
      expect(loaded.lifespanSeconds, equals(3.2));
      expect(loaded.glowIntensity, equals(0.9));
      expect(loaded.isHapticsEnabled, isFalse);
      expect(loaded.isBatteryGuardEnabled, isFalse);

      // Reset
      await repository.resetParticleEffectConfig();
      final reset = repository.getParticleEffectConfig();
      expect(reset, equals(ParticleEffectConfig.defaultConfig));
    });

    test('AuraPaletteConfig CRUD and reset persistence', () async {
      // Default fallback
      final initial = repository.getAuraPaletteConfig();
      expect(initial, equals(AuraPaletteConfig.defaultConfig));

      // Save custom config
      const custom = AuraPaletteConfig(
        preset: AuraThemePreset.cyberAurora,
        isDynamicThemingEnabled: false,
        syncParticles: false,
        syncKineticQuotes: false,
        syncLockScreen: true,
        hueShiftDegrees: 60.0,
        saturationMultiplier: 1.3,
      );
      await repository.saveAuraPaletteConfig(custom);

      final loaded = repository.getAuraPaletteConfig();
      expect(loaded, equals(custom));
      expect(loaded.preset, equals(AuraThemePreset.cyberAurora));
      expect(loaded.isDynamicThemingEnabled, isFalse);
      expect(loaded.syncParticles, isFalse);
      expect(loaded.syncKineticQuotes, isFalse);
      expect(loaded.syncLockScreen, isTrue);
      expect(loaded.hueShiftDegrees, equals(60.0));
      expect(loaded.saturationMultiplier, equals(1.3));

      // Reset
      await repository.resetAuraPaletteConfig();
      final reset = repository.getAuraPaletteConfig();
      expect(reset, equals(AuraPaletteConfig.defaultConfig));
    });

    test('GestureControlConfig CRUD and reset persistence', () async {
      // Default fallback
      final initial = repository.getGestureControlConfig();
      expect(initial, equals(GestureControlConfig.defaultConfig));

      // Save custom config
      const custom = GestureControlConfig(
        isGesturesEnabled: true,
        doubleTapAction: GestureAction.nextWallpaper,
        tripleTapAction: GestureAction.toggleEffects,
        twoFingerSwipeDownAction: GestureAction.none,
        longPressAction: GestureAction.openStudio,
        hapticProfile: HapticFeedbackProfile.firm,
        touchVisualEffect: TouchVisualEffect.particleBurst,
        touchColorMode: TouchColorMode.electricCyan,
        rippleDurationMs: 500,
      );
      await repository.saveGestureControlConfig(custom);

      final loaded = repository.getGestureControlConfig();
      expect(loaded, equals(custom));
      expect(loaded.doubleTapAction, equals(GestureAction.nextWallpaper));
      expect(loaded.tripleTapAction, equals(GestureAction.toggleEffects));
      expect(loaded.twoFingerSwipeDownAction, equals(GestureAction.none));
      expect(loaded.longPressAction, equals(GestureAction.openStudio));
      expect(loaded.hapticProfile, equals(HapticFeedbackProfile.firm));
      expect(loaded.touchVisualEffect, equals(TouchVisualEffect.particleBurst));
      expect(loaded.touchColorMode, equals(TouchColorMode.electricCyan));
      expect(loaded.rippleDurationMs, equals(500));

      // Reset
      await repository.resetGestureControlConfig();
      final reset = repository.getGestureControlConfig();
      expect(reset, equals(GestureControlConfig.defaultConfig));
    });

    test('createBackupBundle and restoreBackupBundle (replace and merge)', () async {
      // 1. Setup initial state
      await repository.toggleFavorite('fav_1');
      await repository.saveCustomQuote('quote_1', 'Original Quote');

      final initialBundle = await repository.createBackupBundle();
      expect(initialBundle.favoriteIds, contains('fav_1'));
      expect(initialBundle.customizedQuotes['quote_1'], equals('Original Quote'));

      // 2. Prepare new bundle with different items
      final importBundle = WalloraBackupBundle(
        exportedAt: DateTime.now(),
        favoriteIds: const {'fav_2'},
        customizedQuotes: const {'quote_2': 'Imported Quote'},
        isAmoledSaverModeEnabled: true,
      );

      // 3. Test Replace (!mergeWithExisting)
      final replaceSuccess = await repository.restoreBackupBundle(
        importBundle,
        mergeWithExisting: false,
      );
      expect(replaceSuccess, isTrue);

      final replacedFavorites = repository.getFavorites();
      expect(replacedFavorites, equals({'fav_2'}));
      expect(repository.getCustomQuotes()['quote_2'], equals('Imported Quote'));
      expect(repository.getCustomQuotes()['quote_1'], isNull);
      expect(repository.isAmoledSaverModeEnabled(), isTrue);

      // 4. Test Merge (mergeWithExisting)
      final mergeBundle = WalloraBackupBundle(
        exportedAt: DateTime.now(),
        favoriteIds: const {'fav_3'},
        customizedQuotes: const {'quote_3': 'Merged Quote'},
      );
      final mergeSuccess = await repository.restoreBackupBundle(
        mergeBundle,
        mergeWithExisting: true,
      );
      expect(mergeSuccess, isTrue);

      final mergedFavorites = repository.getFavorites();
      expect(mergedFavorites, contains('fav_2'));
      expect(mergedFavorites, contains('fav_3'));
      expect(repository.getCustomQuotes()['quote_2'], equals('Imported Quote'));
      expect(repository.getCustomQuotes()['quote_3'], equals('Merged Quote'));
    });

    test('StandbyDockConfig CRUD and reset', () async {
      expect(repository.getStandbyDockConfig(),
          equals(StandbyDockConfig.defaultConfig));

      const custom = StandbyDockConfig(
        clockStyle: DockClockStyle.cyberpunkTech,
        layoutMode: DockLayoutMode.centeredZen,
        isNightModeEnabled: true,
        isBurnInProtectionEnabled: false,
        is24HourFormat: true,
      );
      await repository.saveStandbyDockConfig(custom);
      expect(repository.getStandbyDockConfig(), equals(custom));

      await repository.resetStandbyDockConfig();
      expect(repository.getStandbyDockConfig(),
          equals(StandbyDockConfig.defaultConfig));
    });

    test('resetToFactoryDefaults clears all user customizations and configs', () async {
      await repository.toggleFavorite('fav_wipe');
      await repository.saveCustomQuote('wipe_quote', 'Temp Quote');
      await repository.setAmoledSaverMode(true);
      await repository.saveAuraPaletteConfig(
        const AuraPaletteConfig(preset: AuraThemePreset.solarEclipse),
      );
      await repository.saveStandbyDockConfig(
        const StandbyDockConfig(clockStyle: DockClockStyle.oledMatrix),
      );

      await repository.resetToFactoryDefaults();

      expect(repository.getFavorites(), isEmpty);
      expect(repository.getCustomQuotes(), isEmpty);
      expect(repository.isAmoledSaverModeEnabled(), isFalse);
      expect(repository.getAuraPaletteConfig(), equals(AuraPaletteConfig.defaultConfig));
      expect(repository.getStandbyDockConfig(), equals(StandbyDockConfig.defaultConfig));
    });
  });
}
