import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/models/lock_screen_style_config.dart';

void main() {
  group('LockScreenStyleConfig Model Tests', () {
    test('default configuration provides valid baseline', () {
      const config = LockScreenStyleConfig.defaultConfig;
      expect(config.clockFont, LockScreenClockFont.modern);
      expect(config.clockLayout, LockScreenClockLayout.horizontal);
      expect(config.widgetType, LockScreenWidgetType.circadianSlot);
      expect(config.useWallpaperAccentColor, isTrue);
      expect(config.customColor, Colors.white);
      expect(config.showDate, isTrue);
      expect(config.showShortcuts, isTrue);
      expect(config.clockSize, 82.0);
    });

    test('presets provide cohesive aesthetic defaults', () {
      // Pixel Stacked Preset
      const pixel = LockScreenStyleConfig.pixelStackedPreset;
      expect(pixel.clockFont, LockScreenClockFont.stencil);
      expect(pixel.clockLayout, LockScreenClockLayout.stacked);
      expect(pixel.widgetType, LockScreenWidgetType.circadianSlot);
      expect(pixel.useWallpaperAccentColor, isTrue);

      // Editorial Serif Preset
      const editorial = LockScreenStyleConfig.editorialSerifPreset;
      expect(editorial.clockFont, LockScreenClockFont.editorial);
      expect(editorial.clockLayout, LockScreenClockLayout.horizontal);
      expect(editorial.widgetType, LockScreenWidgetType.quotePill);
      expect(editorial.useWallpaperAccentColor, isFalse);

      // Cyber Matrix Preset
      const cyber = LockScreenStyleConfig.cyberMatrixPreset;
      expect(cyber.clockFont, LockScreenClockFont.cyber);
      expect(cyber.clockLayout, LockScreenClockLayout.stacked);
      expect(cyber.widgetType, LockScreenWidgetType.batteryGlance);
      expect(cyber.customColor, const Color(0xFF00E676));

      // Aurora Neon Preset
      const aurora = LockScreenStyleConfig.auroraNeonPreset;
      expect(aurora.clockFont, LockScreenClockFont.neon);
      expect(aurora.clockLayout, LockScreenClockLayout.horizontal);
      expect(aurora.customColor, const Color(0xFF00E5FF));
    });

    test('resolveClockColor returns accent when useWallpaperAccentColor is true', () {
      const config = LockScreenStyleConfig(
        useWallpaperAccentColor: true,
        customColor: Colors.white,
      );
      const accent = Color(0xFF00E5FF);
      expect(config.resolveClockColor(accent), accent);
    });

    test('resolveClockColor returns customColor when useWallpaperAccentColor is false', () {
      const config = LockScreenStyleConfig(
        useWallpaperAccentColor: false,
        customColor: Color(0xFFFF5722),
      );
      const accent = Color(0xFF00E5FF);
      expect(config.resolveClockColor(accent), const Color(0xFFFF5722));
    });

    test('resolveClockTextStyle generates distinct styles for all fonts', () {
      for (final font in LockScreenClockFont.values) {
        final config = LockScreenStyleConfig(clockFont: font, clockSize: 80.0);
        final style = config.resolveClockTextStyle(Colors.cyan);
        expect(style.color, Colors.cyan);
        expect(style.fontSize, isNotNull);
        expect(style.shadows, isNotEmpty);
      }
    });

    test('copyWith properly overrides specified fields', () {
      const original = LockScreenStyleConfig.defaultConfig;
      final modified = original.copyWith(
        clockFont: LockScreenClockFont.neon,
        clockLayout: LockScreenClockLayout.stacked,
        widgetType: LockScreenWidgetType.batteryGlance,
        useWallpaperAccentColor: false,
        customColor: const Color(0xFFD500F9),
        showDate: false,
        showShortcuts: false,
        clockSize: 96.0,
      );

      expect(modified.clockFont, LockScreenClockFont.neon);
      expect(modified.clockLayout, LockScreenClockLayout.stacked);
      expect(modified.widgetType, LockScreenWidgetType.batteryGlance);
      expect(modified.useWallpaperAccentColor, isFalse);
      expect(modified.customColor, const Color(0xFFD500F9));
      expect(modified.showDate, isFalse);
      expect(modified.showShortcuts, isFalse);
      expect(modified.clockSize, 96.0);
    });

    test('toJson and fromJson serialize and deserialize correctly', () {
      const config = LockScreenStyleConfig(
        clockFont: LockScreenClockFont.cyber,
        clockLayout: LockScreenClockLayout.compact,
        widgetType: LockScreenWidgetType.quotePill,
        useWallpaperAccentColor: false,
        customColor: Color(0xFF00E676),
        showDate: false,
        showShortcuts: true,
        clockSize: 74.0,
      );

      final json = config.toJson();
      final restored = LockScreenStyleConfig.fromJson(json);

      expect(restored, config);
      expect(restored.clockFont, LockScreenClockFont.cyber);
      expect(restored.clockLayout, LockScreenClockLayout.compact);
      expect(restored.widgetType, LockScreenWidgetType.quotePill);
      expect(restored.useWallpaperAccentColor, isFalse);
      expect(restored.customColor.toARGB32(), const Color(0xFF00E676).toARGB32());
      expect(restored.showDate, isFalse);
      expect(restored.showShortcuts, isTrue);
      expect(restored.clockSize, 74.0);
    });

    test('fromJson handles fallback defaults on null / missing data', () {
      final restored = LockScreenStyleConfig.fromJson(const {});
      expect(restored.clockFont, LockScreenClockFont.modern);
      expect(restored.clockLayout, LockScreenClockLayout.horizontal);
      expect(restored.widgetType, LockScreenWidgetType.circadianSlot);
      expect(restored.useWallpaperAccentColor, isTrue);
      expect(restored.customColor, Colors.white);
      expect(restored.showDate, isTrue);
      expect(restored.showShortcuts, isTrue);
      expect(restored.clockSize, 82.0);
    });
  });
}
