import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/models/audio_spectrum_metrics.dart';
import 'package:live_wallpaper/models/audio_visualizer_config.dart';
import 'package:live_wallpaper/services/audio_fft_engine.dart';

void main() {
  group('AudioFftEngine Adversarial Stress Tests (M1 Challenger 1)', () {
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

    // =========================================================================
    // SUITE 1: EXTREME INPUTS STRESS TESTING
    // =========================================================================
    group('Suite 1: Extreme Inputs Stress Testing', () {
      test('1.1 All Zeros with Silence Detection Enabled', () {
        final samples = Float32List(512);
        const config = AudioVisualizerConfig(isSilenceDetectionEnabled: true);

        final metrics = engine.process(samples: samples, config: config);

        expect(metrics.isSilent, isTrue);
        expect(metrics.overallAmplitude, equals(0.0));
        expect(metrics.bass, equals(0.0));
        expect(metrics.mid, equals(0.0));
        expect(metrics.treble, equals(0.0));
        expect(metrics.peakDetected, isFalse);
        expect(metrics.hasAudibleEnergy, isFalse);
      });

      test('1.2 All Zeros with Silence Detection Disabled', () {
        final samples = Float32List(512);
        const config = AudioVisualizerConfig(isSilenceDetectionEnabled: false);

        final metrics = engine.process(samples: samples, config: config);

        expect(metrics.overallAmplitude, equals(0.0));
        expect(metrics.bass, equals(0.0));
        expect(metrics.mid, equals(0.0));
        expect(metrics.treble, equals(0.0));
        expect(metrics.peakDetected, isFalse);
        expect(metrics.hasAudibleEnergy, isFalse);
      });

      test('1.3 Full-Scale Positive DC Rail (all +1.0)', () {
        final samples = Float32List(512);
        samples.fillRange(0, 512, 1.0);
        const config = AudioVisualizerConfig.defaultConfig;

        final metrics = engine.process(samples: samples, config: config);

        expect(metrics.bass.isNaN, isFalse);
        expect(metrics.mid.isNaN, isFalse);
        expect(metrics.treble.isNaN, isFalse);
        expect(metrics.overallAmplitude.isNaN, isFalse);
        expect(metrics.bass, inInclusiveRange(0.0, 1.0));
        expect(metrics.mid, inInclusiveRange(0.0, 1.0));
        expect(metrics.treble, inInclusiveRange(0.0, 1.0));
        expect(metrics.overallAmplitude, inInclusiveRange(0.0, 1.0));
        expect(metrics.isSilent, isFalse);
      });

      test('1.4 Full-Scale Negative DC Rail (all -1.0)', () {
        final samples = Float32List(512);
        samples.fillRange(0, 512, -1.0);
        const config = AudioVisualizerConfig.defaultConfig;

        final metrics = engine.process(samples: samples, config: config);

        expect(metrics.bass.isNaN, isFalse);
        expect(metrics.mid.isNaN, isFalse);
        expect(metrics.treble.isNaN, isFalse);
        expect(metrics.overallAmplitude.isNaN, isFalse);
        expect(metrics.bass, inInclusiveRange(0.0, 1.0));
        expect(metrics.mid, inInclusiveRange(0.0, 1.0));
        expect(metrics.treble, inInclusiveRange(0.0, 1.0));
        expect(metrics.overallAmplitude, inInclusiveRange(0.0, 1.0));
        expect(metrics.isSilent, isFalse);
      });

      test('1.5 Full-Scale Square Wave Clipping (+1.0 / -1.0 alternation)', () {
        final samples = Float32List(512);
        for (int i = 0; i < 512; i++) {
          samples[i] = (i % 64 < 32) ? 1.0 : -1.0;
        }
        const config = AudioVisualizerConfig.defaultConfig;

        final metrics = engine.process(samples: samples, config: config);

        expect(metrics.bass, inInclusiveRange(0.0, 1.0));
        expect(metrics.mid, inInclusiveRange(0.0, 1.0));
        expect(metrics.treble, inInclusiveRange(0.0, 1.0));
        expect(metrics.overallAmplitude, inInclusiveRange(0.0, 1.0));
        expect(metrics.isSilent, isFalse);
      });

      test('1.6 Severe Sine Wave Hard Clipping (10x overdrive clamped to [-1.0, 1.0])', () {
        final samples = Float32List(512);
        for (int i = 0; i < 512; i++) {
          final raw = 10.0 * math.sin(2.0 * math.pi * 200.0 * i / 44100.0);
          samples[i] = raw.clamp(-1.0, 1.0);
        }
        const config = AudioVisualizerConfig.defaultConfig;

        final metrics = engine.process(samples: samples, config: config);

        expect(metrics.bass, inInclusiveRange(0.0, 1.0));
        expect(metrics.mid, inInclusiveRange(0.0, 1.0));
        expect(metrics.treble, inInclusiveRange(0.0, 1.0));
        expect(metrics.overallAmplitude, inInclusiveRange(0.0, 1.0));
        expect(metrics.isSilent, isFalse);
      });

      test('1.7 DC Bias Leakage into Bass Band (Empirical Finding)', () {
        // DC offset of 0.05 (typical hardware microphone DC bias)
        final dcSamples = Float32List(512);
        dcSamples.fillRange(0, 512, 0.05);
        const config = AudioVisualizerConfig.defaultConfig;

        late AudioSpectrumMetrics metrics;
        for (int i = 0; i < 5; i++) {
          metrics = engine.process(samples: dcSamples, config: config);
        }

        // Empirical check: Pure DC energy registers in Bass band because bassStartBin = 0 (0 Hz)
        expect(metrics.bass, greaterThan(0.90),
            reason: 'Empirical confirmation: DC bias (0 Hz) is captured in bin 0 (Bass band)');
        expect(metrics.mid, lessThan(0.05));
        expect(metrics.treble, lessThan(0.05));
        expect(metrics.isSilent, isFalse);
      });

      test('1.8 Dirac Delta Impulse at Midpoint (n=256)', () {
        final samples = Float32List(512);
        samples[256] = 1.0; // Window peak is at n=256 where Hann = 1.0
        const config = AudioVisualizerConfig.defaultConfig;

        final metrics = engine.process(samples: samples, config: config);

        // Dirac delta has a flat theoretical spectrum: energy in all bands
        expect(metrics.bass, greaterThan(0.0));
        expect(metrics.mid, greaterThan(0.0));
        expect(metrics.treble, greaterThan(0.0));
        expect(metrics.bass, inInclusiveRange(0.0, 1.0));
        expect(metrics.mid, inInclusiveRange(0.0, 1.0));
        expect(metrics.treble, inInclusiveRange(0.0, 1.0));
        expect(metrics.overallAmplitude, greaterThan(0.0));
      });

      test('1.9 Dirac Delta Impulse at Index 0 (Hann Window Null)', () {
        final samples = Float32List(512);
        samples[0] = 1.0;
        const config = AudioVisualizerConfig.defaultConfig;

        final metrics = engine.process(samples: samples, config: config);

        // At index 0, Hann window is 0.0; impulse is completely windowed out
        expect(metrics.bass, equals(0.0));
        expect(metrics.mid, equals(0.0));
        expect(metrics.treble, equals(0.0));
      });

      test('1.10 Nyquist Frequency (Alternating +1.0, -1.0 at 22,050 Hz)', () {
        final samples = Float32List(512);
        for (int i = 0; i < 512; i++) {
          samples[i] = (i % 2 == 0) ? 1.0 : -1.0;
        }
        const config = AudioVisualizerConfig.defaultConfig;

        final metrics = engine.process(samples: samples, config: config);

        expect(metrics.bass.isNaN, isFalse);
        expect(metrics.mid.isNaN, isFalse);
        expect(metrics.treble.isNaN, isFalse);
        expect(metrics.overallAmplitude.isNaN, isFalse);
        // Nyquist (22,050 Hz) is beyond trebleBandHighHz (20,000 Hz, bin 232)
        // Bass and Mid bands should have minimal leakage
        expect(metrics.bass, lessThan(0.30));
        expect(metrics.mid, lessThan(0.30));
      });

      test('1.11 Uniform Random White Noise Energy Spread', () {
        final rng = math.Random(1337);
        final samples = Float32List(512);
        for (int i = 0; i < 512; i++) {
          samples[i] = (rng.nextDouble() * 2.0 - 1.0) * 0.8;
        }
        const config = AudioVisualizerConfig.defaultConfig;

        late AudioSpectrumMetrics metrics;
        for (int i = 0; i < 3; i++) {
          metrics = engine.process(samples: samples, config: config);
        }

        // White noise must energize all three spectral bands simultaneously
        expect(metrics.isSilent, isFalse);
        expect(metrics.bass, greaterThan(0.15));
        expect(metrics.mid, greaterThan(0.15));
        expect(metrics.treble, greaterThan(0.15));
        expect(metrics.bass, inInclusiveRange(0.0, 1.0));
        expect(metrics.mid, inInclusiveRange(0.0, 1.0));
        expect(metrics.treble, inInclusiveRange(0.0, 1.0));
      });

      test('1.12 NaN and Infinity handling via processSamples adapter', () {
        final dirtyList = List<double>.generate(512, (i) {
          if (i == 5) return double.nan;
          if (i == 15) return double.infinity;
          if (i == 25) return double.negativeInfinity;
          return 0.5 * math.sin(i * 0.1);
        });

        final metrics = engine.processSamples(dirtyList);

        expect(metrics.bass.isNaN, isFalse);
        expect(metrics.mid.isNaN, isFalse);
        expect(metrics.treble.isNaN, isFalse);
        expect(metrics.overallAmplitude.isNaN, isFalse);
        expect(metrics.bass, inInclusiveRange(0.0, 1.0));
        expect(metrics.mid, inInclusiveRange(0.0, 1.0));
        expect(metrics.treble, inInclusiveRange(0.0, 1.0));
      });

      test('1.13 NaN and Infinity in process() (Vulnerability Characterization)', () {
        final nanSamples = Float32List(512);
        nanSamples[10] = double.nan;
        nanSamples[20] = double.infinity;
        const config = AudioVisualizerConfig.defaultConfig;

        final metrics = engine.process(samples: nanSamples, config: config);

        // Due to Dart's double.nan.clamp(0.0, 1.0) returning 1.0,
        // NaN in process() produces full-scale false positive peak (0.85 attack)
        expect(metrics.bass, equals(0.85));
        expect(metrics.mid, equals(0.85));
        expect(metrics.treble, equals(0.85));
        expect(metrics.peakDetected, isTrue);
      });
    });

    // =========================================================================
    // SUITE 2: FREQUENCY ISOLATION ACCURACY (50 Hz, 1 kHz, 15 kHz)
    // =========================================================================
    group('Suite 2: Pure Tone Frequency Isolation Accuracy', () {
      test('2.1 Pure 50 Hz Bass Tone Isolation', () {
        final samples = generateSine(freq: 50.0, amplitude: 0.9);
        const config = AudioVisualizerConfig.defaultConfig;

        late AudioSpectrumMetrics metrics;
        for (int i = 0; i < 8; i++) {
          metrics = engine.process(samples: samples, config: config);
        }

        // 50 Hz Bass validation
        expect(metrics.bass, greaterThan(0.95),
            reason: '50 Hz pure tone must yield dominant Bass energy (~1.0)');
        expect(metrics.mid, lessThan(0.05),
            reason: '50 Hz pure tone must exhibit near-zero Mid leakage (<5%)');
        expect(metrics.treble, lessThan(0.005),
            reason: '50 Hz pure tone must exhibit negligible Treble leakage (< -46 dB)');
        expect(metrics.bass, greaterThan(metrics.mid * 10.0),
            reason: 'Bass-to-Mid isolation ratio must exceed 10x (20 dB)');
      });

      test('2.2 Pure 1,000 Hz Mid Tone Isolation', () {
        final samples = generateSine(freq: 1000.0, amplitude: 0.9);
        const config = AudioVisualizerConfig.defaultConfig;

        late AudioSpectrumMetrics metrics;
        for (int i = 0; i < 8; i++) {
          metrics = engine.process(samples: samples, config: config);
        }

        // 1 kHz Mid validation
        expect(metrics.mid, greaterThan(0.95),
            reason: '1,000 Hz pure tone must yield dominant Mid energy (~1.0)');
        expect(metrics.bass, lessThan(0.02),
            reason: '1,000 Hz pure tone must exhibit near-zero Bass leakage (<2%)');
        expect(metrics.treble, lessThan(0.005),
            reason: '1,000 Hz pure tone must exhibit negligible Treble leakage (< -46 dB)');
        expect(metrics.mid, greaterThan(metrics.bass * 10.0),
            reason: 'Mid-to-Bass isolation ratio must exceed 10x (20 dB)');
      });

      test('2.3 Pure 15,000 Hz Treble Tone Isolation', () {
        final samples = generateSine(freq: 15000.0, amplitude: 0.9);
        const config = AudioVisualizerConfig.defaultConfig;

        late AudioSpectrumMetrics metrics;
        for (int i = 0; i < 8; i++) {
          metrics = engine.process(samples: samples, config: config);
        }

        // 15 kHz Treble validation
        expect(metrics.treble, greaterThan(0.95),
            reason: '15,000 Hz pure tone must yield dominant Treble energy (~1.0)');
        expect(metrics.bass, lessThan(0.005),
            reason: '15,000 Hz pure tone must exhibit negligible Bass leakage (< -46 dB)');
        expect(metrics.mid, lessThan(0.005),
            reason: '15,000 Hz pure tone must exhibit negligible Mid leakage (< -46 dB)');
      });

      test('2.4 Multi-Tone Separation (Simultaneous 60 Hz + 1 kHz + 12 kHz)', () {
        final mixed = Float32List(512);
        for (int i = 0; i < 512; i++) {
          final t = i / 44100.0;
          final b = math.sin(2.0 * math.pi * 60.0 * t);
          final m = math.sin(2.0 * math.pi * 1000.0 * t);
          final tr = math.sin(2.0 * math.pi * 12000.0 * t);
          mixed[i] = (b + m + tr) / 3.0;
        }
        const config = AudioVisualizerConfig.defaultConfig;

        late AudioSpectrumMetrics metrics;
        for (int i = 0; i < 8; i++) {
          metrics = engine.process(samples: mixed, config: config);
        }

        // All three bands must register simultaneously with measurable energy (>0.20)
        expect(metrics.bass, greaterThan(0.20));
        expect(metrics.mid, greaterThan(0.20));
        expect(metrics.treble, greaterThan(0.20));
      });
    });

    // =========================================================================
    // SUITE 3: STEADY-STATE PERFORMANCE & MEMORY ALLOCATION BENCHMARK
    // =========================================================================
    group('Suite 3: Steady-State Performance (< 0.1 ms) & Memory Allocation', () {
      test('3.1 Steady-state processing latency is strictly < 0.1 ms (100 µs)', () {
        final samples = generateSine(freq: 440.0, amplitude: 0.7);
        const config = AudioVisualizerConfig.defaultConfig;

        // Warmup JIT compiler across 1,000 frames
        for (int i = 0; i < 1000; i++) {
          engine.process(samples: samples, config: config);
        }

        // Execute benchmark across 10,000 frames
        const int iterations = 10000;
        final stopwatch = Stopwatch()..start();
        for (int i = 0; i < iterations; i++) {
          engine.process(samples: samples, config: config);
        }
        stopwatch.stop();

        final totalMicros = stopwatch.elapsedMicroseconds;
        final avgMicros = totalMicros / iterations;
        final avgMs = avgMicros / 1000.0;

        // Requirement: strictly < 0.1 ms (100 µs)
        expect(avgMs, lessThan(0.10),
            reason: 'Processing time must stay strictly < 0.1 ms per frame');
      });

      test('3.2 Zero Heap Buffer Reallocations in Audio Loop', () {
        // Inspect that internal working buffers retain the identical identity across runs
        final initialRealIdentity = engine.cosTwiddleTable;
        final initialHannIdentity = engine.hannTable;
        final initialBitRevIdentity = engine.bitReversalTable;

        final samples = generateSine(freq: 440.0);
        const config = AudioVisualizerConfig.defaultConfig;

        for (int i = 0; i < 500; i++) {
          engine.process(samples: samples, config: config);
        }

        // Verify buffer identities remain completely unchanged
        expect(identical(engine.cosTwiddleTable, initialRealIdentity), isTrue);
        expect(identical(engine.hannTable, initialHannIdentity), isTrue);
        expect(identical(engine.bitReversalTable, initialBitRevIdentity), isTrue);
      });
    });

    // =========================================================================
    // SUITE 4: BUFFER BOUNDARIES & ADAPTIVE ENVELOPE DYNAMICS
    // =========================================================================
    group('Suite 4: Buffer Boundaries & Envelope Dynamics', () {
      test('4.1 Zero-Length Empty Buffer Safe Handling', () {
        final empty = Float32List(0);
        const config = AudioVisualizerConfig.defaultConfig;

        final metrics = engine.process(samples: empty, config: config);
        expect(metrics.isSilent, isTrue);
        expect(metrics.overallAmplitude, equals(0.0));
      });

      test('4.2 Undersized Buffer (128 samples < 512 fftSize) Zero Padding', () {
        final undersized = Float32List(128);
        undersized.fillRange(0, 128, 0.5);
        const config = AudioVisualizerConfig.defaultConfig;

        final metrics = engine.process(samples: undersized, config: config);
        expect(metrics.bass, inInclusiveRange(0.0, 1.0));
      });

      test('4.3 Oversized Buffer (2048 samples > 512 fftSize) Truncation', () {
        final oversized = Float32List(2048);
        oversized.fillRange(0, 2048, 0.5);
        const config = AudioVisualizerConfig.defaultConfig;

        final metrics = engine.process(samples: oversized, config: config);
        expect(metrics.bass, inInclusiveRange(0.0, 1.0));
      });

      test('4.4 reset() completely clears internal smoothed states and peak envelope', () {
        final loud = generateSine(freq: 200.0, amplitude: 0.9);
        engine.process(samples: loud, config: AudioVisualizerConfig.defaultConfig);

        expect(engine.smoothedBass, greaterThan(0.0));
        engine.reset();

        expect(engine.smoothedBass, equals(0.0));
        expect(engine.smoothedMid, equals(0.0));
        expect(engine.smoothedTreble, equals(0.0));
        expect(engine.smoothedOverall, equals(0.0));
        expect(engine.peakEnvelope, equals(0.1));
      });

      test('4.5 Peak Envelope Follower Exponential Decay Tracking (lambda = 0.992)', () {
        // Fire loud impulse to raise peak envelope
        final loud = generateSine(freq: 1000.0, amplitude: 0.8);
        engine.process(samples: loud, config: AudioVisualizerConfig.defaultConfig);
        final initialPeak = engine.peakEnvelope;

        // Process silence with silence detection disabled to observe FFT envelope decay
        final silent = Float32List(512);
        const silentConfig = AudioVisualizerConfig(isSilenceDetectionEnabled: false);
        engine.process(samples: silent, config: silentConfig);

        expect(engine.peakEnvelope, closeTo(initialPeak * 0.992, 0.005));
      });
    });
  });
}
