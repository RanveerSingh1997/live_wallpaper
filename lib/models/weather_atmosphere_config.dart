import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../core/core.dart';

/// Available atmospheric weather and climate particle effects.
enum WeatherEffectType {
  none(
    label: 'Clean Canvas (Off)',
    description: 'Zero atmospheric overlays for pure wallpaper aesthetics',
    icon: Icons.cloud_off_rounded,
    accentColor: Colors.white54,
  ),
  cyberRain(
    label: 'Cyberpunk Rain & Drizzle',
    description: 'Slanted luminous cyan rainfall streaks with ambient ripple dispersion',
    icon: Icons.water_drop_rounded,
    accentColor: AppColors.neonCyan,
  ),
  cosmicSnow(
    label: 'Cosmic Snow & Blizzard',
    description: 'Soft ethereal crystalline snow particles drifting with fluid air currents',
    icon: Icons.ac_unit_rounded,
    accentColor: Color(0xFFE0E0E0),
  ),
  thunderstorm(
    label: 'Neon Thunderstorm',
    description: 'Dynamic precipitation with dramatic atmospheric lightning glow pulses',
    icon: Icons.thunderstorm_rounded,
    accentColor: AppColors.auroraViolet,
  ),
  solarSunbeams(
    label: 'Solar God Rays',
    description: 'Warm volumetric sunbeam shafts gently sweeping across the screen',
    icon: Icons.wb_sunny_rounded,
    accentColor: AppColors.solarGold,
  ),
  etherealMist(
    label: 'Ethereal Nebula Mist',
    description: 'Rolling atmospheric vapor drifts and deep celestial cloud curtains',
    icon: Icons.cloud_rounded,
    accentColor: AppColors.auroraEmerald,
  ),
  meteorShower(
    label: 'Meteor Shower & Starfall',
    description: 'High-speed incandescent shooting stars streaking across the cosmos',
    icon: Icons.auto_awesome_rounded,
    accentColor: AppColors.sunsetAmber,
  );

  final String label;
  final String description;
  final IconData icon;
  final Color accentColor;

  const WeatherEffectType({
    required this.label,
    required this.description,
    required this.icon,
    required this.accentColor,
  });

  String get displayName => label;
  bool get isEnabled => this != WeatherEffectType.none;
}

/// Configuration governing Wallora's real-time atmospheric weather and climate FX engine.
class WeatherAtmosphereConfig extends Equatable {
  final WeatherEffectType effectType;
  final double intensity; // 0.1 to 1.0 (density / particle quantity)
  final double speedMultiplier; // 0.5 to 2.5
  final double windAngleDegrees; // 0.0 to 360.0 (slant angle)
  final bool isGyroTiltEnabled; // responds to gyroscopic device tilt
  final bool isLightningEnabled; // triggers periodic atmospheric aura flashes
  final bool isBatteryGuardEnabled; // throttles particle count in low power

  const WeatherAtmosphereConfig({
    this.effectType = WeatherEffectType.cyberRain,
    this.intensity = 0.6,
    this.speedMultiplier = 1.0,
    this.windAngleDegrees = 65.0,
    this.isGyroTiltEnabled = true,
    this.isLightningEnabled = true,
    this.isBatteryGuardEnabled = true,
  });

  static const WeatherAtmosphereConfig defaultConfig = WeatherAtmosphereConfig();

  static const WeatherAtmosphereConfig cyberRainPreset = WeatherAtmosphereConfig(
    effectType: WeatherEffectType.cyberRain,
    intensity: 0.7,
    speedMultiplier: 1.2,
    windAngleDegrees: 70.0,
    isGyroTiltEnabled: true,
    isLightningEnabled: false,
    isBatteryGuardEnabled: true,
  );

  static const WeatherAtmosphereConfig cosmicSnowPreset = WeatherAtmosphereConfig(
    effectType: WeatherEffectType.cosmicSnow,
    intensity: 0.5,
    speedMultiplier: 0.8,
    windAngleDegrees: 85.0,
    isGyroTiltEnabled: true,
    isLightningEnabled: false,
    isBatteryGuardEnabled: true,
  );

