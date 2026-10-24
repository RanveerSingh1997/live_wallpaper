import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/core/core.dart';
import 'package:live_wallpaper/models/motivational_short.dart';
import 'package:live_wallpaper/models/wallaza_cloud_wallpaper.dart';
import 'package:live_wallpaper/models/wallora_backup_bundle.dart';
import 'package:live_wallpaper/models/wallora_screen_blueprint.dart';
import 'package:live_wallpaper/models/wallpaper_effect_config.dart';
import 'package:live_wallpaper/repositories/repositories.dart';
import 'package:live_wallpaper/services/wallaza_api_service.dart';
import 'package:live_wallpaper/usecases/usecases.dart';

class FakeCatalogRepository implements CatalogRepository {
  final Map<String, dynamic> mockLiveResult;
  final Map<String, dynamic> mockStaticResult;

  FakeCatalogRepository({
    this.mockLiveResult = const {'status': 'applied_mock'},
    this.mockStaticResult = const {'status': 'applied_static_mock'},
  });

  @override
  Future<Map<String, dynamic>> applyAsLiveWallpaper({
    required MotivationalShort short,
    bool isMuted = true,
  }) async =>
      mockLiveResult;

  @override
  Future<Map<String, dynamic>> applyStaticWallpaper({
    required MotivationalShort short,
    String targetScreen = 'both',
    String? customQuote,
    WallpaperEffectConfig? effectConfig,
  }) async =>
      mockStaticResult;

  @override
  List<MotivationalShort> getCuratedShorts() => [];

  @override
  String? getActiveWallpaperId() => null;

  @override
  Future<void> setActiveWallpaperId(String id) async {}

  @override
  List<MotivationalShort> getCustomImportedWallpapers() => [];

  @override
  Future<void> saveCustomImportedWallpaper(MotivationalShort short) async {}

  @override
  Future<void> deleteCustomImportedWallpaper(String id) async {}

  @override
  Future<File?> prepareVideoFile(MotivationalShort short) async => null;

  @override
  Future<List<WallazaCloudWallpaper>> fetchCloudWallpapers({
    int page = 1,
    int limit = 20,
    String? category,
  }) async =>
      [];

  @override
  Future<List<WallazaCloudWallpaper>> searchCloudWallpapers({
    required String query,
    String? resolution,
    int page = 1,
    int limit = 20,
  }) async =>
      [];

  @override
  Future<WallazaCloudWallpaper?> getCloudWallpaper(String id) async => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sampleShort = MotivationalShort(
    id: 'test_short',
    title: 'Focus',
    author: 'Marcus Aurelius',
    quote: 'Waste no more time arguing what a good man should be. Be one.',
    category: 'Philosophy',
    videoAssetPath: 'assets/videos/sample.mp4',
    accentColor: Color(0xFF00E5FF),
    tags: '#Stoicism #Focus',
  );

