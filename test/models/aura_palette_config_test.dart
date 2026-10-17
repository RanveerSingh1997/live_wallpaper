import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/models/aura_palette_config.dart';
import 'package:live_wallpaper/models/motivational_short.dart';

void main() {
  group('AuraPaletteConfig Model Tests', () {
    test('default configuration has correct initial values', () {
      const config = AuraPaletteConfig.defaultConfig;

      expect(config.preset, equals(AuraThemePreset.wallpaperDynamic));
      expect(config.isDynamicThemingEnabled, isTrue);
      expect(config.syncParticles, isTrue);
      expect(config.syncKineticQuotes, isTrue);
      expect(config.syncLockScreen, isTrue);
      expect(config.hueShiftDegrees, equals(0.0));
      expect(config.saturationMultiplier, equals(1.0));
      expect(config.customPrimaryColor, isNull);
      expect(config.customAccentColor, isNull);
    });

    test('serializes to JSON and deserializes back properly', () {
      const config = AuraPaletteConfig(
        preset: AuraThemePreset.cyberAurora,
        isDynamicThemingEnabled: false,
        syncParticles: false,
        syncKineticQuotes: true,
        syncLockScreen: false,
        hueShiftDegrees: 45.0,
        saturationMultiplier: 1.2,
        customPrimaryColor: Color(0xFF00E5FF),
        customAccentColor: Color(0xFFD500F9),
      );

      final json = config.toJson();
      final restored = AuraPaletteConfig.fromJson(json);

      expect(restored.preset, equals(AuraThemePreset.cyberAurora));
      expect(restored.isDynamicThemingEnabled, isFalse);
      expect(restored.syncParticles, isFalse);
      expect(restored.syncKineticQuotes, isTrue);
      expect(restored.syncLockScreen, isFalse);
      expect(restored.hueShiftDegrees, equals(45.0));
      expect(restored.saturationMultiplier, equals(1.2));
      expect(restored.customPrimaryColor, equals(const Color(0xFF00E5FF)));
      expect(restored.customAccentColor, equals(const Color(0xFFD500F9)));
    });

    test('resolves dynamic palette from active wallpaper gradients', () {
      const wallpaper = MotivationalShort(
        id: 'test_short',
        title: 'Neon Horizon',
        quote: 'Dream without fear',
        author: 'Wallora',
        category: 'Cyberpunk',
        videoAssetPath: 'assets/videos/test.mp4',
        accentColor: Color(0xFF00E5FF),
        tags: '#cyberpunk',
        gradientColors: [
          Color(0xFF00E5FF),
          Color(0xFFD500F9),
          Color(0xFFFF5722),
        ],
      );

      const config = AuraPaletteConfig(preset: AuraThemePreset.wallpaperDynamic);
      final palette = config.resolvePalette(wallpaper);

      expect(palette.dominant, equals(const Color(0xFF00E5FF)));
      expect(palette.vibrantNeon, equals(const Color(0xFFD500F9)));
      expect(palette.harmonicSecondary, equals(const Color(0xFFFF5722)));
      expect(palette.allSwatches.length, equals(5));
      expect(palette.deepOledTone.toARGB32() != 0, isTrue);
      expect(palette.etherealGlow.toARGB32() != 0, isTrue);
    });

    test('resolves preset palettes accurately with hue shift and saturation transform', () {
      const config = AuraPaletteConfig(
        preset: AuraThemePreset.solarEclipse,
        hueShiftDegrees: 30.0,
        saturationMultiplier: 1.1,
      );

      final palette = config.resolvePalette(null);

      expect(palette.allSwatches.length, equals(5));
      expect(palette.dominant, isNot(equals(AuraThemePreset.solarEclipse.primaryAccent)));
    });

    test('copyWith creates modified copy preserving unstated properties', () {
      const config = AuraPaletteConfig.defaultConfig;
      final updated = config.copyWith(
        preset: AuraThemePreset.emeraldMatrix,
        hueShiftDegrees: -45.0,
      );

      expect(updated.preset, equals(AuraThemePreset.emeraldMatrix));
      expect(updated.hueShiftDegrees, equals(-45.0));
      expect(updated.isDynamicThemingEnabled, isTrue);
      expect(updated.syncParticles, isTrue);
    });

    test('AuraThemePreset properties are non-empty and well-defined', () {
      for (final preset in AuraThemePreset.values) {
        expect(preset.displayName.isNotEmpty, isTrue);
        expect(preset.description.isNotEmpty, isTrue);
        expect(preset.icon, isNotNull);
        expect(preset.primaryAccent, isNotNull);
        expect(preset.secondaryAccent, isNotNull);
      }
    });
  });
}
