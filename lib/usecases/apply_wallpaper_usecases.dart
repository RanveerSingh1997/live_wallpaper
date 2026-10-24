import 'package:equatable/equatable.dart';
import '../core/core.dart';
import '../models/motivational_short.dart';
import '../models/wallpaper_effect_config.dart';
import '../repositories/catalog_repository.dart';
import 'usecase.dart';

/// Parameters for applying a looping live wallpaper.
class ApplyLiveWallpaperParams extends Equatable {
  final MotivationalShort wallpaper;
  final bool isMuted;

  const ApplyLiveWallpaperParams({
    required this.wallpaper,
    this.isMuted = true,
  });

  @override
  List<Object?> get props => [wallpaper, isMuted];
}

/// Use case that validates and coordinates applying a video as a system live wallpaper.
class ApplyLiveWallpaperUseCase
    implements UseCase<Map<String, dynamic>, ApplyLiveWallpaperParams> {
  final CatalogRepository catalogRepository;

  ApplyLiveWallpaperUseCase({required this.catalogRepository});

  @override
  Future<Result<Map<String, dynamic>>> call(
      ApplyLiveWallpaperParams params) async {
    try {
      final result = await catalogRepository.applyAsLiveWallpaper(
        short: params.wallpaper,
        isMuted: params.isMuted,
      );
      if (result['status'] == 'error') {
        return Failure(result['message'] as String? ?? 'Failed to apply live wallpaper.');
      }
      return Success(result);
    } catch (e, stack) {
      return Failure('Exception applying live wallpaper: $e',
          error: e, stackTrace: stack);
    }
  }
}

/// Parameters for applying high-resolution static wallpaper with custom typography.
class ApplyStaticWallpaperParams extends Equatable {
  final MotivationalShort wallpaper;
  final String targetScreen;
  final String? customQuote;
  final WallpaperEffectConfig? effectConfig;

  const ApplyStaticWallpaperParams({
    required this.wallpaper,
    this.targetScreen = 'both',
    this.customQuote,
    this.effectConfig,
  });

  @override
  List<Object?> get props => [wallpaper, targetScreen, customQuote, effectConfig];
}

/// Use case that coordinates canvas rendering and applying a static wallpaper.
class ApplyStaticWallpaperUseCase
    implements UseCase<Map<String, dynamic>, ApplyStaticWallpaperParams> {
  final CatalogRepository catalogRepository;

  ApplyStaticWallpaperUseCase({required this.catalogRepository});

  @override
  Future<Result<Map<String, dynamic>>> call(
      ApplyStaticWallpaperParams params) async {
    try {
      final result = await catalogRepository.applyStaticWallpaper(
        short: params.wallpaper,
        targetScreen: params.targetScreen,
        customQuote: params.customQuote,
        effectConfig: params.effectConfig,
      );
      return Success(result);
    } catch (e, stack) {
      return Failure('Exception applying static wallpaper: $e',
          error: e, stackTrace: stack);
    }
  }
}
