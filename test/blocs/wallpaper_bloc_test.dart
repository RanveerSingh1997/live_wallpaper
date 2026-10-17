import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/blocs/wallpaper_bloc.dart';
import 'package:live_wallpaper/blocs/wallpaper_intent.dart';
import 'package:live_wallpaper/blocs/wallpaper_state.dart';
import 'package:live_wallpaper/data/curated_shorts_data.dart';
import 'package:live_wallpaper/models/motivational_short.dart';
import 'package:live_wallpaper/models/wallpaper_collection.dart';
import 'package:live_wallpaper/models/wallpaper_effect_config.dart';
import 'package:live_wallpaper/repositories/wallpaper_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    repository = WallpaperRepository(prefs: prefs);
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
  });
}
