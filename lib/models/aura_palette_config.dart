import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'motivational_short.dart';

/// Predefined chromatic Aura theme presets for Wallora.
enum AuraThemePreset {
  wallpaperDynamic,
  cyberAurora,
  solarEclipse,
  emeraldMatrix,
  velvetTwilight,
  obsidianMonochrome;

  String get displayName {
    switch (this) {
      case AuraThemePreset.wallpaperDynamic:
        return 'Wallpaper Reactive (Auto)';
      case AuraThemePreset.cyberAurora:
        return 'Cyber Aurora';
      case AuraThemePreset.solarEclipse:
        return 'Solar Eclipse';
      case AuraThemePreset.emeraldMatrix:
        return 'Emerald Matrix';
      case AuraThemePreset.velvetTwilight:
        return 'Velvet Twilight';
      case AuraThemePreset.obsidianMonochrome:
        return 'Obsidian Monochrome';
    }
  }

  String get description {
    switch (this) {
      case AuraThemePreset.wallpaperDynamic:
        return 'Harmonizes dynamically with dominant colors of active wallpaper';
      case AuraThemePreset.cyberAurora:
        return 'Electric cyan and vivid aurora violet neon contrast';
      case AuraThemePreset.solarEclipse:
        return 'Radiant sunset amber, solar flare gold, and warm embers';
      case AuraThemePreset.emeraldMatrix:
        return 'Bioluminescent cyber mint and deep oceanic emerald tones';
      case AuraThemePreset.velvetTwilight:
        return 'Mystic cosmic purple and cherry blossom luminescence';
      case AuraThemePreset.obsidianMonochrome:
        return 'AMOLED deep blacks with pure titanium silver accents';
    }
  }

  IconData get icon {
    switch (this) {
      case AuraThemePreset.wallpaperDynamic:
        return Icons.auto_awesome_rounded;
      case AuraThemePreset.cyberAurora:
        return Icons.waves_rounded;
      case AuraThemePreset.solarEclipse:
        return Icons.wb_sunny_rounded;
      case AuraThemePreset.emeraldMatrix:
        return Icons.bolt_rounded;
      case AuraThemePreset.velvetTwilight:
        return Icons.nights_stay_rounded;
      case AuraThemePreset.obsidianMonochrome:
        return Icons.contrast_rounded;
    }
  }

  Color get primaryAccent {
    switch (this) {
      case AuraThemePreset.wallpaperDynamic:
        return const Color(0xFF00E5FF);
      case AuraThemePreset.cyberAurora:
        return const Color(0xFF00E5FF);
      case AuraThemePreset.solarEclipse:
        return const Color(0xFFFF5722);
      case AuraThemePreset.emeraldMatrix:
        return const Color(0xFF00E676);
      case AuraThemePreset.velvetTwilight:
        return const Color(0xFF7C4DFF);
      case AuraThemePreset.obsidianMonochrome:
        return const Color(0xFFE0E0E0);
    }
  }

  Color get secondaryAccent {
    switch (this) {
      case AuraThemePreset.wallpaperDynamic:
        return const Color(0xFFD500F9);
      case AuraThemePreset.cyberAurora:
        return const Color(0xFFD500F9);
      case AuraThemePreset.solarEclipse:
        return const Color(0xFFFFD600);
      case AuraThemePreset.emeraldMatrix:
        return const Color(0xFF00B0FF);
      case AuraThemePreset.velvetTwilight:
        return const Color(0xFFFF4081);
      case AuraThemePreset.obsidianMonochrome:
        return const Color(0xFF90A4AE);
    }
  }
}

/// Resolved 5-tone chromatic Aura palette.
class AuraResolvedPalette extends Equatable {
  final Color dominant;
  final Color vibrantNeon;
  final Color harmonicSecondary;
  final Color deepOledTone;
  final Color etherealGlow;

