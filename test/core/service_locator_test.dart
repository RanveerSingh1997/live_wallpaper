import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/core/core.dart';

abstract class AuthService {
  String get role;
}

class AdminAuthService implements AuthService {
  @override
  String get role => 'Admin';
}

class GuestAuthService implements AuthService {
  @override
  String get role => 'Guest';
}

void main() {
  group('ServiceLocator Unit Tests', () {
    setUp(() {
      ServiceLocator.reset();
    });

    tearDown(() {
      ServiceLocator.reset();
    });

    test('registerSingleton persists instance across queries', () {
      expect(ServiceLocator.isRegistered<AuthService>(), isFalse);
      expect(ServiceLocator.getOrNull<AuthService>(), isNull);
      expect(() => ServiceLocator.get<AuthService>(), throwsStateError);

      final service = AdminAuthService();
      ServiceLocator.registerSingleton<AuthService>(service);

      expect(ServiceLocator.isRegistered<AuthService>(), isTrue);
      expect(identical(ServiceLocator.get<AuthService>(), service), isTrue);
      expect(ServiceLocator.get<AuthService>().role, 'Admin');
    });

    test('registerFactory invokes provider function on each query', () {
      int count = 0;
      ServiceLocator.registerFactory<String>(() => 'Instance_${++count}');

      expect(ServiceLocator.get<String>(), 'Instance_1');
      expect(ServiceLocator.get<String>(), 'Instance_2');
      expect(ServiceLocator.get<String>(), 'Instance_3');
    });

    test('unregister removes registered types cleanly', () {
      ServiceLocator.registerSingleton<AuthService>(GuestAuthService());
      expect(ServiceLocator.isRegistered<AuthService>(), isTrue);

      ServiceLocator.unregister<AuthService>();
      expect(ServiceLocator.isRegistered<AuthService>(), isFalse);
      expect(ServiceLocator.getOrNull<AuthService>(), isNull);
    });

    test('reset clears entire container', () {
      ServiceLocator.registerSingleton<String>('Alpha');
      ServiceLocator.registerSingleton<int>(100);

      expect(ServiceLocator.isRegistered<String>(), isTrue);
      expect(ServiceLocator.isRegistered<int>(), isTrue);

      ServiceLocator.reset();

      expect(ServiceLocator.isRegistered<String>(), isFalse);
      expect(ServiceLocator.isRegistered<int>(), isFalse);
    });
  });
}
