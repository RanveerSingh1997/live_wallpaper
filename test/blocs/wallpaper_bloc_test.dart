import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/blocs/wallpaper_bloc.dart';
import 'package:live_wallpaper/blocs/wallpaper_intent.dart';
import 'package:live_wallpaper/blocs/wallpaper_state.dart';
import 'package:live_wallpaper/data/curated_shorts_data.dart';
import 'package:live_wallpaper/models/aura_palette_config.dart';
import 'package:live_wallpaper/models/aurora_synthesizer_config.dart';
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
import 'package:live_wallpaper/models/wallora_screen_blueprint.dart';
import 'package:live_wallpaper/models/weather_atmosphere_config.dart';
import 'package:live_wallpaper/models/wallaza_cloud_wallpaper.dart';
import 'package:live_wallpaper/repositories/wallpaper_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeWallpaperRepository extends WallpaperRepository {
  FakeWallpaperRepository({required super.prefs});

  @override
  Future<Map<String, dynamic>> applyAsLiveWallpaper({
    required MotivationalShort short,
    bool isMuted = true,
  }) async {
    await prefs.setString('active_wallpaper_id', short.id);
    return {'status': 'applied_mock'};
  }

  @override
  Future<Map<String, dynamic>> applyStaticWallpaper({
    required MotivationalShort short,
    String targetScreen = 'both',
    String? customQuote,
    WallpaperEffectConfig? effectConfig,
  }) async {
    await prefs.setString('active_wallpaper_id', short.id);
    return {'status': 'applied_static'};
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late WallpaperRepository repository;
  late WallpaperBloc bloc;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'favorite_short_ids': ['ippo_hard_work'],
      'custom_quote_ippo_hard_work': 'Custom test quote for Ippo',
    });
    final prefs = await SharedPreferences.getInstance();
    repository = FakeWallpaperRepository(prefs: prefs);
    bloc = WallpaperBloc(repository: repository);
  });

  tearDown(() {
    bloc.close();
  });

  group('WallpaperBloc - Intent-Driven Tests', () {
    test('initial state has default idle values', () {
      expect(bloc.state.allShorts, isEmpty);
      expect(bloc.state.filteredShorts, isEmpty);
      expect(bloc.state.activeIndex, 0);
      expect(bloc.state.actionStatus, WallpaperActionStatus.idle);
      expect(bloc.state.isFeedMuted, true);
    });

    test('LoadFeedIntent loads shorts catalog, favorites and custom quotes', () async {
      bloc.add(LoadFeedIntent());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<WallpaperState>(
            (s) => s.actionStatus == WallpaperActionStatus.loading,
          ),
          predicate<WallpaperState>((s) {
            final hasIppo = s.allShorts.any((x) => x.id == 'ippo_hard_work');
            final isFav = s.favoriteIds.contains('ippo_hard_work');
            final hasCustomQuote =
                s.customizedQuotes['ippo_hard_work'] == 'Custom test quote for Ippo';

            return s.actionStatus == WallpaperActionStatus.idle &&
                s.allShorts.isNotEmpty &&
                s.filteredShorts.length == s.allShorts.length &&
                hasIppo &&
                isFav &&
                hasCustomQuote;
          }),
        ]),
      );
    });

    test('ChangeActiveShortIntent updates activeIndex within bounds', () async {
      bloc.add(LoadFeedIntent());
      await bloc.stream.firstWhere((s) => s.allShorts.isNotEmpty);

      bloc.add(const ChangeActiveShortIntent(2));

      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) => s.activeIndex == 2)),
      );
    });

    test('ToggleFeedMuteIntent toggles between mute and unmute', () async {
      expect(bloc.state.isFeedMuted, true);

      bloc.add(ToggleFeedMuteIntent());
      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) => s.isFeedMuted == false)),
      );

      bloc.add(ToggleFeedMuteIntent());
      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) => s.isFeedMuted == true)),
      );
    });

    test('FilterByCategoryIntent filters shorts list properly', () async {
      bloc.add(LoadFeedIntent());
      await bloc.stream.firstWhere((s) => s.allShorts.isNotEmpty);

      bloc.add(const FilterByCategoryIntent('Anime & Gaming'));

      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) {
          return s.selectedCategory == 'Anime & Gaming' &&
              s.filteredShorts.every((x) => x.category == 'Anime & Gaming') &&
              s.filteredShorts.isNotEmpty;
        })),
      );

      bloc.add(const FilterByCategoryIntent('All'));

      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) {
          return s.selectedCategory == 'All' &&
              s.filteredShorts.length == s.allShorts.length;
        })),
      );
    });

    test('UpdateUserPreferencesIntent personalizes For You feed', () async {
      bloc.add(LoadFeedIntent());
      await bloc.stream.firstWhere((s) => s.allShorts.isNotEmpty);

      // Set preferences to Cars & Speed and Nature & Scenery
      bloc.add(const UpdateUserPreferencesIntent({'Cars & Speed', 'Nature & Scenery'}));

      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) {
          final firstCategories = s.filteredShorts.take(2).map((x) => x.category).toSet();
          return s.userPreferences.contains('Cars & Speed') &&
              s.userPreferences.contains('Nature & Scenery') &&
              firstCategories.contains('Cars & Speed') &&
              firstCategories.contains('Nature & Scenery');
        })),
      );
    });

    test('ToggleTextOverlayVisibilityIntent toggles overlay state', () async {
      bloc.add(LoadFeedIntent());
      await bloc.stream.firstWhere((s) => s.allShorts.isNotEmpty);

      final initialVisibility = bloc.state.isTextOverlayVisible;

      bloc.add(ToggleTextOverlayVisibilityIntent());
      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>(
            (s) => s.isTextOverlayVisible == !initialVisibility)),
      );

      bloc.add(ToggleTextOverlayVisibilityIntent());
      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>(
            (s) => s.isTextOverlayVisible == initialVisibility)),
      );
    });

    test('ToggleFavoriteIntent adds and removes short from favorites', () async {
      bloc.add(LoadFeedIntent());
      await bloc.stream.firstWhere((s) => s.allShorts.isNotEmpty);

      // Toggle off ippo_hard_work (was initial favorite)
      bloc.add(const ToggleFavoriteIntent('ippo_hard_work'));
      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>(
            (s) => !s.favoriteIds.contains('ippo_hard_work'))),
      );

      // Toggle back on
      bloc.add(const ToggleFavoriteIntent('ippo_hard_work'));
      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>(
            (s) => s.favoriteIds.contains('ippo_hard_work'))),
      );
    });

    test('UpdateCustomQuoteIntent and ResetCustomQuoteIntent work properly', () async {
      bloc.add(LoadFeedIntent());
      await bloc.stream.firstWhere((s) => s.allShorts.isNotEmpty);

      bloc.add(const UpdateCustomQuoteIntent(
        shortId: 'discipline_grind',
        newQuote: 'Pain is temporary, pride is forever.',
      ));

      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) =>
            s.customizedQuotes['discipline_grind'] ==
            'Pain is temporary, pride is forever.')),
      );

      bloc.add(const ResetCustomQuoteIntent('discipline_grind'));

      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) =>
            !s.customizedQuotes.containsKey('discipline_grind'))),
      );
    });

    test('ChangeNavigationTabIntent updates currentNavigationTab', () async {
      expect(bloc.state.currentNavigationTab, 0);

      bloc.add(const ChangeNavigationTabIntent(2));
      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) => s.currentNavigationTab == 2)),
      );
    });

    test('SearchWallpapersIntent updates search query and filters results', () async {
      bloc.add(LoadFeedIntent());
      await bloc.stream.firstWhere((s) => s.allShorts.isNotEmpty);

      bloc.add(const SearchWallpapersIntent('anime'));
      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) {
          return s.searchQuery == 'anime' &&
              s.searchResults.isNotEmpty &&
              s.searchResults.every((w) =>
                  w.title.toLowerCase().contains('anime') ||
                  w.tags.toLowerCase().contains('anime') ||
                  w.category.toLowerCase().contains('anime'));
        })),
      );
    });

    test('FilterByCategoryIntent filters live and static wallpapers specifically', () async {
      bloc.add(LoadFeedIntent());
      await bloc.stream.firstWhere((s) => s.allShorts.isNotEmpty);

      // Filter Live Only
      bloc.add(const FilterByCategoryIntent('Live Wallpapers'));
      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) {
          return s.selectedCategory == 'Live Wallpapers' &&
              s.filteredShorts.isNotEmpty &&
              s.filteredShorts.every((w) => w.isLive);
        })),
      );

      // Filter Static Only
      bloc.add(const FilterByCategoryIntent('Static Wallpapers'));
      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) {
          return s.selectedCategory == 'Static Wallpapers' &&
              s.filteredShorts.isNotEmpty &&
              s.filteredShorts.every((w) => !w.isLive);
        })),
      );
    });

    test('ClearAllDownloadsIntent resets downloadedIds and storage', () async {
      bloc.add(ClearAllDownloadsIntent());
      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>(
            (s) => s.downloadedIds.isEmpty && s.totalStorageUsedBytes == 0)),
      );
    });

    test('RecordWallpaperViewedIntent updates recentlyViewedIds in MRU order', () async {
      bloc.add(const RecordWallpaperViewedIntent('amoled_void_black'));
      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) =>
            s.recentlyViewedIds.first == 'amoled_void_black')),
      );

      bloc.add(const RecordWallpaperViewedIntent('nature_cyber_rain'));
      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) =>
            s.recentlyViewedIds.first == 'nature_cyber_rain' &&
            s.recentlyViewedIds[1] == 'amoled_void_black')),
      );
    });

    test('ReportWallpaperIntent records reported wallpaper id', () async {
      bloc.add(const ReportWallpaperIntent(
        wallpaperId: 'nature_cyber_rain',
        reason: 'Poor resolution',
      ));

      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) =>
            s.reportedIds.contains('nature_cyber_rain') &&
            s.message != null)),
      );
    });

    test('CompleteOnboardingIntent sets hasSeenOnboarding and updates preferences', () async {
      bloc.add(const CompleteOnboardingIntent({'Minimal & AMOLED', 'Cars & Speed'}));

      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) =>
            s.hasSeenOnboarding == true &&
            s.userPreferences.contains('Minimal & AMOLED') &&
            s.userPreferences.contains('Cars & Speed'))),
      );
    });

    test('ResetOnboardingIntent sets hasSeenOnboarding to false', () async {
      bloc.add(ResetOnboardingIntent());

      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) => s.hasSeenOnboarding == false)),
      );
    });

    test('ToggleAutoRotationIntent activates and pauses auto rotation', () async {
      bloc.add(const ToggleAutoRotationIntent(true));
      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) => s.isAutoRotationEnabled == true)),
      );

      bloc.add(const ToggleAutoRotationIntent(false));
      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) => s.isAutoRotationEnabled == false)),
      );
    });

    test('UpdateAutoRotationIntervalIntent updates frequency minutes', () async {
      bloc.add(const UpdateAutoRotationIntervalIntent(180));
      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) => s.autoRotationIntervalMinutes == 180)),
      );
    });

    test('UpdateAutoRotationSourceIntent updates rotation playlist pool', () async {
      bloc.add(const UpdateAutoRotationSourceIntent('col_oled'));
      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) => s.autoRotationSource == 'col_oled')),
      );
    });

    test('ImportCustomWallpaperIntent saves custom wallpaper to catalog and updates state', () async {
      const customWallpaper = MotivationalShort(
        id: 'custom_test_1',
        title: 'Custom Neon Apex',
        quote: 'Speed defines existence.',
        author: 'Creator Test',
        category: 'Cars & Speed',
        videoAssetPath: 'assets/videos/ippo_motivation.mp4',
        accentColor: Color(0xFFFF5722),
        tags: 'cars speed test',
        isLive: true,
      );

      bloc.add(const ImportCustomWallpaperIntent(customWallpaper));

      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) =>
            s.allShorts.isNotEmpty &&
            s.allShorts.first.id == 'custom_test_1' &&
            s.message != null &&
            s.message!.contains('Custom Neon Apex'))),
      );

      // Verify persisted in repository
      final saved = repository.getCustomImportedWallpapers();
      expect(saved.any((w) => w.id == 'custom_test_1'), isTrue);
    });

    test('CreateCustomCollectionIntent saves playlist to state and repository', () async {
      const playlist = WallpaperCollection(
        id: 'custom_col_test_1',
        title: 'Cyberpunk Night Mode',
        subtitle: 'Curated high contrast AMOLED',
        badge: 'PLAYLIST',
        icon: Icons.electric_bolt_rounded,
        wallpaperIds: ['ippo_hard_work'],
        gradientColors: [Color(0xFF00E5FF), Color(0xFFD500F9)],
        isUserCreated: true,
      );

      bloc.add(const CreateCustomCollectionIntent(playlist));

      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) =>
            s.customCollections.any((c) => c.id == 'custom_col_test_1') &&
            s.allCollections.any((c) => c.id == 'custom_col_test_1') &&
            s.message != null &&
            s.message!.contains('Cyberpunk Night Mode'))),
      );

      final saved = repository.getCustomCollections();
      expect(saved.any((c) => c.id == 'custom_col_test_1'), isTrue);
    });

    test('ToggleWallpaperInCollectionIntent adds and removes wallpaper from playlist', () async {
      const playlist = WallpaperCollection(
        id: 'custom_col_toggle_test',
        title: 'Toggle Test Playlist',
        subtitle: 'Testing membership toggle',
        badge: 'PLAYLIST',
        icon: Icons.palette_rounded,
        wallpaperIds: [],
        gradientColors: [Color(0xFFFF5722), Color(0xFFFF1744)],
        isUserCreated: true,
      );

      bloc.add(const CreateCustomCollectionIntent(playlist));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      // 1. Toggle add 'ippo_hard_work'
      bloc.add(const ToggleWallpaperInCollectionIntent(
        collectionId: 'custom_col_toggle_test',
        wallpaperId: 'ippo_hard_work',
      ));

      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) {
          final col = s.customCollections.firstWhere(
            (c) => c.id == 'custom_col_toggle_test',
          );
          return col.wallpaperIds.contains('ippo_hard_work');
        })),
      );

      // 2. Toggle remove 'ippo_hard_work'
      bloc.add(const ToggleWallpaperInCollectionIntent(
        collectionId: 'custom_col_toggle_test',
        wallpaperId: 'ippo_hard_work',
      ));

      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) {
          final col = s.customCollections.firstWhere(
            (c) => c.id == 'custom_col_toggle_test',
          );
          return !col.wallpaperIds.contains('ippo_hard_work');
        })),
      );
    });

    test('DeleteCustomCollectionIntent removes playlist from state and storage', () async {
      const playlist = WallpaperCollection(
        id: 'custom_col_delete_test',
        title: 'To Be Deleted',
        subtitle: 'Temporary playlist',
        badge: 'PLAYLIST',
        icon: Icons.delete_outline_rounded,
        wallpaperIds: ['ippo_hard_work'],
        gradientColors: [Color(0xFF00E676), Color(0xFF00B0FF)],
        isUserCreated: true,
      );

      bloc.add(const CreateCustomCollectionIntent(playlist));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      bloc.add(const DeleteCustomCollectionIntent('custom_col_delete_test'));

      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) =>
            !s.customCollections.any((c) => c.id == 'custom_col_delete_test'))),
      );

      final saved = repository.getCustomCollections();
      expect(saved.any((c) => c.id == 'custom_col_delete_test'), isFalse);
    });

    test('Custom playlist used as auto-rotation pool correctly returns rotationPoolShorts', () async {
      bloc.add(LoadFeedIntent());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      const playlist = WallpaperCollection(
        id: 'custom_col_rotation_test',
        title: 'Rotation Pool Test',
        subtitle: 'Testing rotation pool resolution',
        badge: 'PLAYLIST',
        icon: Icons.sync_rounded,
        wallpaperIds: ['ippo_hard_work'],
        gradientColors: [Color(0xFFFFD600), Color(0xFFFF6D00)],
        isUserCreated: true,
      );

      bloc.add(const CreateCustomCollectionIntent(playlist));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      bloc.add(const UpdateAutoRotationSourceIntent('custom_col_rotation_test'));

      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) {
          final pool = s.rotationPoolShorts;
          return s.autoRotationSource == 'custom_col_rotation_test' &&
              pool.length == 1 &&
              pool.first.id == 'ippo_hard_work';
        })),
      );
    });

    test('ToggleAmoledSaverModeIntent toggles AMOLED battery saver mode and persists', () async {
      expect(bloc.state.isAmoledSaverModeEnabled, isFalse);

      // 1. Toggle ON
      bloc.add(const ToggleAmoledSaverModeIntent());

      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) =>
            s.isAmoledSaverModeEnabled == true &&
            s.message != null &&
            s.message!.contains('AMOLED Battery Saver active'))),
      );

      expect(repository.isAmoledSaverModeEnabled(), isTrue);

      // 2. Toggle OFF
      bloc.add(const ToggleAmoledSaverModeIntent());

      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) =>
            s.isAmoledSaverModeEnabled == false &&
            s.message != null &&
            s.message!.contains('Standard display mode active'))),
      );

      expect(repository.isAmoledSaverModeEnabled(), isFalse);
    });

    test('FilterByCategoryIntent with AMOLED True-Black isolates certified high-contrast canvases', () async {
      bloc.add(LoadFeedIntent());
      await bloc.stream.firstWhere((s) => s.allShorts.isNotEmpty);

      bloc.add(const FilterByCategoryIntent('AMOLED True-Black'));

      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) {
          final isAmoled = s.selectedCategory == 'AMOLED True-Black';
          final allCertified = s.filteredShorts.every((w) => w.isAmoledCertified && w.trueBlackPercentage >= 75);
          final hasKeyItems = s.filteredShorts.any((w) => w.id == 'minimal_monolith') &&
              s.filteredShorts.any((w) => w.id == 'cyber_netrunner_terminal') &&
              s.filteredShorts.any((w) => w.id == 'solo_shadow_monarch') &&
              s.filteredShorts.any((w) => w.id == 'olympia_heavy_iron');
          return isAmoled && allCertified && hasKeyItems && s.filteredShorts.isNotEmpty;
        })),
      );
    });

    test('Catalog contains certified 4K Ultra-HD AMOLED canvases with true black ratings', () {
      final catalog = CuratedShortsData.shorts;
      final solo = catalog.firstWhere((w) => w.id == 'solo_shadow_monarch');
      final cyber = catalog.firstWhere((w) => w.id == 'cyber_netrunner_terminal');
      final iron = catalog.firstWhere((w) => w.id == 'olympia_heavy_iron');
      final monolith = catalog.firstWhere((w) => w.id == 'minimal_monolith');

      expect(solo.isAmoledCertified, isTrue);
      expect(solo.trueBlackPercentage, 88);

      expect(cyber.isAmoledCertified, isTrue);
      expect(cyber.trueBlackPercentage, 92);

      expect(iron.isAmoledCertified, isTrue);
      expect(iron.trueBlackPercentage, 86);

      expect(monolith.isAmoledCertified, isTrue);
      expect(monolith.trueBlackPercentage, 96);
    });

    test('UpdateWallpaperEffectIntent updates state and persists effect configuration', () async {
      const config = WallpaperEffectConfig(
        blurSigma: 8.0,
        vignetteStrength: 0.6,
        contrast: 1.3,
        brightness: 0.1,
        colorFilterPreset: 'cyber_cyan',
      );

      bloc.add(const UpdateWallpaperEffectIntent(
        wallpaperId: 'ippo_hard_work',
        effectConfig: config,
      ));

      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) {
          final effective = s.getEffectiveEffects('ippo_hard_work');
          return s.customEffects['ippo_hard_work'] == config &&
              effective.blurSigma == 8.0 &&
              effective.colorFilterPreset == 'cyber_cyan' &&
              s.message != null &&
              s.message!.contains('Visual canvas effects saved');
        })),
      );

      // Verify persistence in repository
      final saved = repository.getCustomEffects();
      expect(saved['ippo_hard_work'], equals(config));
    });

    test('ResetWallpaperEffectIntent clears custom effect in state and repository', () async {
      // First save an effect
      const config = WallpaperEffectConfig(
        blurSigma: 12.0,
        vignetteStrength: 0.8,
        colorFilterPreset: 'noir',
      );
      await repository.saveCustomEffect('ippo_hard_work', config);

      bloc.add(const ResetWallpaperEffectIntent('ippo_hard_work'));

      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) {
          final effective = s.getEffectiveEffects('ippo_hard_work');
          return !s.customEffects.containsKey('ippo_hard_work') &&
              effective == WallpaperEffectConfig.defaultConfig &&
              s.message != null &&
              s.message!.contains('Visual canvas effects reset');
        })),
      );

      final saved = repository.getCustomEffects();
      expect(saved.containsKey('ippo_hard_work'), isFalse);
    });

    test('WallpaperEffectConfig presets have distinct aesthetic visual properties', () {
      expect(WallpaperEffectConfig.defaultConfig.colorFilterPreset, 'original');
      expect(WallpaperEffectConfig.noirPreset.colorFilterPreset, 'noir');
      expect(WallpaperEffectConfig.noirPreset.contrast, greaterThan(1.0));

      expect(WallpaperEffectConfig.cyberPreset.colorFilterPreset, 'cyber_cyan');
      expect(WallpaperEffectConfig.sunsetPreset.colorFilterPreset, 'sunset_amber');
      expect(WallpaperEffectConfig.matrixPreset.colorFilterPreset, 'matrix_emerald');
      expect(WallpaperEffectConfig.auroraPreset.colorFilterPreset, 'aurora_violet');
      expect(WallpaperEffectConfig.softBlurPreset.blurSigma, greaterThan(0.0));

      final json = WallpaperEffectConfig.noirPreset.toJson();
      final fromJson = WallpaperEffectConfig.fromJson(json);
      expect(fromJson, equals(WallpaperEffectConfig.noirPreset));
    });

    test('UpdateDayNightScheduleIntent saves config and updates state', () async {
      const customConfig = DayNightScheduleConfig(
        isEnabled: false,
        morningHour: 7,
        morningWallpaperId: 'custom_dawn',
      );

      bloc.add(const UpdateDayNightScheduleIntent(customConfig));

      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) {
          return s.dayNightSchedule == customConfig &&
              s.message != null &&
              s.message!.contains('Solar Day & Night schedule updated');
        })),
      );

      final persisted = repository.getDayNightScheduleConfig();
      expect(persisted, equals(customConfig));
    });

    test('ToggleDayNightScheduleIntent toggles isEnabled in state and repository', () async {
      expect(bloc.state.dayNightSchedule.isEnabled, isFalse);

      bloc.add(const ToggleDayNightScheduleIntent());

      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) {
          return s.dayNightSchedule.isEnabled == true &&
              s.message != null &&
              s.message!.contains('Day & Night Solar Schedule enabled');
        })),
      );

      expect(repository.getDayNightScheduleConfig().isEnabled, isTrue);

      bloc.add(const ToggleDayNightScheduleIntent());

      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) {
          return s.dayNightSchedule.isEnabled == false &&
              s.message != null &&
              s.message!.contains('Day & Night Solar Schedule paused');
        })),
      );

      expect(repository.getDayNightScheduleConfig().isEnabled, isFalse);
    });

    test('CheckDayNightTransitionIntent evaluates slot and applies wallpaper at night', () async {
      bloc.add(LoadFeedIntent());
      await bloc.stream.firstWhere((s) => s.allShorts.isNotEmpty);

      const scheduleConfig = DayNightScheduleConfig(
        isEnabled: false,
        morningWallpaperId: 'ippo_hard_work',
        afternoonWallpaperId: 'cyber_netrunner_terminal',
        eveningWallpaperId: 'silent_ambition',
        nightWallpaperId: 'minimal_monolith',
        autoAmoledAtNight: true,
      );
      await repository.saveDayNightScheduleConfig(scheduleConfig);

      // Set schedule
      bloc.add(const UpdateDayNightScheduleIntent(scheduleConfig));
      await bloc.stream.firstWhere((s) => s.dayNightSchedule.eveningWallpaperId == 'silent_ambition');

      // Enable schedule
      bloc.add(const ToggleDayNightScheduleIntent());
      await bloc.stream.firstWhere((s) => s.dayNightSchedule.isEnabled);

      // Transition to evening slot (19:00)
      final eveningExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) => s.activeWallpaperId == 'silent_ambition')),
      );
      bloc.add(CheckDayNightTransitionIntent(DateTime(2026, 1, 1, 19, 0)));
      await eveningExpectation;

      // Transition to night slot (23:30) with AMOLED saver
      final nightExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) {
          return s.activeWallpaperId == 'minimal_monolith' &&
              s.isAmoledSaverModeEnabled == true;
        })),
      );
      bloc.add(CheckDayNightTransitionIntent(DateTime(2026, 1, 1, 23, 30)));
      await nightExpectation;

      expect(repository.isAmoledSaverModeEnabled(), isTrue);
    });

    test('UpdateLockScreenStyleIntent updates state, persists, and emits notification', () async {
      const customConfig = LockScreenStyleConfig(
        clockFont: LockScreenClockFont.neon,
        clockLayout: LockScreenClockLayout.stacked,
        widgetType: LockScreenWidgetType.batteryGlance,
        useWallpaperAccentColor: false,
        customColor: Color(0xFF00E5FF),
        clockSize: 94.0,
      );

      final updateExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) {
          return s.lockScreenStyle == customConfig &&
              s.message == 'Lock screen simulation aesthetic updated.';
        })),
      );

      bloc.add(const UpdateLockScreenStyleIntent(customConfig));
      await updateExpectation;

      final persisted = repository.getLockScreenStyleConfig();
      expect(persisted, customConfig);
    });

    test('ResetLockScreenStyleIntent resets style to default and cleans persistence', () async {
      // First save custom config
      await repository.saveLockScreenStyleConfig(LockScreenStyleConfig.cyberMatrixPreset);

      final resetExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) {
          return s.lockScreenStyle == LockScreenStyleConfig.defaultConfig &&
              s.message == 'Lock screen aesthetic reset to default.';
        })),
      );

      bloc.add(const ResetLockScreenStyleIntent());
      await resetExpectation;

      final persisted = repository.getLockScreenStyleConfig();
      expect(persisted, LockScreenStyleConfig.defaultConfig);
    });

    test('UpdateParallaxConfigIntent updates state, persists, and emits notification', () async {
      const customParallax = ParallaxEffectConfig(
        isEnabled: true,
        sensitivity: 2.0,
        maxAngleDegrees: 18.0,
        invertPitch: true,
        preset: ParallaxPreset.deepSpatial,
      );

      final updateExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) {
          return s.parallaxConfig == customParallax &&
              s.message == '3D Spatial Parallax motion updated.';
        })),
      );

      bloc.add(const UpdateParallaxConfigIntent(customParallax));
      await updateExpectation;

      final persisted = repository.getParallaxEffectConfig();
      expect(persisted, customParallax);
    });

    test('ToggleParallaxIntent toggles isEnabled in state, persists, and notifies', () async {
      expect(bloc.state.parallaxConfig.isEnabled, isTrue);

      // Toggle to false
      final pauseExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) {
          return s.parallaxConfig.isEnabled == false &&
              s.message == '3D Spatial Parallax paused.';
        })),
      );
      bloc.add(const ToggleParallaxIntent());
      await pauseExpectation;

      expect(repository.getParallaxEffectConfig().isEnabled, isFalse);

      // Toggle back to true
      final activateExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) {
          return s.parallaxConfig.isEnabled == true &&
              s.message == '3D Spatial Parallax active.';
        })),
      );
      bloc.add(const ToggleParallaxIntent());
      await activateExpectation;

      expect(repository.getParallaxEffectConfig().isEnabled, isTrue);
    });

    test('ResetParallaxConfigIntent resets configuration to default and cleans persistence', () async {
      // First save custom config
      await repository.saveParallaxEffectConfig(ParallaxEffectConfig.hyperFloatPreset);

      final resetExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) {
          return s.parallaxConfig == ParallaxEffectConfig.defaultConfig &&
              s.message == '3D Spatial Parallax reset to default.';
        })),
      );

      bloc.add(const ResetParallaxConfigIntent());
      await resetExpectation;

      final persisted = repository.getParallaxEffectConfig();
      expect(persisted, ParallaxEffectConfig.defaultConfig);
    });

    test('UpdateSmartFilterIntent updates state, persists, updates filteredShorts, and notifies', () async {
      // Load feed first
      final loadExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) => s.allShorts.isNotEmpty)),
      );
      bloc.add(const LoadFeedIntent());
      await loadExpectation;

      final initialShortCount = bloc.state.filteredShorts.length;
      expect(initialShortCount, greaterThan(0));

      const filter = SmartFilterConfig(
        mediaType: SmartMediaType.liveOnly,
        amoledCertifiedOnly: true,
      );

      final filterExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) {
          return s.smartFilter == filter &&
              s.filteredShorts.every((w) => w.isLive && w.isAmoledCertified) &&
              s.message == 'Smart discovery filter applied (2 active).';
        })),
      );

      bloc.add(const UpdateSmartFilterIntent(filter));
      await filterExpectation;

      final persisted = repository.getSmartFilterConfig();
      expect(persisted, equals(filter));
    });

    test('ResetSmartFilterIntent restores default filter, cleans persistence, and resets filteredShorts', () async {
      // Load feed first
      final loadExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) => s.allShorts.isNotEmpty)),
      );
      bloc.add(const LoadFeedIntent());
      await loadExpectation;

      // Apply filter
      const filter = SmartFilterConfig(mediaType: SmartMediaType.liveOnly);
      bloc.add(const UpdateSmartFilterIntent(filter));
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) => s.smartFilter == filter)),
      );

      // Now reset
      final resetExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) {
          return s.smartFilter == SmartFilterConfig.defaultConfig &&
              s.message == 'Smart discovery filters reset.';
        })),
      );

      bloc.add(const ResetSmartFilterIntent());
      await resetExpectation;

      final persisted = repository.getSmartFilterConfig();
      expect(persisted, equals(SmartFilterConfig.defaultConfig));
    });

    test('LoadFeedIntent loads persisted battery telemetry from repository', () async {
      const savedConfig = BatteryTelemetryConfig(
        targetFps: TargetFpsMode.fps30,
        isEcoModeEnabled: true,
      );
      await repository.saveBatteryTelemetryConfig(savedConfig);

      final loadExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) => s.batteryTelemetry == savedConfig)),
      );

      bloc.add(const LoadFeedIntent());
      await loadExpectation;

      expect(bloc.state.batteryTelemetry.targetFps, TargetFpsMode.fps30);
      expect(bloc.state.batteryTelemetry.isEcoModeEnabled, isTrue);
    });

    test('UpdateBatteryTelemetryIntent updates state, persists, and notifies', () async {
      const config = BatteryTelemetryConfig(
        targetFps: TargetFpsMode.fpsAuto,
        isEcoModeEnabled: true,
        isPixelShiftEnabled: false,
      );

      final updateExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) {
          return s.batteryTelemetry == config &&
              s.message == 'Battery & display telemetry updated.';
        })),
      );

      bloc.add(const UpdateBatteryTelemetryIntent(config));
      await updateExpectation;

      final persisted = repository.getBatteryTelemetryConfig();
      expect(persisted, equals(config));
    });

    test('ToggleEcoModeIntent toggles isEcoModeEnabled, persists, and notifies', () async {
      expect(bloc.state.batteryTelemetry.isEcoModeEnabled, isFalse);

      // Toggle ON
      final toggleOnExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) {
          return s.batteryTelemetry.isEcoModeEnabled == true &&
              s.message != null &&
              s.message!.contains('Adaptive Eco Scaling enabled');
        })),
      );

      bloc.add(const ToggleEcoModeIntent());
      await toggleOnExpectation;

      expect(repository.getBatteryTelemetryConfig().isEcoModeEnabled, isTrue);

      // Toggle OFF
      final toggleOffExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) {
          return s.batteryTelemetry.isEcoModeEnabled == false &&
              s.message != null &&
              s.message!.contains('Adaptive Eco Scaling disabled');
        })),
      );

      bloc.add(const ToggleEcoModeIntent());
      await toggleOffExpectation;

      expect(repository.getBatteryTelemetryConfig().isEcoModeEnabled, isFalse);
    });

    test('ResetBatteryTelemetryIntent restores defaults, cleans persistence, and notifies', () async {
      const customConfig = BatteryTelemetryConfig(
        targetFps: TargetFpsMode.fps30,
        isPixelShiftEnabled: false,
      );
      bloc.add(const UpdateBatteryTelemetryIntent(customConfig));
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) => s.batteryTelemetry == customConfig)),
      );

      final resetExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) {
          return s.batteryTelemetry == BatteryTelemetryConfig.defaultConfig &&
              s.message == 'Battery & display telemetry reset to defaults.';
        })),
      );

      bloc.add(const ResetBatteryTelemetryIntent());
      await resetExpectation;

      expect(repository.getBatteryTelemetryConfig(), BatteryTelemetryConfig.defaultConfig);
    });

    test('LoadFeedIntent loads persisted particleConfig from repository', () async {
      const savedConfig = ParticleEffectConfig(
        preset: ParticlePreset.electricSparks,
        particleCount: 80,
      );
      await repository.saveParticleEffectConfig(savedConfig);

      final loadExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) => s.particleConfig == savedConfig)),
      );

      bloc.add(const LoadFeedIntent());
      await loadExpectation;

      expect(bloc.state.particleConfig.preset, ParticlePreset.electricSparks);
      expect(bloc.state.particleConfig.particleCount, 80);
    });

    test('UpdateParticleConfigIntent updates state, persists, and notifies', () async {
      const config = ParticleEffectConfig(
        preset: ParticlePreset.auroraVortex,
        particleCount: 60,
        speedMultiplier: 1.6,
      );

      final updateExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) {
          return s.particleConfig == config &&
              s.message == 'Interactive Particle FX updated (Aurora Vortex).';
        })),
      );

      bloc.add(const UpdateParticleConfigIntent(config));
      await updateExpectation;

      final persisted = repository.getParticleEffectConfig();
      expect(persisted, equals(config));
    });

    test('ToggleParticleEffectIntent toggles isEnabled, persists, and notifies', () async {
      expect(bloc.state.particleConfig.isEnabled, isTrue);

      // Toggle OFF
      final toggleOffExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) {
          return s.particleConfig.isEnabled == false &&
              s.message != null &&
              s.message!.contains('Interactive Particle FX disabled');
        })),
      );

      bloc.add(const ToggleParticleEffectIntent());
      await toggleOffExpectation;

      expect(repository.getParticleEffectConfig().isEnabled, isFalse);

      // Toggle ON
      final toggleOnExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) {
          return s.particleConfig.isEnabled == true &&
              s.message != null &&
              s.message!.contains('Interactive Particle FX enabled');
        })),
      );

      bloc.add(const ToggleParticleEffectIntent());
      await toggleOnExpectation;

      expect(repository.getParticleEffectConfig().isEnabled, isTrue);
    });

    test('ResetParticleConfigIntent restores defaults, cleans persistence, and notifies', () async {
      const customConfig = ParticleEffectConfig(
        preset: ParticlePreset.sakuraDrift,
        particleCount: 90,
      );
      bloc.add(const UpdateParticleConfigIntent(customConfig));
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) => s.particleConfig == customConfig)),
      );

      final resetExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) {
          return s.particleConfig == ParticleEffectConfig.defaultConfig &&
              s.message == 'Interactive Particle FX reset to defaults.';
        })),
      );

      bloc.add(const ResetParticleConfigIntent());
      await resetExpectation;

      expect(repository.getParticleEffectConfig(), ParticleEffectConfig.defaultConfig);
    });

    test('UpdateAuraPaletteIntent updates state, persists, and notifies', () async {
      const config = AuraPaletteConfig(
        preset: AuraThemePreset.cyberAurora,
        isDynamicThemingEnabled: false,
        syncParticles: false,
        syncKineticQuotes: true,
        syncLockScreen: true,
        hueShiftDegrees: 45.0,
        saturationMultiplier: 1.2,
      );

      final updateExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) {
          return s.auraConfig == config &&
              s.message != null &&
              s.message!.contains('Cyber Aurora');
        })),
      );

      bloc.add(const UpdateAuraPaletteIntent(config));
      await updateExpectation;

      final persisted = repository.getAuraPaletteConfig();
      expect(persisted, equals(config));
    });

    test('SetAuraThemePresetIntent switches preset, persists, and notifies', () async {
      final presetExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) {
          return s.auraConfig.preset == AuraThemePreset.solarEclipse &&
              s.message != null &&
              s.message!.contains('Solar Eclipse');
        })),
      );

      bloc.add(const SetAuraThemePresetIntent(AuraThemePreset.solarEclipse));
      await presetExpectation;

      expect(repository.getAuraPaletteConfig().preset, AuraThemePreset.solarEclipse);
    });

    test('ResetAuraPaletteIntent restores default Aura config, cleans persistence, and notifies', () async {
      const customConfig = AuraPaletteConfig(
        preset: AuraThemePreset.emeraldMatrix,
        hueShiftDegrees: -90.0,
      );
      bloc.add(const UpdateAuraPaletteIntent(customConfig));
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) => s.auraConfig == customConfig)),
      );

      final resetExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) {
          return s.auraConfig == AuraPaletteConfig.defaultConfig &&
              s.message == 'Aura Chromatic Harmonizer reset to defaults.';
        })),
      );

      bloc.add(const ResetAuraPaletteIntent());
      await resetExpectation;

      expect(repository.getAuraPaletteConfig(), AuraPaletteConfig.defaultConfig);
    });

    test('RestoreBackupIntent restores state, persists to storage, and notifies', () async {
      final bundle = WalloraBackupBundle(
        exportedAt: DateTime.now(),
        favoriteIds: const {'wall_imported_1'},
        customizedQuotes: const {'wall_imported_1': 'Never give up'},
        isAmoledSaverModeEnabled: true,
        auraConfig: const AuraPaletteConfig(preset: AuraThemePreset.cyberAurora),
      );

      final restoreExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) {
          return s.favoriteIds.contains('wall_imported_1') &&
              s.customizedQuotes['wall_imported_1'] == 'Never give up' &&
              s.isAmoledSaverModeEnabled == true &&
              s.auraConfig.preset == AuraThemePreset.cyberAurora &&
              s.message != null &&
              s.message!.contains('Successfully restored backup');
        })),
      );

      bloc.add(RestoreBackupIntent(bundle: bundle, mergeWithExisting: false));
      await restoreExpectation;

      expect(repository.getFavorites(), contains('wall_imported_1'));
      expect(repository.isAmoledSaverModeEnabled(), isTrue);
    });

    test('ResetFactoryDefaultsIntent wipes customizations and resets all configs to factory defaults', () async {
      // First populate custom items
      await repository.toggleFavorite('temp_fav');
      await repository.setAmoledSaverMode(true);

      final resetExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) {
          return s.favoriteIds.isEmpty &&
              s.customCollections.isEmpty &&
              s.customizedQuotes.isEmpty &&
              s.customEffects.isEmpty &&
              s.isAmoledSaverModeEnabled == false &&
              s.auraConfig == AuraPaletteConfig.defaultConfig &&
              s.message == 'Wallora reset to factory defaults.';
        })),
      );

      bloc.add(const ResetFactoryDefaultsIntent());
      await resetExpectation;

      expect(repository.getFavorites(), isEmpty);
      expect(repository.isAmoledSaverModeEnabled(), isFalse);
    });

    test('UpdateGestureControlIntent updates state, persists to repository, and notifies', () async {
      const customConfig = GestureControlConfig(
        isGesturesEnabled: true,
        doubleTapAction: GestureAction.nextWallpaper,
        tripleTapAction: GestureAction.cycleAuraPalette,
        twoFingerSwipeDownAction: GestureAction.toggleCleanCanvas,
        longPressAction: GestureAction.openStudio,
        hapticProfile: HapticFeedbackProfile.firm,
        touchVisualEffect: TouchVisualEffect.particleBurst,
        touchColorMode: TouchColorMode.electricCyan,
      );

      final updateExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) {
          return s.gestureConfig == customConfig &&
              s.message == 'Gesture controls updated.';
        })),
      );

      bloc.add(const UpdateGestureControlIntent(customConfig));
      await updateExpectation;

      expect(repository.getGestureControlConfig(), customConfig);
    });

    test('ResetGestureControlIntent resets gesture config to defaults, cleans persistence, and notifies', () async {
      const customConfig = GestureControlConfig(
        hapticProfile: HapticFeedbackProfile.firm,
      );
      bloc.add(const UpdateGestureControlIntent(customConfig));
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) => s.gestureConfig == customConfig)),
      );

      final resetExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) {
          return s.gestureConfig == GestureControlConfig.defaultConfig &&
              s.message == 'Gesture controls reset to defaults.';
        })),
      );

      bloc.add(const ResetGestureControlIntent());
      await resetExpectation;

      expect(repository.getGestureControlConfig(), GestureControlConfig.defaultConfig);
    });

    test('ToggleCleanCanvasIntent toggles zen mode visibility state cleanly', () async {
      expect(bloc.state.isCleanCanvasMode, isFalse);

      final cleanExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) => s.isCleanCanvasMode == true)),
      );
      bloc.add(const ToggleCleanCanvasIntent());
      await cleanExpectation;

      final restoreExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) => s.isCleanCanvasMode == false)),
      );
      bloc.add(const ToggleCleanCanvasIntent());
      await restoreExpectation;
    });

    test('ExecuteGestureActionIntent triggers corresponding domain actions', () async {
      // 1. Load feed first
      final loadExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) => s.allShorts.isNotEmpty)),
      );
      bloc.add(const LoadFeedIntent());
      await loadExpectation;

      // 2. Next wallpaper action
      final initialIndex = bloc.state.activeIndex;
      final nextExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) => s.activeIndex == initialIndex + 1)),
      );
      bloc.add(const ExecuteGestureActionIntent(GestureAction.nextWallpaper));
      await nextExpectation;

      // 3. Toggle favorite action
      final currentId = bloc.state.currentShort!.id;
      final favExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) => s.favoriteIds.contains(currentId))),
      );
      bloc.add(const ExecuteGestureActionIntent(GestureAction.toggleFavorite));
      await favExpectation;

      // 4. Cycle Aura palette action
      final initialAuraPreset = bloc.state.auraConfig.preset;
      final auraExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) => s.auraConfig.preset != initialAuraPreset)),
      );
      bloc.add(const ExecuteGestureActionIntent(GestureAction.cycleAuraPalette));
      await auraExpectation;
    });

    test('UpdateStandbyDockIntent persists and updates state', () async {
      const config = StandbyDockConfig(
        clockStyle: DockClockStyle.cyberpunkTech,
        layoutMode: DockLayoutMode.centeredZen,
        isNightModeEnabled: true,
        isBurnInProtectionEnabled: false,
        is24HourFormat: true,
      );

      final expectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) =>
            s.standbyDockConfig == config &&
            s.message == 'Standby dock settings updated.')),
      );

      bloc.add(const UpdateStandbyDockIntent(config));
      await expectation;

      expect(repository.getStandbyDockConfig(), equals(config));
    });

    test('ResetStandbyDockIntent restores defaultConfig and updates state', () async {
      const custom = StandbyDockConfig(
        clockStyle: DockClockStyle.oledMatrix,
        layoutMode: DockLayoutMode.fullscreenHUD,
      );
      await repository.saveStandbyDockConfig(custom);

      final expectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) =>
            s.standbyDockConfig == StandbyDockConfig.defaultConfig &&
            s.message == 'Standby dock settings reset to defaults.')),
      );

      bloc.add(const ResetStandbyDockIntent());
      await expectation;

      expect(repository.getStandbyDockConfig(),
          equals(StandbyDockConfig.defaultConfig));
    });

    test('ToggleNightStandbyModeIntent flips isNightModeEnabled in state and repository', () async {
      expect(bloc.state.standbyDockConfig.isNightModeEnabled, isFalse);

      final enableExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>(
            (s) => s.standbyDockConfig.isNightModeEnabled == true)),
      );
      bloc.add(const ToggleNightStandbyModeIntent());
      await enableExpectation;

      expect(repository.getStandbyDockConfig().isNightModeEnabled, isTrue);

      final disableExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>(
            (s) => s.standbyDockConfig.isNightModeEnabled == false)),
      );
      bloc.add(const ToggleNightStandbyModeIntent());
      await disableExpectation;

      expect(repository.getStandbyDockConfig().isNightModeEnabled, isFalse);
    });

    test('UpdateAuroraSynthesizerIntent persists and updates state', () async {
      const config = AuroraSynthesizerConfig(
        waveStyle: AuroraWaveStyle.bioluminescentDeepSea,
        colorMode: AuroraColorMode.cyanViolet,
        waveCount: 5,
        waveSpeed: 1.5,
        crestAmplitude: 60.0,
        frequency: 2.2,
        blurSpread: 30.0,
        isTouchReactive: true,
        isGyroReactive: false,
        isEnabled: true,
      );

      final expectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) =>
            s.auroraSynthesizerConfig == config &&
            s.message == 'Aurora wave settings updated.')),
      );

      bloc.add(const UpdateAuroraSynthesizerIntent(config));
      await expectation;

      expect(repository.getAuroraSynthesizerConfig(), equals(config));
    });

    test('ResetAuroraSynthesizerIntent restores defaultConfig and updates state', () async {
      const custom = AuroraSynthesizerConfig(
        waveStyle: AuroraWaveStyle.monochromeOled,
        crestAmplitude: 75.0,
      );
      await repository.saveAuroraSynthesizerConfig(custom);

      final expectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) =>
            s.auroraSynthesizerConfig == AuroraSynthesizerConfig.defaultConfig &&
            s.message == 'Aurora wave settings reset to defaults.')),
      );

      bloc.add(const ResetAuroraSynthesizerIntent());
      await expectation;

      expect(repository.getAuroraSynthesizerConfig(),
          equals(AuroraSynthesizerConfig.defaultConfig));
    });

    test('ToggleAuroraSynthesizerIntent flips isEnabled in state and repository', () async {
      expect(bloc.state.auroraSynthesizerConfig.isEnabled, isTrue);

      final disableExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) =>
            s.auroraSynthesizerConfig.isEnabled == false &&
            s.message == 'Procedural Aurora Wave Synthesizer paused.')),
      );
      bloc.add(const ToggleAuroraSynthesizerIntent());
      await disableExpectation;

      expect(repository.getAuroraSynthesizerConfig().isEnabled, isFalse);

      final enableExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) =>
            s.auroraSynthesizerConfig.isEnabled == true &&
            s.message == 'Procedural Aurora Wave Synthesizer active.')),
      );
      bloc.add(const ToggleAuroraSynthesizerIntent());
      await enableExpectation;

      expect(repository.getAuroraSynthesizerConfig().isEnabled, isTrue);
    });

    test('ApplyScreenBlueprintIntent applies all aesthetic dimensions atomically', () async {
      bloc.add(LoadFeedIntent());
      await bloc.stream.firstWhere((s) => s.allShorts.isNotEmpty);

      final blueprint = WalloraScreenBlueprint.curatedBlueprints.first;

      final expectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) {
          return s.activeWallpaperId == blueprint.wallpaper.id &&
              s.customizedQuotes[blueprint.wallpaper.id] == blueprint.customQuote &&
              s.auraConfig == blueprint.auraConfig &&
              s.particleConfig == blueprint.particleConfig &&
              s.parallaxConfig == blueprint.parallaxConfig &&
              s.auroraSynthesizerConfig == blueprint.auroraConfig &&
              s.message != null &&
              s.message!.contains(blueprint.title);
        })),
      );

      bloc.add(ApplyScreenBlueprintIntent(blueprint));
      await expectation;

      expect(repository.getActiveWallpaperId(), equals(blueprint.wallpaper.id));
      expect(repository.getCustomQuotes()[blueprint.wallpaper.id], equals(blueprint.customQuote));
      expect(repository.getAuraPaletteConfig(), equals(blueprint.auraConfig));
      expect(repository.getParticleEffectConfig(), equals(blueprint.particleConfig));
      expect(repository.getParallaxEffectConfig(), equals(blueprint.parallaxConfig));
      expect(repository.getAuroraSynthesizerConfig(), equals(blueprint.auroraConfig));
    });

    test('PublishCurrentSetupIntent packages and publishes active setup', () async {
      bloc.add(LoadFeedIntent());
      await bloc.stream.firstWhere((s) => s.allShorts.isNotEmpty);

      final initialCount = bloc.state.communityBlueprints.length;

      final expectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) {
          return s.communityBlueprints.length == initialCount + 1 &&
              s.communityBlueprints.first.title == 'Neon Cyber Dreams' &&
              s.communityBlueprints.first.creatorName == 'CyberAgent' &&
              s.message != null &&
              s.message!.contains('published to Community Showcase');
        })),
      );

      bloc.add(const PublishCurrentSetupIntent(
        title: 'Neon Cyber Dreams',
        creatorName: 'CyberAgent',
        description: 'Vibrant obsidian neon setup.',
        tags: ['Cyberpunk', 'Neon'],
      ));
      await expectation;

      expect(repository.getCommunityBlueprints().length, equals(initialCount + 1));
    });

    test('ToggleBlueprintLikeIntent increments likes and updates repository', () async {
      bloc.add(LoadFeedIntent());
      await bloc.stream.firstWhere((s) => s.communityBlueprints.isNotEmpty);

      final targetBlueprint = bloc.state.communityBlueprints.first;
      final initialLikes = targetBlueprint.likesCount;

      final likeExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) {
          return s.likedBlueprintIds.contains(targetBlueprint.id) &&
              s.communityBlueprints.firstWhere((b) => b.id == targetBlueprint.id).likesCount ==
                  initialLikes + 1 &&
              s.message == 'Blueprint liked! ❤️';
        })),
      );

      bloc.add(ToggleBlueprintLikeIntent(targetBlueprint.id));
      await likeExpectation;

      expect(repository.getLikedBlueprintIds().contains(targetBlueprint.id), isTrue);

      final unlikeExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) {
          return !s.likedBlueprintIds.contains(targetBlueprint.id) &&
              s.communityBlueprints.firstWhere((b) => b.id == targetBlueprint.id).likesCount ==
                  initialLikes &&
              s.message == 'Blueprint unliked.';
        })),
      );

      bloc.add(ToggleBlueprintLikeIntent(targetBlueprint.id));
      await unlikeExpectation;

      expect(repository.getLikedBlueprintIds().contains(targetBlueprint.id), isFalse);
    });

    test('FilterCommunityBlueprintsIntent updates communityTagFilter in state', () async {
      expect(bloc.state.communityTagFilter, equals('All'));

      bloc.add(const FilterCommunityBlueprintsIntent('Cyberpunk'));
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) => s.communityTagFilter == 'Cyberpunk')),
      );

      expect(bloc.state.filteredBlueprints.every((b) =>
          b.tags.any((t) => t.toLowerCase() == 'cyberpunk') ||
          b.title.toLowerCase().contains('cyberpunk')), isTrue);
    });

    test('UpdateWeatherAtmosphereIntent saves config and emits state', () async {
      const updated = WeatherAtmosphereConfig(
        effectType: WeatherEffectType.cosmicSnow,
        intensity: 0.8,
        speedMultiplier: 1.4,
        windAngleDegrees: 75.0,
        isGyroTiltEnabled: true,
        isLightningEnabled: false,
        isBatteryGuardEnabled: true,
      );

      final expectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) =>
            s.weatherConfig == updated &&
            s.message == 'Weather & Atmosphere FX updated.')),
      );

      bloc.add(const UpdateWeatherAtmosphereIntent(updated));
      await expectation;

      expect(repository.getWeatherAtmosphereConfig(), equals(updated));
    });

    test('ResetWeatherAtmosphereIntent resets config to defaults', () async {
      await repository.saveWeatherAtmosphereConfig(
        const WeatherAtmosphereConfig(effectType: WeatherEffectType.thunderstorm),
      );

      final expectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) =>
            s.weatherConfig == WeatherAtmosphereConfig.defaultConfig &&
            s.message == 'Weather & Atmosphere FX reset to defaults.')),
      );

      bloc.add(const ResetWeatherAtmosphereIntent());
      await expectation;

      expect(repository.getWeatherAtmosphereConfig(), equals(WeatherAtmosphereConfig.defaultConfig));
    });

    test('ToggleWeatherAtmosphereIntent toggles between enabled and clean canvas', () async {
      // Initially cyberRain (isEnabled == true)
      expect(bloc.state.weatherConfig.isEnabled, isTrue);

      // Toggle off -> WeatherEffectType.none
      final offExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) =>
            !s.weatherConfig.isEnabled &&
            s.message == 'Atmospheric Weather FX disabled.')),
      );

      bloc.add(const ToggleWeatherAtmosphereIntent());
      await offExpectation;
      expect(bloc.state.weatherConfig.effectType, equals(WeatherEffectType.none));

      // Toggle back on -> WeatherEffectType.cyberRain
      final onExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) =>
            s.weatherConfig.isEnabled &&
            s.weatherConfig.effectType == WeatherEffectType.cyberRain &&
            s.message == 'Atmospheric Weather FX activated.')),
      );

      bloc.add(const ToggleWeatherAtmosphereIntent());
      await onExpectation;
      expect(bloc.state.weatherConfig.isEnabled, isTrue);
    });

    test('SetWeatherEffectPresetIntent updates effect preset', () async {
      final expectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) =>
            s.weatherConfig.effectType == WeatherEffectType.meteorShower &&
            s.message == 'Applied Meteor Shower & Starfall effect.')),
      );

      bloc.add(const SetWeatherEffectPresetIntent(WeatherEffectType.meteorShower));
      await expectation;

      expect(repository.getWeatherAtmosphereConfig().effectType, equals(WeatherEffectType.meteorShower));
    });

    test('FetchCloudWallpapersIntent fetches wallpapers and updates cloud state', () async {
      final expectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) =>
            !s.isCloudLoading &&
            s.cloudWallpapers.isNotEmpty &&
            s.selectedCloudCategory == 'Cyberpunk')),
      );

      bloc.add(const FetchCloudWallpapersIntent(
        page: 1,
        category: 'Cyberpunk',
      ));
      await expectation;

      expect(bloc.state.cloudWallpapers.isNotEmpty, isTrue);
    });

    test('SearchCloudWallpapersIntent searches cloud wallpapers by query and resolution', () async {
      final expectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) =>
            !s.isCloudLoading &&
            s.cloudSearchQuery == 'orion' &&
            s.selectedCloudResolution == '3840x2160')),
      );

      bloc.add(const SearchCloudWallpapersIntent(
        query: 'orion',
        resolution: '3840x2160',
      ));
      await expectation;

      expect(bloc.state.cloudWallpapers.isNotEmpty, isTrue);
    });

    test('ImportCloudWallpaperIntent saves wallpaper to library', () async {
      const item = WallazaCloudWallpaper(
        id: 'wlz_test_import_01',
        title: 'Cyber Import Test',
        description: 'Test import wallpaper',
        url: 'https://example.com/import.jpg',
        thumbnailUrl: 'https://example.com/import_thumb.jpg',
        category: 'Cyberpunk',
      );

      final expectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) =>
            s.message != null &&
            s.message!.contains('Imported "Cyber Import Test"') &&
            s.allShorts.any((sh) => sh.id == 'cloud_wlz_test_import_01'))),
      );

      bloc.add(const ImportCloudWallpaperIntent(item, setAsActive: false));
      await expectation;

      final saved = repository.getCustomImportedWallpapers();
      expect(saved.any((s) => s.id == 'cloud_wlz_test_import_01'), isTrue);
    });

    test('ImportCloudWallpaperIntent with setAsActive sets wallpaper active', () async {
      const item = WallazaCloudWallpaper(
        id: 'wlz_test_apply_02',
        title: 'Active Apply Test',
        description: 'Apply wallpaper immediately',
        url: 'https://example.com/apply.jpg',
        thumbnailUrl: 'https://example.com/apply_thumb.jpg',
        category: 'Nature',
      );

      final expectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) =>
            s.activeWallpaperId == 'cloud_wlz_test_apply_02' &&
            s.actionStatus == WallpaperActionStatus.appliedSuccess)),
      );

      bloc.add(const ImportCloudWallpaperIntent(item, setAsActive: true));
      await expectation;

      expect(bloc.state.activeWallpaperId, 'cloud_wlz_test_apply_02');
    });

    test('ClearCloudSearchIntent resets query and refreshes wallpapers', () async {
      // First set search query
      bloc.add(const SearchCloudWallpapersIntent(query: 'space'));
      await bloc.stream.firstWhere((s) => s.cloudSearchQuery == 'space');

      final clearExpectation = expectLater(
        bloc.stream,
        emitsThrough(predicate<WallpaperState>((s) =>
            s.cloudSearchQuery.isEmpty &&
            s.selectedCloudResolution == 'All' &&
            !s.isCloudLoading &&
            s.cloudWallpapers.isNotEmpty)),
      );

      bloc.add(const ClearCloudSearchIntent());
      await clearExpectation;

      expect(bloc.state.cloudSearchQuery, isEmpty);
    });
  });
}
