import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/models/aura_palette_config.dart';
import 'package:live_wallpaper/models/wallpaper_collection.dart';
import 'package:live_wallpaper/models/wallpaper_effect_config.dart';
import 'package:live_wallpaper/models/wallora_backup_bundle.dart';

void main() {
  group('WalloraBackupBundle Model Tests', () {
    test('creates bundle with correct metadata and defaults', () {
      final now = DateTime.now();
      final bundle = WalloraBackupBundle(exportedAt: now);

      expect(bundle.version, equals(1));
      expect(bundle.appName, equals('Wallora'));
      expect(bundle.exportedAt, equals(now));
      expect(bundle.favoriteIds, isEmpty);
      expect(bundle.customCollections, isEmpty);
      expect(bundle.customizedQuotes, isEmpty);
      expect(bundle.customEffects, isEmpty);
      expect(bundle.summary, equals('Default Wallora setup'));
    });

    test('serializes to JSON, converts to string, and restores back losslessly', () {
      final now = DateTime(2026, 10, 18, 12, 0, 0);
      final bundle = WalloraBackupBundle(
        exportedAt: now,
        favoriteIds: const {'wall_1', 'wall_2'},
        customCollections: const [
          WallpaperCollection(
            id: 'col_synthwave',
            title: 'Synthwave Night',
            subtitle: 'Neon retro futuristic aesthetics',
            badge: 'CYBER',
            icon: Icons.flash_on_rounded,
            wallpaperIds: ['wall_1'],
            gradientColors: [Color(0xFF00E5FF), Color(0xFFD500F9)],
          ),
        ],
        customizedQuotes: const {'wall_1': 'Be legendary.'},
        customEffects: const {
          'wall_1': WallpaperEffectConfig(
            colorFilterPreset: 'cyber_cyan',
            vignetteStrength: 0.8,
          ),
        },
        auraConfig: const AuraPaletteConfig(
          preset: AuraThemePreset.cyberAurora,
          hueShiftDegrees: 30.0,
        ),
        userPreferences: const {'Cyberpunk', 'AMOLED'},
        isAmoledSaverModeEnabled: true,
      );

      final jsonStr = bundle.toJsonString(pretty: true);
      expect(WalloraBackupBundle.isValidJson(jsonStr), isTrue);

      final restored = WalloraBackupBundle.fromJsonString(jsonStr);

      expect(restored.version, equals(1));
      expect(restored.appName, equals('Wallora'));
      expect(restored.favoriteIds, equals({'wall_1', 'wall_2'}));
      expect(restored.customCollections.length, equals(1));
      expect(restored.customCollections.first.title, equals('Synthwave Night'));
      expect(restored.customizedQuotes['wall_1'], equals('Be legendary.'));
      expect(restored.customEffects['wall_1']?.colorFilterPreset, equals('cyber_cyan'));
      expect(restored.auraConfig.preset, equals(AuraThemePreset.cyberAurora));
      expect(restored.userPreferences, equals({'Cyberpunk', 'AMOLED'}));
      expect(restored.isAmoledSaverModeEnabled, isTrue);
    });

    test('isValidJson returns false for malformed or non-bundle inputs', () {
      expect(WalloraBackupBundle.isValidJson(''), isFalse);
      expect(WalloraBackupBundle.isValidJson('not a json'), isFalse);
      expect(WalloraBackupBundle.isValidJson('{"appName": "OtherApp", "version": 1}'), isFalse);
      expect(WalloraBackupBundle.isValidJson('{"appName": "Wallora"}'), isFalse);
    });

    test('summary reflects non-empty configurations accurately', () {
      final bundle = WalloraBackupBundle(
        exportedAt: DateTime.now(),
        favoriteIds: const {'f1', 'f2', 'f3'},
        customCollections: const [
          WallpaperCollection(
            id: 'c1',
            title: 'P1',
            subtitle: 'Sub',
            badge: 'B',
            icon: Icons.star,
            wallpaperIds: [],
            gradientColors: [],
          ),
        ],
        customizedQuotes: const {'w1': 'Quote 1'},
        customEffects: const {
          'w1': WallpaperEffectConfig.defaultPreset,
        },
      );

      expect(bundle.summary, contains('3 favorites'));
      expect(bundle.summary, contains('1 playlists'));
      expect(bundle.summary, contains('1 quotes'));
      expect(bundle.summary, contains('1 effect presets'));
    });

    test('copyWith updates properties while preserving others', () {
      final now = DateTime.now();
      final bundle = WalloraBackupBundle(
        exportedAt: now,
        favoriteIds: const {'w1'},
      );

      final updated = bundle.copyWith(
        favoriteIds: {'w1', 'w2'},
        isAmoledSaverModeEnabled: true,
      );

      expect(updated.favoriteIds, equals({'w1', 'w2'}));
      expect(updated.isAmoledSaverModeEnabled, isTrue);
      expect(updated.appName, equals('Wallora'));
      expect(updated.exportedAt, equals(now));
    });
  });
}
