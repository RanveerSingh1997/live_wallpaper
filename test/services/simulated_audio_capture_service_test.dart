import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/models/audio_spectrum_metrics.dart';
import 'package:live_wallpaper/models/audio_visualizer_config.dart';
import 'package:live_wallpaper/services/simulated_audio_capture_service.dart';

void main() {
  group('SimulatedAudioCaptureService Unit Tests', () {
    late SimulatedAudioCaptureService service;

    setUp(() {
      service = SimulatedAudioCaptureService();
    });

    tearDown(() async {
      await service.dispose();
    });

    test('initial state is not running and not paused', () {
      expect(service.isRunning, isFalse);
      expect(service.isPaused, isFalse);
      expect(service.preset, equals(SimulatedAudioPreset.technoBeat));
      expect(service.frameIndex, equals(0));
    });

    test('lifecycle: start, pause, resume, stop work correctly', () async {
      expect(service.isRunning, isFalse);

      await service.start();
      expect(service.isRunning, isTrue);
      expect(service.isPaused, isFalse);

      // Idempotent start
      await service.start();
      expect(service.isRunning, isTrue);

      await service.pause();
      expect(service.isPaused, isTrue);
      expect(service.isRunning, isTrue);

      await service.resume();
      expect(service.isPaused, isFalse);

      await service.stop();
      expect(service.isRunning, isFalse);
      expect(service.isPaused, isFalse);
    });

    test('stepFrame ticks deterministically and emits to broadcast stream', () async {
      final received1 = <AudioSpectrumMetrics>[];
      final received2 = <AudioSpectrumMetrics>[];

      final sub1 = service.spectrumStream.listen(received1.add);
      final sub2 = service.spectrumStream.listen(received2.add);

      final m1 = service.stepFrame();
      final m2 = service.stepFrame();

      await Future<void>.delayed(Duration.zero);

      expect(service.frameIndex, equals(2));
      expect(received1.length, equals(2));
      expect(received2.length, equals(2));
      expect(received1[0], equals(m1));
      expect(received2[0], equals(m1));
      expect(received1[1], equals(m2));
      expect(received2[1], equals(m2));

      await sub1.cancel();
      await sub2.cancel();
    });

    test('100% determinism: two independent instances produce identical outputs', () {
      final serviceA = SimulatedAudioCaptureService(
        initialPreset: SimulatedAudioPreset.technoBeat,
      );
      final serviceB = SimulatedAudioCaptureService(
        initialPreset: SimulatedAudioPreset.technoBeat,
      );

      for (int i = 0; i < 50; i++) {
        final mA = serviceA.stepFrame();
        final mB = serviceB.stepFrame();
        expect(mA.bass, equals(mB.bass));
        expect(mA.mid, equals(mB.mid));
        expect(mA.treble, equals(mB.treble));
        expect(mA.overallAmplitude, equals(mB.overallAmplitude));
      }

      serviceA.dispose();
      serviceB.dispose();
    });

    test('technoBeat preset produces audible rhythmic signals', () {
      service.preset = SimulatedAudioPreset.technoBeat;
      double maxBass = 0.0;

      for (int i = 0; i < 60; i++) {
        final m = service.stepFrame();
        if (m.bass > maxBass) maxBass = m.bass;
      }

      expect(maxBass, greaterThan(0.5));
    });

    test('ambientCosmic preset produces high bass drone and treble shimmer', () {
      service.preset = SimulatedAudioPreset.ambientCosmic;
      double maxBass = 0.0;
      double maxTreble = 0.0;

      for (int i = 0; i < 60; i++) {
        final m = service.stepFrame();
        if (m.bass > maxBass) maxBass = m.bass;
        if (m.treble > maxTreble) maxTreble = m.treble;
      }

      expect(maxBass, greaterThan(0.4));
      expect(maxTreble, greaterThan(0.1));
    });

    test('melodicFlow preset produces active mid frequencies', () {
      service.preset = SimulatedAudioPreset.melodicFlow;
      double maxMid = 0.0;

      for (int i = 0; i < 60; i++) {
        final m = service.stepFrame();
        if (m.mid > maxMid) maxMid = m.mid;
      }

      expect(maxMid, greaterThan(0.3));
    });

    test('silence preset produces digital silence', () {
      service.preset = SimulatedAudioPreset.silence;

      for (int i = 0; i < 10; i++) {
        final m = service.stepFrame();
        expect(m.bass, equals(0.0));
        expect(m.mid, equals(0.0));
        expect(m.treble, equals(0.0));
        expect(m.overallAmplitude, equals(0.0));
        expect(m.isSilent, isTrue);
      }
    });

    test('updateConfig modifies sensitivity dynamically', () {
      service.preset = SimulatedAudioPreset.ambientCosmic;

      service.updateConfig(const AudioVisualizerConfig(sensitivity: 0.5));
      final mLow = service.stepFrame();

      service.updateConfig(const AudioVisualizerConfig(sensitivity: 2.0));
      final mHigh = service.stepFrame();

      expect(mHigh.bass, greaterThan(mLow.bass));
    });

    test('generateBuffer static helper produces valid List<double>', () {
      final buffer = SimulatedAudioCaptureService.generateBuffer(
        0,
        SimulatedAudioPreset.technoBeat,
      );
      expect(buffer.length, equals(512));
      for (final s in buffer) {
        expect(s.isNaN, isFalse);
        expect(s.isInfinite, isFalse);
        expect(s, inInclusiveRange(-1.0, 1.0));
      }
    });
  });
}
