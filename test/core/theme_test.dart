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

  group('AppTheme Unit Tests', () {
    test('Dark theme configures obsidian background and aurora neon accents', () {
      final theme = AppTheme.darkTheme;

      expect(theme.scaffoldBackgroundColor, AppColors.obsidianBlack);
      expect(theme.colorScheme.primary, AppColors.sunsetAmber);
      expect(theme.colorScheme.secondary, AppColors.neonCyan);
      expect(theme.colorScheme.surface, AppColors.surfaceElevated);
      expect(theme.cardTheme.color, AppColors.cardBackground);
    });
  });
}
