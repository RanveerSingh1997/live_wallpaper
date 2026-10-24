import 'dart:async';
import 'local_cache_service.dart';

/// Metadata tracking individual cached files for LRU (Least Recently Used) eviction.
class LruItemMetadata {
  final String key;
  final int sizeInBytes;
  final DateTime lastAccessedAt;
  final bool isPinned;

  const LruItemMetadata({
    required this.key,
    required this.sizeInBytes,
    required this.lastAccessedAt,
    this.isPinned = false,
  });

  LruItemMetadata copyWith({
    int? sizeInBytes,
    DateTime? lastAccessedAt,
    bool? isPinned,
  }) {
    return LruItemMetadata(
      key: key,
      sizeInBytes: sizeInBytes ?? this.sizeInBytes,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'sizeInBytes': sizeInBytes,
        'lastAccessedAt': lastAccessedAt.toIso8601String(),
        'isPinned': isPinned,
      };

  factory LruItemMetadata.fromJson(Map<String, dynamic> json) {
    return LruItemMetadata(
      key: json['key'] as String? ?? '',
      sizeInBytes: (json['sizeInBytes'] as num?)?.toInt() ?? 0,
      lastAccessedAt: DateTime.tryParse(json['lastAccessedAt'] as String? ?? '') ??
          DateTime.now(),
      isPinned: json['isPinned'] as bool? ?? false,
    );
  }
}

/// LRU Disk and Cache Manager with a 350MB ceiling to prevent device storage bloat.
///
/// Follows Single Responsibility Principle (SRP) and Dependency Inversion Principle (DIP).
/// Tracks access times and safely purges oldest unpinned items when reaching the storage ceiling.
class LruStorageManager {
  /// Default ceiling: 350 Megabytes (350 * 1024 * 1024 bytes).
  static const int defaultMaxSizeBytes = 350 * 1024 * 1024;

  /// Default purge watermark ratio: 80% (0.80) of maximum limit.
  static const double defaultEvictionRatio = 0.80;

  static const String lruStorageKey = 'wallora_lru_storage_index';

  final LocalCacheService cache;
  final int maxSizeBytes;
  final double evictionRatio;

  final Map<String, LruItemMetadata> _index = {};
  bool _isInitialized = false;

  LruStorageManager({
    required this.cache,
    this.maxSizeBytes = defaultMaxSizeBytes,
    this.evictionRatio = defaultEvictionRatio,
  });

  /// Ensures the persisted index is loaded into memory.
  Future<void> initialize() async {
    if (_isInitialized) return;
    final json = cache.getJson(lruStorageKey);
    if (json != null) {
      json.forEach((k, v) {
        if (v is Map<String, dynamic>) {
          _index[k] = LruItemMetadata.fromJson(v);
        }
      });
    }
    _isInitialized = true;
  }

  /// Returns an unmodifiable copy of all tracked metadata items.
  List<LruItemMetadata> get entries => List.unmodifiable(_index.values);

  /// Total recorded size in bytes across all indexed files.
  int get currentTotalSizeBytes {
    return _index.values.fold<int>(0, (sum, item) => sum + item.sizeInBytes);
  }

  /// Whether a specific key or file is currently pinned (protected from eviction).
  bool isPinned(String key) {
    return _index[key]?.isPinned ?? false;
  }

  /// Records an access event for [key], refreshing its timestamp and updating its size.
  Future<void> recordAccess(
    String key,
    int sizeInBytes, {
    bool? isPinned,
  }) async {
    await initialize();
    final existing = _index[key];
    final updated = LruItemMetadata(
      key: key,
      sizeInBytes: sizeInBytes > 0 ? sizeInBytes : (existing?.sizeInBytes ?? 0),
      lastAccessedAt: DateTime.now(),
      isPinned: isPinned ?? (existing?.isPinned ?? false),
    );

    _index[key] = updated;
    await _persistIndex();
  }

  /// Explicitly pins or unpins an item to protect or release it from eviction.
  Future<void> setPinned(String key, bool isPinned) async {
    await initialize();
    final existing = _index[key];
    if (existing != null) {
      _index[key] = existing.copyWith(isPinned: isPinned);
      await _persistIndex();
    }
  }

  /// Manually removes an item from tracking.
  Future<void> remove(String key) async {
    await initialize();
    if (_index.remove(key) != null) {
      await _persistIndex();
    }
  }

  /// Checks if total stored size exceeds [maxSizeBytes], and if so, evicts oldest
  /// unpinned items until current usage falls below [evictionRatio] * [maxSizeBytes].
  ///
  /// Returns the list of keys that were evicted.
  Future<List<String>> evictIfNeeded({
    Future<void> Function(String key)? onDeleteFile,
  }) async {
    await initialize();
    if (currentTotalSizeBytes <= maxSizeBytes) {
      return const [];
    }

    final targetSizeBytes = (maxSizeBytes * evictionRatio).toInt();
    final evictedKeys = <String>[];

    // Filter unpinned candidates and sort ascending by lastAccessedAt (oldest first).
    final candidates = _index.values
        .where((item) => !item.isPinned)
        .toList()
      ..sort((a, b) => a.lastAccessedAt.compareTo(b.lastAccessedAt));

    for (final candidate in candidates) {
      if (currentTotalSizeBytes <= targetSizeBytes) {
        break;
      }

      final key = candidate.key;
      _index.remove(key);
      evictedKeys.add(key);

      if (onDeleteFile != null) {
        try {
          await onDeleteFile(key);
        } catch (_) {
          // Failure to delete file on disk must not corrupt LRU index
        }
      }
    }

    await _persistIndex();
    return evictedKeys;
  }

  /// Clears tracked entries, optionally preserving pinned items.
  Future<void> clearAll({
    bool keepPinned = true,
    Future<void> Function(String key)? onDeleteFile,
  }) async {
    await initialize();
    final toRemove = _index.entries
        .where((e) => !keepPinned || !e.value.isPinned)
        .map((e) => e.key)
        .toList();

    for (final key in toRemove) {
      _index.remove(key);
      if (onDeleteFile != null) {
        try {
          await onDeleteFile(key);
        } catch (_) {}
      }
    }

    await _persistIndex();
  }

  Future<void> _persistIndex() async {
    final map = <String, dynamic>{};
    for (final entry in _index.entries) {
      map[entry.key] = entry.value.toJson();
    }
    await cache.setJson(lruStorageKey, map);
  }
}
