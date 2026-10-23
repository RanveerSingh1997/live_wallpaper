import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/models/weather_atmosphere_config.dart';

void main() {
  group('WeatherAtmosphereConfig Model Tests', () {
    test('default configuration has expected defaults and isEnabled true', () {
      const config = WeatherAtmosphereConfig.defaultConfig;
      expect(config.effectType, equals(WeatherEffectType.cyberRain));
      expect(config.intensity, equals(0.6));
      expect(config.speedMultiplier, equals(1.0));
      expect(config.windAngleDegrees, equals(65.0));
      expect(config.isGyroTiltEnabled, isTrue);
      expect(config.isLightningEnabled, isTrue);
      expect(config.isBatteryGuardEnabled, isTrue);
      expect(config.isEnabled, isTrue);
    });

    test('WeatherEffectType.none sets isEnabled to false', () {
      const config = WeatherAtmosphereConfig(effectType: WeatherEffectType.none);
      expect(config.isEnabled, isFalse);
    });

    test('presets have distinct types and properties', () {
      expect(WeatherAtmosphereConfig.cyberRainPreset.effectType,
          equals(WeatherEffectType.cyberRain));
      expect(WeatherAtmosphereConfig.cosmicSnowPreset.effectType,
          equals(WeatherEffectType.cosmicSnow));
      expect(WeatherAtmosphereConfig.thunderstormPreset.effectType,
          equals(WeatherEffectType.thunderstorm));
      expect(WeatherAtmosphereConfig.solarSunbeamsPreset.effectType,
          equals(WeatherEffectType.solarSunbeams));
      expect(WeatherAtmosphereConfig.etherealMistPreset.effectType,
          equals(WeatherEffectType.etherealMist));
      expect(WeatherAtmosphereConfig.meteorShowerPreset.effectType,
          equals(WeatherEffectType.meteorShower));
    });

    test('copyWith properly updates selected fields and preserves others', () {
      const initial = WeatherAtmosphereConfig.defaultConfig;
      final updated = initial.copyWith(
        effectType: WeatherEffectType.meteorShower,
        intensity: 0.9,
        speedMultiplier: 2.0,
      );

      expect(updated.effectType, equals(WeatherEffectType.meteorShower));
      expect(updated.intensity, equals(0.9));
      expect(updated.speedMultiplier, equals(2.0));
      expect(updated.windAngleDegrees, equals(initial.windAngleDegrees));
      expect(updated.isGyroTiltEnabled, equals(initial.isGyroTiltEnabled));
    });

    test('toJson and fromJson serialize and deserialize symmetrically', () {
      const config = WeatherAtmosphereConfig(
        effectType: WeatherEffectType.thunderstorm,
        intensity: 0.85,
        speedMultiplier: 1.5,
        windAngleDegrees: 75.0,
        isGyroTiltEnabled: false,
        isLightningEnabled: true,
        isBatteryGuardEnabled: false,
      );

      final json = config.toJson();
      final fromJson = WeatherAtmosphereConfig.fromJson(json);

      expect(fromJson, equals(config));
    });

    test('equality and hashCode adhere to Equatable contract', () {
      const c1 = WeatherAtmosphereConfig(
        effectType: WeatherEffectType.cosmicSnow,
        intensity: 0.5,
      );
      const c2 = WeatherAtmosphereConfig(
        effectType: WeatherEffectType.cosmicSnow,
        intensity: 0.5,
      );
      const c3 = WeatherAtmosphereConfig(
        effectType: WeatherEffectType.cosmicSnow,
        intensity: 0.8,
      );

      expect(c1, equals(c2));
      expect(c1.hashCode, equals(c2.hashCode));
      expect(c1, isNot(equals(c3)));
    });
  });
}
