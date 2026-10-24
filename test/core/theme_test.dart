import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/core/core.dart';

void main() {
  group('AppColors Unit Tests', () {
    test('Brand Aurora Neon Palette colors are configured', () {
      expect(AppColors.neonCyan, const Color(0xFF00E5FF));
      expect(AppColors.auroraViolet, const Color(0xFFD500F9));
      expect(AppColors.sunsetAmber, const Color(0xFFFF5722));
      expect(AppColors.cyberEmerald, const Color(0xFF00E676));
      expect(AppColors.solarGold, const Color(0xFFFFD600));
      expect(AppColors.electricBlue, const Color(0xFF00B0FF));
      expect(AppColors.plasmaPink, const Color(0xFFFF4081));
      expect(AppColors.deepPurple, const Color(0xFF7C4DFF));
    });

    test('Dark Obsidian surface palette colors are defined', () {
      expect(AppColors.obsidianBlack, const Color(0xFF000000));
      expect(AppColors.darkSurface, const Color(0xFF101018));
      expect(AppColors.surfaceElevated, const Color(0xFF121214));
      expect(AppColors.cardBackground, const Color(0xFF161622));
      expect(AppColors.modalBackground, const Color(0xFF1A1A24));
      expect(AppColors.sheetBackground, const Color(0xFF1E1E28));
    });

    test('Signature gradients have at least two contrasting colors', () {
      expect(AppColors.auroraGradient.colors.length, 2);
      expect(AppColors.auroraGradient.colors.first, AppColors.neonCyan);
      expect(AppColors.auroraGradient.colors.last, AppColors.auroraViolet);

      expect(AppColors.sunsetGradient.colors.length, 2);
      expect(AppColors.cyberGradient.colors.length, 2);
      expect(AppColors.obsidianGradient.colors.length, 2);
    });
  });

  group('AuroraThemeExtension Unit Tests', () {
    test('standard configuration provides aurora gradients and specular borders', () {
      const ext = AuroraThemeExtension.standard;
      expect(ext.primaryAuroraGradient, AppColors.auroraGradient);
      expect(ext.cyberGradient, AppColors.cyberGradient);
      expect(ext.sunsetGradient, AppColors.sunsetGradient);
      expect(ext.neonBorder.color, const Color(0x5900E5FF));
      expect(ext.neonGlowShadow.isNotEmpty, isTrue);
    });

    test('copyWith updates specified properties', () {
      const ext = AuroraThemeExtension.standard;
      final updated = ext.copyWith(
        glassmorphicSurface: Colors.red,
      );
      expect(updated.glassmorphicSurface, Colors.red);
      expect(updated.primaryAuroraGradient, ext.primaryAuroraGradient);
    });

    test('lerp smoothly interpolates theme extension values', () {
      const ext1 = AuroraThemeExtension.standard;
      final ext2 = ext1.copyWith(glassmorphicSurface: Colors.black);
      final lerped = ext1.lerp(ext2, 0.5);

      expect(lerped, isNotNull);
      expect(lerped.primaryAuroraGradient, isNotNull);
    });
  });

  group('AppTheme Unit Tests', () {
    test('Dark theme configures obsidian background and aurora neon accents', () {
      final theme = AppTheme.darkTheme;

      expect(theme.scaffoldBackgroundColor, AppColors.obsidianBlack);
      expect(theme.colorScheme.primary, AppColors.sunsetAmber);
      expect(theme.colorScheme.secondary, AppColors.neonCyan);
      expect(theme.colorScheme.surface, AppColors.surfaceElevated);
      expect(theme.cardTheme.color, AppColors.cardBackground);
    });

    test('Dark theme registers AuroraThemeExtension', () {
      final theme = AppTheme.darkTheme;
      final auroraExt = theme.extension<AuroraThemeExtension>();

      expect(auroraExt, isNotNull);
      expect(auroraExt!.primaryAuroraGradient, AppColors.auroraGradient);
    });

    test('Dark theme configures cohesive component themes', () {
      final theme = AppTheme.darkTheme;

      expect(theme.appBarTheme.backgroundColor, Colors.transparent);
      expect(theme.chipTheme.backgroundColor, AppColors.cardSurface);
      expect(theme.elevatedButtonTheme.style, isNotNull);
      expect(theme.inputDecorationTheme.filled, isTrue);
      expect(theme.dialogTheme.backgroundColor, AppColors.modalBackground);
      expect(theme.bottomSheetTheme.backgroundColor, Colors.transparent);
    });
  });
}
