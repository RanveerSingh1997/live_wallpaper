import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Available procedural wave styles for the Wallora Aurora Synthesizer.
enum AuroraWaveStyle {
  cosmicNorthernLights(
    label: 'Cosmic Northern Lights',
    description: 'Ethereal curtains of celestial emerald and radiant cyan waves',
    icon: Icons.waves_rounded,
  ),
  cyberpunkRibbon(
    label: 'Cyberpunk Laser Ribbon',
    description: 'Sharp, vibrant electric laser ribbons in neon violet and cyan',
    icon: Icons.electric_bolt_rounded,
  ),
  solarFlarePlasma(
    label: 'Solar Flare Plasma',
    description: 'Warm radiant coronal waves, fiery amber plasma and magma crests',
    icon: Icons.wb_sunny_rounded,
  ),
  bioluminescentDeepSea(
    label: 'Bioluminescent Abyss',
    description: 'Deep oceanic bioluminescent glow with soothing harmonic pulses',
    icon: Icons.water_rounded,
  ),
  monochromeOled(
    label: 'AMOLED Minimalist Noir',
    description: 'Pure obsidian black background with crisp white-silver ridges',
    icon: Icons.dark_mode_rounded,
  );

  final String label;
  final String description;
  final IconData icon;

  const AuroraWaveStyle({
    required this.label,
    required this.description,
    required this.icon,
  });

  String get displayName => label;
}

/// Color modes for procedural aurora wave generation.
enum AuroraColorMode {
  auraSync(
    label: 'Aura Chromatic Sync',
    description: 'Harmonizes dynamically with the active 5-point Aura palette',
    icon: Icons.palette_rounded,
  ),
  cyanViolet(
    label: 'Wallora Signature',
    description: 'Electric cyan (#00E5FF) and aurora violet (#D500F9)',
    icon: Icons.auto_awesome_rounded,
  ),
  amberEmerald(
    label: 'Solar Aurora',
    description: 'Fiery sunset amber (#FF5722) and emerald neon (#00E676)',
    icon: Icons.local_fire_department_rounded,
  ),
  pureOledRed(
    label: 'Circadian Crimson',
    description: 'Monochrome pure red (#FF3B30) for night vision and sleep',
    icon: Icons.bedtime_rounded,
  );

  final String label;
  final String description;
  final IconData icon;

  const AuroraColorMode({
    required this.label,
    required this.description,
    required this.icon,
  });

  String get displayName => label;
}

/// Configuration for the Wallora Procedural Aurora Wave Synthesizer.
class AuroraSynthesizerConfig extends Equatable {
  final AuroraWaveStyle waveStyle;
  final AuroraColorMode colorMode;
  final int waveCount;
  final double waveSpeed;
  final double crestAmplitude;
  final double frequency;
  final double blurSpread;
  final bool isTouchReactive;
  final bool isGyroReactive;
  final bool isEnabled;

  const AuroraSynthesizerConfig({
    this.waveStyle = AuroraWaveStyle.cosmicNorthernLights,
    this.colorMode = AuroraColorMode.auraSync,
    this.waveCount = 3,
    this.waveSpeed = 1.0,
    this.crestAmplitude = 1.0,
    this.frequency = 1.2,
    this.blurSpread = 16.0,
    this.isTouchReactive = true,
    this.isGyroReactive = true,
    this.isEnabled = true,
  });

  static const AuroraSynthesizerConfig defaultConfig = AuroraSynthesizerConfig();

  AuroraSynthesizerConfig copyWith({
    AuroraWaveStyle? waveStyle,
    AuroraColorMode? colorMode,
    int? waveCount,
    double? waveSpeed,
    double? crestAmplitude,
    double? frequency,
    double? blurSpread,
    bool? isTouchReactive,
    bool? isGyroReactive,
    bool? isEnabled,
  }) {
    return AuroraSynthesizerConfig(
      waveStyle: waveStyle ?? this.waveStyle,
      colorMode: colorMode ?? this.colorMode,
      waveCount: waveCount ?? this.waveCount,
      waveSpeed: waveSpeed ?? this.waveSpeed,
      crestAmplitude: crestAmplitude ?? this.crestAmplitude,
      frequency: frequency ?? this.frequency,
      blurSpread: blurSpread ?? this.blurSpread,
      isTouchReactive: isTouchReactive ?? this.isTouchReactive,
      isGyroReactive: isGyroReactive ?? this.isGyroReactive,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'waveStyle': waveStyle.name,
      'colorMode': colorMode.name,
      'waveCount': waveCount,
      'waveSpeed': waveSpeed,
      'crestAmplitude': crestAmplitude,
      'frequency': frequency,
      'blurSpread': blurSpread,
      'isTouchReactive': isTouchReactive,
      'isGyroReactive': isGyroReactive,
      'isEnabled': isEnabled,
    };
  }

  factory AuroraSynthesizerConfig.fromJson(Map<String, dynamic> json) {
    AuroraWaveStyle parseWaveStyle(String? name) {
      if (name == null) return AuroraWaveStyle.cosmicNorthernLights;
      return AuroraWaveStyle.values.firstWhere(
        (e) => e.name == name,
        orElse: () => AuroraWaveStyle.cosmicNorthernLights,
      );
    }

    AuroraColorMode parseColorMode(String? name) {
      if (name == null) return AuroraColorMode.auraSync;
      return AuroraColorMode.values.firstWhere(
        (e) => e.name == name,
        orElse: () => AuroraColorMode.auraSync,
      );
    }

    return AuroraSynthesizerConfig(
      waveStyle: parseWaveStyle(json['waveStyle'] as String?),
      colorMode: parseColorMode(json['colorMode'] as String?),
      waveCount: json['waveCount'] as int? ?? 3,
      waveSpeed: (json['waveSpeed'] as num?)?.toDouble() ?? 1.0,
      crestAmplitude: (json['crestAmplitude'] as num?)?.toDouble() ?? 1.0,
      frequency: (json['frequency'] as num?)?.toDouble() ?? 1.2,
      blurSpread: (json['blurSpread'] as num?)?.toDouble() ?? 16.0,
      isTouchReactive: json['isTouchReactive'] as bool? ?? true,
      isGyroReactive: json['isGyroReactive'] as bool? ?? true,
      isEnabled: json['isEnabled'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        waveStyle,
        colorMode,
        waveCount,
        waveSpeed,
        crestAmplitude,
        frequency,
        blurSpread,
        isTouchReactive,
        isGyroReactive,
        isEnabled,
      ];
}
