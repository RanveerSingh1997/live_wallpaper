import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/models/aurora_synthesizer_config.dart';

void main() {
  group('AuroraSynthesizerConfig Unit Tests', () {
    test('defaultConfig has expected parameters', () {
      const config = AuroraSynthesizerConfig.defaultConfig;
      expect(config.waveStyle, equals(AuroraWaveStyle.cosmicNorthernLights));
      expect(config.colorMode, equals(AuroraColorMode.auraSync));
      expect(config.waveCount, equals(3));
      expect(config.waveSpeed, equals(1.0));
      expect(config.crestAmplitude, equals(1.0));
      expect(config.frequency, equals(1.2));
      expect(config.blurSpread, equals(16.0));
      expect(config.isTouchReactive, isTrue);
      expect(config.isGyroReactive, isTrue);
      expect(config.isEnabled, isTrue);
    });

    test('toJson and fromJson serialize and deserialize correctly', () {
      const original = AuroraSynthesizerConfig(
        waveStyle: AuroraWaveStyle.cyberpunkRibbon,
        colorMode: AuroraColorMode.cyanViolet,
        waveCount: 5,
        waveSpeed: 1.8,
        crestAmplitude: 1.5,
        frequency: 2.0,
        blurSpread: 24.0,
        isTouchReactive: false,
        isGyroReactive: false,
        isEnabled: false,
      );

      final json = original.toJson();
      final restored = AuroraSynthesizerConfig.fromJson(json);

      expect(restored, equals(original));
      expect(restored.waveStyle, equals(AuroraWaveStyle.cyberpunkRibbon));
      expect(restored.colorMode, equals(AuroraColorMode.cyanViolet));
      expect(restored.waveCount, equals(5));
      expect(restored.waveSpeed, equals(1.8));
      expect(restored.isTouchReactive, isFalse);
    });

    test('fromJson falls back safely on null or invalid keys', () {
      final restored = AuroraSynthesizerConfig.fromJson(const {});
      expect(restored.waveStyle, equals(AuroraWaveStyle.cosmicNorthernLights));
      expect(restored.colorMode, equals(AuroraColorMode.auraSync));
      expect(restored.waveCount, equals(3));
      expect(restored.isEnabled, isTrue);
    });

    test('copyWith updates fields as expected', () {
      const config = AuroraSynthesizerConfig.defaultConfig;
      final updated = config.copyWith(
        waveStyle: AuroraWaveStyle.solarFlarePlasma,
        waveCount: 6,
        isEnabled: false,
      );

      expect(updated.waveStyle, equals(AuroraWaveStyle.solarFlarePlasma));
      expect(updated.waveCount, equals(6));
      expect(updated.isEnabled, isFalse);
      expect(updated.colorMode, equals(config.colorMode));
      expect(updated.waveSpeed, equals(config.waveSpeed));
    });

    test('Equatable value equality works', () {
      const a = AuroraSynthesizerConfig(
        waveStyle: AuroraWaveStyle.bioluminescentDeepSea,
        waveCount: 4,
      );
      const b = AuroraSynthesizerConfig(
        waveStyle: AuroraWaveStyle.bioluminescentDeepSea,
        waveCount: 4,
      );
      const c = AuroraSynthesizerConfig(
        waveStyle: AuroraWaveStyle.monochromeOled,
        waveCount: 4,
      );

      expect(a, equals(b));
      expect(a == c, isFalse);
    });

    test('All styles and color modes have non-empty displayNames and descriptions', () {
      for (final style in AuroraWaveStyle.values) {
        expect(style.displayName.isNotEmpty, isTrue);
        expect(style.description.isNotEmpty, isTrue);
      }
      for (final mode in AuroraColorMode.values) {
        expect(mode.displayName.isNotEmpty, isTrue);
        expect(mode.description.isNotEmpty, isTrue);
      }
    });
  });
}