  const AuraResolvedPalette({
    required this.dominant,
    required this.vibrantNeon,
    required this.harmonicSecondary,
    required this.deepOledTone,
    required this.etherealGlow,
  });

  List<Color> get allSwatches => [
        dominant,
        vibrantNeon,
        harmonicSecondary,
        deepOledTone,
        etherealGlow,
      ];

  @override
  List<Object?> get props => [
        dominant,
        vibrantNeon,
        harmonicSecondary,
        deepOledTone,
        etherealGlow,
      ];
}

/// Configuration for Wallora's Dynamic Color & Aura Harmonizer Engine.
class AuraPaletteConfig extends Equatable {
  final AuraThemePreset preset;
  final bool isDynamicThemingEnabled;
  final bool syncParticles;
  final bool syncKineticQuotes;
  final bool syncLockScreen;
  final double hueShiftDegrees; // -180.0 to 180.0
  final double saturationMultiplier; // 0.5 to 1.5
  final Color? customPrimaryColor;
  final Color? customAccentColor;

  const AuraPaletteConfig({
    this.preset = AuraThemePreset.wallpaperDynamic,
    this.isDynamicThemingEnabled = true,
    this.syncParticles = true,
    this.syncKineticQuotes = true,
    this.syncLockScreen = true,
    this.hueShiftDegrees = 0.0,
    this.saturationMultiplier = 1.0,
    this.customPrimaryColor,
    this.customAccentColor,
  });

  static const AuraPaletteConfig defaultConfig = AuraPaletteConfig();

  /// Resolves the 5-point chromatic palette based on active settings and wallpaper.
  AuraResolvedPalette resolvePalette(MotivationalShort? currentWallpaper) {
    Color baseDominant;
    Color baseVibrant;
    Color baseSecondary;

    if (preset == AuraThemePreset.wallpaperDynamic && currentWallpaper != null) {
      if (currentWallpaper.gradientColors.isNotEmpty) {
        baseDominant = currentWallpaper.gradientColors.first;
        baseVibrant = currentWallpaper.gradientColors.length > 1
            ? currentWallpaper.gradientColors[1]
            : _generateVibrantAccent(baseDominant);
        baseSecondary = currentWallpaper.gradientColors.length > 2
            ? currentWallpaper.gradientColors[2]
            : _generateComplement(baseVibrant);
      } else {
        baseDominant = const Color(0xFF00E5FF);
        baseVibrant = const Color(0xFFD500F9);
        baseSecondary = const Color(0xFFFF5722);
      }
    } else {
      baseDominant = customPrimaryColor ?? preset.primaryAccent;
      baseVibrant = customAccentColor ?? preset.secondaryAccent;
      baseSecondary = _generateComplement(baseVibrant);
    }

    final adjustedDominant = _applyTransforms(baseDominant);
    final adjustedVibrant = _applyTransforms(baseVibrant);
    final adjustedSecondary = _applyTransforms(baseSecondary);

    final deepOled = Color.fromARGB(
      255,
      (adjustedDominant.r * 255 * 0.12).round().clamp(0, 255),
      (adjustedDominant.g * 255 * 0.12).round().clamp(0, 255),
      (adjustedDominant.b * 255 * 0.12).round().clamp(0, 255),
    );

    final etherealGlow = Color.fromARGB(
      255,
      ((adjustedVibrant.r * 255 * 0.7) + 60).round().clamp(0, 255),
      ((adjustedVibrant.g * 255 * 0.7) + 60).round().clamp(0, 255),
      ((adjustedVibrant.b * 255 * 0.7) + 60).round().clamp(0, 255),
    );

    return AuraResolvedPalette(
      dominant: adjustedDominant,
      vibrantNeon: adjustedVibrant,
      harmonicSecondary: adjustedSecondary,
      deepOledTone: deepOled,
      etherealGlow: etherealGlow,
    );
  }

