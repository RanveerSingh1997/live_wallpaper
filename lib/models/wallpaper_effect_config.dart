import 'package:equatable/equatable.dart';

/// Configuration for post-processing visual effects and filters applied to a wallpaper canvas.
class WallpaperEffectConfig extends Equatable {
  final double blurSigma;
  final double vignetteStrength;
  final double brightness;
  final double contrast;
  final String colorFilterPreset;
  final double filmGrainStrength;

  const WallpaperEffectConfig({
    this.blurSigma = 0.0,
    this.vignetteStrength = 0.0,
    this.brightness = 0.0,
    this.contrast = 1.0,
    this.colorFilterPreset = 'original',
    this.filmGrainStrength = 0.0,
  });

  static const WallpaperEffectConfig defaultPreset = WallpaperEffectConfig();
  static const WallpaperEffectConfig defaultConfig = defaultPreset;

  static const WallpaperEffectConfig noirPreset = WallpaperEffectConfig(
    colorFilterPreset: 'noir',
    contrast: 1.25,
    vignetteStrength: 0.35,
  );

  static const WallpaperEffectConfig cyberPreset = WallpaperEffectConfig(
    colorFilterPreset: 'cyber_cyan',
    contrast: 1.2,
    brightness: 0.05,
    vignetteStrength: 0.2,
  );

  static const WallpaperEffectConfig sunsetPreset = WallpaperEffectConfig(
    colorFilterPreset: 'sunset_amber',
    contrast: 1.15,
    brightness: 0.02,
    vignetteStrength: 0.2,
  );

  static const WallpaperEffectConfig matrixPreset = WallpaperEffectConfig(
    colorFilterPreset: 'matrix_emerald',
    contrast: 1.2,
    vignetteStrength: 0.3,
  );

  static const WallpaperEffectConfig auroraPreset = WallpaperEffectConfig(
    colorFilterPreset: 'aurora_violet',
    contrast: 1.15,
    brightness: 0.05,
    vignetteStrength: 0.25,
  );

  static const WallpaperEffectConfig softBlurPreset = WallpaperEffectConfig(
    blurSigma: 8.0,
    vignetteStrength: 0.3,
  );

  bool get isDefault =>
      blurSigma == 0.0 &&
      vignetteStrength == 0.0 &&
      brightness == 0.0 &&
      contrast == 1.0 &&
      colorFilterPreset == 'original' &&
      filmGrainStrength == 0.0;

  WallpaperEffectConfig copyWith({
    double? blurSigma,
    double? vignetteStrength,
    double? brightness,
    double? contrast,
    String? colorFilterPreset,
    double? filmGrainStrength,
  }) {
    return WallpaperEffectConfig(
      blurSigma: blurSigma ?? this.blurSigma,
      vignetteStrength: vignetteStrength ?? this.vignetteStrength,
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      colorFilterPreset: colorFilterPreset ?? this.colorFilterPreset,
      filmGrainStrength: filmGrainStrength ?? this.filmGrainStrength,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'blurSigma': blurSigma,
      'vignetteStrength': vignetteStrength,
      'brightness': brightness,
      'contrast': contrast,
      'colorFilterPreset': colorFilterPreset,
      'filmGrainStrength': filmGrainStrength,
    };
  }

  factory WallpaperEffectConfig.fromJson(Map<String, dynamic> json) {
    return WallpaperEffectConfig(
      blurSigma: (json['blurSigma'] as num?)?.toDouble() ?? 0.0,
      vignetteStrength: (json['vignetteStrength'] as num?)?.toDouble() ?? 0.0,
      brightness: (json['brightness'] as num?)?.toDouble() ?? 0.0,
      contrast: (json['contrast'] as num?)?.toDouble() ?? 1.0,
      colorFilterPreset: json['colorFilterPreset'] as String? ?? 'original',
      filmGrainStrength: (json['filmGrainStrength'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [
        blurSigma,
        vignetteStrength,
        brightness,
        contrast,
        colorFilterPreset,
        filmGrainStrength,
      ];
}
