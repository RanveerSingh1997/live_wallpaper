import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/models/particle_effect_config.dart';

void main() {
  group('ParticleEffectConfig', () {
    const defaultConfig = ParticleEffectConfig.defaultConfig;

    test('defaultConfig has expected factory defaults', () {
      expect(defaultConfig.preset, ParticlePreset.neonStardust);
      expect(defaultConfig.particleCount, 45);
      expect(defaultConfig.speedMultiplier, 1.0);
      expect(defaultConfig.lifespanSeconds, 2.0);
      expect(defaultConfig.glowIntensity, 0.75);
      expect(defaultConfig.isHapticsEnabled, isTrue);
      expect(defaultConfig.isBatteryGuardEnabled, isTrue);
      expect(defaultConfig.isEnabled, isTrue);
    });

    test('ParticlePreset properties and enabled states', () {
      expect(ParticlePreset.neonStardust.isEnabled, isTrue);
      expect(ParticlePreset.electricSparks.isEnabled, isTrue);
      expect(ParticlePreset.fluidRipples.isEnabled, isTrue);
      expect(ParticlePreset.sakuraDrift.isEnabled, isTrue);
      expect(ParticlePreset.auroraVortex.isEnabled, isTrue);
      expect(ParticlePreset.none.isEnabled, isFalse);

      expect(ParticlePreset.neonStardust.label, 'Neon Stardust');
      expect(ParticlePreset.electricSparks.label, 'Electric Sparks');
      expect(ParticlePreset.fluidRipples.label, 'Fluid Ripples');
      expect(ParticlePreset.sakuraDrift.label, 'Sakura Petal Drift');
      expect(ParticlePreset.auroraVortex.label, 'Aurora Vortex');
      expect(ParticlePreset.none.label, contains('Clean Canvas'));

      expect(ParticlePreset.neonStardust.accentColor, const Color(0xFF00E5FF));
      expect(ParticlePreset.electricSparks.accentColor, const Color(0xFFFF5722));
      expect(ParticlePreset.fluidRipples.accentColor, const Color(0xFF00E676));
      expect(ParticlePreset.sakuraDrift.accentColor, const Color(0xFFD500F9));
    });

    test('copyWith updates specified fields only', () {
      final updated = defaultConfig.copyWith(
        preset: ParticlePreset.electricSparks,
        particleCount: 80,
        speedMultiplier: 1.8,
        isHapticsEnabled: false,
      );

      expect(updated.preset, ParticlePreset.electricSparks);
      expect(updated.particleCount, 80);
      expect(updated.speedMultiplier, 1.8);
      expect(updated.lifespanSeconds, 2.0);
      expect(updated.glowIntensity, 0.75);
      expect(updated.isHapticsEnabled, isFalse);
      expect(updated.isBatteryGuardEnabled, isTrue);
    });

    test('JSON serialization round-trip', () {
      final config = const ParticleEffectConfig(
        preset: ParticlePreset.auroraVortex,
        particleCount: 65,
        speedMultiplier: 1.5,
        lifespanSeconds: 3.0,
        glowIntensity: 0.9,
        isHapticsEnabled: false,
        isBatteryGuardEnabled: true,
      );

      final json = config.toJson();
      final restored = ParticleEffectConfig.fromJson(json);

      expect(restored, equals(config));
      expect(restored.preset, ParticlePreset.auroraVortex);
      expect(restored.particleCount, 65);
      expect(restored.speedMultiplier, 1.5);
      expect(restored.lifespanSeconds, 3.0);
      expect(restored.glowIntensity, 0.9);
      expect(restored.isHapticsEnabled, isFalse);
      expect(restored.isBatteryGuardEnabled, isTrue);
    });

    test('fromJson handles fallback defaults on null or unknown values', () {
      final restored = ParticleEffectConfig.fromJson({
        'preset': 'unknown_preset',
      });

      expect(restored.preset, ParticlePreset.neonStardust);
      expect(restored.particleCount, 45);
      expect(restored.speedMultiplier, 1.0);
      expect(restored.lifespanSeconds, 2.0);
      expect(restored.glowIntensity, 0.75);
      expect(restored.isHapticsEnabled, isTrue);
      expect(restored.isBatteryGuardEnabled, isTrue);
    });
  });
}