  group('ApplyLiveWallpaperUseCase & ApplyStaticWallpaperUseCase Unit Tests', () {
    test('ApplyLiveWallpaperUseCase returns Success when status is valid', () async {
      final catalog = FakeCatalogRepository(
        mockLiveResult: {'status': 'updated_active'},
      );
      final useCase = ApplyLiveWallpaperUseCase(catalogRepository: catalog);

      final result = await useCase(const ApplyLiveWallpaperParams(
        wallpaper: sampleShort,
        isMuted: true,
      ));

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?['status'], 'updated_active');
    });

    test('ApplyLiveWallpaperUseCase returns Failure when status is error', () async {
      final catalog = FakeCatalogRepository(
        mockLiveResult: {'status': 'error', 'message': 'Player corrupted'},
      );
      final useCase = ApplyLiveWallpaperUseCase(catalogRepository: catalog);

      final result = await useCase(const ApplyLiveWallpaperParams(
        wallpaper: sampleShort,
      ));

      expect(result.isFailure, isTrue);
      expect(result.errorMessageOrNull, 'Player corrupted');
    });

    test('ApplyStaticWallpaperUseCase coordinates rendering and returns Success', () async {
      final catalog = FakeCatalogRepository(
        mockStaticResult: {'status': 'applied_static'},
      );
      final useCase = ApplyStaticWallpaperUseCase(catalogRepository: catalog);

      final result = await useCase(const ApplyStaticWallpaperParams(
        wallpaper: sampleShort,
        targetScreen: 'both',
        customQuote: 'Custom quote override',
      ));

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?['status'], 'applied_static');
    });
  });

  group('ToggleFavoriteUseCase Unit Tests', () {
    test('toggles favorite and returns boolean outcome', () async {
      final cache = MemoryCacheService();
      final playlistRepo = PlaylistRepository(cache: cache);
      final useCase = ToggleFavoriteUseCase(playlistRepository: playlistRepo);

      final addResult = await useCase('fav_wall_01');
      expect(addResult.isSuccess, isTrue);
      expect(addResult.dataOrNull, isTrue);
      expect(playlistRepo.isFavorite('fav_wall_01'), isTrue);

      final removeResult = await useCase('fav_wall_01');
      expect(removeResult.isSuccess, isTrue);
      expect(removeResult.dataOrNull, isFalse);
      expect(playlistRepo.isFavorite('fav_wall_01'), isFalse);
    });
  });

  group('DownloadWallpaperUseCase Unit Tests', () {
    test('downloads wallpaper via repository and returns Success', () async {
      final cache = MemoryCacheService();
      final downloadRepo = DownloadRepository(
        cache: cache,
        wallazaService: WallazaApiService(),
      );
      final useCase = DownloadWallpaperUseCase(downloadRepository: downloadRepo);

      final result = await useCase(sampleShort);
      expect(result.isSuccess, isTrue);
      expect(downloadRepo.isDownloaded('test_short'), isTrue);
    });
  });

  group('Blueprint UseCases Unit Tests', () {
    test('PublishBlueprintUseCase and LikeBlueprintUseCase execute successfully', () async {
      final cache = MemoryCacheService();
      final communityRepo = CommunityBlueprintRepository(cache: cache);
      final publishUseCase = PublishBlueprintUseCase(communityRepository: communityRepo);
      final likeUseCase = LikeBlueprintUseCase(communityRepository: communityRepo);

      final blueprint = WalloraScreenBlueprint(
        id: 'bp_zenith_01',
        title: 'Zenith Aurora',
        creatorName: 'Aero',
        description: 'Atmospheric aesthetic preset',
        wallpaper: sampleShort,
        customQuote: 'Look beyond the horizon.',
        createdAt: DateTime.now(),
        likesCount: 5,
      );

      final publishResult = await publishUseCase(blueprint);
      expect(publishResult.isSuccess, isTrue);
      expect(communityRepo.getPublishedBlueprints().length, 1);

      final likeResult = await likeUseCase('bp_zenith_01');
      expect(likeResult.isSuccess, isTrue);
      expect(likeResult.dataOrNull, 6);
    });
  });

  group('Portability UseCases Unit Tests', () {
    test('CreateBackupBundleUseCase and RestoreBackupBundleUseCase', () async {
      final cache = MemoryCacheService();
      final playlistRepo = PlaylistRepository(cache: cache);
      final studioRepo = StudioConfigRepository(cache: cache);
      final portabilityRepo = DataPortabilityRepository(
        cache: cache,
        playlistRepo: playlistRepo,
        studioRepo: studioRepo,
      );

      final createUseCase = CreateBackupBundleUseCase(portabilityRepository: portabilityRepo);
      final restoreUseCase = RestoreBackupBundleUseCase(portabilityRepository: portabilityRepo);

      await playlistRepo.toggleFavorite('fav_bundle_01');
      final createResult = await createUseCase(const NoParams());
      expect(createResult.isSuccess, isTrue);
      expect(createResult.dataOrNull?.favoriteIds.contains('fav_bundle_01'), isTrue);

      final newBundle = WalloraBackupBundle(
        exportedAt: DateTime.now(),
        favoriteIds: const {'restored_fav_02'},
      );

      final restoreResult = await restoreUseCase(RestoreBackupParams(
        bundle: newBundle,
        mergeWithExisting: true,
      ));
      expect(restoreResult.isSuccess, isTrue);
      expect(playlistRepo.getFavorites().contains('fav_bundle_01'), isTrue);
      expect(playlistRepo.getFavorites().contains('restored_fav_02'), isTrue);
    });
  });
}
