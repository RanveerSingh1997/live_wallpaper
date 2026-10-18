import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/data/curated_shorts_data.dart';
import 'package:live_wallpaper/models/aura_palette_config.dart';
import 'package:live_wallpaper/models/aurora_synthesizer_config.dart';
import 'package:live_wallpaper/models/parallax_effect_config.dart';
import 'package:live_wallpaper/models/particle_effect_config.dart';
import 'package:live_wallpaper/models/wallora_screen_blueprint.dart';

void main() {
  group('WalloraScreenBlueprint Model Tests', () {
    final sampleWallpaper = CuratedShortsData.shorts.first;

    test('default instantiation and props equality', () {
      final now = DateTime(2026, 10, 18);
      final bp1 = WalloraScreenBlueprint(
        id: 'test_bp_1',
        title: 'Zen Garden',
        creatorName: 'ZenMaster',
        description: 'Tranquil garden',
        wallpaper: sampleWallpaper,
        customQuote: 'Find peace.',
        createdAt: now,
      );

      final bp2 = WalloraScreenBlueprint(
        id: 'test_bp_1',
        title: 'Zen Garden',
        creatorName: 'ZenMaster',
        description: 'Tranquil garden',
        wallpaper: sampleWallpaper,
        customQuote: 'Find peace.',
        createdAt: now,
      );

      expect(bp1, equals(bp2));
      expect(bp1.creatorAvatarColor.toARGB32(), equals(0xFF00E5FF));
      expect(bp1.auraConfig, equals(AuraPaletteConfig.defaultConfig));
      expect(bp1.particleConfig, equals(ParticleEffectConfig.defaultConfig));
      expect(bp1.parallaxConfig, equals(ParallaxEffectConfig.defaultConfig));
      expect(bp1.auroraConfig, equals(AuroraSynthesizerConfig.defaultConfig));
    });

    test('copyWith updates properties properly', () {
      final bp = WalloraScreenBlueprint(
        id: 'test_bp_1',
        title: 'Zen Garden',
        creatorName: 'ZenMaster',
        description: 'Tranquil garden',
        wallpaper: sampleWallpaper,
        customQuote: 'Find peace.',
        createdAt: DateTime(2026, 10, 18),
      );

      final updated = bp.copyWith(
        title: 'Updated Zen Garden',
        likesCount: 42,
        isStaffPick: true,
      );

      expect(updated.title, equals('Updated Zen Garden'));
      expect(updated.likesCount, equals(42));
      expect(updated.isStaffPick, isTrue);
      expect(updated.id, equals(bp.id));
      expect(updated.creatorName, equals(bp.creatorName));
    });

    test('toJson and fromJson round-trip preserves all fields', () {
      final now = DateTime(2026, 10, 18, 12, 0, 0);
      final original = WalloraScreenBlueprint(
        id: 'test_bp_json',
        title: 'Cyber Ronin',
        creatorName: 'KageKaze',
        creatorAvatarColorValue: 0xFFD500F9,
        description: 'High voltage electric theme',
        wallpaper: sampleWallpaper,
        customQuote: 'Never back down.',
        auraConfig: const AuraPaletteConfig(preset: AuraThemePreset.cyberAurora),
        particleConfig: const ParticleEffectConfig(preset: ParticlePreset.electricSparks),
        parallaxConfig: const ParallaxEffectConfig(preset: ParallaxPreset.cinematic3D),
        auroraConfig: const AuroraSynthesizerConfig(waveStyle: AuroraWaveStyle.cyberpunkRibbon),
        tags: const ['Cyberpunk', 'Live'],
        likesCount: 150,
        clonesCount: 80,
        isStaffPick: true,
        createdAt: now,
      );

      final json = original.toJson();
      final reconstructed = WalloraScreenBlueprint.fromJson(json);

      expect(reconstructed, equals(original));
      expect(reconstructed.id, equals('test_bp_json'));
      expect(reconstructed.title, equals('Cyber Ronin'));
      expect(reconstructed.creatorName, equals('KageKaze'));
      expect(reconstructed.creatorAvatarColorValue, equals(0xFFD500F9));
      expect(reconstructed.auraConfig.preset, equals(AuraThemePreset.cyberAurora));
      expect(reconstructed.particleConfig.preset, equals(ParticlePreset.electricSparks));
      expect(reconstructed.parallaxConfig.preset, equals(ParallaxPreset.cinematic3D));
      expect(reconstructed.auroraConfig.waveStyle, equals(AuroraWaveStyle.cyberpunkRibbon));
      expect(reconstructed.tags, equals(['Cyberpunk', 'Live']));
      expect(reconstructed.likesCount, equals(150));
      expect(reconstructed.clonesCount, equals(80));
      expect(reconstructed.isStaffPick, isTrue);
    });

    test('toJsonString and fromJsonString serialization works properly', () {
      final original = WalloraScreenBlueprint.curatedBlueprints.first;
      final jsonString = original.toJsonString();
      final parsed = WalloraScreenBlueprint.fromJsonString(jsonString);

      expect(parsed.id, equals(original.id));
      expect(parsed.title, equals(original.title));
      expect(parsed.creatorName, equals(original.creatorName));
      expect(parsed.customQuote, equals(original.customQuote));
      expect(parsed.tags, equals(original.tags));
    });

    test('curatedBlueprints contains 5 distinct showcase setups', () {
      final blueprints = WalloraScreenBlueprint.curatedBlueprints;
      expect(blueprints.length, equals(5));

      final titles = blueprints.map((b) => b.title).toSet();
      expect(titles.length, equals(5));

      final ids = blueprints.map((b) => b.id).toSet();
      expect(ids.length, equals(5));

      for (final bp in blueprints) {
        expect(bp.title.isNotEmpty, isTrue);
        expect(bp.creatorName.isNotEmpty, isTrue);
        expect(bp.description.isNotEmpty, isTrue);
        expect(bp.wallpaper.id.isNotEmpty, isTrue);
        expect(bp.tags.isNotEmpty, isTrue);
        expect(bp.likesCount, greaterThan(0));
      }
    });
  });
}
