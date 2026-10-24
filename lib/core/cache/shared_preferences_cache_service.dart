import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cache_entry.dart';
import 'local_cache_service.dart';

/// Concrete [LocalCacheService] implementation backed by [SharedPreferences] and the local app file system.
class SharedPreferencesCacheService implements LocalCacheService {
  final SharedPreferences prefs;

  SharedPreferencesCacheService({required this.prefs});

  /// Factory helper for async initialization.
  static Future<SharedPreferencesCacheService> create() async {
    final preferences = await SharedPreferences.getInstance();
    return SharedPreferencesCacheService(prefs: preferences);
  }

  @override
  Future<bool> setString(String key, String value, {Duration? ttl}) async {
    if (ttl != null) {
      final entry = CacheEntry<String>(value: value, ttl: ttl);
      return prefs.setString(
        key,
        jsonEncode(entry.toJson((v) => v)),
      );
    }
    return prefs.setString(key, value);
  }

  @override
  String? getString(String key) {
    final raw = prefs.getString(key);
    if (raw == null) return null;

    // Check if it's a TTL wrapped CacheEntry
    if (raw.startsWith('{"value":') && raw.contains('"createdAt":')) {
      try {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        final entry = CacheEntry.fromJson<String>(json, (v) => v as String);
        if (entry.isExpired) {
          prefs.remove(key);
          return null;
        }
        return entry.value;
      } catch (_) {
        return raw;
      }
    }
    return raw;
  }

  @override
  Future<bool> setBool(String key, bool value) => prefs.setBool(key, value);

  @override
  bool? getBool(String key, {bool? defaultValue}) =>
      prefs.getBool(key) ?? defaultValue;

  @override
  Future<bool> setInt(String key, int value) => prefs.setInt(key, value);

  @override
  int? getInt(String key, {int? defaultValue}) =>
      prefs.getInt(key) ?? defaultValue;

  @override
  Future<bool> setDouble(String key, double value) =>
      prefs.setDouble(key, value);

  @override
  double? getDouble(String key, {double? defaultValue}) =>
      prefs.getDouble(key) ?? defaultValue;

  @override
  Future<bool> setStringList(String key, List<String> value) =>
      prefs.setStringList(key, value);

  @override
  List<String>? getStringList(String key) => prefs.getStringList(key);

  @override
  Future<bool> setJson(String key, Map<String, dynamic> json,
      {Duration? ttl}) async {
    final str = jsonEncode(json);
    return setString(key, str, ttl: ttl);
  }

  @override
  Map<String, dynamic>? getJson(String key) {
    final str = getString(key);
    if (str == null || str.isEmpty) return null;
    try {
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  @override
  T? getObject<T>(
    String key,
    T Function(Map<String, dynamic> json) fromJson, {
    T? fallback,
  }) {
    final map = getJson(key);
    if (map == null) return fallback;
    try {
      return fromJson(map);
    } catch (_) {
      return fallback;
    }
  }

  @override
  Future<bool> setObject<T>(
    String key,
    Map<String, dynamic> Function(T object) toJson,
    T object, {
    Duration? ttl,
  }) {
    final map = toJson(object);
    return setJson(key, map, ttl: ttl);
  }

  @override
  Future<File?> saveFile(String fileName, List<int> bytes) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);
      return file;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<File?> getFile(String fileName) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> deleteFile(String fileName) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> fileExists(String fileName) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      return file.exists();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<int> getCacheSizeInBytes() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      if (!await dir.exists()) return 0;
      int totalSize = 0;
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<void> clearAllFiles() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      if (!await dir.exists()) return;
      await for (final entity in dir.list(followLinks: false)) {
        if (entity is File &&
            (entity.path.endsWith('.mp4') || entity.path.endsWith('.jpg') || entity.path.endsWith('.png'))) {
          await entity.delete();
        }
      }
    } catch (_) {
      // Ignored
    }
  }

  @override
  Future<bool> remove(String key) => prefs.remove(key);

  @override
  Future<bool> containsKey(String key) async => prefs.containsKey(key);

  @override
  Set<String> getKeys({String? prefix}) {
    final keys = prefs.getKeys();
    if (prefix == null || prefix.isEmpty) {
      return keys;
    }
    return keys.where((k) => k.startsWith(prefix)).toSet();
  }

  @override
  Future<bool> clear() => prefs.clear();
}
