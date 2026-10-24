import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SampleUser {
  final String id;
  final String name;

  SampleUser({required this.id, required this.name});

  factory SampleUser.fromJson(Map<String, dynamic> json) {
    return SampleUser(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

void main() {
  group('MemoryCacheService Unit Tests', () {
    late LocalCacheService cache;

    setUp(() {
      cache = MemoryCacheService();
    });

    test('primitives CRUD: String, bool, int, double, List<String>', () async {
      // String
      expect(cache.getString('str_key'), isNull);
      await cache.setString('str_key', 'hello_wallora');
      expect(cache.getString('str_key'), 'hello_wallora');

      // bool
      expect(cache.getBool('bool_key'), isNull);
      expect(cache.getBool('bool_key', defaultValue: true), isTrue);
      await cache.setBool('bool_key', false);
      expect(cache.getBool('bool_key'), isFalse);

      // int
      expect(cache.getInt('int_key'), isNull);
      await cache.setInt('int_key', 42);
      expect(cache.getInt('int_key'), 42);

      // double
      expect(cache.getDouble('double_key'), isNull);
      await cache.setDouble('double_key', 3.1415);
      expect(cache.getDouble('double_key'), 3.1415);

      // List<String>
      expect(cache.getStringList('list_key'), isNull);
      await cache.setStringList('list_key', ['alpha', 'beta', 'gamma']);
      expect(cache.getStringList('list_key'), ['alpha', 'beta', 'gamma']);
    });

    test('JSON and typed object serialization with fallback', () async {
      final user = SampleUser(id: 'u1', name: 'Wallora Creator');

      expect(
        cache.getObject('user_key', SampleUser.fromJson),
        isNull,
      );

      await cache.setObject('user_key', (u) => u.toJson(), user);
      final retrieved = cache.getObject('user_key', SampleUser.fromJson);
      expect(retrieved?.id, 'u1');
      expect(retrieved?.name, 'Wallora Creator');

      // Test setJson and getJson directly
      await cache.setJson('raw_json', {'status': 'active', 'code': 200});
      final raw = cache.getJson('raw_json');
      expect(raw?['status'], 'active');
      expect(raw?['code'], 200);
    });

    test('CacheEntry TTL expiration behavior', () async {
      await cache.setString(
        'expiring_key',
        'transient_value',
        ttl: const Duration(milliseconds: 50),
      );
      expect(cache.getString('expiring_key'), 'transient_value');

      await Future<void>.delayed(const Duration(milliseconds: 70));
      expect(cache.getString('expiring_key'), isNull);
    });

    test('File caching, size calculation, and deletion', () async {
      expect(await cache.fileExists('test.png'), isFalse);
      expect(await cache.getCacheSizeInBytes(), 0);

      final dummyBytes = [1, 2, 3, 4, 5, 6, 7, 8];
      await cache.saveFile('test.png', dummyBytes);
      expect(await cache.fileExists('test.png'), isTrue);
      expect(await cache.getCacheSizeInBytes(), 8);

      final file = await cache.getFile('test.png');
      expect(file, isNotNull);

      await cache.deleteFile('test.png');
      expect(await cache.fileExists('test.png'), isFalse);
      expect(await cache.getCacheSizeInBytes(), 0);
    });

    test('Key filtering by prefix and clearing', () async {
      await cache.setString('prefix_a', 'val_a');
      await cache.setString('prefix_b', 'val_b');
      await cache.setString('other_c', 'val_c');

      final prefixed = cache.getKeys(prefix: 'prefix_');
      expect(prefixed.contains('prefix_a'), isTrue);
      expect(prefixed.contains('prefix_b'), isTrue);
      expect(prefixed.contains('other_c'), isFalse);

      await cache.clear();
      expect(cache.getKeys(), isEmpty);
    });
  });

  group('SharedPreferencesCacheService Unit Tests', () {
    late LocalCacheService cache;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'initial_key': 'initial_value',
        'int_count': 10,
      });
      final prefs = await SharedPreferences.getInstance();
      cache = SharedPreferencesCacheService(prefs: prefs);
    });

    test('reads existing initial mock values and persists changes', () async {
      expect(cache.getString('initial_key'), 'initial_value');
      expect(cache.getInt('int_count'), 10);

      await cache.setString('new_key', 'new_val');
      expect(cache.getString('new_key'), 'new_val');

      await cache.remove('new_key');
      expect(cache.getString('new_key'), isNull);
    });

    test('typed JSON object persistence through SharedPreferences', () async {
      final user = SampleUser(id: 'u2', name: 'Aurora Artist');
      await cache.setObject('user_prefs', (u) => u.toJson(), user);

      final retrieved = cache.getObject('user_prefs', SampleUser.fromJson);
      expect(retrieved?.id, 'u2');
      expect(retrieved?.name, 'Aurora Artist');
    });

    test('handles TTL expiration encoding and auto-eviction', () async {
      await cache.setString(
        'ephemeral_sp',
        'sp_value',
        ttl: const Duration(milliseconds: 40),
      );
      expect(cache.getString('ephemeral_sp'), 'sp_value');

      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(cache.getString('ephemeral_sp'), isNull);
    });
  });
}
