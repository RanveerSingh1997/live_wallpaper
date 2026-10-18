import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/models/standby_dock_config.dart';

void main() {
  group('StandbyDockConfig Model Tests', () {
    test('defaultConfig initializes with expected Wallora desk dock defaults', () {
      const config = StandbyDockConfig.defaultConfig;
      expect(config.clockStyle, DockClockStyle.modernSans);
      expect(config.layoutMode, DockLayoutMode.dualPaneSplit);
      expect(config.isNightModeEnabled, isFalse);
      expect(config.isAutoNightModeEnabled, isTrue);
      expect(config.isBurnInProtectionEnabled, isTrue);
      expect(config.showBatteryPill, isTrue);
      expect(config.showMotivationalQuote, isTrue);
      expect(config.showDateAndSolarSlot, isTrue);
      expect(config.is24HourFormat, isFalse);
      expect(config.nightDimLevel, 0.20);
    });

    test('toJson and fromJson serialize and deserialize symmetrically', () {
      const original = StandbyDockConfig(
        clockStyle: DockClockStyle.cyberpunkTech,
        layoutMode: DockLayoutMode.centeredZen,
        isNightModeEnabled: true,
        isAutoNightModeEnabled: false,
        isBurnInProtectionEnabled: false,
        showBatteryPill: false,
        showMotivationalQuote: false,
        showDateAndSolarSlot: false,
        is24HourFormat: true,
        nightDimLevel: 0.10,
      );

      final json = original.toJson();
      final restored = StandbyDockConfig.fromJson(json);

      expect(restored, equals(original));
      expect(restored.clockStyle, DockClockStyle.cyberpunkTech);
      expect(restored.layoutMode, DockLayoutMode.centeredZen);
      expect(restored.isNightModeEnabled, isTrue);
      expect(restored.isAutoNightModeEnabled, isFalse);
      expect(restored.isBurnInProtectionEnabled, isFalse);
      expect(restored.is24HourFormat, isTrue);
      expect(restored.nightDimLevel, 0.10);
    });

    test('fromJson handles empty or partial json with robust fallbacks', () {
      final config = StandbyDockConfig.fromJson(const {});
      expect(config.clockStyle, DockClockStyle.modernSans);
      expect(config.layoutMode, DockLayoutMode.dualPaneSplit);
      expect(config.isNightModeEnabled, isFalse);
      expect(config.isAutoNightModeEnabled, isTrue);
      expect(config.isBurnInProtectionEnabled, isTrue);
      expect(config.showBatteryPill, isTrue);
      expect(config.is24HourFormat, isFalse);
      expect(config.nightDimLevel, 0.20);
    });

    test('isNightActiveNow correctly evaluates manual toggle and circadian schedule', () {
      // 1. Manual night mode enabled
      const manualNight = StandbyDockConfig(isNightModeEnabled: true);
      expect(manualNight.isNightActiveNow(DateTime(2026, 10, 18, 14, 0)), isTrue);

      // 2. Auto night mode active during night hours (23:00)
      const autoNight = StandbyDockConfig(isNightModeEnabled: false, isAutoNightModeEnabled: true);
      expect(autoNight.isNightActiveNow(DateTime(2026, 10, 18, 23, 30)), isTrue);
      expect(autoNight.isNightActiveNow(DateTime(2026, 10, 18, 3, 15)), isTrue);

      // 3. Auto night mode inactive during daytime hours (14:00)
      expect(autoNight.isNightActiveNow(DateTime(2026, 10, 18, 14, 0)), isFalse);

      // 4. Auto night mode disabled
      const noAuto = StandbyDockConfig(isNightModeEnabled: false, isAutoNightModeEnabled: false);
      expect(noAuto.isNightActiveNow(DateTime(2026, 10, 18, 23, 30)), isFalse);
    });

    test('copyWith updates properties while preserving others', () {
      const original = StandbyDockConfig.defaultConfig;
      final updated = original.copyWith(
        clockStyle: DockClockStyle.oledMatrix,
        layoutMode: DockLayoutMode.fullscreenHUD,
        isNightModeEnabled: true,
      );

      expect(updated.clockStyle, DockClockStyle.oledMatrix);
      expect(updated.layoutMode, DockLayoutMode.fullscreenHUD);
      expect(updated.isNightModeEnabled, isTrue);
      expect(updated.isAutoNightModeEnabled, original.isAutoNightModeEnabled);
      expect(updated.showBatteryPill, original.showBatteryPill);
    });

    test('enum properties provide correct display names and icons', () {
      for (final style in DockClockStyle.values) {
        expect(style.displayName, isNotEmpty);
        expect(style.description, isNotEmpty);
        expect(style.icon, isA<IconData>());
      }

      for (final layout in DockLayoutMode.values) {
        expect(layout.displayName, isNotEmpty);
        expect(layout.description, isNotEmpty);
        expect(layout.icon, isA<IconData>());
      }
    });
  });
}
