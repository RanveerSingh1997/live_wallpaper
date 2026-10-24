import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/core/cache/cache.dart';

void main() {
  group('LruStorageManager Unit Tests', () {
    late MemoryCacheService cacheService;
    late LruStorageManager lruManager;

    setUp(() {
      cacheService = MemoryCacheService();
      // Use small 1000-byte ceiling for deterministic unit testing with 0.5 (50%) eviction ratio
      lruManager = LruStorageManager(
        cache: cacheService,
        maxSizeBytes: 1000,
        evictionRatio: 0.5,
      );
    });

    test('Initializes with empty index and persists newly recorded files', () async {
      await lruManager.initialize();
      expect(lruManager.entries, isEmpty);
      expect(lruManager.currentTotalSizeBytes, 0);

      await lruManager.recordAccess('wallpaper_1.mp4', 300);
      expect(lruManager.entries.length, 1);
      expect(lruManager.currentTotalSizeBytes, 300);
      expect(lruManager.isPinned('wallpaper_1.mp4'), isFalse);

      // Verify persisted in cache
      final json = cacheService.getJson(LruStorageManager.lruStorageKey);
      expect(json, isNotNull);
      expect(json!.containsKey('wallpaper_1.mp4'), isTrue);
    });

    test('Pinning protects item from eviction even if it is the oldest candidate', () async {
      final deletedFiles = <String>[];

      // Add oldest file and pin it
      await lruManager.recordAccess('pinned_hero.mp4', 400, isPinned: true);
      expect(lruManager.isPinned('pinned_hero.mp4'), isTrue);

      // Add newer unpinned files
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await lruManager.recordAccess('ephemeral_1.mp4', 400);

      await Future<void>.delayed(const Duration(milliseconds: 10));
      await lruManager.recordAccess('ephemeral_2.mp4', 400);

      // Total size is now 1200 bytes (> 1000 bytes max limit)
      expect(lruManager.currentTotalSizeBytes, 1200);

      final evicted = await lruManager.evictIfNeeded(
        onDeleteFile: (key) async => deletedFiles.add(key),
      );

      // Pinned file must NOT be evicted. ephemeral_1.mp4 (oldest unpinned) must be evicted first.
      expect(evicted.contains('pinned_hero.mp4'), isFalse);
      expect(evicted.contains('ephemeral_1.mp4'), isTrue);
      expect(deletedFiles, contains('ephemeral_1.mp4'));
      expect(lruManager.isPinned('pinned_hero.mp4'), isTrue);
    });

    test('Evicts items down to eviction ratio watermark', () async {
      final deletedFiles = <String>[];

      await lruManager.recordAccess('file_a.jpg', 300);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await lruManager.recordAccess('file_b.jpg', 300);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await lruManager.recordAccess('file_c.jpg', 300);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await lruManager.recordAccess('file_d.jpg', 300);

      // Total size = 1200 (> 1000 max). Target is 1000 * 0.5 = 500 bytes.
      final evicted = await lruManager.evictIfNeeded(
        onDeleteFile: (key) async => deletedFiles.add(key),
      );

      // To drop below or equal to 500 bytes, it must evict file_a (300) and file_b (300), remaining 600 -> then file_c (300), remaining 300 (<= 500).
      expect(evicted, ['file_a.jpg', 'file_b.jpg', 'file_c.jpg']);
      expect(lruManager.currentTotalSizeBytes, 300);
      expect(deletedFiles, ['file_a.jpg', 'file_b.jpg', 'file_c.jpg']);
    });

    test('Toggling pin status with setPinned updates metadata and persistence', () async {
      await lruManager.recordAccess('sample.mp4', 250);
      expect(lruManager.isPinned('sample.mp4'), isFalse);

      await lruManager.setPinned('sample.mp4', true);
      expect(lruManager.isPinned('sample.mp4'), isTrue);

      await lruManager.setPinned('sample.mp4', false);
      expect(lruManager.isPinned('sample.mp4'), isFalse);
    });

    test('remove deletes item from index and decreases total size', () async {
      await lruManager.recordAccess('item_1.mp4', 500);
      await lruManager.recordAccess('item_2.mp4', 200);
      expect(lruManager.currentTotalSizeBytes, 700);

      await lruManager.remove('item_1.mp4');
      expect(lruManager.currentTotalSizeBytes, 200);
      expect(lruManager.entries.map((e) => e.key), contains('item_2.mp4'));
    });

    test('clearAll with keepPinned true preserves pinned files only', () async {
      final deletedFiles = <String>[];

      await lruManager.recordAccess('pinned.mp4', 300, isPinned: true);
      await lruManager.recordAccess('unpinned.mp4', 200, isPinned: false);

      await lruManager.clearAll(
        keepPinned: true,
        onDeleteFile: (k) async => deletedFiles.add(k),
      );

      expect(lruManager.entries.length, 1);
      expect(lruManager.entries.first.key, 'pinned.mp4');
      expect(deletedFiles, ['unpinned.mp4']);

      await lruManager.clearAll(
        keepPinned: false,
        onDeleteFile: (k) async => deletedFiles.add(k),
      );
      expect(lruManager.entries, isEmpty);
      expect(deletedFiles, ['unpinned.mp4', 'pinned.mp4']);
    });
  });
}
