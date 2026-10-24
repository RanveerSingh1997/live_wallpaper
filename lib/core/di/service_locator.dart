/// Clean Architecture Service Locator / Dependency Injection container.
/// Follows Dependency Inversion Principle (DIP): Enables decoupling instantiation
/// from usage and allows replacing production services with mocks/fakes in tests.
class ServiceLocator {
  ServiceLocator._();

  static final Map<Type, Object> _registry = {};
  static final Map<Type, Object Function()> _factories = {};

  /// Registers a singleton instance of type [T].
  static void registerSingleton<T extends Object>(T instance) {
    _registry[T] = instance;
  }

  /// Registers a lazy factory creating a new instance of type [T] on each retrieval.
  static void registerFactory<T extends Object>(T Function() factory) {
    _factories[T] = factory;
  }

  /// Retrieves the registered service instance of type [T].
  /// Throws [StateError] if no instance or factory is registered.
  static T get<T extends Object>() {
    if (_registry.containsKey(T)) {
      return _registry[T] as T;
    }
    if (_factories.containsKey(T)) {
      return _factories[T]!() as T;
    }
    throw StateError('ServiceLocator: No service or factory registered for type $T.');
  }

  /// Retrieves the registered service instance or returns null if not registered.
  static T? getOrNull<T extends Object>() {
    if (_registry.containsKey(T)) {
      return _registry[T] as T;
    }
    if (_factories.containsKey(T)) {
      return _factories[T]!() as T;
    }
    return null;
  }

  /// Returns true if a service of type [T] is registered.
  static bool isRegistered<T extends Object>() {
    return _registry.containsKey(T) || _factories.containsKey(T);
  }

  /// Unregisters service of type [T].
  static void unregister<T extends Object>() {
    _registry.remove(T);
    _factories.remove(T);
  }

  /// Resets all registered singletons and factories (useful for test tear-downs).
  static void reset() {
    _registry.clear();
    _factories.clear();
  }
}
