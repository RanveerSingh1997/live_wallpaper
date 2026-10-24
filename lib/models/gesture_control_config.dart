import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../core/core.dart';

/// Available actions triggered by touch gestures on Wallora wallpapers.
enum GestureAction {
  nextWallpaper(
    label: 'Next Wallpaper / Shuffle',
    description: 'Advance to the next wallpaper in the feed or collection',
    icon: Icons.skip_next_rounded,
  ),
  toggleFavorite(
    label: 'Toggle Favorite (Heart)',
    description: 'Instantly like or remove wallpaper from favorites with haptic pulse',
    icon: Icons.favorite_rounded,
  ),
  toggleQuote(
    label: 'Toggle Quote Overlay',
    description: 'Show or hide the typography quote and motivational text',
    icon: Icons.format_quote_rounded,
  ),
  toggleEffects(
    label: 'Toggle Visual FX / Monochrome',
    description: 'Toggle grayscale or custom canvas visual filters',
    icon: Icons.auto_fix_high_rounded,
  ),
  cycleAuraPalette(
    label: 'Cycle Aura Theme Palette',
    description: 'Step through celestial aurora neon chromatic harmonies',
    icon: Icons.palette_rounded,
  ),
  toggleCleanCanvas(
    label: 'Clean Canvas (Zen Mode)',
    description: 'Fade out all HUD, clock, widgets, and quotes for pure wallpaper view',
    icon: Icons.visibility_off_rounded,
  ),
  pauseResume(
    label: 'Pause / Resume Video',
    description: 'Pause or resume animated live wallpaper playback',
    icon: Icons.play_arrow_rounded,
  ),
  openStudio(
    label: 'Open Settings Studio',
    description: 'Quick-open Wallora settings and configuration studio',
    icon: Icons.tune_rounded,
  ),
  none(
    label: 'Disabled',
    description: 'No action triggered for this gesture',
    icon: Icons.block_rounded,
  );

  final String label;
  final String description;
  final IconData icon;

  const GestureAction({
    required this.label,
    required this.description,
    required this.icon,
  });

  String get displayName => label;
  bool get isEnabled => this != GestureAction.none;
}

/// Tactile feedback intensities for touch gestures.
enum HapticFeedbackProfile {
  off(
    label: 'Off',
    description: 'Zero vibration / silent touch',
    icon: Icons.volume_mute_rounded,
  ),
  subtle(
    label: 'Subtle',
    description: 'Light tactile tick for delicate taps',
    icon: Icons.vibration_rounded,
  ),
  medium(
    label: 'Balanced',
    description: 'Satisfying medium pulse for responsive feedback',
    icon: Icons.vibration_rounded,
  ),
  firm(
    label: 'Firm',
    description: 'Strong impact pulse for confirmed actions',
    icon: Icons.vibration_rounded,
  ),
  selection(
    label: 'Selection Click',
    description: 'Crisp mechanical click sensation',
    icon: Icons.touch_app_rounded,
  );

  final String label;
  final String description;
  final IconData icon;

  const HapticFeedbackProfile({
    required this.label,
    required this.description,
    required this.icon,
  });

  String get displayName => label;
  bool get isEnabled => this != HapticFeedbackProfile.off;
}

/// Visual particle or wave effects rendered at the touch contact point.
enum TouchVisualEffect {
  neonRipple(
    label: 'Neon Shockwave',
    description: 'Expanding luminous neon ring dispersing outwards',
    icon: Icons.album_rounded,
  ),
  particleBurst(
    label: 'Stardust Sparks',
    description: 'Scatter burst of radiant stardust glowing embers',
    icon: Icons.flare_rounded,
  ),
  auroraWave(
    label: 'Aurora Glow',
    description: 'Soft celestial ambient glow wave radiating on contact',
    icon: Icons.blur_circular_rounded,
  ),
  none(
    label: 'Off (Clean)',
    description: 'Zero visual overlay at touch contact point',
    icon: Icons.do_not_disturb_alt_rounded,
  );

  final String label;
  final String description;
  final IconData icon;

  const TouchVisualEffect({
    required this.label,
    required this.description,
    required this.icon,
  });

  String get displayName => label;
  bool get isEnabled => this != TouchVisualEffect.none;
}

/// Color harmonies for touch ripples and spark bursts.
enum TouchColorMode {
  auraSync(
    label: 'Dynamic Aura Sync',
    description: 'Inherits active Aura Chromatic Harmonizer neon primary color',
    color: AppColors.neonCyan,
  ),
  electricCyan(
    label: 'Electric Cyan',
    description: 'High-contrast cyber neon cyan (#00E5FF)',
    color: AppColors.neonCyan,
  ),
  auroraViolet(
    label: 'Aurora Violet',
    description: 'Deep celestial electric violet (#D500F9)',
    color: AppColors.auroraViolet,
  ),
  solarAmber(
    label: 'Solar Amber',
    description: 'Warm energetic twilight amber (#FF5722)',
    color: AppColors.sunsetAmber,
  ),
  emeraldNeon(
    label: 'Emerald Neon',
    description: 'Vivid biometric emerald glow (#00E676)',
    color: AppColors.auroraEmerald,
  ),
  pureWhite(
    label: 'Pure White',
    description: 'Bright obsidian starlight (#FFFFFF)',
    color: AppColors.textPrimary,
  );

  final String label;
  final String description;
  final Color color;

  const TouchColorMode({
    required this.label,
    required this.description,
    required this.color,
  });

  String get displayName => label;
}

