import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/models/day_night_schedule_config.dart';
import 'package:live_wallpaper/models/lock_screen_style_config.dart';
import 'package:live_wallpaper/models/motivational_short.dart';
import 'package:live_wallpaper/models/wallpaper_collection.dart';
import 'package:live_wallpaper/models/wallpaper_effect_config.dart';
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
  });
}
