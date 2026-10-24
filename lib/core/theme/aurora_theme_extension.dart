import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Wallora theme extension providing obsidian glassmorphism, aurora gradients, and glowing specular borders.
@immutable
class AuroraThemeExtension extends ThemeExtension<AuroraThemeExtension> {
  final LinearGradient primaryAuroraGradient;
  final LinearGradient cyberGradient;
  final LinearGradient sunsetGradient;
  final Color glassmorphicSurface;
  final BorderSide subtleBorder;
  final BorderSide neonBorder;
  final List<BoxShadow> neonGlowShadow;
  final List<BoxShadow> modalShadow;

  const AuroraThemeExtension({
    required this.primaryAuroraGradient,
    required this.cyberGradient,
    required this.sunsetGradient,
    required this.glassmorphicSurface,
    required this.subtleBorder,
    required this.neonBorder,
    required this.neonGlowShadow,
    required this.modalShadow,
  });

  static const AuroraThemeExtension standard = AuroraThemeExtension(
    primaryAuroraGradient: AppColors.auroraGradient,
    cyberGradient: AppColors.cyberGradient,
    sunsetGradient: AppColors.sunsetGradient,
    glassmorphicSurface: Color(0xE0121216),
    subtleBorder: BorderSide(color: Color(0x1FFFFFFF), width: 1.0),
    neonBorder: BorderSide(color: Color(0x5900E5FF), width: 1.2),
    neonGlowShadow: [
      BoxShadow(
        color: Color(0x3300E5FF),
        blurRadius: 16,
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

  @override
  AuroraThemeExtension copyWith({
    LinearGradient? primaryAuroraGradient,
    LinearGradient? cyberGradient,
    LinearGradient? sunsetGradient,
    Color? glassmorphicSurface,
    BorderSide? subtleBorder,
    BorderSide? neonBorder,
    List<BoxShadow>? neonGlowShadow,
    List<BoxShadow>? modalShadow,
  }) {
    return AuroraThemeExtension(
      primaryAuroraGradient: primaryAuroraGradient ?? this.primaryAuroraGradient,
      cyberGradient: cyberGradient ?? this.cyberGradient,
      sunsetGradient: sunsetGradient ?? this.sunsetGradient,
      glassmorphicSurface: glassmorphicSurface ?? this.glassmorphicSurface,
      subtleBorder: subtleBorder ?? this.subtleBorder,
      neonBorder: neonBorder ?? this.neonBorder,
      neonGlowShadow: neonGlowShadow ?? this.neonGlowShadow,
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
      glassmorphicSurface: Color.lerp(glassmorphicSurface, other.glassmorphicSurface, t)!,
      subtleBorder: BorderSide.lerp(subtleBorder, other.subtleBorder, t),
      neonBorder: BorderSide.lerp(neonBorder, other.neonBorder, t),
      neonGlowShadow: BoxShadow.lerpList(neonGlowShadow, other.neonGlowShadow, t) ?? neonGlowShadow,
      modalShadow: BoxShadow.lerpList(modalShadow, other.modalShadow, t) ?? modalShadow,
    );
  }
}
