import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// One-tap aesthetic motion presets for the 3D Spatial Parallax Engine.
enum ParallaxPreset {
  subtleBreath('Subtle Depth', Icons.air_rounded, 'Gentle responsive tilt for daily minimalist elegance.'),
  cinematic3D('Cinematic 3D', Icons.view_in_ar_rounded, 'Balanced multi-plane perspective with natural focal depth.'),
  deepSpatial('Deep Spatial Hologram', Icons.layers_rounded, 'Pronounced multi-layer separation with holographic aura.'),
  hyperFloat('Hyper Float', Icons.blur_linear_rounded, 'Exaggerated motion for dynamic action & gaming visuals.'),
  off('Disabled', Icons.motion_photos_off_rounded, 'Static viewport with zero sensor or gesture tilt.');

  final String label;
  final IconData icon;
  final String description;

  const ParallaxPreset(this.label, this.icon, this.description);
}

/// Configuration model governing the 3D Gyroscopic & Touch Parallax Motion Engine.
class ParallaxEffectConfig extends Equatable {
  final bool isEnabled;
  final double sensitivity;
  final double maxAngleDegrees;
  final bool invertPitch;
  final bool invertRoll;
  final double depthZoomScale;
  final ParallaxPreset preset;

  const ParallaxEffectConfig({
    this.isEnabled = true,
    this.sensitivity = 1.2,
    this.maxAngleDegrees = 12.0,
    this.invertPitch = false,
    this.invertRoll = false,
    this.depthZoomScale = 1.08,
    this.preset = ParallaxPreset.cinematic3D,
  });

  static const ParallaxEffectConfig defaultConfig = ParallaxEffectConfig();

  static const ParallaxEffectConfig subtlePreset = ParallaxEffectConfig(
    isEnabled: true,
    sensitivity: 0.8,
    maxAngleDegrees: 7.0,
    depthZoomScale: 1.05,
    preset: ParallaxPreset.subtleBreath,
  );

  static const ParallaxEffectConfig cinematicPreset = ParallaxEffectConfig(
    isEnabled: true,
    sensitivity: 1.2,
    maxAngleDegrees: 12.0,
    depthZoomScale: 1.08,
    preset: ParallaxPreset.cinematic3D,
  );

  static const ParallaxEffectConfig deepSpatialPreset = ParallaxEffectConfig(
    isEnabled: true,
    sensitivity: 1.8,
    maxAngleDegrees: 18.0,
    depthZoomScale: 1.12,
    preset: ParallaxPreset.deepSpatial,
  );

  static const ParallaxEffectConfig hyperFloatPreset = ParallaxEffectConfig(
    isEnabled: true,
    sensitivity: 2.4,
    maxAngleDegrees: 24.0,
    depthZoomScale: 1.16,
    preset: ParallaxPreset.hyperFloat,
  );

  static const ParallaxEffectConfig disabledPreset = ParallaxEffectConfig(
    isEnabled: false,
    sensitivity: 0.0,
    maxAngleDegrees: 0.0,
    depthZoomScale: 1.0,
    preset: ParallaxPreset.off,
  );

  ParallaxEffectConfig copyWith({
    bool? isEnabled,
    double? sensitivity,
    double? maxAngleDegrees,
    bool? invertPitch,
    bool? invertRoll,
    double? depthZoomScale,
    ParallaxPreset? preset,
  }) {
    return ParallaxEffectConfig(
      isEnabled: isEnabled ?? this.isEnabled,
      sensitivity: sensitivity ?? this.sensitivity,
      maxAngleDegrees: maxAngleDegrees ?? this.maxAngleDegrees,
      invertPitch: invertPitch ?? this.invertPitch,
      invertRoll: invertRoll ?? this.invertRoll,
      depthZoomScale: depthZoomScale ?? this.depthZoomScale,
      preset: preset ?? this.preset,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled,
      'sensitivity': sensitivity,
      'maxAngleDegrees': maxAngleDegrees,
      'invertPitch': invertPitch,
      'invertRoll': invertRoll,
      'depthZoomScale': depthZoomScale,
      'preset': preset.name,
    };
  }

  factory ParallaxEffectConfig.fromJson(Map<String, dynamic> json) {
    return ParallaxEffectConfig(
      isEnabled: json['isEnabled'] as bool? ?? true,
      sensitivity: (json['sensitivity'] as num?)?.toDouble() ?? 1.2,
      maxAngleDegrees: (json['maxAngleDegrees'] as num?)?.toDouble() ?? 12.0,
      invertPitch: json['invertPitch'] as bool? ?? false,
      invertRoll: json['invertRoll'] as bool? ?? false,
      depthZoomScale: (json['depthZoomScale'] as num?)?.toDouble() ?? 1.08,
      preset: ParallaxPreset.values.firstWhere(
        (p) => p.name == json['preset'],
        orElse: () => ParallaxPreset.cinematic3D,
      ),
    );
  }

  @override
  List<Object?> get props => [
        isEnabled,
        sensitivity,
        maxAngleDegrees,
        invertPitch,
        invertRoll,
        depthZoomScale,
        preset,
      ];
}