  static const WeatherAtmosphereConfig thunderstormPreset = WeatherAtmosphereConfig(
    effectType: WeatherEffectType.thunderstorm,
    intensity: 0.85,
    speedMultiplier: 1.4,
    windAngleDegrees: 60.0,
    isGyroTiltEnabled: true,
    isLightningEnabled: true,
    isBatteryGuardEnabled: true,
  );

  static const WeatherAtmosphereConfig solarSunbeamsPreset = WeatherAtmosphereConfig(
    effectType: WeatherEffectType.solarSunbeams,
    intensity: 0.65,
    speedMultiplier: 0.7,
    windAngleDegrees: 45.0,
    isGyroTiltEnabled: true,
    isLightningEnabled: false,
    isBatteryGuardEnabled: true,
  );

  static const WeatherAtmosphereConfig etherealMistPreset = WeatherAtmosphereConfig(
    effectType: WeatherEffectType.etherealMist,
    intensity: 0.6,
    speedMultiplier: 0.6,
    windAngleDegrees: 90.0,
    isGyroTiltEnabled: false,
    isLightningEnabled: false,
    isBatteryGuardEnabled: true,
  );

  static const WeatherAtmosphereConfig meteorShowerPreset = WeatherAtmosphereConfig(
    effectType: WeatherEffectType.meteorShower,
    intensity: 0.75,
    speedMultiplier: 1.6,
    windAngleDegrees: 55.0,
    isGyroTiltEnabled: true,
    isLightningEnabled: false,
    isBatteryGuardEnabled: true,
  );

  bool get isEnabled => effectType.isEnabled;

  WeatherAtmosphereConfig copyWith({
    WeatherEffectType? effectType,
    double? intensity,
    double? speedMultiplier,
    double? windAngleDegrees,
    bool? isGyroTiltEnabled,
    bool? isLightningEnabled,
    bool? isBatteryGuardEnabled,
  }) {
    return WeatherAtmosphereConfig(
      effectType: effectType ?? this.effectType,
      intensity: intensity ?? this.intensity,
      speedMultiplier: speedMultiplier ?? this.speedMultiplier,
      windAngleDegrees: windAngleDegrees ?? this.windAngleDegrees,
      isGyroTiltEnabled: isGyroTiltEnabled ?? this.isGyroTiltEnabled,
      isLightningEnabled: isLightningEnabled ?? this.isLightningEnabled,
      isBatteryGuardEnabled:
          isBatteryGuardEnabled ?? this.isBatteryGuardEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'effectType': effectType.name,
      'intensity': intensity,
      'speedMultiplier': speedMultiplier,
      'windAngleDegrees': windAngleDegrees,
      'isGyroTiltEnabled': isGyroTiltEnabled,
      'isLightningEnabled': isLightningEnabled,
      'isBatteryGuardEnabled': isBatteryGuardEnabled,
    };
  }

  factory WeatherAtmosphereConfig.fromJson(Map<String, dynamic> json) {
    return WeatherAtmosphereConfig(
      effectType: WeatherEffectType.values.firstWhere(
        (e) => e.name == json['effectType'],
        orElse: () => WeatherEffectType.cyberRain,
      ),
      intensity: (json['intensity'] as num?)?.toDouble() ?? 0.6,
      speedMultiplier: (json['speedMultiplier'] as num?)?.toDouble() ?? 1.0,
      windAngleDegrees: (json['windAngleDegrees'] as num?)?.toDouble() ?? 65.0,
      isGyroTiltEnabled: json['isGyroTiltEnabled'] as bool? ?? true,
      isLightningEnabled: json['isLightningEnabled'] as bool? ?? true,
      isBatteryGuardEnabled: json['isBatteryGuardEnabled'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        effectType,
        intensity,
        speedMultiplier,
        windAngleDegrees,
        isGyroTiltEnabled,
        isLightningEnabled,
        isBatteryGuardEnabled,
      ];
}
