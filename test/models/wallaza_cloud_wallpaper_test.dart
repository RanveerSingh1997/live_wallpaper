import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:live_wallpaper/models/wallaza_cloud_wallpaper.dart';

void main() {
  group('WallazaCloudWallpaper Model Tests', () {
    test('props and equality work as expected', () {
      const item1 = WallazaCloudWallpaper(
        id: 'test_1',
        title: 'Cyber City',
        description: 'Night lights',
        url: 'https://example.com/1.jpg',
        thumbnailUrl: 'https://example.com/1_thumb.jpg',
        category: 'Cyberpunk',
        tags: ['cyber', 'neon'],
        resolution: '3840x2160',
        fileSizeBytes: 4000000,
        downloads: 100,
        favorites: 50,
      );

      const item2 = WallazaCloudWallpaper(
        id: 'test_1',
        title: 'Cyber City',
        description: 'Night lights',
        url: 'https://example.com/1.jpg',
        thumbnailUrl: 'https://example.com/1_thumb.jpg',
        category: 'Cyberpunk',
        tags: ['cyber', 'neon'],
        resolution: '3840x2160',
        fileSizeBytes: 4000000,
        downloads: 100,
        favorites: 50,
      );

      expect(item1, equals(item2));
      expect(item1.is4K, isTrue);
      expect(item1.fileSizeFormatted, '3.8 MB');
    });

    test('toJson and fromJson serialize and deserialize accurately', () {
      final now = DateTime.utc(2026, 4, 15, 12, 0, 0);
      final item = WallazaCloudWallpaper(
        id: 'wlz_100',
        title: 'Cosmic Nebula',
        description: 'Deep galaxy',
        url: 'https://example.com/nebula.jpg',
        thumbnailUrl: 'https://example.com/nebula_t.jpg',
        category: 'Space',
        tags: const ['space', 'galaxy'],
        resolution: '3840x2160',
        fileSizeBytes: 2048 * 1024,
        downloads: 500,
        favorites: 200,
        authorName: 'Aria',
        authorUsername: 'ariacosmos',
        createdAt: now,
      );

      final json = item.toJson();
      final restored = WallazaCloudWallpaper.fromJson(json);

      expect(restored.id, 'wlz_100');
      expect(restored.title, 'Cosmic Nebula');
      expect(restored.description, 'Deep galaxy');
      expect(restored.category, 'Space');
      expect(restored.tags, ['space', 'galaxy']);
      expect(restored.resolution, '3840x2160');
      expect(restored.downloads, 500);
      expect(restored.favorites, 200);
      expect(restored.authorName, 'Aria');
      expect(restored.authorUsername, 'ariacosmos');
      expect(restored.createdAt, now);
    });

    test('copyWith modifies targeted fields while preserving others', () {
      const item = WallazaCloudWallpaper(
        id: '1',
        title: 'Mountain Ridge',
        description: 'Alpine peaks',
        url: 'https://example.com/mountain.jpg',
        thumbnailUrl: 'https://example.com/mountain_t.jpg',
        category: 'Nature',
      );

      final updated = item.copyWith(
        title: 'Sunset Ridge',
        downloads: 1200,
        resolution: '1920x1080',
      );

      expect(updated.id, '1');
      expect(updated.title, 'Sunset Ridge');
      expect(updated.description, 'Alpine peaks');
      expect(updated.downloads, 1200);
      expect(updated.resolution, '1920x1080');
      expect(updated.is4K, isFalse);
    });

    test('toMotivationalShort converts to Wallora short seamlessly', () {
      const item = WallazaCloudWallpaper(
        id: 'amoled_singularity',
        title: 'True Black Void',
        description: 'OLED abyss',
        url: 'https://example.com/amoled.jpg',
        thumbnailUrl: 'https://example.com/amoled_t.jpg',
        category: 'AMOLED',
        tags: ['amoled', 'dark', 'oled'],
        resolution: '3840x2160',
        fileSizeBytes: 1500000,
        downloads: 5000,
        favorites: 2000,
        authorName: 'Eleni',
      );

      expect(item.isAmoled, isTrue);

      final short = item.toMotivationalShort();
      expect(short.id, 'cloud_amoled_singularity');
      expect(short.title, 'True Black Void');
      expect(short.imageUrl, 'https://example.com/amoled.jpg');
      expect(short.isLive, isFalse);
      expect(short.isAmoledCertified, isTrue);
      expect(short.trueBlackPercentage, 85);
      expect(short.author, 'Eleni');
      expect(short.accentColor, const Color(0xFFFFFFFF));
    });

    test('curatedCloudLibrary contains valid fallback wallpapers', () {
      expect(WallazaCloudWallpaper.curatedCloudLibrary.isNotEmpty, isTrue);
      for (final item in WallazaCloudWallpaper.curatedCloudLibrary) {
        expect(item.id.isNotEmpty, isTrue);
        expect(item.title.isNotEmpty, isTrue);
        expect(item.url.isNotEmpty, isTrue);
        expect(item.category.isNotEmpty, isTrue);
      }
    });
  });
}
