import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/models/motivational_short.dart';
import 'package:live_wallpaper/models/smart_filter_config.dart';

void main() {
  group('SmartFilterConfig Model Tests', () {
    const liveShort = MotivationalShort(
      id: 'short-1',
      title: 'Iron Will - Live',
      videoAssetPath: 'assets/videos/short1.mp4',
      quote: 'Never back down.',
      author: 'Wallora',
      category: 'Anime & Gaming',
      accentColor: Color(0xFF00E5FF),
      gradientColors: [Color(0xFF00E5FF), Color(0xFFD500F9)],
      tags: 'anime, fighting, spirit, motivation',
      mood: 'Fighter Spirit',
      isLive: true,
      hasTextByDefault: true,
      trueBlackPercentage: 85,
    );

    const staticShort = MotivationalShort(
      id: 'short-2',
      title: 'Zen Forest - Static',
      videoAssetPath: 'assets/videos/short2.mp4',
      quote: 'Find your peace.',
      author: 'Wallora',
      category: 'Nature & Landscapes',
      accentColor: Color(0xFF00E676),
      gradientColors: [Color(0xFF00E676), Color(0xFF1B5E20)],
      tags: 'nature, forest, calm, serenity',
      mood: 'Serenity & Calm',
      isLive: false,
      hasTextByDefault: false,
      trueBlackPercentage: 15,
    );

    test('default configuration has no active filters', () {
      const config = SmartFilterConfig.defaultConfig;
      expect(config.hasActiveFilters, isFalse);
      expect(config.activeFilterCount, equals(0));
      expect(config.mediaType, equals(SmartMediaType.all));
      expect(config.mood, equals(SmartMood.all));
      expect(config.paletteColor, equals(SmartPaletteColor.all));
      expect(config.amoledCertifiedOnly, isFalse);
      expect(config.hasTextOverlayOnly, isNull);
      expect(config.requiresTextOverlay, isFalse);
    });

    test('matches correctly evaluates media formats', () {
      const liveOnlyConfig = SmartFilterConfig(mediaType: SmartMediaType.liveOnly);
      expect(liveOnlyConfig.hasActiveFilters, isTrue);
      expect(liveOnlyConfig.activeFilterCount, equals(1));
      expect(liveOnlyConfig.matches(liveShort), isTrue);
      expect(liveOnlyConfig.matches(staticShort), isFalse);

      const staticOnlyConfig = SmartFilterConfig(mediaType: SmartMediaType.staticOnly);
      expect(staticOnlyConfig.matches(liveShort), isFalse);
      expect(staticOnlyConfig.matches(staticShort), isTrue);
    });

    test('matches correctly evaluates AMOLED certification', () {
      const amoledConfig = SmartFilterConfig(amoledCertifiedOnly: true);
      expect(amoledConfig.hasActiveFilters, isTrue);
      expect(amoledConfig.matches(liveShort), isTrue);
      expect(amoledConfig.matches(staticShort), isFalse);
    });

    test('matches correctly evaluates text overlay requirement', () {
      const textConfig = SmartFilterConfig(hasTextOverlayOnly: true);
      expect(textConfig.requiresTextOverlay, isTrue);
      expect(textConfig.matches(liveShort), isTrue);
      expect(textConfig.matches(staticShort), isFalse);

      const noTextConfig = SmartFilterConfig(hasTextOverlayOnly: false);
      expect(noTextConfig.matches(liveShort), isFalse);
      expect(noTextConfig.matches(staticShort), isTrue);
    });

    test('matches correctly evaluates mood & tags', () {
      const fighterConfig = SmartFilterConfig(mood: SmartMood.fighterSpirit);
      expect(fighterConfig.matches(liveShort), isTrue);
      expect(fighterConfig.matches(staticShort), isFalse);

      const serenityConfig = SmartFilterConfig(mood: SmartMood.serenityCalm);
      expect(serenityConfig.matches(liveShort), isFalse);
      expect(serenityConfig.matches(staticShort), isTrue);
    });

    test('matches correctly evaluates color harmony palette', () {
      const cyanConfig = SmartFilterConfig(paletteColor: SmartPaletteColor.neonCyan);
      expect(cyanConfig.matches(liveShort), isTrue);
      expect(cyanConfig.matches(staticShort), isFalse);

      const emeraldConfig = SmartFilterConfig(paletteColor: SmartPaletteColor.cyberEmerald);
      expect(emeraldConfig.matches(liveShort), isFalse);
      expect(emeraldConfig.matches(staticShort), isTrue);

      const amoledBlackConfig = SmartFilterConfig(paletteColor: SmartPaletteColor.amoledBlack);
      expect(amoledBlackConfig.matches(liveShort), isTrue); // trueBlackPercentage 85 >= 70
      expect(amoledBlackConfig.matches(staticShort), isFalse); // trueBlackPercentage 15 < 70
    });

    test('copyWith properly updates and clears fields', () {
      const initial = SmartFilterConfig.defaultConfig;
      final updated = initial.copyWith(
        mediaType: SmartMediaType.liveOnly,
        mood: SmartMood.relentlessDrive,
        paletteColor: SmartPaletteColor.sunsetAmber,
        amoledCertifiedOnly: true,
        requiresTextOverlay: true,
      );

      expect(updated.mediaType, equals(SmartMediaType.liveOnly));
      expect(updated.mood, equals(SmartMood.relentlessDrive));
      expect(updated.paletteColor, equals(SmartPaletteColor.sunsetAmber));
      expect(updated.amoledCertifiedOnly, isTrue);
      expect(updated.requiresTextOverlay, isTrue);
      expect(updated.activeFilterCount, equals(5));

      final cleared = updated.copyWith(clearTextOverlay: true);
      expect(cleared.hasTextOverlayOnly, isNull);
      expect(cleared.requiresTextOverlay, isFalse);
      expect(cleared.activeFilterCount, equals(4));
    });

    test('toJson and fromJson serialize and deserialize accurately', () {
      const original = SmartFilterConfig(
        mediaType: SmartMediaType.liveOnly,
        mood: SmartMood.electricRush,
        paletteColor: SmartPaletteColor.auroraViolet,
        amoledCertifiedOnly: true,
        hasTextOverlayOnly: true,
      );

      final json = original.toJson();
      final restored = SmartFilterConfig.fromJson(json);

      expect(restored, equals(original));
      expect(restored.mediaType, equals(SmartMediaType.liveOnly));
      expect(restored.mood, equals(SmartMood.electricRush));
      expect(restored.paletteColor, equals(SmartPaletteColor.auroraViolet));
      expect(restored.amoledCertifiedOnly, isTrue);
      expect(restored.hasTextOverlayOnly, isTrue);
    });

    test('fromJson handles empty/malformed map with defaults', () {
      final config = SmartFilterConfig.fromJson(const {});
      expect(config, equals(SmartFilterConfig.defaultConfig));
    });
  });
}
