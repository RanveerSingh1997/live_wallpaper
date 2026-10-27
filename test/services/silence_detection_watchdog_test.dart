import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/models/audio_spectrum_metrics.dart';
import 'package:live_wallpaper/services/silence_detection_watchdog.dart';

void main() {
  group('SilenceDetectionWatchdog Unit Tests', () {
    late SilenceDetectionWatchdog watchdog;
    bool haltCalled = false;
    bool wakeupCalled = false;
    bool? lastSilenceChanged;

    setUp(() {
      haltCalled = false;
      wakeupCalled = false;
      lastSilenceChanged = null;

      watchdog = SilenceDetectionWatchdog(
        silenceThreshold: 0.015,
        wakeupThreshold: 0.025,
        silenceTimeout: const Duration(seconds: 3),
        isEnabled: true,
        onHaltRequested: () => haltCalled = true,
        onWakeupRequested: () => wakeupCalled = true,
        onSilenceChanged: (silent) => lastSilenceChanged = silent,
      );
    });

    test('1. Initial state is active and non-silent', () {
      expect(watchdog.isSilent, isFalse);
      expect(watchdog.isHalted, isFalse);
      expect(watchdog.continuousSilenceDuration, equals(Duration.zero));
    });

    test('2. Silence below 3.0s threshold does not halt', () {
      watchdog.processFrame(rawRms: 0.010, elapsed: const Duration(seconds: 1));
      expect(watchdog.isHalted, isFalse);
      expect(haltCalled, isFalse);

      watchdog.processFrame(rawRms: 0.010, elapsed: const Duration(milliseconds: 1900));
      expect(watchdog.isHalted, isFalse);
      expect(haltCalled, isFalse);
      expect(watchdog.continuousSilenceDuration, equals(const Duration(milliseconds: 2900)));
    });

    test('3. Continuous silence exceeding 3.0s halts and emits callbacks', () {
      watchdog.processFrame(rawRms: 0.010, elapsed: const Duration(milliseconds: 3100));

      expect(watchdog.isHalted, isTrue);
      expect(watchdog.isSilent, isTrue);
      expect(haltCalled, isTrue);
      expect(lastSilenceChanged, isTrue);
    });

    test('4. Sound pulse resets silence accumulator', () {
      watchdog.processFrame(rawRms: 0.010, elapsed: const Duration(milliseconds: 2500));
      expect(watchdog.continuousSilenceDuration, equals(const Duration(milliseconds: 2500)));

      // Audio pulse above wakeup threshold
      watchdog.processFrame(rawRms: 0.050, elapsed: const Duration(milliseconds: 16));
      expect(watchdog.continuousSilenceDuration, equals(Duration.zero));
      expect(watchdog.isHalted, isFalse);

      // Another 1 second of silence
      watchdog.processFrame(rawRms: 0.010, elapsed: const Duration(seconds: 1));
      expect(watchdog.isHalted, isFalse);
    });

    test('5. Hysteresis prevents flickering near silence threshold', () {
      // Force halt
      watchdog.processFrame(rawRms: 0.010, elapsed: const Duration(seconds: 4));
      expect(watchdog.isHalted, isTrue);

      // Sound in hysteresis zone: 0.020 (between 0.015 and 0.025)
      watchdog.processFrame(rawRms: 0.020, elapsed: const Duration(milliseconds: 16));
      expect(watchdog.isHalted, isTrue); // Must remain halted
      expect(wakeupCalled, isFalse);

      // Sound above wakeup threshold: 0.030 (> 0.025)
      watchdog.processFrame(rawRms: 0.030, elapsed: const Duration(milliseconds: 16));
      expect(watchdog.isHalted, isFalse); // Wakes up immediately
      expect(watchdog.isSilent, isFalse);
      expect(wakeupCalled, isTrue);
      expect(lastSilenceChanged, isFalse);
    });

    test('6. evaluateMetrics zeros out data when halted', () {
      const activeMetrics = AudioSpectrumMetrics(
        bass: 0.8,
        mid: 0.6,
        treble: 0.4,
        overallAmplitude: 0.7,
        peakDetected: true,
        isSilent: false,
      );

      final resultActive = watchdog.evaluateMetrics(activeMetrics, const Duration(milliseconds: 16));
      expect(resultActive.isSilent, isFalse);
      expect(resultActive.bass, equals(0.8));

      // Force into halted state
      watchdog.processFrame(rawRms: 0.005, elapsed: const Duration(seconds: 4));
      expect(watchdog.isHalted, isTrue);

      const quietMetrics = AudioSpectrumMetrics(
        bass: 0.01,
        mid: 0.01,
        treble: 0.01,
        overallAmplitude: 0.005,
        peakDetected: false,
        isSilent: true,
      );

      final resultHalted = watchdog.evaluateMetrics(quietMetrics, const Duration(milliseconds: 16));
      expect(resultHalted.isSilent, isTrue);
      expect(resultHalted.bass, equals(0.0));
      expect(resultHalted.mid, equals(0.0));
      expect(resultHalted.treble, equals(0.0));
      expect(resultHalted.overallAmplitude, equals(0.0));
      expect(resultHalted.peakDetected, isFalse);
    });

    test('7. reset() returns watchdog to clean initial state', () {
      watchdog.processFrame(rawRms: 0.005, elapsed: const Duration(seconds: 5));
      expect(watchdog.isHalted, isTrue);

      watchdog.reset();
      expect(watchdog.isHalted, isFalse);
      expect(watchdog.isSilent, isFalse);
      expect(watchdog.continuousSilenceDuration, equals(Duration.zero));
    });

    test('8. isEnabled = false bypasses halting', () {
      watchdog.isEnabled = false;
      watchdog.processFrame(rawRms: 0.001, elapsed: const Duration(seconds: 10));

      expect(watchdog.isHalted, isFalse);
      expect(watchdog.isSilent, isFalse);
    });

    test('9. updateConfig updates parameters dynamically', () {
      watchdog.updateConfig(
        silenceTimeout: const Duration(seconds: 1),
        silenceThreshold: 0.010,
        wakeupThreshold: 0.020,
      );

      expect(watchdog.silenceTimeout, equals(const Duration(seconds: 1)));
      expect(watchdog.silenceThreshold, equals(0.010));
      expect(watchdog.wakeupThreshold, equals(0.020));

      watchdog.processFrame(rawRms: 0.005, elapsed: const Duration(milliseconds: 1100));
      expect(watchdog.isHalted, isTrue);
    });
  });
}
