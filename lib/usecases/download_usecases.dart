import '../core/core.dart';
import '../models/motivational_short.dart';
import '../repositories/download_repository.dart';
import 'usecase.dart';

/// Use case that downloads and physically caches full-resolution wallpaper assets for offline usage.
class DownloadWallpaperUseCase implements UseCase<bool, MotivationalShort> {
  final DownloadRepository downloadRepository;

  DownloadWallpaperUseCase({required this.downloadRepository});

  @override
  Future<Result<bool>> call(MotivationalShort short) async {
    try {
      final success = await downloadRepository.downloadWallpaper(short);
      if (!success) {
        return const Failure('Failed to complete wallpaper download.');
      }
      return const Success(true);
    } catch (e, stack) {
      return Failure('Exception downloading wallpaper: $e',
          error: e, stackTrace: stack);
    }
  }
}
