import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Available interactive particle visual styles.
enum ParticlePreset {
  neonStardust(
    label: 'Neon Stardust',
    description: 'Luminous ambient particles floating and scattering on touch',
    icon: Icons.auto_awesome_rounded,
    accentColor: Color(0xFF00E5FF),
  ),
  electricSparks(
    label: 'Electric Sparks',
    description: 'High-energy cyber sparks snapping from contact points',
    icon: Icons.bolt_rounded,
    accentColor: Color(0xFFFF5722),
  ),
  fluidRipples(
    label: 'Fluid Ripples',
    description: 'Concentric liquid wave rings dispersing outwards on touch',
    icon: Icons.waves_rounded,
    accentColor: Color(0xFF00E676),
  ),
  sakuraDrift(
    label: 'Sakura Petal Drift',
    description: 'Soft ethereal blossom petals dancing in ambient air',
    icon: Icons.spa_rounded,
    accentColor: Color(0xFFD500F9),
  ),
  auroraVortex(
    label: 'Aurora Vortex',
    description: 'Swirling Northern Lights ribbon trails following gestures',
    icon: Icons.blur_circular_rounded,
    accentColor: Color(0xFF00E5FF),
  ),
  none(
    label: 'Clean Canvas (Off)',
    description: 'Zero particle overlays for unadorned video playback',
    icon: Icons.block_rounded,
    accentColor: Colors.white54,
  );

  final String label;
  final String description;
  final IconData icon;
  final Color accentColor;

  const ParticlePreset({
    required this.label,
    required this.description,
    required this.icon,
    required this.accentColor,
  });

  String get displayName => label;
  bool get isEnabled => this != ParticlePreset.none;
}

/// Configuration for Wallora real-time interactive particle physics and touch FX.
class ParticleEffectConfig extends Equatable {
  final ParticlePreset preset;
  final int particleCount;
  final double speedMultiplier;
  final double lifespanSeconds;
  final double glowIntensity;
  final bool isHapticsEnabled;
  final bool isBatteryGuardEnabled;

  const ParticleEffectConfig({
    this.preset = ParticlePreset.neonStardust,
    this.particleCount = 45,
    this.speedMultiplier = 1.0,
    this.lifespanSeconds = 2.0,
    this.glowIntensity = 0.75,
    this.isHapticsEnabled = true,
    this.isBatteryGuardEnabled = true,
  });

  static const ParticleEffectConfig defaultConfig = ParticleEffectConfig();

  bool get isEnabled => preset.isEnabled;

  ParticleEffectConfig copyWith({
    ParticlePreset? preset,
    int? particleCount,
    double? speedMultiplier,
    double? lifespanSeconds,
    double? glowIntensity,
    bool? isHapticsEnabled,
    bool? isBatteryGuardEnabled,
  }) {
    return ParticleEffectConfig(
      preset: preset ?? this.preset,
      particleCount: particleCount ?? this.particleCount,
      speedMultiplier: speedMultiplier ?? this.speedMultiplier,
      lifespanSeconds: lifespanSeconds ?? this.lifespanSeconds,
      glowIntensity: glowIntensity ?? this.glowIntensity,
      isHapticsEnabled: isHapticsEnabled ?? this.isHapticsEnabled,
      isBatteryGuardEnabled:
          isBatteryGuardEnabled ?? this.isBatteryGuardEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preset': preset.name,
      'particleCount': particleCount,
      'speedMultiplier': speedMultiplier,
      'lifespanSeconds': lifespanSeconds,
      'glowIntensity': glowIntensity,
      'isHapticsEnabled': isHapticsEnabled,
      'isBatteryGuardEnabled': isBatteryGuardEnabled,
    };
  }

  factory ParticleEffectConfig.fromJson(Map<String, dynamic> json) {
    ParticlePreset parsePreset(String? name) {
      if (name == null) return ParticlePreset.neonStardust;
      return ParticlePreset.values.firstWhere(
        (e) => e.name == name,
        orElse: () => ParticlePreset.neonStardust,
      );
    }

    return ParticleEffectConfig(
      preset: parsePreset(json['preset'] as String?),
      particleCount: json['particleCount'] as int? ?? 45,
      speedMultiplier: (json['speedMultiplier'] as num?)?.toDouble() ?? 1.0,
      lifespanSeconds: (json['lifespanSeconds'] as num?)?.toDouble() ?? 2.0,
      glowIntensity: (json['glowIntensity'] as num?)?.toDouble() ?? 0.75,
      isHapticsEnabled: json['isHapticsEnabled'] as bool? ?? true,
      isBatteryGuardEnabled: json['isBatteryGuardEnabled'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        preset,
        particleCount,
        speedMultiplier,
        lifespanSeconds,
        glowIntensity,
        isHapticsEnabled,
        isBatteryGuardEnabled,
      ];
}
