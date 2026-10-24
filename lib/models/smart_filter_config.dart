import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../core/core.dart';
import 'motivational_short.dart';

/// Media format filter options.
enum SmartMediaType {
  all('All Formats', Icons.auto_awesome_mosaic_rounded),
  liveOnly('60 FPS Live', Icons.play_circle_outline_rounded),
  staticOnly('4K Ultra-HD', Icons.image_outlined);

  final String label;
  final IconData icon;
  const SmartMediaType(this.label, this.icon);

  String get displayName => label;
}

/// Aesthetic Mood & Energy Vibe filter options.
enum SmartMood {
  all('All Moods', Icons.interests_rounded),
  fighterSpirit('Fighter Spirit', Icons.sports_mma_rounded),
  deepFocus('Deep Focus', Icons.psychology_rounded),
  serenityCalm('Serenity & Calm', Icons.spa_rounded),
  relentlessDrive('Relentless Drive', Icons.fitness_center_rounded),
  pureObsidian('Pure Obsidian', Icons.dark_mode_rounded),
  electricRush('Electric Rush', Icons.bolt_rounded);

  final String label;
  final IconData icon;
  const SmartMood(this.label, this.icon);

  String get displayName => label;
  static const SmartMood any = SmartMood.all;
}

/// Dominant color harmony palette filter options.
enum SmartPaletteColor {
  all('All Colors', null),
  neonCyan('Neon Cyan', AppColors.neonCyan),
  auroraViolet('Aurora Violet', AppColors.auroraViolet),
  sunsetAmber('Sunset Amber', AppColors.sunsetAmber),
  cyberEmerald('Cyber Emerald', AppColors.auroraEmerald),
  solarGold('Solar Gold', AppColors.solarGold),
  amoledBlack('AMOLED Black', AppColors.obsidianBlack);

  final String label;
  final Color? color;
  const SmartPaletteColor(this.label, this.color);

  String get displayName => label;
  static const SmartPaletteColor any = SmartPaletteColor.all;
}

/// Filter configuration for multi-attribute smart discovery.
class SmartFilterConfig extends Equatable {
  final SmartMediaType mediaType;
  final SmartMood mood;
  final SmartPaletteColor paletteColor;
  final bool amoledCertifiedOnly;
  final bool? hasTextOverlayOnly;

  const SmartFilterConfig({
    this.mediaType = SmartMediaType.all,
    this.mood = SmartMood.all,
    this.paletteColor = SmartPaletteColor.all,
    this.amoledCertifiedOnly = false,
    this.hasTextOverlayOnly,
  });

  static const SmartFilterConfig defaultConfig = SmartFilterConfig();

  bool get requiresTextOverlay => hasTextOverlayOnly == true;

  bool get hasActiveFilters =>
      mediaType != SmartMediaType.all ||
      mood != SmartMood.all ||
      paletteColor != SmartPaletteColor.all ||
      amoledCertifiedOnly ||
      hasTextOverlayOnly != null;

  int get activeFilterCount {
    int count = 0;
    if (mediaType != SmartMediaType.all) count++;
    if (mood != SmartMood.all) count++;
    if (paletteColor != SmartPaletteColor.all) count++;
    if (amoledCertifiedOnly) count++;
    if (hasTextOverlayOnly != null) count++;
    return count;
  }

  /// Evaluates whether a given wallpaper satisfies this filter configuration.
  bool matches(MotivationalShort short) {
    // 1. Media Type
    if (mediaType == SmartMediaType.liveOnly && !short.isLive) return false;
    if (mediaType == SmartMediaType.staticOnly && short.isLive) return false;

    // 2. AMOLED Certified
    if (amoledCertifiedOnly && !short.isAmoledCertified) return false;

    // 3. Text Overlay
    if (hasTextOverlayOnly != null && short.hasTextByDefault != hasTextOverlayOnly) {
      return false;
    }

    // 4. Mood Matching
    if (mood != SmartMood.all) {
      final shortMood = short.mood.toLowerCase();
      final targetMood = mood.label.toLowerCase();
      if (!shortMood.contains(targetMood) &&
          !targetMood.contains(shortMood) &&
          !short.tags.toLowerCase().contains(targetMood)) {
        return false;
      }
    }

    // 5. Color Palette Matching
    if (paletteColor != SmartPaletteColor.all && paletteColor.color != null) {
      final targetColor = paletteColor.color!;
      final accent = short.accentColor;

      bool matchesColor(Color c) {
        // Color distance in RGB space
        final dr = ((c.r * 255).round() - (targetColor.r * 255).round()).abs();
        final dg = ((c.g * 255).round() - (targetColor.g * 255).round()).abs();
        final db = ((c.b * 255).round() - (targetColor.b * 255).round()).abs();
        return (dr + dg + db) < 100;
      }

      final matchesAccent = matchesColor(accent);
      final matchesGradients = short.gradientColors.any(matchesColor);

      if (!matchesAccent && !matchesGradients) {
        if (paletteColor == SmartPaletteColor.amoledBlack && short.trueBlackPercentage >= 70) {
          // AMOLED match
        } else {
          return false;
        }
      }
    }

    return true;
  }

  SmartFilterConfig copyWith({
    SmartMediaType? mediaType,
    SmartMood? mood,
    SmartPaletteColor? paletteColor,
    bool? amoledCertifiedOnly,
    bool? hasTextOverlayOnly,
    bool? requiresTextOverlay,
    bool clearTextOverlay = false,
  }) {
    return SmartFilterConfig(
      mediaType: mediaType ?? this.mediaType,
      mood: mood ?? this.mood,
      paletteColor: paletteColor ?? this.paletteColor,
      amoledCertifiedOnly: amoledCertifiedOnly ?? this.amoledCertifiedOnly,
      hasTextOverlayOnly: clearTextOverlay
          ? null
          : (requiresTextOverlay != null
              ? (requiresTextOverlay ? true : null)
              : (hasTextOverlayOnly ?? this.hasTextOverlayOnly)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mediaType': mediaType.name,
      'mood': mood.name,
      'paletteColor': paletteColor.name,
      'amoledCertifiedOnly': amoledCertifiedOnly,
      'hasTextOverlayOnly': hasTextOverlayOnly,
    };
  }

  factory SmartFilterConfig.fromJson(Map<String, dynamic> json) {
    return SmartFilterConfig(
      mediaType: SmartMediaType.values.firstWhere(
        (m) => m.name == json['mediaType'],
        orElse: () => SmartMediaType.all,
      ),
      mood: SmartMood.values.firstWhere(
        (m) => m.name == json['mood'],
        orElse: () => SmartMood.all,
      ),
      paletteColor: SmartPaletteColor.values.firstWhere(
        (p) => p.name == json['paletteColor'],
        orElse: () => SmartPaletteColor.all,
      ),
      amoledCertifiedOnly: json['amoledCertifiedOnly'] as bool? ?? false,
      hasTextOverlayOnly: json['hasTextOverlayOnly'] as bool?,
    );
  }

  @override
  List<Object?> get props => [
        mediaType,
        mood,
        paletteColor,
        amoledCertifiedOnly,
        hasTextOverlayOnly,
      ];
}
