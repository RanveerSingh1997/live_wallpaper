import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/models/wallpaper_collection.dart';

void main() {
  group('WallpaperCollection Model Tests', () {
    const testCollection = WallpaperCollection(
      id: 'test_col_1',
      title: 'Obsidian Night',
      subtitle: 'Pure dark aesthetics',
      badge: 'DARK',
      icon: Icons.nightlight_round,
      wallpaperIds: ['wall_1', 'wall_2'],
      gradientColors: [Color(0xFF000000), Color(0xFF1A1A24)],
      isUserCreated: true,
    );

    test('props and equality work as expected', () {
      const copy = WallpaperCollection(
        id: 'test_col_1',
        title: 'Obsidian Night',
        subtitle: 'Pure dark aesthetics',
        badge: 'DARK',
        icon: Icons.nightlight_round,
        wallpaperIds: ['wall_1', 'wall_2'],
        gradientColors: [Color(0xFF000000), Color(0xFF1A1A24)],
        isUserCreated: true,
      );

      expect(testCollection, equals(copy));
      expect(testCollection.hashCode, equals(copy.hashCode));
    });

    test('toJson and fromJson serialize and deserialize accurately', () {
      final json = testCollection.toJson();
      expect(json['id'], 'test_col_1');
      expect(json['title'], 'Obsidian Night');
      expect(json['iconCodePoint'], Icons.nightlight_round.codePoint);
      expect(json['isUserCreated'], isTrue);

      final deserialized = WallpaperCollection.fromJson(json);
      expect(deserialized.id, testCollection.id);
      expect(deserialized.title, testCollection.title);
      expect(deserialized.wallpaperIds, testCollection.wallpaperIds);
      expect(deserialized.isUserCreated, isTrue);
    });

    test('copyWith modifies targeted fields while preserving others', () {
      final modified = testCollection.copyWith(
        title: 'Updated Obsidian',
        wallpaperIds: ['wall_1', 'wall_2', 'wall_3'],
      );

      expect(modified.id, testCollection.id);
      expect(modified.title, 'Updated Obsidian');
      expect(modified.wallpaperIds.length, 3);
      expect(modified.subtitle, testCollection.subtitle);
    });
  });
}
