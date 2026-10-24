import 'dart:convert';
import '../core/core.dart';
import '../models/wallora_screen_blueprint.dart';

/// Abstract contract for Community Exchange blueprints and user likes.
/// Follows Dependency Inversion Principle (DIP).
abstract class CommunityBlueprintRepository {
  factory CommunityBlueprintRepository({required LocalCacheService cache}) =
      CommunityBlueprintRepositoryImpl;

  /// Returns list of all user-published aesthetic blueprints.
  List<WalloraScreenBlueprint> getPublishedBlueprints();

  /// Publishes a new setup blueprint to the community repository.
  Future<void> publishBlueprint(WalloraScreenBlueprint blueprint);

  /// Returns set of blueprint IDs liked by the local user.
  Set<String> getLikedBlueprintIds();

  /// Toggles like on a blueprint, returning updated total likes count.
  Future<int> likeBlueprint(String blueprintId);
}

/// Concrete implementation of [CommunityBlueprintRepository].
class CommunityBlueprintRepositoryImpl implements CommunityBlueprintRepository {
  final LocalCacheService cache;

  CommunityBlueprintRepositoryImpl({required this.cache});

  @override
  List<WalloraScreenBlueprint> getPublishedBlueprints() {
    final rawList =
        cache.getStringList(AppConstants.keyPublishedBlueprints) ?? [];
    return rawList
        .map((str) {
          try {
            return WalloraScreenBlueprint.fromJson(
              jsonDecode(str) as Map<String, dynamic>,
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<WalloraScreenBlueprint>()
        .toList();
  }

  @override
  Future<void> publishBlueprint(WalloraScreenBlueprint blueprint) async {
    final current = getPublishedBlueprints();
    current.removeWhere((b) => b.id == blueprint.id);
    current.insert(0, blueprint);
    await cache.setStringList(
      AppConstants.keyPublishedBlueprints,
      current.map((b) => jsonEncode(b.toJson())).toList(),
    );
  }

  @override
  Set<String> getLikedBlueprintIds() {
    final list = cache.getStringList(AppConstants.keyLikedBlueprintIds) ?? [];
    return list.toSet();
  }

  @override
  Future<int> likeBlueprint(String blueprintId) async {
    final likedIds = getLikedBlueprintIds();
    final bool isAlreadyLiked = likedIds.contains(blueprintId);

    if (isAlreadyLiked) {
      likedIds.remove(blueprintId);
    } else {
      likedIds.add(blueprintId);
    }
    await cache.setStringList(
      AppConstants.keyLikedBlueprintIds,
      likedIds.toList(),
    );

    final published = getPublishedBlueprints();
    final index = published.indexWhere((b) => b.id == blueprintId);
    if (index >= 0) {
      final bp = published[index];
      final newLikes = isAlreadyLiked
          ? (bp.likesCount - 1).clamp(0, 999999)
          : bp.likesCount + 1;
      final updatedBp = bp.copyWith(likesCount: newLikes);
      published[index] = updatedBp;
      await cache.setStringList(
        AppConstants.keyPublishedBlueprints,
        published.map((b) => jsonEncode(b.toJson())).toList(),
      );
      return newLikes;
    }

    // Curated blueprint match
    final curatedIndex = WalloraScreenBlueprint.curatedBlueprints
        .indexWhere((b) => b.id == blueprintId);
    if (curatedIndex >= 0) {
      final bp = WalloraScreenBlueprint.curatedBlueprints[curatedIndex];
      return isAlreadyLiked
          ? (bp.likesCount - 1).clamp(0, 999999)
          : bp.likesCount + 1;
    }

    return 0;
  }
}
