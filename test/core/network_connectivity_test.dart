import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/core/network/network.dart';

void main() {
  group('NetworkConnectivityService & ConnectivityRetryQueue Tests', () {
    late FakeNetworkConnectivityService connectivity;
    late ConnectivityRetryQueue retryQueue;

    setUp(() {
      connectivity = FakeNetworkConnectivityService(
        initialStatus: ConnectivityType.wifi,
      );
      retryQueue = ConnectivityRetryQueue(connectivity: connectivity);
    });

    tearDown(() {
      retryQueue.dispose();
      connectivity.dispose();
    });

    test('Initializes with provided connectivity and flags', () async {
      expect(connectivity.isOnline, isTrue);
      expect(connectivity.isWifi, isTrue);
      expect(connectivity.currentStatus, ConnectivityType.wifi);
      expect(await connectivity.checkConnectivity(), ConnectivityType.wifi);
    });

    test('Transitions connectivity state and emits stream events', () async {
      final emitted = <ConnectivityType>[];
      final subscription = connectivity.onConnectivityChanged.listen(emitted.add);

      connectivity.setConnectivity(ConnectivityType.cellular);
      expect(connectivity.isOnline, isTrue);
      expect(connectivity.isWifi, isFalse);

      connectivity.setConnectivity(ConnectivityType.none);
      expect(connectivity.isOnline, isFalse);
      expect(connectivity.isWifi, isFalse);

      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(emitted, [ConnectivityType.cellular, ConnectivityType.none]);

      await subscription.cancel();
    });

    test('ConnectivityRetryQueue enqueues failed tasks and auto-flushes when back online', () async {
      connectivity.setConnectivity(ConnectivityType.none);
      expect(connectivity.isOnline, isFalse);

      int executionCount = 0;
      final task = RetryableTask(
        id: 'sync_setup_1',
        tag: 'cloud_sync',
        action: () async {
          executionCount++;
          return true;
        },
      );

      retryQueue.enqueue(task);
      expect(retryQueue.pendingTasks.length, 1);
      expect(executionCount, 0);

      // Attempt manual process while offline -> 0 successes, task remains queued
      final countWhileOffline = await retryQueue.processQueue();
      expect(countWhileOffline, 0);
      expect(retryQueue.pendingTasks.length, 1);
      expect(executionCount, 0);

      // Transition back online -> queue listener triggers auto-flush
      connectivity.setConnectivity(ConnectivityType.wifi);

      // Yield event loop
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(executionCount, 1);
      expect(retryQueue.pendingTasks, isEmpty);
    });

    test('RetryableTask increments retryCount on failure and stops after maxRetries', () async {
      connectivity.setConnectivity(ConnectivityType.wifi);

      int attempts = 0;
      final failingTask = RetryableTask(
        id: 'failing_action',
        tag: 'telemetry',
        maxRetries: 2,
        action: () async {
          attempts++;
          return false;
        },
      );

      retryQueue.enqueue(failingTask);

      // Run 1st attempt
      await retryQueue.processQueue();
      expect(attempts, 1);
      expect(failingTask.retryCount, 1);
      expect(retryQueue.pendingTasks.length, 1);

      // Run 2nd attempt -> reaches maxRetries and is evicted
      await retryQueue.processQueue();
      expect(attempts, 2);
      expect(failingTask.retryCount, 2);
      expect(retryQueue.pendingTasks, isEmpty);
    });
  });
}
