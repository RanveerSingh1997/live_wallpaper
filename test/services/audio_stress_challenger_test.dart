// ignore: depend_on_referenced_packages
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/models/audio_spectrum_metrics.dart';
import 'package:live_wallpaper/models/audio_visualizer_config.dart';
import 'package:live_wallpaper/services/live_audio_capture_service.dart';
import 'package:live_wallpaper/services/silence_detection_watchdog.dart';
import 'package:live_wallpaper/services/simulated_audio_capture_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('M1 Challenger Stress Tests — Audio Stream Lifecycles & Watchdog', () {
    // -------------------------------------------------------------------------
    // 1. Rapid start/stop/pause/resume cycling & Stream lifecycle
    // -------------------------------------------------------------------------
    group('1. Rapid start/stop/pause/resume cycling', () {
      test('1.1 SimulatedAudioCaptureService handles 100 rapid sequential cycles', () async {
        final service = SimulatedAudioCaptureService();
        final received = <AudioSpectrumMetrics>[];
        final sub = service.spectrumStream.listen(received.add);

        for (int i = 0; i < 100; i++) {
          await service.start();
          expect(service.isRunning, isTrue);
          await service.pause();
          expect(service.isPaused, isTrue);
          await service.resume();
          expect(service.isPaused, isFalse);
          await service.stop();
          expect(service.isRunning, isFalse);
        }

        await sub.cancel();
        await service.dispose();
      });

      test('1.2 SimulatedAudioCaptureService starts cleanly and stops cleanly multiple times', () async {
        final service = SimulatedAudioCaptureService();
        for (int i = 0; i < 10; i++) {
          await service.start();
          expect(service.isRunning, isTrue);
          service.stepFrame();
          await service.stop();
          expect(service.isRunning, isFalse);
        }
        await service.dispose();
      });

      test('1.3 SimulatedAudioCaptureService: start() after dispose() leak test', () async {
        final service = SimulatedAudioCaptureService();
        await service.dispose();

        // Calling start on a disposed service
        await service.start();

        // If it starts running on a disposed service, it has created a rogue timer!
        final wasRogueStarted = service.isRunning;

        // Clean up rogue timer if created
        await service.stop();

        // Expectation: A disposed service MUST NOT restart or create rogue timers.
        expect(
          wasRogueStarted,
          isFalse,
          reason: 'Calling start() after dispose() must not revive the service or run timers',
        );
      });

      test('1.4 LiveAudioCaptureService rapid start/stop with simulated fallback', () async {
        final fallback = SimulatedAudioCaptureService();
        final liveService = LiveAudioCaptureService(
          fallbackService: fallback,
          simulatePermissionDenied: true,
        );

        final received = <AudioSpectrumMetrics>[];
        final sub = liveService.spectrumStream.listen(received.add);

        for (int i = 0; i < 30; i++) {
          await liveService.start();
          expect(liveService.isRunning, isTrue);
          expect(liveService.isFallbackActive, isTrue);

          await liveService.pause();
          expect(liveService.isPaused, isTrue);

          await liveService.resume();
          expect(liveService.isPaused, isFalse);

          await liveService.stop();
          expect(liveService.isRunning, isFalse);
        }

        await sub.cancel();
        await liveService.dispose();
      });

      test('1.5 SimulatedAudioCaptureService dynamic preset switching during active stream', () async {
        final service = SimulatedAudioCaptureService();
        await service.start();

        const presets = [
          SimulatedAudioPreset.technoBeat,
          SimulatedAudioPreset.ambientCosmic,
          SimulatedAudioPreset.melodicFlow,
          SimulatedAudioPreset.silence,
        ];

        for (int i = 0; i < 40; i++) {
          service.preset = presets[i % presets.length];
          final metrics = service.stepFrame();
          expect(metrics.bass, inInclusiveRange(0.0, 1.0));
          expect(metrics.mid, inInclusiveRange(0.0, 1.0));
          expect(metrics.treble, inInclusiveRange(0.0, 1.0));
          expect(metrics.overallAmplitude, inInclusiveRange(0.0, 1.0));
        }

        await service.stop();
        await service.dispose();
      });

      test('1.6 Dynamic config update during active stream processing', () async {
        final service = SimulatedAudioCaptureService();
        await service.start();

        for (int i = 0; i < 50; i++) {
          service.updateConfig(AudioVisualizerConfig(
            sensitivity: 0.5 + (i * 0.05),
            smoothingFactor: (i % 10) * 0.09,
          ));
          final m = service.stepFrame();
          expect(m.bass.isNaN, isFalse);
          expect(m.mid.isNaN, isFalse);
          expect(m.treble.isNaN, isFalse);
        }

        await service.stop();
        await service.dispose();
      });

      test('1.7 LiveAudioCaptureService dispose() while running stops capture cleanly', () async {
        final fallback = SimulatedAudioCaptureService();
        final service = LiveAudioCaptureService(
          fallbackService: fallback,
          simulatePermissionDenied: true,
        );

        await service.start();
        expect(service.isRunning, isTrue);
        expect(fallback.isRunning, isTrue);

        // Disposing while running must halt underlying capture
        await service.dispose();
        expect(service.isRunning, isFalse);
        expect(fallback.isRunning, isFalse);
      });
    });

    // -------------------------------------------------------------------------
    // 2. Silence threshold transitions: silence -> active -> silence -> loud burst
    // -------------------------------------------------------------------------
    group('2. Silence threshold transitions & hysteresis', () {
      test('2.1 Lifecycle: silence -> active -> silence -> loud burst transitions cleanly', () {
        final haltEvents = <int>[];
        final wakeupEvents = <int>[];
        final silenceEvents = <bool>[];

        final watchdog = SilenceDetectionWatchdog(
          silenceThreshold: 0.015,
          wakeupThreshold: 0.025,
          silenceTimeout: const Duration(seconds: 3),
          onHaltRequested: () => haltEvents.add(1),
          onWakeupRequested: () => wakeupEvents.add(1),
          onSilenceChanged: silenceEvents.add,
        );

        // Step 1: Continuous silence for 3.1s -> triggers halt
        watchdog.processFrame(rawRms: 0.005, elapsed: const Duration(milliseconds: 3100));
        expect(watchdog.isHalted, isTrue);
        expect(watchdog.isSilent, isTrue);
        expect(haltEvents.length, 1);
        expect(silenceEvents.last, isTrue);

        // Step 2: Transition to active sound (> wakeupThreshold)
        watchdog.processFrame(rawRms: 0.150, elapsed: const Duration(milliseconds: 16));
        expect(watchdog.isHalted, isFalse);
        expect(watchdog.isSilent, isFalse);
        expect(wakeupEvents.length, 1);
        expect(silenceEvents.last, isFalse);
        expect(watchdog.continuousSilenceDuration, equals(Duration.zero));

        // Step 3: Transition back to silence for 3.1s -> halts again
        watchdog.processFrame(rawRms: 0.008, elapsed: const Duration(milliseconds: 3100));
        expect(watchdog.isHalted, isTrue);
        expect(watchdog.isSilent, isTrue);
        expect(haltEvents.length, 2);
        expect(silenceEvents.last, isTrue);

        // Step 4: Loud burst transition (> 0.8 RMS)
        watchdog.processFrame(rawRms: 0.850, elapsed: const Duration(milliseconds: 16));
        expect(watchdog.isHalted, isFalse);
        expect(watchdog.isSilent, isFalse);
        expect(wakeupEvents.length, 2);
        expect(silenceEvents.last, isFalse);
      });

      test('2.2 Interrupted silence: audible sound in deadband [0.015, 0.025] resets silence duration', () {
        final watchdog = SilenceDetectionWatchdog(
          silenceThreshold: 0.015,
          wakeupThreshold: 0.025,
          silenceTimeout: const Duration(seconds: 3),
        );

        // Initial 2.5s silence
        watchdog.processFrame(rawRms: 0.005, elapsed: const Duration(milliseconds: 2500));
        expect(watchdog.isHalted, isFalse);
        expect(watchdog.continuousSilenceDuration, equals(const Duration(milliseconds: 2500)));

        // Now 10 seconds of audible sound at RMS 0.020 (ABOVE silenceThreshold 0.015, so NOT silence!)
        watchdog.processFrame(rawRms: 0.020, elapsed: const Duration(seconds: 10));

        // Since music was playing above silenceThreshold, the silence was broken!
        // A subsequent 0.6s silence MUST NOT cause the watchdog to halt!
        watchdog.processFrame(rawRms: 0.005, elapsed: const Duration(milliseconds: 600));

        expect(
          watchdog.isHalted,
          isFalse,
          reason: 'Watchdog must NOT halt after 0.6s silence when separated by 10s of non-silent sound',
        );
      });

      test('2.3 evaluateMetrics preserves frame silence before watchdog timeout', () {
        final watchdog = SilenceDetectionWatchdog(
          silenceThreshold: 0.015,
          wakeupThreshold: 0.025,
          silenceTimeout: const Duration(seconds: 3),
        );

        const silentFrame = AudioSpectrumMetrics(
          bass: 0.0,
          mid: 0.0,
          treble: 0.0,
          overallAmplitude: 0.0,
          isSilent: true,
        );

        // After 1 second of silence (watchdog has not timed out yet)
        final evaluated = watchdog.evaluateMetrics(silentFrame, const Duration(seconds: 1));

        expect(
          evaluated.isSilent,
          isTrue,
          reason: 'A completely silent frame (0 amplitude) should have isSilent: true even before watchdog 3s timeout',
        );
      });

      test('2.4 Watchdog hysteresis dead-band rejects noise floor when halted', () {
        final watchdog = SilenceDetectionWatchdog(
          silenceThreshold: 0.015,
          wakeupThreshold: 0.025,
          silenceTimeout: const Duration(seconds: 3),
        );

        // Force halt with 4s silence
        watchdog.processFrame(rawRms: 0.001, elapsed: const Duration(seconds: 4));
        expect(watchdog.isHalted, isTrue);

        // Sub-threshold noise floor fluctuations (0.018 - 0.024) must NOT wake up
        for (double rms = 0.016; rms < 0.025; rms += 0.002) {
          final halted = watchdog.processFrame(rawRms: rms, elapsed: const Duration(milliseconds: 16));
          expect(halted, isTrue);
          expect(watchdog.isHalted, isTrue);
        }

        // Only above 0.025 wakes up
        watchdog.processFrame(rawRms: 0.026, elapsed: const Duration(milliseconds: 16));
        expect(watchdog.isHalted, isFalse);
      });
    });

    // -------------------------------------------------------------------------
    // 3. Zero CPU / Zero Active Timers (Zero Sleep Overhead Mandate)
    // -------------------------------------------------------------------------
    group('3. Zero CPU / Zero Active Timers (Zero Sleep Overhead Mandate)', () {
      test('3.1 SimulatedAudioCaptureService has ZERO active timers when stopped', () {
        fakeAsync((async) {
          final service = SimulatedAudioCaptureService();
          service.start();
          async.elapse(const Duration(milliseconds: 50));

          expect(service.isRunning, isTrue);

          service.stop();
          expect(service.isRunning, isFalse);

          // Mandate check: When stopped, there must be ZERO pending timers!
          expect(
            async.pendingTimers.length,
            equals(0),
            reason: 'Zero Sleep Overhead: No active timers must remain when stopped',
          );

          service.dispose();
        });
      });

      test('3.2 SimulatedAudioCaptureService has ZERO active timers when paused', () {
        fakeAsync((async) {
          final service = SimulatedAudioCaptureService();
          service.start();
          async.elapse(const Duration(milliseconds: 50));

          expect(service.isRunning, isTrue);

          service.pause();
          expect(service.isPaused, isTrue);

          // Mandate check: When paused, there must be ZERO active timers!
          // A running timer waking up every 16ms violates Zero Sleep Overhead.
          expect(
            async.pendingTimers.length,
            equals(0),
            reason: 'Zero Sleep Overhead: No active timers must remain ticking when paused',
          );

          service.resume();
          expect(service.isPaused, isFalse);

          service.stop();
          service.dispose();
        });
      });

      test('3.3 SimulatedAudioCaptureService emits NO frames and advances NO frameIndex when paused', () {
        fakeAsync((async) {
          final service = SimulatedAudioCaptureService();
          final received = <AudioSpectrumMetrics>[];
          final sub = service.spectrumStream.listen(received.add);

          service.start();
          async.elapse(const Duration(milliseconds: 80)); // ~5 frames
          final frameCountBeforePause = received.length;
          expect(frameCountBeforePause, greaterThan(0));

          service.pause();
          final frameIndexAtPause = service.frameIndex;

          // Advance virtual time by 500ms while paused
          async.elapse(const Duration(milliseconds: 500));

          expect(
            received.length,
            equals(frameCountBeforePause),
            reason: 'Zero frames should be emitted while paused',
          );
          expect(
            service.frameIndex,
            equals(frameIndexAtPause),
            reason: 'frameIndex must not advance while paused',
          );

          service.resume();
          async.elapse(const Duration(milliseconds: 80));
          expect(received.length, greaterThan(frameCountBeforePause));

          sub.cancel();
          service.stop();
          service.dispose();
        });
      });

      test('3.4 Watchdog halts processing and zeroes metrics when silence detected', () async {
        bool haltSignalSent = false;
        final watchdog = SilenceDetectionWatchdog(
          silenceTimeout: const Duration(seconds: 3),
          silenceThreshold: 0.015,
          onHaltRequested: () => haltSignalSent = true,
        );

        final service = SimulatedAudioCaptureService(
          initialPreset: SimulatedAudioPreset.silence,
        );

        // Process frames through watchdog
        for (int i = 0; i < 200; i++) {
          final metrics = service.stepFrame();
          final evaluated = watchdog.evaluateMetrics(
            metrics,
            const Duration(milliseconds: 16),
          );
          if (watchdog.isHalted) {
            expect(evaluated.bass, equals(0.0));
            expect(evaluated.mid, equals(0.0));
            expect(evaluated.treble, equals(0.0));
            expect(evaluated.overallAmplitude, equals(0.0));
            expect(evaluated.isSilent, isTrue);
          }
        }

        expect(haltSignalSent, isTrue);
        expect(watchdog.isHalted, isTrue);

        await service.dispose();
      });

      test('3.5 LiveAudioCaptureService in fallback mode has ZERO active timers when paused', () {
        fakeAsync((async) {
          final liveService = LiveAudioCaptureService(simulatePermissionDenied: true);
          liveService.start();
          async.elapse(const Duration(milliseconds: 50));
          expect(liveService.isRunning, isTrue);
          expect(liveService.isFallbackActive, isTrue);

          liveService.pause();
          expect(liveService.isPaused, isTrue);

          // Mandate check: When paused, there must be ZERO active timers!
          expect(
            async.pendingTimers.length,
            equals(0),
            reason: 'Zero Sleep Overhead: Fallback service periodic timer must not tick when live service is paused',
          );

          liveService.resume();
          liveService.stop();
          liveService.dispose();
        });
      });
    });
  });
}
