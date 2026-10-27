import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/models/audio_visualizer_config.dart';
import 'package:live_wallpaper/services/audio_fft_engine.dart';

void main() {
  group('AudioFftEngine Unit Tests', () {
    late AudioFftEngine engine;

    setUp(() {
      engine = AudioFftEngine();
    });

    Float32List generateSine({
      required double freq,
      double amplitude = 1.0,
      double sampleRate = 44100.0,
      int count = 512,
    }) {
      final buffer = Float32List(count);
      for (int i = 0; i < count; i++) {
        final t = i / sampleRate;
        buffer[i] = amplitude * math.sin(2.0 * math.pi * freq * t);
      }
      return buffer;
    }

    test('1. Frequency band bin boundaries are calculated accurately', () {
      // Bin 0 (0 Hz DC offset) is excluded, bass begins at bin 1
      expect(engine.bassStartBin, equals(1));
      expect(engine.bassEndBin, equals(2));
      expect(engine.midStartBin, equals(3));
      expect(engine.midEndBin, equals(46));
      expect(engine.trebleStartBin, equals(47));
      expect(engine.trebleEndBin, equals(232));
    });

    test('2. 100 Hz pure sine wave yields dominant Bass energy (>0.70)', () {
      final samples = generateSine(freq: 100.0);
      const config = AudioVisualizerConfig.defaultConfig;

      // Process 3 frames to allow smoothing to settle
      var metrics = engine.process(samples: samples, config: config);
      metrics = engine.process(samples: samples, config: config);
      metrics = engine.process(samples: samples, config: config);

      expect(metrics.bass, greaterThan(0.70));
      expect(metrics.mid, lessThan(0.20));
      expect(metrics.treble, lessThan(0.05));
      expect(metrics.isSilent, isFalse);
    });

    test('3. 1,000 Hz pure sine wave yields dominant Mid energy (>0.70)', () {
      final samples = generateSine(freq: 1000.0);
      const config = AudioVisualizerConfig.defaultConfig;

      var metrics = engine.process(samples: samples, config: config);
      metrics = engine.process(samples: samples, config: config);
      metrics = engine.process(samples: samples, config: config);

      expect(metrics.mid, greaterThan(0.70));
      expect(metrics.bass, lessThan(0.20));
      expect(metrics.treble, lessThan(0.05));
      expect(metrics.isSilent, isFalse);
    });

    test('4. 10,000 Hz pure sine wave yields dominant Treble energy (>0.70)', () {
      final samples = generateSine(freq: 10000.0);
      const config = AudioVisualizerConfig.defaultConfig;

      var metrics = engine.process(samples: samples, config: config);
      metrics = engine.process(samples: samples, config: config);
      metrics = engine.process(samples: samples, config: config);

      expect(metrics.treble, greaterThan(0.70));
      expect(metrics.bass, lessThan(0.10));
      expect(metrics.mid, lessThan(0.10));
      expect(metrics.isSilent, isFalse);
    });

    test('5. Digital silence yields isSilent true and zero energy', () {
      final silentSamples = Float32List(512);
      const config = AudioVisualizerConfig.defaultConfig;

      final metrics = engine.process(samples: silentSamples, config: config);
      expect(metrics.isSilent, isTrue);
      expect(metrics.overallAmplitude, equals(0.0));
      expect(metrics.peakDetected, isFalse);
    });

    test('6. Audio below silence threshold triggers isSilent true', () {
      final quietSamples = generateSine(freq: 440.0, amplitude: 0.005);
      const config = AudioVisualizerConfig(silenceThreshold: 0.015);

      final metrics = engine.process(samples: quietSamples, config: config);
      expect(metrics.isSilent, isTrue);
    });

    test('7. Sensitivity setting scales frequency bands proportionally', () {
      final samples = generateSine(freq: 1000.0, amplitude: 0.3);

      final engineLow = AudioFftEngine();
      final engineHigh = AudioFftEngine();

      const configLow = AudioVisualizerConfig(sensitivity: 0.5);
      const configHigh = AudioVisualizerConfig(sensitivity: 2.0);

      var mLow = engineLow.process(samples: samples, config: configLow);
      var mHigh = engineHigh.process(samples: samples, config: configHigh);

      mLow = engineLow.process(samples: samples, config: configLow);
      mHigh = engineHigh.process(samples: samples, config: configHigh);

      expect(mHigh.mid, greaterThan(mLow.mid));
    });

    test('8. Frequency focus modes bias respective band outputs', () {
      // Mixed signal with equal components
      final mixed = Float32List(512);
      for (int i = 0; i < 512; i++) {
        final t = i / 44100.0;
        mixed[i] = (math.sin(2 * math.pi * 100 * t) +
                math.sin(2 * math.pi * 1000 * t) +
                math.sin(2 * math.pi * 10000 * t)) /
            3.0;
      }

      final engineBass = AudioFftEngine();
      final engineMid = AudioFftEngine();
      final engineTreble = AudioFftEngine();

      const confBass = AudioVisualizerConfig(frequencyFocus: AudioFrequencyFocus.bassCentric);
      const confMid = AudioVisualizerConfig(frequencyFocus: AudioFrequencyFocus.midVocal);
      const confTreble = AudioVisualizerConfig(frequencyFocus: AudioFrequencyFocus.trebleShimmer);

      final mBass = engineBass.process(samples: mixed, config: confBass);
      final mMid = engineMid.process(samples: mixed, config: confMid);
      final mTreble = engineTreble.process(samples: mixed, config: confTreble);

      expect(mBass.bass, greaterThan(mMid.bass));
      expect(mMid.mid, greaterThan(mBass.mid));
      expect(mTreble.treble, greaterThan(mMid.treble));
    });

    test('9. Transient peak detection activates on sudden volume spikes', () {
      final quiet = generateSine(freq: 100.0, amplitude: 0.02);
      final loud = generateSine(freq: 100.0, amplitude: 0.95);
      const config = AudioVisualizerConfig.defaultConfig;

      // Prime engine with quiet sound
      engine.process(samples: quiet, config: config);
      engine.process(samples: quiet, config: config);

      // Sudden explosion
      final spikeMetrics = engine.process(samples: loud, config: config);
      expect(spikeMetrics.peakDetected, isTrue);
    });

    test('10. reset() clears internal smoothed state and envelope', () {
      final loud = generateSine(freq: 500.0, amplitude: 0.9);
      engine.process(samples: loud, config: AudioVisualizerConfig.defaultConfig);

      expect(engine.smoothedMid, greaterThan(0.0));
      engine.reset();

      expect(engine.smoothedBass, equals(0.0));
      expect(engine.smoothedMid, equals(0.0));
      expect(engine.smoothedTreble, equals(0.0));
      expect(engine.smoothedOverall, equals(0.0));
      expect(engine.peakEnvelope, equals(0.1));
    });

    test('11. processSamples accepts generic List<double>', () {
      final list = List.generate(512, (i) => math.sin(2 * math.pi * 440 * (i / 44100.0)));
      final metrics = engine.processSamples(list);

      expect(metrics.mid, greaterThan(0.5));
      expect(metrics.isSilent, isFalse);
    });

    test('12. High-throughput performance execution benchmark (< 0.2 ms)', () {
      final samples = generateSine(freq: 440.0);
      const config = AudioVisualizerConfig.defaultConfig;

      // Warmup
      for (int i = 0; i < 50; i++) {
        engine.process(samples: samples, config: config);
      }

      final stopwatch = Stopwatch()..start();
      const iterations = 500;
      for (int i = 0; i < iterations; i++) {
        engine.process(samples: samples, config: config);
      }
      stopwatch.stop();

      final avgMsPerFft = stopwatch.elapsedMicroseconds / (iterations * 1000.0);
      expect(avgMsPerFft, lessThan(0.20)); // Requirement is < 0.2 ms
    });
  });
}
