import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'cache_entry.dart';
import 'local_cache_service.dart';

/// In-memory implementation of [LocalCacheService] for unit testing and ephemeral storage.
class MemoryCacheService implements LocalCacheService {
  final Map<String, dynamic> _storage = {};
  final Map<String, CacheEntry<dynamic>> _ttlStorage = {};
  final Map<String, List<int>> _fileStorage = {};

  @override
  Future<bool> setString(String key, String value, {Duration? ttl}) async {
    if (ttl != null) {
      _ttlStorage[key] = CacheEntry<String>(value: value, ttl: ttl);
    } else {
      _storage[key] = value;
      _ttlStorage.remove(key);
    }
    return true;
  }

  @override
  String? getString(String key) {
    if (_ttlStorage.containsKey(key)) {
      final entry = _ttlStorage[key]!;
      if (entry.isExpired) {
        _ttlStorage.remove(key);
        return null;
      }
      return entry.value as String;
    }
    final val = _storage[key];
    return val is String ? val : null;
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    _storage[key] = value;
    return true;
  }

  @override
  bool? getBool(String key, {bool? defaultValue}) {
    final val = _storage[key];
    return val is bool ? val : defaultValue;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    _storage[key] = value;
    return true;
  }

  @override
  int? getInt(String key, {int? defaultValue}) {
    final val = _storage[key];
    return val is int ? val : defaultValue;
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    _storage[key] = value;
    return true;
  }

  @override
  double? getDouble(String key, {double? defaultValue}) {
    final val = _storage[key];
    return val is double ? val : defaultValue;
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    _storage[key] = List<String>.from(value);
    return true;
  }

  @override
  List<String>? getStringList(String key) {
    final val = _storage[key];
    return val is List<String> ? List<String>.from(val) : null;
  }

  @override
  Future<bool> setJson(String key, Map<String, dynamic> json, {Duration? ttl}) {
    return setString(key, jsonEncode(json), ttl: ttl);
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
    _fileStorage[fileName] = List<int>.from(bytes);
    if (kIsWeb) return null;
    return File('/virtual/$fileName');
  }

  @override
  Future<File?> getFile(String fileName) async {
    if (_fileStorage.containsKey(fileName)) {
      if (kIsWeb) return null;
      return File('/virtual/$fileName');
    }
    return null;
  }

  @override
  Future<bool> deleteFile(String fileName) async {
    return _fileStorage.remove(fileName) != null;
  }

  @override
  Future<bool> fileExists(String fileName) async {
    return _fileStorage.containsKey(fileName);
  }

  @override
  Future<int> getCacheSizeInBytes() async {
    return _fileStorage.values.fold<int>(0, (sum, bytes) => sum + bytes.length);
  }

  @override
  Future<void> clearAllFiles() async {
    _fileStorage.clear();
  }

  @override
  Future<bool> remove(String key) async {
    _storage.remove(key);
    _ttlStorage.remove(key);
    return true;
  }

  @override
  Future<bool> containsKey(String key) async {
    return _storage.containsKey(key) || _ttlStorage.containsKey(key);
  }

  @override
  Set<String> getKeys({String? prefix}) {
    final keys = {..._storage.keys, ..._ttlStorage.keys};
    if (prefix == null || prefix.isEmpty) {
      return keys;
    }
    return keys.where((k) => k.startsWith(prefix)).toSet();
  }

  @override
  Future<bool> clear() async {
    _storage.clear();
    _ttlStorage.clear();
    _fileStorage.clear();
    return true;
  }
}