/// Configuration for Wallora interactive touch gestures, tactile haptics, and visual contact ripples.
class GestureControlConfig extends Equatable {
  final bool isGesturesEnabled;
  final GestureAction doubleTapAction;
  final GestureAction tripleTapAction;
  final GestureAction twoFingerSwipeDownAction;
  final GestureAction longPressAction;
  final HapticFeedbackProfile hapticProfile;
  final TouchVisualEffect touchVisualEffect;
  final TouchColorMode touchColorMode;
  final int rippleDurationMs;

  const GestureControlConfig({
    this.isGesturesEnabled = true,
    this.doubleTapAction = GestureAction.toggleFavorite,
    this.tripleTapAction = GestureAction.cycleAuraPalette,
    this.twoFingerSwipeDownAction = GestureAction.toggleCleanCanvas,
    this.longPressAction = GestureAction.toggleQuote,
    this.hapticProfile = HapticFeedbackProfile.medium,
    this.touchVisualEffect = TouchVisualEffect.neonRipple,
    this.touchColorMode = TouchColorMode.auraSync,
    this.rippleDurationMs = 450,
  });

  static const GestureControlConfig defaultConfig = GestureControlConfig();

  GestureControlConfig copyWith({
    bool? isGesturesEnabled,
    GestureAction? doubleTapAction,
    GestureAction? tripleTapAction,
    GestureAction? twoFingerSwipeDownAction,
    GestureAction? longPressAction,
    HapticFeedbackProfile? hapticProfile,
    TouchVisualEffect? touchVisualEffect,
    TouchColorMode? touchColorMode,
    int? rippleDurationMs,
  }) {
    return GestureControlConfig(
      isGesturesEnabled: isGesturesEnabled ?? this.isGesturesEnabled,
      doubleTapAction: doubleTapAction ?? this.doubleTapAction,
      tripleTapAction: tripleTapAction ?? this.tripleTapAction,
      twoFingerSwipeDownAction:
          twoFingerSwipeDownAction ?? this.twoFingerSwipeDownAction,
      longPressAction: longPressAction ?? this.longPressAction,
      hapticProfile: hapticProfile ?? this.hapticProfile,
      touchVisualEffect: touchVisualEffect ?? this.touchVisualEffect,
      touchColorMode: touchColorMode ?? this.touchColorMode,
      rippleDurationMs: rippleDurationMs ?? this.rippleDurationMs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isGesturesEnabled': isGesturesEnabled,
      'doubleTapAction': doubleTapAction.name,
      'tripleTapAction': tripleTapAction.name,
      'twoFingerSwipeDownAction': twoFingerSwipeDownAction.name,
      'longPressAction': longPressAction.name,
      'hapticProfile': hapticProfile.name,
      'touchVisualEffect': touchVisualEffect.name,
      'touchColorMode': touchColorMode.name,
      'rippleDurationMs': rippleDurationMs,
    };
  }

  factory GestureControlConfig.fromJson(Map<String, dynamic> json) {
    GestureAction parseGestureAction(String? name, GestureAction fallback) {
      if (name == null) return fallback;
      return GestureAction.values.firstWhere(
        (e) => e.name == name,
        orElse: () => fallback,
      );
    }

    HapticFeedbackProfile parseHapticProfile(
        String? name, HapticFeedbackProfile fallback) {
      if (name == null) return fallback;
      return HapticFeedbackProfile.values.firstWhere(
        (e) => e.name == name,
        orElse: () => fallback,
      );
    }

    TouchVisualEffect parseTouchEffect(
        String? name, TouchVisualEffect fallback) {
      if (name == null) return fallback;
      return TouchVisualEffect.values.firstWhere(
        (e) => e.name == name,
        orElse: () => fallback,
      );
    }

    TouchColorMode parseColorMode(String? name, TouchColorMode fallback) {
      if (name == null) return fallback;
      return TouchColorMode.values.firstWhere(
        (e) => e.name == name,
        orElse: () => fallback,
      );
    }

    return GestureControlConfig(
      isGesturesEnabled: json['isGesturesEnabled'] as bool? ?? true,
      doubleTapAction: parseGestureAction(
        json['doubleTapAction'] as String?,
        GestureAction.toggleFavorite,
      ),
      tripleTapAction: parseGestureAction(
        json['tripleTapAction'] as String?,
        GestureAction.cycleAuraPalette,
      ),
      twoFingerSwipeDownAction: parseGestureAction(
        json['twoFingerSwipeDownAction'] as String?,
        GestureAction.toggleCleanCanvas,
      ),
      longPressAction: parseGestureAction(
        json['longPressAction'] as String?,
        GestureAction.toggleQuote,
      ),
      hapticProfile: parseHapticProfile(
        json['hapticProfile'] as String?,
        HapticFeedbackProfile.medium,
      ),
      touchVisualEffect: parseTouchEffect(
        json['touchVisualEffect'] as String?,
        TouchVisualEffect.neonRipple,
      ),
      touchColorMode: parseColorMode(
        json['touchColorMode'] as String?,
        TouchColorMode.auraSync,
      ),
      rippleDurationMs: json['rippleDurationMs'] as int? ?? 450,
    );
  }

  @override
  List<Object?> get props => [
        isGesturesEnabled,
        doubleTapAction,
        tripleTapAction,
        twoFingerSwipeDownAction,
        longPressAction,
        hapticProfile,
        touchVisualEffect,
        touchColorMode,
        rippleDurationMs,
      ];
}
