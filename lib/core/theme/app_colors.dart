import 'package:flutter/material.dart';

/// Centralized color palette for Wallora — Obsidian aesthetic with fluid Aurora Neon gradients.
abstract final class AppColors {
  // Brand Aurora Neon Palette
  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color auroraCyan = neonCyan;
  static const Color auroraViolet = Color(0xFFD500F9);
  static const Color sunsetAmber = Color(0xFFFF5722);
  static const Color auroraAmber = sunsetAmber;
  static const Color cyberEmerald = Color(0xFF00E676);
  static const Color auroraEmerald = cyberEmerald;
  static const Color emeraldGreen = auroraEmerald;
  static const Color cyberTeal = Color(0xFF1DE9B6);
  static const Color solarGold = Color(0xFFFFD600);
  static const Color electricBlue = Color(0xFF00B0FF);
  static const Color plasmaPink = Color(0xFFFF4081);
  static const Color deepPurple = Color(0xFF7C4DFF);
  static const Color crimsonAccent = Color(0xFFD50000);

  // Obsidian & Dark Surface Palette
  static const Color obsidianBlack = Color(0xFF000000);
  static const Color surfacePureBlack = obsidianBlack;
  static const Color darkBackground = Color(0xFF0A0A0E);
  static const Color backgroundDark = darkBackground;
  static const Color darkSurface = Color(0xFF101018);
  static const Color obsidianSurface = darkSurface;
  static const Color surfaceElevated = Color(0xFF121214);
  static const Color cardBackground = Color(0xFF161622);
  static const Color cardSurface = cardBackground;
  static const Color obsidianCard = cardBackground;
  static const Color modalBackground = Color(0xFF1A1A24);
  static const Color surfaceMedium = modalBackground;
  static const Color sheetBackground = Color(0xFF1E1E28);
  static const Color cardHighlight = Color(0xFF222630);

  // Text & Neutral Shades
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF); // 70%
  static const Color textTertiary = Color(0x61FFFFFF);  // 38%
  static const Color textDisabled = Color(0x3DFFFFFF);  // 24%

  // Borders & Dividers
  static const Color borderSubtle = Color(0x1AFFFFFF);  // 10%
  static const Color borderMedium = Color(0x1FFFFFFF);  // 12%
  static const Color borderAccent = Color(0xFF00E5FF);

  // Status & Semantic Colors
  static const Color error = Color(0xFFFF5252);
  static const Color favoriteRed = Color(0xFFFF1744);
  static const Color nightCrimson = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFFFB74D);
  static const Color success = Color(0xFF00E676);
  static const Color info = Color(0xFF00E5FF);

  // Signature Aurora Neon Gradients
  static const LinearGradient auroraGradient = LinearGradient(
    colors: [neonCyan, auroraViolet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [sunsetAmber, solarGold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyberGradient = LinearGradient(
    colors: [cyberEmerald, neonCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient obsidianGradient = LinearGradient(
    colors: [obsidianBlack, modalBackground],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
