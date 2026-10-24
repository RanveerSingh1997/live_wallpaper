import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/core/core.dart';
import 'package:live_wallpaper/models/aura_palette_config.dart';
import 'package:live_wallpaper/models/motivational_short.dart';
import 'package:live_wallpaper/models/wallora_backup_bundle.dart';
import 'package:live_wallpaper/models/wallora_screen_blueprint.dart';
import 'package:live_wallpaper/models/wallpaper_collection.dart';
import 'package:live_wallpaper/models/wallpaper_effect_config.dart';
import 'package:live_wallpaper/repositories/repositories.dart';
import 'package:live_wallpaper/services/wallaza_api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PlaylistRepository Unit Tests (Isolated MemoryCache)', () {
    late LocalCacheService cache;
    late PlaylistRepository playlistRepo;

    setUp(() {
      cache = MemoryCacheService();
      playlistRepo = PlaylistRepository(cache: cache);
    });

    test('Favorites CRUD and toggle operations', () async {
      expect(playlistRepo.getFavorites(), isEmpty);
      expect(playlistRepo.isFavorite('wall_01'), isFalse);

      final added = await playlistRepo.toggleFavorite('wall_01');
      expect(added, isTrue);
      expect(playlistRepo.getFavorites().contains('wall_01'), isTrue);
      expect(playlistRepo.isFavorite('wall_01'), isTrue);

      final removed = await playlistRepo.toggleFavorite('wall_01');
      expect(removed, isFalse);
      expect(playlistRepo.getFavorites(), isEmpty);
    });

    test('Custom collections CRUD and membership toggling', () async {
      expect(playlistRepo.getCustomCollections(), isEmpty);

      const collection = WallpaperCollection(
        id: 'col_synth',
        title: 'Synthwave Dreams',
        subtitle: 'Neon 80s Vibe',
        badge: 'SYNTH',
        icon: Icons.music_note_rounded,
        wallpaperIds: ['wall_synth_01'],
        gradientColors: [Color(0xFF00E5FF), Color(0xFFD500F9)],
      );

      await playlistRepo.saveCollection(collection);
      expect(playlistRepo.getCustomCollections().length, 1);
      expect(playlistRepo.isWallpaperInCollection('col_synth', 'wall_synth_01'), isTrue);
      expect(playlistRepo.isWallpaperInCollection('col_synth', 'wall_other'), isFalse);

      // Add wall_other to collection
      final toggledIn = await playlistRepo.toggleWallpaperInCollection('col_synth', 'wall_other');
      expect(toggledIn, isTrue);
      expect(playlistRepo.isWallpaperInCollection('col_synth', 'wall_other'), isTrue);

      // Delete collection
      await playlistRepo.deleteCollection('col_synth');
      expect(playlistRepo.getCustomCollections(), isEmpty);
    });
  });

  group('DownloadRepository Unit Tests (Isolated MemoryCache)', () {
    late LocalCacheService cache;
    late DownloadRepository downloadRepo;

    setUp(() {
      cache = MemoryCacheService();
      downloadRepo = DownloadRepository(
        cache: cache,
        wallazaService: WallazaApiService(),
      );
    });

    test('Download tracking, deletion, and cache size', () async {
      expect(downloadRepo.getDownloads(), isEmpty);
      expect(downloadRepo.isDownloaded('wall_01'), isFalse);

      await downloadRepo.setDownloads({'wall_01', 'wall_02'});
      expect(downloadRepo.isDownloaded('wall_01'), isTrue);
      expect(downloadRepo.getDownloads().length, 2);

      await downloadRepo.deleteDownload('wall_01');
      expect(downloadRepo.isDownloaded('wall_01'), isFalse);
      expect(downloadRepo.getDownloads().length, 1);

      await downloadRepo.clearAllDownloads();
      expect(downloadRepo.getDownloads(), isEmpty);
    });
  });

  group('StudioConfigRepository Unit Tests (Isolated MemoryCache)', () {
    late LocalCacheService cache;
    late StudioConfigRepository studioRepo;

    setUp(() {
      cache = MemoryCacheService();
      studioRepo = StudioConfigRepository(cache: cache);
    });

    test('Aura palette persistence and reset', () async {
      final initial = studioRepo.getAuraPaletteConfig();
      expect(initial, equals(AuraPaletteConfig.defaultConfig));

      const customAura = AuraPaletteConfig(
        preset: AuraThemePreset.cyberAurora,
        hueShiftDegrees: 45.0,
        saturationMultiplier: 1.2,
      );

      await studioRepo.saveAuraPaletteConfig(customAura);
      expect(studioRepo.getAuraPaletteConfig(), equals(customAura));

      await studioRepo.resetAuraPaletteConfig();
      expect(studioRepo.getAuraPaletteConfig(), equals(AuraPaletteConfig.defaultConfig));
    });

    test('AMOLED saver mode and custom effects', () async {
      expect(studioRepo.isAmoledSaverModeEnabled(), isFalse);
      await studioRepo.setAmoledSaverMode(true);
      expect(studioRepo.isAmoledSaverModeEnabled(), isTrue);

      const effect = WallpaperEffectConfig(
        blurSigma: 8.0,
        vignetteStrength: 0.5,
        colorFilterPreset: 'cyber_cyan',
      );
      await studioRepo.saveCustomEffect('wall_fx', effect);
      expect(studioRepo.getCustomEffects()['wall_fx'], equals(effect));

      await studioRepo.resetCustomEffect('wall_fx');
      expect(studioRepo.getCustomEffects().containsKey('wall_fx'), isFalse);
    });
  });

  group('CommunityBlueprintRepository Unit Tests (Isolated MemoryCache)', () {
    late LocalCacheService cache;
    late CommunityBlueprintRepository communityRepo;

    setUp(() {
      cache = MemoryCacheService();
      communityRepo = CommunityBlueprintRepository(cache: cache);
    });

    test('Blueprint publishing and like counter toggling', () async {
      expect(communityRepo.getPublishedBlueprints(), isEmpty);

      final blueprint = WalloraScreenBlueprint(
        id: 'bp_cyber_01',
        title: 'Cyberpunk Aurora',
        creatorName: 'NeonKnight',
        description: 'Vibrant obsidian neon aesthetics',
        wallpaper: const MotivationalShort(
          id: 'short_neon',
          title: 'Neon Drift',
          author: 'CyberArtist',
          quote: 'Ride the electric storm.',
          category: 'Anime & Gaming',
          videoAssetPath: 'assets/videos/placeholder.mp4',
          accentColor: Color(0xFF00E5FF),
          tags: '#Neon #Cyber',
        ),
        customQuote: 'Ride the electric storm.',
        createdAt: DateTime.now(),
        likesCount: 10,
      );

      await communityRepo.publishBlueprint(blueprint);
      expect(communityRepo.getPublishedBlueprints().length, 1);

      // Like blueprint
      final likesAfterLike = await communityRepo.likeBlueprint('bp_cyber_01');
      expect(likesAfterLike, 11);
      expect(communityRepo.getLikedBlueprintIds().contains('bp_cyber_01'), isTrue);

      // Unlike blueprint
      final likesAfterUnlike = await communityRepo.likeBlueprint('bp_cyber_01');
      expect(likesAfterUnlike, 10);
      expect(communityRepo.getLikedBlueprintIds().contains('bp_cyber_01'), isFalse);
    });
  });

  group('DataPortabilityRepository Unit Tests (Isolated MemoryCache)', () {
    late LocalCacheService cache;
    late PlaylistRepository playlistRepo;
    late StudioConfigRepository studioRepo;
    late DataPortabilityRepository portabilityRepo;

    setUp(() {
      cache = MemoryCacheService();
      playlistRepo = PlaylistRepository(cache: cache);
      studioRepo = StudioConfigRepository(cache: cache);
      portabilityRepo = DataPortabilityRepository(
        cache: cache,
        playlistRepo: playlistRepo,
        studioRepo: studioRepo,
      );
    });

    test('createBackupBundle captures current configurations', () async {
      await playlistRepo.toggleFavorite('fav_01');
      await studioRepo.setAmoledSaverMode(true);

      final bundle = await portabilityRepo.createBackupBundle();
      expect(bundle.favoriteIds.contains('fav_01'), isTrue);
      expect(bundle.isAmoledSaverModeEnabled, isTrue);
    });

    test('restoreBackupBundle merges or replaces cleanly and factoryResetData resets all', () async {
      await playlistRepo.toggleFavorite('fav_01');

      final newBundle = WalloraBackupBundle(
        exportedAt: DateTime.now(),
        favoriteIds: const {'fav_02'},
        isAmoledSaverModeEnabled: true,
      );

      // Merge
      final mergeSuccess = await portabilityRepo.restoreBackupBundle(newBundle, mergeWithExisting: true);
      expect(mergeSuccess, isTrue);
      expect(playlistRepo.getFavorites().contains('fav_01'), isTrue);
      expect(playlistRepo.getFavorites().contains('fav_02'), isTrue);

      // Factory Reset
      await portabilityRepo.factoryResetData();
      expect(playlistRepo.getFavorites(), isEmpty);
      expect(studioRepo.isAmoledSaverModeEnabled(), isFalse);
    });
  });
}
