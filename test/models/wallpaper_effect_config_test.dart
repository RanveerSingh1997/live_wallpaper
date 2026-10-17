import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/models/wallpaper_effect_config.dart';

void main() {
  group('WallpaperEffectConfig Model Tests', () {
    const customConfig = WallpaperEffectConfig(
      blurSigma: 10.0,
      vignetteStrength: 0.5,
      brightness: 0.1,
      contrast: 1.3,
      colorFilterPreset: 'cyber_cyan',
    );

    test('defaultPreset and defaultConfig are equivalent and default', () {
      expect(WallpaperEffectConfig.defaultPreset.isDefault, isTrue);
      expect(WallpaperEffectConfig.defaultConfig.isDefault, isTrue);
      expect(WallpaperEffectConfig.defaultPreset.blurSigma, 0.0);
      expect(WallpaperEffectConfig.defaultPreset.vignetteStrength, 0.0);
      expect(WallpaperEffectConfig.defaultPreset.contrast, 1.0);
      expect(WallpaperEffectConfig.defaultPreset.colorFilterPreset, 'original');
    });

    test('custom config isDefault returns false', () {
      expect(customConfig.isDefault, isFalse);
    });

    test('presets have distinct expected properties', () {
      expect(WallpaperEffectConfig.noirPreset.colorFilterPreset, 'noir');
      expect(WallpaperEffectConfig.noirPreset.contrast, 1.25);
      expect(WallpaperEffectConfig.noirPreset.vignetteStrength, 0.35);

      expect(WallpaperEffectConfig.cyberPreset.colorFilterPreset, 'cyber_cyan');
      expect(WallpaperEffectConfig.sunsetPreset.colorFilterPreset, 'sunset_amber');
      expect(WallpaperEffectConfig.matrixPreset.colorFilterPreset, 'matrix_emerald');
      expect(WallpaperEffectConfig.auroraPreset.colorFilterPreset, 'aurora_violet');
      expect(WallpaperEffectConfig.softBlurPreset.blurSigma, 8.0);
    });

    test('toJson and fromJson serialize and deserialize accurately', () {
      final json = customConfig.toJson();
      expect(json['blurSigma'], 10.0);
      expect(json['vignetteStrength'], 0.5);
      expect(json['colorFilterPreset'], 'cyber_cyan');

      final deserialized = WallpaperEffectConfig.fromJson(json);
      expect(deserialized, equals(customConfig));
    });

    test('copyWith modifies targeted fields while preserving others', () {
      final modified = customConfig.copyWith(
        blurSigma: 15.0,
        colorFilterPreset: 'noir',
      );

      expect(modified.blurSigma, 15.0);
      expect(modified.colorFilterPreset, 'noir');
      expect(modified.vignetteStrength, customConfig.vignetteStrength);
      expect(modified.contrast, customConfig.contrast);
    });
  });
}
