import 'dart:convert';
import '../core/core.dart';
import '../models/wallpaper_collection.dart';

/// Abstract contract for user favorites and custom wallpaper playlists.
/// Follows Dependency Inversion Principle (DIP).
abstract class PlaylistRepository {
  factory PlaylistRepository({required LocalCacheService cache}) =
      PlaylistRepositoryImpl;

  Set<String> getFavorites();
  Future<bool> toggleFavorite(String shortId);
  bool isFavorite(String shortId);
  Future<void> setFavorites(Set<String> favorites);

  List<WallpaperCollection> getCustomCollections();
  Future<void> saveCollection(WallpaperCollection collection);
  Future<void> deleteCollection(String collectionId);
  Future<bool> toggleWallpaperInCollection(String collectionId, String shortId);
  bool isWallpaperInCollection(String collectionId, String shortId);
  Future<void> setCustomCollections(List<WallpaperCollection> collections);
}

/// Concrete implementation of [PlaylistRepository].
class PlaylistRepositoryImpl implements PlaylistRepository {
  final LocalCacheService cache;

  PlaylistRepositoryImpl({required this.cache});

  @override
  Set<String> getFavorites() {
    final list = cache.getStringList(AppConstants.keyFavorites) ?? [];
    return list.toSet();
  }

  @override
  Future<bool> toggleFavorite(String shortId) async {
    final current = getFavorites();
    final isAdded = !current.contains(shortId);
    if (isAdded) {
      current.add(shortId);
    } else {
      current.remove(shortId);
    }
    await cache.setStringList(AppConstants.keyFavorites, current.toList());
    return isAdded;
  }

  @override
  bool isFavorite(String shortId) {
    return getFavorites().contains(shortId);
  }

  @override
  Future<void> setFavorites(Set<String> favorites) async {
    await cache.setStringList(AppConstants.keyFavorites, favorites.toList());
  }

  @override
  List<WallpaperCollection> getCustomCollections() {
    final rawList =
        cache.getStringList(AppConstants.keyCustomCollections) ?? [];
    return rawList
        .map((str) {
          try {
            return WallpaperCollection.fromJson(
              jsonDecode(str) as Map<String, dynamic>,
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<WallpaperCollection>()
        .toList();
  }

  @override
  Future<void> saveCollection(WallpaperCollection collection) async {
    final current = getCustomCollections();
    final index = current.indexWhere((c) => c.id == collection.id);
    if (index >= 0) {
      current[index] = collection;
    } else {
      current.add(collection);
    }
    await cache.setStringList(
      AppConstants.keyCustomCollections,
      current.map((c) => jsonEncode(c.toJson())).toList(),
    );
  }

  @override
  Future<void> deleteCollection(String collectionId) async {
    final current = getCustomCollections();
    current.removeWhere((c) => c.id == collectionId);
    await cache.setStringList(
      AppConstants.keyCustomCollections,
      current.map((c) => jsonEncode(c.toJson())).toList(),
    );
  }

  @override
  Future<bool> toggleWallpaperInCollection(
    String collectionId,
    String shortId,
  ) async {
    final current = getCustomCollections();
    final index = current.indexWhere((c) => c.id == collectionId);
    if (index < 0) return false;

    final col = current[index];
    final isMember = col.wallpaperIds.contains(shortId);
    final updatedIds = Set<String>.from(col.wallpaperIds);
    if (isMember) {
      updatedIds.remove(shortId);
    } else {
      updatedIds.add(shortId);
    }

    final updatedCol = col.copyWith(wallpaperIds: updatedIds.toList());
    current[index] = updatedCol;

    await cache.setStringList(
      AppConstants.keyCustomCollections,
      current.map((c) => jsonEncode(c.toJson())).toList(),
    );
    return !isMember;
  }

  @override
  bool isWallpaperInCollection(String collectionId, String shortId) {
    final current = getCustomCollections();
    final match = current.where((c) => c.id == collectionId);
    if (match.isEmpty) return false;
    return match.first.wallpaperIds.contains(shortId);
  }

  @override
  Future<void> setCustomCollections(
      List<WallpaperCollection> collections) async {
    await cache.setStringList(
      AppConstants.keyCustomCollections,
      collections.map((c) => jsonEncode(c.toJson())).toList(),
    );
  }
}
