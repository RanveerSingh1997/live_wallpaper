import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/models/gesture_control_config.dart';

void main() {
  group('GestureControlConfig Model Tests', () {
    test('defaultConfig initializes with expected Wallora defaults', () {
      const config = GestureControlConfig.defaultConfig;
      expect(config.isGesturesEnabled, isTrue);
      expect(config.doubleTapAction, GestureAction.toggleFavorite);
      expect(config.tripleTapAction, GestureAction.cycleAuraPalette);
      expect(config.twoFingerSwipeDownAction, GestureAction.toggleCleanCanvas);
      expect(config.longPressAction, GestureAction.toggleQuote);
      expect(config.hapticProfile, HapticFeedbackProfile.medium);
      expect(config.touchVisualEffect, TouchVisualEffect.neonRipple);
      expect(config.touchColorMode, TouchColorMode.auraSync);
      expect(config.rippleDurationMs, 450);
    });

    test('toJson and fromJson serialize and deserialize symmetrically', () {
      const original = GestureControlConfig(
        isGesturesEnabled: false,
        doubleTapAction: GestureAction.nextWallpaper,
        tripleTapAction: GestureAction.toggleEffects,
        twoFingerSwipeDownAction: GestureAction.none,
        longPressAction: GestureAction.openStudio,
        hapticProfile: HapticFeedbackProfile.firm,
        touchVisualEffect: TouchVisualEffect.particleBurst,
        touchColorMode: TouchColorMode.electricCyan,
        rippleDurationMs: 600,
      );

      final json = original.toJson();
      final restored = GestureControlConfig.fromJson(json);

      expect(restored, equals(original));
      expect(restored.isGesturesEnabled, isFalse);
      expect(restored.doubleTapAction, GestureAction.nextWallpaper);
      expect(restored.tripleTapAction, GestureAction.toggleEffects);
      expect(restored.twoFingerSwipeDownAction, GestureAction.none);
      expect(restored.longPressAction, GestureAction.openStudio);
      expect(restored.hapticProfile, HapticFeedbackProfile.firm);
      expect(restored.touchVisualEffect, TouchVisualEffect.particleBurst);
      expect(restored.touchColorMode, TouchColorMode.electricCyan);
      expect(restored.rippleDurationMs, 600);
    });

    test('fromJson handles empty or partial json with robust fallbacks', () {
      final config = GestureControlConfig.fromJson(const {});
      expect(config.isGesturesEnabled, isTrue);
      expect(config.doubleTapAction, GestureAction.toggleFavorite);
      expect(config.tripleTapAction, GestureAction.cycleAuraPalette);
      expect(config.twoFingerSwipeDownAction, GestureAction.toggleCleanCanvas);
      expect(config.longPressAction, GestureAction.toggleQuote);
      expect(config.hapticProfile, HapticFeedbackProfile.medium);
      expect(config.touchVisualEffect, TouchVisualEffect.neonRipple);
      expect(config.touchColorMode, TouchColorMode.auraSync);
      expect(config.rippleDurationMs, 450);
    });

    test('copyWith creates modified copy correctly', () {
      const original = GestureControlConfig.defaultConfig;
      final updated = original.copyWith(
        doubleTapAction: GestureAction.cycleAuraPalette,
        hapticProfile: HapticFeedbackProfile.subtle,
        touchVisualEffect: TouchVisualEffect.auroraWave,
        touchColorMode: TouchColorMode.solarAmber,
      );

      expect(updated.doubleTapAction, GestureAction.cycleAuraPalette);
      expect(updated.hapticProfile, HapticFeedbackProfile.subtle);
      expect(updated.touchVisualEffect, TouchVisualEffect.auroraWave);
      expect(updated.touchColorMode, TouchColorMode.solarAmber);
      expect(updated.tripleTapAction, original.tripleTapAction);
      expect(updated.isGesturesEnabled, original.isGesturesEnabled);
    });

    test('enum properties provide correct display names and icons', () {
      for (final action in GestureAction.values) {
        expect(action.displayName, isNotEmpty);
        expect(action.description, isNotEmpty);
        expect(action.icon, isA<IconData>());
      }

      for (final profile in HapticFeedbackProfile.values) {
        expect(profile.displayName, isNotEmpty);
        expect(profile.description, isNotEmpty);
      }

      for (final effect in TouchVisualEffect.values) {
        expect(effect.displayName, isNotEmpty);
        expect(effect.description, isNotEmpty);
      }

      for (final mode in TouchColorMode.values) {
        expect(mode.displayName, isNotEmpty);
        expect(mode.color, isNotNull);
      }
    });
  });
}
