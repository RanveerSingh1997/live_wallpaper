import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/models/battery_telemetry_config.dart';
import 'package:live_wallpaper/models/motivational_short.dart';

void main() {
  group('BatteryTelemetryConfig', () {
    const defaultConfig = BatteryTelemetryConfig.defaultConfig;

    test('defaultConfig has expected factory defaults', () {
      expect(defaultConfig.targetFps, TargetFpsMode.fps60);
      expect(defaultConfig.isEcoModeEnabled, isFalse);
      expect(defaultConfig.isPixelShiftEnabled, isTrue);
      expect(defaultConfig.isHardwareDecodingPreferred, isTrue);
      expect(defaultConfig.isBackgroundZeroSleepVerified, isTrue);
    });

    test('TargetFpsMode properties and labels are defined correctly', () {
      expect(TargetFpsMode.fps60.fps, 60);
      expect(TargetFpsMode.fps60.displayName, contains('60 FPS'));
      expect(TargetFpsMode.fps30.fps, 30);
      expect(TargetFpsMode.fps30.displayName, contains('30 FPS'));
      expect(TargetFpsMode.fpsAuto.fps, 0);
      expect(TargetFpsMode.fpsAuto.displayName, contains('Adaptive'));
    });

    test('calculateHourlyDrainPercent calculates appropriately for null short', () {
      final drain = defaultConfig.calculateHourlyDrainPercent(null);
      expect(drain, equals(0.25));
    });

    test('calculateHourlyDrainPercent calculates for static vs live shorts', () {
      const liveShort = MotivationalShort(
        id: 'test_live',
        title: 'Live Aurora',
        author: 'Wallora',
        quote: 'Fluid Motion',
        category: 'Cyberpunk',
        videoAssetPath: 'assets/videos/aurora.mp4',
        durationSeconds: 15,
        isLive: true,
        trueBlackPercentage: 0,
        accentColor: Color(0xFF00E5FF),
        tags: '#cyber #neon',
      );

      const staticShort = MotivationalShort(
        id: 'test_static',
        title: 'Static Peak',
        author: 'Wallora',
        quote: 'Stillness',
        category: 'Nature',
        videoAssetPath: '',
        durationSeconds: 0,
        isLive: false,
        trueBlackPercentage: 0,
        accentColor: Color(0xFF00E676),
        tags: '#nature #mountain',
      );

      final liveDrain = defaultConfig.calculateHourlyDrainPercent(liveShort);
      final staticDrain = defaultConfig.calculateHourlyDrainPercent(staticShort);

      expect(liveDrain, greaterThan(staticDrain));
      expect(liveDrain, greaterThan(0.5));
      expect(staticDrain, lessThan(0.2));
    });

    test('calculateHourlyDrainPercent reduces consumption with 30 FPS mode', () {
      const liveShort = MotivationalShort(
        id: 'test_live',
        title: 'Live Aurora',
        author: 'Wallora',
        quote: 'Fluid Motion',
        category: 'Cyberpunk',
        videoAssetPath: 'assets/videos/aurora.mp4',
        durationSeconds: 15,
        isLive: true,
        trueBlackPercentage: 0,
        accentColor: Color(0xFF00E5FF),
        tags: '#cyber #neon',
      );

      const config60 = BatteryTelemetryConfig(targetFps: TargetFpsMode.fps60);
      const config30 = BatteryTelemetryConfig(targetFps: TargetFpsMode.fps30);

      final drain60 = config60.calculateHourlyDrainPercent(liveShort);
      final drain30 = config30.calculateHourlyDrainPercent(liveShort);

      expect(drain30, lessThan(drain60));
    });

    test('calculateHourlyDrainPercent reduces consumption with AMOLED true black', () {
      const fullColorShort = MotivationalShort(
        id: 'test_color',
        title: 'Full Color',
        author: 'Wallora',
        quote: 'Vibrant',
        category: 'Cyberpunk',
        videoAssetPath: 'assets/videos/aurora.mp4',
        durationSeconds: 15,
        isLive: true,
        trueBlackPercentage: 0,
        accentColor: Color(0xFF00E5FF),
        tags: '#cyber #neon',
      );

      const amoledShort = MotivationalShort(
        id: 'test_amoled',
        title: 'AMOLED Black',
        author: 'Wallora',
        quote: 'Deep Black',
        category: 'AMOLED True-Black',
        videoAssetPath: 'assets/videos/aurora.mp4',
        durationSeconds: 15,
        isLive: true,
        trueBlackPercentage: 85,
        accentColor: Color(0xFF000000),
        tags: '#amoled #black',
      );

      final colorDrain = defaultConfig.calculateHourlyDrainPercent(fullColorShort);
      final amoledDrain = defaultConfig.calculateHourlyDrainPercent(amoledShort);

      expect(amoledDrain, lessThan(colorDrain));
    });

    test('calculateDailyMahSaved returns bounded savings', () {
      const liveShort = MotivationalShort(
        id: 'test_live',
        title: 'Live Aurora',
        author: 'Wallora',
        quote: 'Fluid Motion',
        category: 'Cyberpunk',
        videoAssetPath: 'assets/videos/aurora.mp4',
        durationSeconds: 15,
        isLive: true,
        trueBlackPercentage: 70,
        accentColor: Color(0xFF00E5FF),
        tags: '#cyber #neon',
      );

      final mahSaved = defaultConfig.calculateDailyMahSaved(liveShort);
      expect(mahSaved, greaterThanOrEqualTo(10));
      expect(mahSaved, lessThanOrEqualTo(480));
    });

    test('copyWith updates specified fields only', () {
      final updated = defaultConfig.copyWith(
        targetFps: TargetFpsMode.fps30,
        isEcoModeEnabled: true,
        isPixelShiftEnabled: false,
      );

      expect(updated.targetFps, TargetFpsMode.fps30);
      expect(updated.isEcoModeEnabled, isTrue);
      expect(updated.isPixelShiftEnabled, isFalse);
      expect(updated.isHardwareDecodingPreferred, isTrue);
      expect(updated.isBackgroundZeroSleepVerified, isTrue);
    });

    test('JSON serialization round-trip', () {
      final config = const BatteryTelemetryConfig(
        targetFps: TargetFpsMode.fpsAuto,
        isEcoModeEnabled: true,
        isPixelShiftEnabled: false,
        isHardwareDecodingPreferred: true,
        isBackgroundZeroSleepVerified: true,
      );

      final json = config.toJson();
      final restored = BatteryTelemetryConfig.fromJson(json);

      expect(restored, equals(config));
      expect(restored.targetFps, TargetFpsMode.fpsAuto);
      expect(restored.isEcoModeEnabled, isTrue);
      expect(restored.isPixelShiftEnabled, isFalse);
    });

    test('fromJson handles fallback defaults on null or unknown values', () {
      final restored = BatteryTelemetryConfig.fromJson({
        'targetFps': 'unknown_mode',
      });

      expect(restored.targetFps, TargetFpsMode.fps60);
      expect(restored.isEcoModeEnabled, isFalse);
      expect(restored.isPixelShiftEnabled, isTrue);
    });
  });
}
