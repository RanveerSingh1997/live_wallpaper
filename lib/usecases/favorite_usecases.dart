import '../core/core.dart';
import '../repositories/playlist_repository.dart';
import 'usecase.dart';

/// Use case that toggles favorite status for a given wallpaper ID.
class ToggleFavoriteUseCase implements UseCase<bool, String> {
  final PlaylistRepository playlistRepository;

  ToggleFavoriteUseCase({required this.playlistRepository});

  @override
  Future<Result<bool>> call(String wallpaperId) async {
    try {
      final isAdded = await playlistRepository.toggleFavorite(wallpaperId);
      return Success(isAdded);
    } catch (e, stack) {
      return Failure('Failed to toggle favorite: $e',
          error: e, stackTrace: stack);
    }
  }
}
