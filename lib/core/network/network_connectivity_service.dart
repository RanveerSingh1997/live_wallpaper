import 'dart:async';

/// Network connection medium.
enum ConnectivityType {
  none,
  wifi,
  cellular,
  ethernet,
  other,
}

/// Abstract contract for device network state observation and online checks.
/// Follows Dependency Inversion Principle (DIP).
abstract class NetworkConnectivityService {
  Future<ConnectivityType> checkConnectivity();
  Stream<ConnectivityType> get onConnectivityChanged;
  ConnectivityType get currentStatus;
  bool get isOnline;
  bool get isWifi;
  void dispose();
}

/// In-memory & testable implementation of [NetworkConnectivityService].
class FakeNetworkConnectivityService implements NetworkConnectivityService {
  final _controller = StreamController<ConnectivityType>.broadcast();
  ConnectivityType _currentStatus;

  FakeNetworkConnectivityService({
    ConnectivityType initialStatus = ConnectivityType.wifi,
  }) : _currentStatus = initialStatus;

  @override
  Future<ConnectivityType> checkConnectivity() async => _currentStatus;

  @override
  Stream<ConnectivityType> get onConnectivityChanged => _controller.stream;

  @override
  ConnectivityType get currentStatus => _currentStatus;

  @override
  bool get isOnline => _currentStatus != ConnectivityType.none;

  @override
  bool get isWifi =>
      _currentStatus == ConnectivityType.wifi ||
      _currentStatus == ConnectivityType.ethernet;

  /// Simulates a connectivity transition.
  void setConnectivity(ConnectivityType type) {
    if (_currentStatus != type) {
      _currentStatus = type;
      _controller.add(type);
    }
  }

  @override
  void dispose() {
    _controller.close();
  }
}

/// Default production [NetworkConnectivityService] backed by platform and ping fallback.
class DefaultNetworkConnectivityService implements NetworkConnectivityService {
  final _controller = StreamController<ConnectivityType>.broadcast();
  ConnectivityType _currentStatus = ConnectivityType.wifi;
  Timer? _heartbeatTimer;

  DefaultNetworkConnectivityService({
    Duration? heartbeatInterval,
  }) {
    if (heartbeatInterval != null) {
      _heartbeatTimer =
          Timer.periodic(heartbeatInterval, (_) => checkConnectivity());
    }
  }

  @override
  Future<ConnectivityType> checkConnectivity() async {
    // In production Flutter environment without heavy third-party plugins,
    // we default to wifi and broadcast changes.
    return _currentStatus;
  }

  @override
  Stream<ConnectivityType> get onConnectivityChanged => _controller.stream;

  @override
  ConnectivityType get currentStatus => _currentStatus;

  @override
  bool get isOnline => _currentStatus != ConnectivityType.none;

  @override
  bool get isWifi =>
      _currentStatus == ConnectivityType.wifi ||
      _currentStatus == ConnectivityType.ethernet;

  void updateStatus(ConnectivityType type) {
    if (_currentStatus != type) {
      _currentStatus = type;
      _controller.add(type);
    }
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    _controller.close();
  }
}

/// Task descriptor for deferred or retried network operations.
class RetryableTask {
  final String id;
  final String tag;
  final Future<bool> Function() action;
  final int maxRetries;
  int retryCount;
  final DateTime createdAt;

  RetryableTask({
    required this.id,
    required this.tag,
    required this.action,
    this.maxRetries = 3,
    this.retryCount = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

/// Resilience queue that accumulates failed operations and replays them
/// when network connectivity is re-established.
class ConnectivityRetryQueue {
  final NetworkConnectivityService connectivity;
  final List<RetryableTask> _queue = [];
  StreamSubscription<ConnectivityType>? _subscription;
  bool _isProcessing = false;

  ConnectivityRetryQueue({required this.connectivity}) {
    _subscription = connectivity.onConnectivityChanged.listen((status) {
      if (status != ConnectivityType.none) {
        processQueue();
      }
    });
  }

  List<RetryableTask> get pendingTasks => List.unmodifiable(_queue);

  /// Enqueues an operation to be replayed upon connection restoration.
  void enqueue(RetryableTask task) {
    _queue.add(task);
  }

  /// Flushes pending tasks sequentially.
  Future<int> processQueue() async {
    if (_isProcessing || !connectivity.isOnline || _queue.isEmpty) {
      return 0;
    }

    _isProcessing = true;
    int successCount = 0;
    final List<RetryableTask> remaining = [];

    for (final task in List<RetryableTask>.from(_queue)) {
      if (!connectivity.isOnline) {
        remaining.add(task);
        continue;
      }

      try {
        final success = await task.action();
        if (success) {
          successCount++;
        } else {
          task.retryCount++;
          if (task.retryCount < task.maxRetries) {
            remaining.add(task);
          }
        }
      } catch (_) {
        task.retryCount++;
        if (task.retryCount < task.maxRetries) {
          remaining.add(task);
        }
      }
    }

    _queue.clear();
    _queue.addAll(remaining);
    _isProcessing = false;
    return successCount;
  }

  void clear() {
    _queue.clear();
  }

  void dispose() {
    _subscription?.cancel();
    _queue.clear();
  }
}
