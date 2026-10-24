import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Wallora theme extension providing obsidian glassmorphism, aurora gradients, and glowing specular borders.
@immutable
class AuroraThemeExtension extends ThemeExtension<AuroraThemeExtension> {
  final LinearGradient primaryAuroraGradient;
  final LinearGradient cyberGradient;
  final LinearGradient sunsetGradient;
  final LinearGradient auroraMeshGradient;
  final LinearGradient obsidianGlassGradient;
  final LinearGradient specularRimGradient;
  final Color glassmorphicSurface;
  final BorderSide subtleBorder;
  final BorderSide neonBorder;
  final BorderSide specularBorder;
  final BorderSide neonActiveBorder;
  final List<BoxShadow> neonGlowShadow;
  final List<BoxShadow> ambientVioletGlow;
  final List<BoxShadow> ambientAmberGlow;
  final List<BoxShadow> ambientEmeraldGlow;
  final List<BoxShadow> modalShadow;

  const AuroraThemeExtension({
    required this.primaryAuroraGradient,
    required this.cyberGradient,
    required this.sunsetGradient,
    this.auroraMeshGradient = AppColors.auroraMeshGradient,
    this.obsidianGlassGradient = AppColors.obsidianGlassGradient,
    this.specularRimGradient = AppColors.specularRimGradient,
    required this.glassmorphicSurface,
    required this.subtleBorder,
    required this.neonBorder,
    this.specularBorder = const BorderSide(color: Color(0x33FFFFFF), width: 1.0),
    this.neonActiveBorder = const BorderSide(color: AppColors.neonCyan, width: 1.5),
    required this.neonGlowShadow,
    this.ambientVioletGlow = const [
      BoxShadow(
        color: Color(0x33D500F9),
        blurRadius: 18,
        offset: Offset(0, 4),
      ),
    ],
    this.ambientAmberGlow = const [
      BoxShadow(
        color: Color(0x33FF5722),
        blurRadius: 18,
        offset: Offset(0, 4),
      ),
    ],
    this.ambientEmeraldGlow = const [
      BoxShadow(
        color: Color(0x3300E676),
        blurRadius: 18,
        offset: Offset(0, 4),
      ),
    ],
    required this.modalShadow,
  });

  static const AuroraThemeExtension standard = AuroraThemeExtension(
    primaryAuroraGradient: AppColors.auroraGradient,
    cyberGradient: AppColors.cyberGradient,
    sunsetGradient: AppColors.sunsetGradient,
    auroraMeshGradient: AppColors.auroraMeshGradient,
    obsidianGlassGradient: AppColors.obsidianGlassGradient,
    specularRimGradient: AppColors.specularRimGradient,
    glassmorphicSurface: Color(0xE0121216),
    subtleBorder: BorderSide(color: Color(0x1FFFFFFF), width: 1.0),
    neonBorder: BorderSide(color: Color(0x5900E5FF), width: 1.2),
    specularBorder: BorderSide(color: Color(0x33FFFFFF), width: 1.0),
    neonActiveBorder: BorderSide(color: AppColors.neonCyan, width: 1.5),
    neonGlowShadow: [
      BoxShadow(
        color: Color(0x3300E5FF),
        blurRadius: 16,
        offset: Offset(0, 4),
      ),
    ],
    ambientVioletGlow: [
      BoxShadow(
        color: Color(0x33D500F9),
        blurRadius: 18,
        offset: Offset(0, 4),
      ),
    ],
    ambientAmberGlow: [
      BoxShadow(
        color: Color(0x33FF5722),
        blurRadius: 18,
        offset: Offset(0, 4),
      ),
    ],
    ambientEmeraldGlow: [
      BoxShadow(
        color: Color(0x3300E676),
        blurRadius: 18,
        offset: Offset(0, 4),
      ),
    ],
    modalShadow: [
      BoxShadow(
        color: Color(0x99000000),
        blurRadius: 24,
        offset: Offset(0, -6),
      ),
    ],
  );

  /// Safely resolves the [AuroraThemeExtension] from the active [BuildContext].
  static AuroraThemeExtension of(BuildContext context) {
    return Theme.of(context).extension<AuroraThemeExtension>() ?? standard;
  }

  /// Creates a premium obsidian card decoration with subtle specular border.
  BoxDecoration cardDecoration({
    BorderRadiusGeometry? borderRadius,
    Color? color,
    Border? border,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      color: color ?? AppColors.cardBackground,
      borderRadius: borderRadius ?? BorderRadius.circular(18),
      border: border ?? Border.all(color: subtleBorder.color, width: subtleBorder.width),
      boxShadow: boxShadow,
    );
  }

  /// Creates a floating glassmorphic sheet/dialog decoration with specular rim and ambient depth.
  BoxDecoration glassDecoration({
    BorderRadiusGeometry? borderRadius,
    LinearGradient? gradient,
    Border? border,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      gradient: gradient ?? obsidianGlassGradient,
      borderRadius: borderRadius ?? BorderRadius.circular(24),
      border: border ?? Border.all(color: specularBorder.color, width: specularBorder.width),
      boxShadow: boxShadow ?? modalShadow,
    );
  }

