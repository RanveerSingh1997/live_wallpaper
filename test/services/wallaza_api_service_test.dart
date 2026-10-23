import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/services/wallaza_api_service.dart';

void main() {
  group('WallazaApiService Unit Tests', () {
    late WallazaApiService service;

    setUp(() {
      // Points to unreachable port so fallback behavior is verified safely
      service = WallazaApiService(
        baseUrl: 'http://127.0.0.1:54321/api/v1/wallpapers',
        timeout: const Duration(milliseconds: 100),
      );
    });

    test('fetchWallpapers falls back gracefully to curated library on network timeout', () async {
      final results = await service.fetchWallpapers();
      expect(results.isNotEmpty, isTrue);
      expect(results.length, greaterThanOrEqualTo(5));
    });

    test('fetchWallpapers filters fallback items by category', () async {
      final cyber = await service.fetchWallpapers(category: 'Cyberpunk');
      expect(cyber.every((w) => w.category.toLowerCase() == 'cyberpunk'), isTrue);
    });

    test('searchWallpapers returns matching items on fallback', () async {
      final results = await service.searchWallpapers(query: 'orion');
      expect(results.isNotEmpty, isTrue);
      expect(results.first.title.toLowerCase().contains('orion'), isTrue);
    });

    test('searchWallpapers handles empty results gracefully', () async {
      final results = await service.searchWallpapers(query: 'xyz_non_existent_key_9999');
      expect(results.isEmpty, isTrue);
    });

    test('getWallpaperById returns valid item on fallback', () async {
      final item = await service.getWallpaperById('wlz_cyber_01');
      expect(item, isNotNull);
      expect(item!.id, 'wlz_cyber_01');
      expect(item.category, 'Cyberpunk');
    });

    test('getWallpaperById returns null for unknown id on fallback', () async {
      final item = await service.getWallpaperById('unknown_9999');
      expect(item, isNull);
    });
  });
}
