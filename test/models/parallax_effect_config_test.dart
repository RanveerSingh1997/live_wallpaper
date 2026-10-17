import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/models/parallax_effect_config.dart';

void main() {
  group('ParallaxEffectConfig Model Tests', () {
    test('default configuration provides balanced baseline', () {
      const config = ParallaxEffectConfig.defaultConfig;
      expect(config.isEnabled, isTrue);
      expect(config.sensitivity, 1.2);
      expect(config.maxAngleDegrees, 12.0);
      expect(config.invertPitch, isFalse);
      expect(config.invertRoll, isFalse);
      expect(config.depthZoomScale, 1.08);
      expect(config.preset, ParallaxPreset.cinematic3D);
    });

    test('presets have distinct visual and sensitivity metrics', () {
      // Subtle
      const subtle = ParallaxEffectConfig.subtlePreset;
      expect(subtle.preset, ParallaxPreset.subtleBreath);
      expect(subtle.sensitivity, 0.8);
      expect(subtle.maxAngleDegrees, 7.0);

      // Cinematic
      const cinematic = ParallaxEffectConfig.cinematicPreset;
      expect(cinematic.preset, ParallaxPreset.cinematic3D);
      expect(cinematic.sensitivity, 1.2);
      expect(cinematic.maxAngleDegrees, 12.0);

      // Deep Spatial
      const deep = ParallaxEffectConfig.deepSpatialPreset;
      expect(deep.preset, ParallaxPreset.deepSpatial);
      expect(deep.sensitivity, 1.8);
      expect(deep.maxAngleDegrees, 18.0);

      // Hyper Float
      const hyper = ParallaxEffectConfig.hyperFloatPreset;
      expect(hyper.preset, ParallaxPreset.hyperFloat);
      expect(hyper.sensitivity, 2.4);
      expect(hyper.maxAngleDegrees, 24.0);

      // Disabled
      const disabled = ParallaxEffectConfig.disabledPreset;
      expect(disabled.isEnabled, isFalse);
      expect(disabled.preset, ParallaxPreset.off);
    });

    test('copyWith modifies only specified properties', () {
      const base = ParallaxEffectConfig.defaultConfig;
      final modified = base.copyWith(
        isEnabled: false,
        sensitivity: 2.1,
        maxAngleDegrees: 15.0,
        invertPitch: true,
        invertRoll: true,
        depthZoomScale: 1.15,
        preset: ParallaxPreset.hyperFloat,
      );

      expect(modified.isEnabled, isFalse);
      expect(modified.sensitivity, 2.1);
      expect(modified.maxAngleDegrees, 15.0);
      expect(modified.invertPitch, isTrue);
      expect(modified.invertRoll, isTrue);
      expect(modified.depthZoomScale, 1.15);
      expect(modified.preset, ParallaxPreset.hyperFloat);
    });

    test('toJson and fromJson serialize and deserialize correctly', () {
      const config = ParallaxEffectConfig(
        isEnabled: true,
        sensitivity: 1.9,
        maxAngleDegrees: 16.0,
        invertPitch: true,
        invertRoll: false,
        depthZoomScale: 1.14,
        preset: ParallaxPreset.deepSpatial,
      );

      final json = config.toJson();
      final restored = ParallaxEffectConfig.fromJson(json);

      expect(restored, config);
      expect(restored.sensitivity, 1.9);
      expect(restored.maxAngleDegrees, 16.0);
      expect(restored.invertPitch, isTrue);
      expect(restored.preset, ParallaxPreset.deepSpatial);
    });

    test('fromJson handles fallback defaults gracefully', () {
      final restored = ParallaxEffectConfig.fromJson(const {});
      expect(restored.isEnabled, isTrue);
      expect(restored.sensitivity, 1.2);
      expect(restored.maxAngleDegrees, 12.0);
      expect(restored.preset, ParallaxPreset.cinematic3D);
    });
  });
}
