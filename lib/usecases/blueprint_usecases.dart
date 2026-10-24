import '../core/core.dart';
import '../models/wallora_screen_blueprint.dart';
import '../repositories/community_blueprint_repository.dart';
import 'usecase.dart';

/// Use case that publishes a user's curated aesthetic blueprint to the community exchange.
class PublishBlueprintUseCase implements UseCase<void, WalloraScreenBlueprint> {
  final CommunityBlueprintRepository communityRepository;

  PublishBlueprintUseCase({required this.communityRepository});

  @override
  Future<Result<void>> call(WalloraScreenBlueprint blueprint) async {
    try {
      await communityRepository.publishBlueprint(blueprint);
      return const Success(null);
    } catch (e, stack) {
      return Failure('Failed to publish blueprint: $e',
          error: e, stackTrace: stack);
    }
  }
}

/// Use case that toggles a user's like on a community blueprint and returns updated likes count.
class LikeBlueprintUseCase implements UseCase<int, String> {
  final CommunityBlueprintRepository communityRepository;

  LikeBlueprintUseCase({required this.communityRepository});

  @override
  Future<Result<int>> call(String blueprintId) async {
    try {
      final likes = await communityRepository.likeBlueprint(blueprintId);
      return Success(likes);
    } catch (e, stack) {
      return Failure('Failed to toggle like on blueprint: $e',
          error: e, stackTrace: stack);
    }
  }
}
