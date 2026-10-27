import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/models/audio_visualizer_config.dart';

void main() {
  group('AudioVisualizerConfig Unit Tests', () {
    test('defaultConfig has expected parameters', () {
      const config = AudioVisualizerConfig.defaultConfig;
      expect(config.isEnabled, isFalse);
      expect(config.mode, equals(AudioCaptureMode.simulated));
      expect(config.preset, equals(AudioVisualizerPreset.cosmicPulse));
      expect(config.sensitivity, equals(1.0));
      expect(config.smoothingFactor, equals(0.65));
      expect(config.frequencyFocus, equals(AudioFrequencyFocus.allFrequencies));
      expect(config.reactiveIntensity, equals(1.0));
      expect(config.isSilenceDetectionEnabled, isTrue);
      expect(config.silenceThreshold, equals(0.015));
      expect(config.isCustom, isFalse);
      expect(config.isLive, isFalse);
      expect(config.isSimulated, isTrue);
    });

    test('predefined presets have expected distinct configurations', () {
      final club = AudioVisualizerConfig.forPreset(AudioVisualizerPreset.clubBassDrop);
      expect(club.preset, equals(AudioVisualizerPreset.clubBassDrop));
      expect(club.frequencyFocus, equals(AudioFrequencyFocus.bassCentric));
      expect(club.sensitivity, greaterThan(1.0));
      expect(club.smoothingFactor, lessThan(0.55));
      expect(club.isEnabled, isTrue);

      final ambient = AudioVisualizerConfig.forPreset(AudioVisualizerPreset.ambientChill);
      expect(ambient.preset, equals(AudioVisualizerPreset.ambientChill));
      expect(ambient.smoothingFactor, greaterThanOrEqualTo(0.80));
      expect(ambient.reactiveIntensity, lessThan(1.0));

      final vocal = AudioVisualizerConfig.forPreset(AudioVisualizerPreset.vocalAcoustic);
      expect(vocal.preset, equals(AudioVisualizerPreset.vocalAcoustic));
      expect(vocal.frequencyFocus, equals(AudioFrequencyFocus.midVocal));

      final noir = AudioVisualizerConfig.forPreset(AudioVisualizerPreset.minimalistNoir);
      expect(noir.preset, equals(AudioVisualizerPreset.minimalistNoir));
      expect(noir.reactiveIntensity, lessThanOrEqualTo(0.5));
      expect(noir.silenceThreshold, greaterThan(0.015));

      final custom = AudioVisualizerConfig.forPreset(AudioVisualizerPreset.custom);
      expect(custom.preset, equals(AudioVisualizerPreset.custom));
      expect(custom.isCustom, isTrue);

      final compat = AudioVisualizerConfig.presetConfig(AudioVisualizerPreset.cosmicPulse);
      expect(compat.preset, equals(AudioVisualizerPreset.cosmicPulse));
    });

    test('toJson and fromJson serialize and deserialize symmetrically', () {
      const original = AudioVisualizerConfig(
        isEnabled: true,
        mode: AudioCaptureMode.live,
        preset: AudioVisualizerPreset.clubBassDrop,
        sensitivity: 2.2,
        smoothingFactor: 0.4,
        frequencyFocus: AudioFrequencyFocus.bassCentric,
        reactiveIntensity: 1.5,
        isSilenceDetectionEnabled: false,
        silenceThreshold: 0.03,
      );

      final json = original.toJson();
      final restored = AudioVisualizerConfig.fromJson(json);

      expect(restored, equals(original));
      expect(restored.isEnabled, isTrue);
      expect(restored.mode, equals(AudioCaptureMode.live));
      expect(restored.preset, equals(AudioVisualizerPreset.clubBassDrop));
      expect(restored.sensitivity, equals(2.2));
      expect(restored.smoothingFactor, equals(0.4));
      expect(restored.frequencyFocus, equals(AudioFrequencyFocus.bassCentric));
      expect(restored.reactiveIntensity, equals(1.5));
      expect(restored.isSilenceDetectionEnabled, isFalse);
      expect(restored.silenceThreshold, equals(0.03));
    });

    test('fromJson falls back safely on empty or malformed maps', () {
      final fallback = AudioVisualizerConfig.fromJson(const {});

      expect(fallback.isEnabled, isFalse);
      expect(fallback.mode, equals(AudioCaptureMode.simulated));
      expect(fallback.preset, equals(AudioVisualizerPreset.cosmicPulse));
      expect(fallback.sensitivity, equals(AudioVisualizerConfig.defaultSensitivity));
      expect(fallback.smoothingFactor, equals(AudioVisualizerConfig.defaultSmoothingFactor));
      expect(fallback.frequencyFocus, equals(AudioFrequencyFocus.allFrequencies));
      expect(fallback.reactiveIntensity, equals(AudioVisualizerConfig.defaultReactiveIntensity));
      expect(fallback.isSilenceDetectionEnabled, isTrue);
      expect(fallback.silenceThreshold, equals(AudioVisualizerConfig.defaultSilenceThreshold));

      final corrupted = AudioVisualizerConfig.fromJson(const {
        'mode': 'unknownMode',
        'preset': 'nonExistentPreset',
        'frequencyFocus': 'invalidFocus',
      });
      expect(corrupted.mode, equals(AudioCaptureMode.simulated));
      expect(corrupted.preset, equals(AudioVisualizerPreset.cosmicPulse));
      expect(corrupted.frequencyFocus, equals(AudioFrequencyFocus.allFrequencies));
    });

    test('fromJson and copyWith defensively clamp numerical bounds', () {
      final jsonLow = AudioVisualizerConfig.fromJson(const {
        'sensitivity': -5.0,
        'smoothingFactor': -1.0,
        'reactiveIntensity': -0.5,
        'silenceThreshold': -0.1,
      });

      expect(jsonLow.sensitivity, equals(AudioVisualizerConfig.minSensitivity));
      expect(jsonLow.smoothingFactor, equals(AudioVisualizerConfig.minSmoothingFactor));
      expect(jsonLow.reactiveIntensity, equals(AudioVisualizerConfig.minReactiveIntensity));
      expect(jsonLow.silenceThreshold, equals(AudioVisualizerConfig.minSilenceThreshold));

      final jsonHigh = AudioVisualizerConfig.fromJson(const {
        'sensitivity': 10.0,
        'smoothingFactor': 1.5,
        'reactiveIntensity': 5.0,
      });

      expect(jsonHigh.sensitivity, equals(AudioVisualizerConfig.maxSensitivity));
      expect(jsonHigh.smoothingFactor, equals(AudioVisualizerConfig.maxSmoothingFactor));
      expect(jsonHigh.reactiveIntensity, equals(AudioVisualizerConfig.maxReactiveIntensity));

      const base = AudioVisualizerConfig.defaultConfig;
      final clampedCopy = base.copyWith(
        sensitivity: 99.0,
        smoothingFactor: -10.0,
        reactiveIntensity: 4.0,
        silenceThreshold: -2.0,
      );

      expect(clampedCopy.sensitivity, equals(AudioVisualizerConfig.maxSensitivity));
      expect(clampedCopy.smoothingFactor, equals(AudioVisualizerConfig.minSmoothingFactor));
      expect(clampedCopy.reactiveIntensity, equals(AudioVisualizerConfig.maxReactiveIntensity));
      expect(clampedCopy.silenceThreshold, equals(AudioVisualizerConfig.minSilenceThreshold));
    });

    test('copyWith updates selected fields while preserving others', () {
      const original = AudioVisualizerConfig.defaultConfig;
      final updated = original.copyWith(
        isEnabled: true,
        mode: AudioCaptureMode.live,
        preset: AudioVisualizerPreset.minimalistNoir,
        sensitivity: 0.8,
        smoothingFactor: 0.5,
        frequencyFocus: AudioFrequencyFocus.trebleShimmer,
        reactiveIntensity: 0.9,
        isSilenceDetectionEnabled: false,
        silenceThreshold: 0.025,
      );

      expect(updated.isEnabled, isTrue);
      expect(updated.mode, equals(AudioCaptureMode.live));
      expect(updated.preset, equals(AudioVisualizerPreset.minimalistNoir));
      expect(updated.sensitivity, equals(0.8));
      expect(updated.smoothingFactor, equals(0.5));
      expect(updated.frequencyFocus, equals(AudioFrequencyFocus.trebleShimmer));
      expect(updated.reactiveIntensity, equals(0.9));
      expect(updated.isSilenceDetectionEnabled, isFalse);
      expect(updated.silenceThreshold, equals(0.025));

      final partial = updated.copyWith(isEnabled: false);
      expect(partial.isEnabled, isFalse);
      expect(partial.mode, equals(AudioCaptureMode.live));
      expect(partial.sensitivity, equals(0.8));
    });

    test('Equatable value equality and hashCode consistency', () {
      const configA = AudioVisualizerConfig(
        isEnabled: true,
        mode: AudioCaptureMode.simulated,
        sensitivity: 1.5,
      );
      const configB = AudioVisualizerConfig(
        isEnabled: true,
        mode: AudioCaptureMode.simulated,
        sensitivity: 1.5,
      );
      const configC = AudioVisualizerConfig(
        isEnabled: false,
        mode: AudioCaptureMode.simulated,
        sensitivity: 1.5,
      );

      expect(configA, equals(configB));
      expect(configA.hashCode, equals(configB.hashCode));
      expect(configA, isNot(equals(configC)));
    });

    test('enum metadata invariants', () {
      for (final mode in AudioCaptureMode.values) {
        expect(mode.label.isNotEmpty, isTrue);
        expect(mode.description.isNotEmpty, isTrue);
        expect(mode.displayName, equals(mode.label));
        expect(mode.icon, isNotNull);
      }
      expect(AudioCaptureMode.live.isLive, isTrue);
      expect(AudioCaptureMode.live.isSimulated, isFalse);
      expect(AudioCaptureMode.simulated.isSimulated, isTrue);
      expect(AudioCaptureMode.simulated.isLive, isFalse);

      for (final preset in AudioVisualizerPreset.values) {
        expect(preset.label.isNotEmpty, isTrue);
        expect(preset.description.isNotEmpty, isTrue);
        expect(preset.displayName, equals(preset.label));
        expect(preset.icon, isNotNull);
      }
      expect(AudioVisualizerPreset.custom.isCustom, isTrue);
      expect(AudioVisualizerPreset.cosmicPulse.isCustom, isFalse);

      for (final focus in AudioFrequencyFocus.values) {
        expect(focus.label.isNotEmpty, isTrue);
        expect(focus.description.isNotEmpty, isTrue);
        expect(focus.displayName, equals(focus.label));
        expect(focus.icon, isNotNull);
      }
    });
  });
}
