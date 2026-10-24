import 'dart:io';

/// Abstract contract defining the Local Cache & Storage Service.
/// Follows Dependency Inversion Principle (DIP) and Single Responsibility Principle (SRP):
/// Decouples higher-level repositories from direct platform storage implementations (SharedPreferences, Hive, SQLite).
abstract class LocalCacheService {
  // Primitives
  Future<bool> setString(String key, String value, {Duration? ttl});
  String? getString(String key);

  Future<bool> setBool(String key, bool value);
  bool? getBool(String key, {bool? defaultValue});

  Future<bool> setInt(String key, int value);
  int? getInt(String key, {int? defaultValue});

  Future<bool> setDouble(String key, double value);
  double? getDouble(String key, {double? defaultValue});

  Future<bool> setStringList(String key, List<String> value);
  List<String>? getStringList(String key);

  // JSON & Objects
  Future<bool> setJson(String key, Map<String, dynamic> json, {Duration? ttl});
  Map<String, dynamic>? getJson(String key);

  T? getObject<T>(
    String key,
    T Function(Map<String, dynamic> json) fromJson, {
    T? fallback,
  });

  Future<bool> setObject<T>(
    String key,
    Map<String, dynamic> Function(T object) toJson,
    T object, {
    Duration? ttl,
  });

  // Binary & File Storage
  Future<File?> saveFile(String fileName, List<int> bytes);
  Future<File?> getFile(String fileName);
  Future<bool> deleteFile(String fileName);
  Future<bool> fileExists(String fileName);
  Future<int> getCacheSizeInBytes();
  Future<void> clearAllFiles();

  // Cache Lifecycle
  Future<bool> remove(String key);
  Future<bool> containsKey(String key);
  Set<String> getKeys({String? prefix});
  Future<bool> clear();
}