  Color _applyTransforms(Color color) {
    if (hueShiftDegrees == 0.0 && saturationMultiplier == 1.0) {
      return color;
    }
    final hsv = HSVColor.fromColor(color);
    var newHue = (hsv.hue + hueShiftDegrees) % 360.0;
    if (newHue < 0) newHue += 360.0;
    final newSat = (hsv.saturation * saturationMultiplier).clamp(0.0, 1.0);
    return hsv.withHue(newHue).withSaturation(newSat).toColor();
  }

  static Color _generateVibrantAccent(Color base) {
    final hsv = HSVColor.fromColor(base);
    final newHue = (hsv.hue + 60.0) % 360.0;
    return HSVColor.fromAHSV(1.0, newHue, 0.85, 0.95).toColor();
  }

  static Color _generateComplement(Color base) {
    final hsv = HSVColor.fromColor(base);
    final newHue = (hsv.hue + 180.0) % 360.0;
    return HSVColor.fromAHSV(1.0, newHue, 0.75, 0.9).toColor();
  }

  AuraPaletteConfig copyWith({
    AuraThemePreset? preset,
    bool? isDynamicThemingEnabled,
    bool? syncParticles,
    bool? syncKineticQuotes,
    bool? syncLockScreen,
    double? hueShiftDegrees,
    double? saturationMultiplier,
    Color? customPrimaryColor,
    Color? customAccentColor,
  }) {
    return AuraPaletteConfig(
      preset: preset ?? this.preset,
      isDynamicThemingEnabled:
          isDynamicThemingEnabled ?? this.isDynamicThemingEnabled,
      syncParticles: syncParticles ?? this.syncParticles,
      syncKineticQuotes: syncKineticQuotes ?? this.syncKineticQuotes,
      syncLockScreen: syncLockScreen ?? this.syncLockScreen,
      hueShiftDegrees: hueShiftDegrees ?? this.hueShiftDegrees,
      saturationMultiplier:
          saturationMultiplier ?? this.saturationMultiplier,
      customPrimaryColor: customPrimaryColor ?? this.customPrimaryColor,
      customAccentColor: customAccentColor ?? this.customAccentColor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preset': preset.name,
      'isDynamicThemingEnabled': isDynamicThemingEnabled,
      'syncParticles': syncParticles,
      'syncKineticQuotes': syncKineticQuotes,
      'syncLockScreen': syncLockScreen,
      'hueShiftDegrees': hueShiftDegrees,
      'saturationMultiplier': saturationMultiplier,
      'customPrimaryColor': customPrimaryColor?.toARGB32(),
      'customAccentColor': customAccentColor?.toARGB32(),
    };
  }

  factory AuraPaletteConfig.fromJson(Map<String, dynamic> json) {
    final presetName = json['preset'] as String?;
    final preset = AuraThemePreset.values.firstWhere(
      (e) => e.name == presetName,
      orElse: () => AuraThemePreset.wallpaperDynamic,
    );

    return AuraPaletteConfig(
      preset: preset,
      isDynamicThemingEnabled: json['isDynamicThemingEnabled'] as bool? ?? true,
      syncParticles: json['syncParticles'] as bool? ?? true,
      syncKineticQuotes: json['syncKineticQuotes'] as bool? ?? true,
      syncLockScreen: json['syncLockScreen'] as bool? ?? true,
      hueShiftDegrees: (json['hueShiftDegrees'] as num?)?.toDouble() ?? 0.0,
      saturationMultiplier:
          (json['saturationMultiplier'] as num?)?.toDouble() ?? 1.0,
      customPrimaryColor: json['customPrimaryColor'] != null
          ? Color(json['customPrimaryColor'] as int)
          : null,
      customAccentColor: json['customAccentColor'] != null
          ? Color(json['customAccentColor'] as int)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        preset,
        isDynamicThemingEnabled,
        syncParticles,
        syncKineticQuotes,
        syncLockScreen,
        hueShiftDegrees,
        saturationMultiplier,
        customPrimaryColor,
        customAccentColor,
      ];
}
