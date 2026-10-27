import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/models/audio_spectrum_metrics.dart';
import 'package:live_wallpaper/models/audio_visualizer_config.dart';

void main() {
  group('AudioSpectrumMetrics Unit Tests', () {
    test('canonical zero state has expected values', () {
      const zero = AudioSpectrumMetrics.zero;
      expect(zero.bass, equals(0.0));
      expect(zero.mid, equals(0.0));
      expect(zero.treble, equals(0.0));
      expect(zero.overallAmplitude, equals(0.0));
      expect(zero.peakDetected, isFalse);
      expect(zero.isSilent, isTrue);
      expect(zero.timestampMs, equals(0));
      expect(zero.hasAudibleEnergy, isFalse);
      expect(zero.averageEnergy, equals(0.0));
      expect(zero.maxBandEnergy, equals(0.0));
    });

    test('clamped factory restricts out-of-range numeric values to [0.0, 1.0]', () {
      final metrics = AudioSpectrumMetrics.clamped(
        bass: 2.5,
        mid: -0.5,
        treble: 1.2,
        overallAmplitude: -1.0,
        peakDetected: true,
        isSilent: false,
        timestampMs: 12345,
      );

      expect(metrics.bass, equals(1.0));
      expect(metrics.mid, equals(0.0));
      expect(metrics.treble, equals(1.0));
      expect(metrics.overallAmplitude, equals(0.0));
      expect(metrics.peakDetected, isTrue);
      expect(metrics.isSilent, isFalse);
      expect(metrics.timestampMs, equals(12345));
    });

    test('fromRawValues normalizes energies and evaluates silence and peak', () {
      final loud = AudioSpectrumMetrics.fromRawValues(
        rawBass: 9.0,
        rawMid: 5.0,
        rawTreble: 2.0,
        rawAmplitude: 8.0,
        maxExpectedEnergy: 10.0,
        silenceThreshold: 0.015,
        peakThreshold: 0.85,
        timestampMs: 1000,
      );

      expect(loud.bass, closeTo(0.9, 0.001));
      expect(loud.mid, closeTo(0.5, 0.001));
      expect(loud.treble, closeTo(0.2, 0.001));
      expect(loud.overallAmplitude, closeTo(0.8, 0.001));
      expect(loud.isSilent, isFalse);
      expect(loud.peakDetected, isTrue); // bass 0.9 >= 0.85

      final quiet = AudioSpectrumMetrics.fromRawValues(
        rawBass: 0.05,
        rawMid: 0.05,
        rawTreble: 0.05,
        rawAmplitude: 0.01, // < 0.015
        maxExpectedEnergy: 10.0,
        silenceThreshold: 0.015,
      );

      expect(quiet.isSilent, isTrue);
      expect(quiet.peakDetected, isFalse);
      expect(quiet.hasAudibleEnergy, isFalse);
    });

    test('smoothedWith computes exponential moving average correctly', () {
      const prev = AudioSpectrumMetrics(
        bass: 0.2,
        mid: 0.4,
        treble: 0.6,
        overallAmplitude: 0.5,
      );

      const next = AudioSpectrumMetrics(
        bass: 0.8,
        mid: 0.8,
        treble: 0.8,
        overallAmplitude: 0.9,
      );

      // factor = 0.5 -> 0.5 * prev + 0.5 * next
      final smoothed = next.smoothedWith(prev, 0.5);
      expect(smoothed.bass, closeTo(0.5, 0.001));
      expect(smoothed.mid, closeTo(0.6, 0.001));
      expect(smoothed.treble, closeTo(0.7, 0.001));
      expect(smoothed.overallAmplitude, closeTo(0.7, 0.001));
    });

    test('applySensitivity scales and clamps energies', () {
      const m = AudioSpectrumMetrics(
        bass: 0.4,
        mid: 0.5,
        treble: 0.6,
        overallAmplitude: 0.5,
      );

      final scaled2x = m.applySensitivity(2.0);
      expect(scaled2x.bass, closeTo(0.8, 0.001));
      expect(scaled2x.mid, equals(1.0));
      expect(scaled2x.treble, equals(1.0));
      expect(scaled2x.overallAmplitude, equals(1.0));

      final scaledHalf = m.applySensitivity(0.5);
      expect(scaledHalf.bass, closeTo(0.2, 0.001));
      expect(scaledHalf.mid, closeTo(0.25, 0.001));
      expect(scaledHalf.treble, closeTo(0.3, 0.001));
    });

    test('applyFocus boosts target band and attenuates others', () {
      const m = AudioSpectrumMetrics(
        bass: 0.5,
        mid: 0.5,
        treble: 0.5,
        overallAmplitude: 0.5,
      );

      final bassFocus = m.applyFocus(AudioFrequencyFocus.bassCentric);
      expect(bassFocus.bass, greaterThan(0.5));
      expect(bassFocus.mid, lessThan(0.5));
      expect(bassFocus.treble, lessThan(0.5));

      final midFocus = m.applyFocus(AudioFrequencyFocus.midVocal);
      expect(midFocus.mid, greaterThan(0.5));
      expect(midFocus.bass, lessThan(0.5));
      expect(midFocus.treble, lessThan(0.5));

      final trebleFocus = m.applyFocus(AudioFrequencyFocus.trebleShimmer);
      expect(trebleFocus.treble, greaterThan(0.5));
      expect(trebleFocus.bass, lessThan(0.5));
      expect(trebleFocus.mid, lessThan(0.5));

      final allFocus = m.applyFocus(AudioFrequencyFocus.allFrequencies);
      expect(allFocus, equals(m));
    });

    test('computed getters evaluate correctly', () {
      const m = AudioSpectrumMetrics(
        bass: 0.3,
        mid: 0.6,
        treble: 0.9,
        overallAmplitude: 0.4,
        isSilent: false,
      );

      expect(m.averageEnergy, closeTo(0.6, 0.001));
      expect(m.maxBandEnergy, closeTo(0.9, 0.001));
      expect(m.hasAudibleEnergy, isTrue);
    });

    test('toJson and fromJson serialize and deserialize symmetrically', () {
      const original = AudioSpectrumMetrics(
        bass: 0.75,
        mid: 0.45,
        treble: 0.25,
        overallAmplitude: 0.65,
        peakDetected: true,
        isSilent: false,
        timestampMs: 987654321,
      );

      final json = original.toJson();
      final restored = AudioSpectrumMetrics.fromJson(json);

      expect(restored, equals(original));
      expect(restored.bass, equals(0.75));
      expect(restored.mid, equals(0.45));
      expect(restored.treble, equals(0.25));
      expect(restored.overallAmplitude, equals(0.65));
      expect(restored.peakDetected, isTrue);
      expect(restored.isSilent, isFalse);
      expect(restored.timestampMs, equals(987654321));
    });

    test('copyWith updates specified fields while clamping', () {
      const original = AudioSpectrumMetrics.zero;
      final copy = original.copyWith(
        bass: 1.5, // clamps to 1.0
        mid: 0.3,
        peakDetected: true,
        isSilent: false,
      );

      expect(copy.bass, equals(1.0));
      expect(copy.mid, equals(0.3));
      expect(copy.treble, equals(0.0));
      expect(copy.peakDetected, isTrue);
      expect(copy.isSilent, isFalse);
    });
  });
}