  /// Creates a vibrant neon action pill decoration with aurora gradient and neon glow.
  BoxDecoration neonPillDecoration({
    LinearGradient? gradient,
    BorderRadiusGeometry? borderRadius,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      gradient: gradient ?? primaryAuroraGradient,
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      boxShadow: boxShadow ?? neonGlowShadow,
    );
  }

  @override
  AuroraThemeExtension copyWith({
    LinearGradient? primaryAuroraGradient,
    LinearGradient? cyberGradient,
    LinearGradient? sunsetGradient,
    LinearGradient? auroraMeshGradient,
    LinearGradient? obsidianGlassGradient,
    LinearGradient? specularRimGradient,
    Color? glassmorphicSurface,
    BorderSide? subtleBorder,
    BorderSide? neonBorder,
    BorderSide? specularBorder,
    BorderSide? neonActiveBorder,
    List<BoxShadow>? neonGlowShadow,
    List<BoxShadow>? ambientVioletGlow,
    List<BoxShadow>? ambientAmberGlow,
    List<BoxShadow>? ambientEmeraldGlow,
    List<BoxShadow>? modalShadow,
  }) {
    return AuroraThemeExtension(
      primaryAuroraGradient: primaryAuroraGradient ?? this.primaryAuroraGradient,
      cyberGradient: cyberGradient ?? this.cyberGradient,
      sunsetGradient: sunsetGradient ?? this.sunsetGradient,
      auroraMeshGradient: auroraMeshGradient ?? this.auroraMeshGradient,
      obsidianGlassGradient: obsidianGlassGradient ?? this.obsidianGlassGradient,
      specularRimGradient: specularRimGradient ?? this.specularRimGradient,
      glassmorphicSurface: glassmorphicSurface ?? this.glassmorphicSurface,
      subtleBorder: subtleBorder ?? this.subtleBorder,
      neonBorder: neonBorder ?? this.neonBorder,
      specularBorder: specularBorder ?? this.specularBorder,
      neonActiveBorder: neonActiveBorder ?? this.neonActiveBorder,
      neonGlowShadow: neonGlowShadow ?? this.neonGlowShadow,
      ambientVioletGlow: ambientVioletGlow ?? this.ambientVioletGlow,
      ambientAmberGlow: ambientAmberGlow ?? this.ambientAmberGlow,
      ambientEmeraldGlow: ambientEmeraldGlow ?? this.ambientEmeraldGlow,
      modalShadow: modalShadow ?? this.modalShadow,
    );
  }

  @override
  AuroraThemeExtension lerp(ThemeExtension<AuroraThemeExtension>? other, double t) {
    if (other is! AuroraThemeExtension) {
      return this;
    }
    return AuroraThemeExtension(
      primaryAuroraGradient:
          LinearGradient.lerp(primaryAuroraGradient, other.primaryAuroraGradient, t)!,
      cyberGradient: LinearGradient.lerp(cyberGradient, other.cyberGradient, t)!,
      sunsetGradient: LinearGradient.lerp(sunsetGradient, other.sunsetGradient, t)!,
      auroraMeshGradient:
          LinearGradient.lerp(auroraMeshGradient, other.auroraMeshGradient, t)!,
      obsidianGlassGradient:
          LinearGradient.lerp(obsidianGlassGradient, other.obsidianGlassGradient, t)!,
      specularRimGradient:
          LinearGradient.lerp(specularRimGradient, other.specularRimGradient, t)!,
      glassmorphicSurface: Color.lerp(glassmorphicSurface, other.glassmorphicSurface, t)!,
      subtleBorder: BorderSide.lerp(subtleBorder, other.subtleBorder, t),
      neonBorder: BorderSide.lerp(neonBorder, other.neonBorder, t),
      specularBorder: BorderSide.lerp(specularBorder, other.specularBorder, t),
      neonActiveBorder: BorderSide.lerp(neonActiveBorder, other.neonActiveBorder, t),
      neonGlowShadow: BoxShadow.lerpList(neonGlowShadow, other.neonGlowShadow, t) ?? neonGlowShadow,
      ambientVioletGlow:
          BoxShadow.lerpList(ambientVioletGlow, other.ambientVioletGlow, t) ?? ambientVioletGlow,
      ambientAmberGlow:
          BoxShadow.lerpList(ambientAmberGlow, other.ambientAmberGlow, t) ?? ambientAmberGlow,
      ambientEmeraldGlow:
          BoxShadow.lerpList(ambientEmeraldGlow, other.ambientEmeraldGlow, t) ?? ambientEmeraldGlow,
      modalShadow: BoxShadow.lerpList(modalShadow, other.modalShadow, t) ?? modalShadow,
    );
  }
}
