import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../data/curated_shorts_data.dart';
import 'aura_palette_config.dart';
import 'aurora_synthesizer_config.dart';
import 'motivational_short.dart';
import 'parallax_effect_config.dart';
import 'particle_effect_config.dart';

/// Represents a complete, shareable Wallora Screen Blueprint ("Aesthetic Profile").
/// A blueprint packages a wallpaper, quote typography, chromatic aura,
/// interactive particle physics, 3D parallax depth, and synthesized aurora waves.
class WalloraScreenBlueprint extends Equatable {
  final String id;
  final String title;
  final String creatorName;
  final int creatorAvatarColorValue;
  final String description;
  final MotivationalShort wallpaper;
  final String customQuote;
  final AuraPaletteConfig auraConfig;
  final ParticleEffectConfig particleConfig;
  final ParallaxEffectConfig parallaxConfig;
  final AuroraSynthesizerConfig auroraConfig;
  final List<String> tags;
  final int likesCount;
  final int clonesCount;
  final bool isStaffPick;
  final DateTime createdAt;

  const WalloraScreenBlueprint({
    required this.id,
    required this.title,
    required this.creatorName,
    this.creatorAvatarColorValue = 0xFF00E5FF,
    required this.description,
    required this.wallpaper,
    required this.customQuote,
    this.auraConfig = AuraPaletteConfig.defaultConfig,
    this.particleConfig = ParticleEffectConfig.defaultConfig,
    this.parallaxConfig = ParallaxEffectConfig.defaultConfig,
    this.auroraConfig = AuroraSynthesizerConfig.defaultConfig,
    this.tags = const [],
    this.likesCount = 0,
    this.clonesCount = 0,
    this.isStaffPick = false,
    required this.createdAt,
  });

  Color get creatorAvatarColor => Color(creatorAvatarColorValue);

  WalloraScreenBlueprint copyWith({
    String? id,
    String? title,
    String? creatorName,
    int? creatorAvatarColorValue,
    String? description,
    MotivationalShort? wallpaper,
    String? customQuote,
    AuraPaletteConfig? auraConfig,
    ParticleEffectConfig? particleConfig,
    ParallaxEffectConfig? parallaxConfig,
    AuroraSynthesizerConfig? auroraConfig,
    List<String>? tags,
    int? likesCount,
    int? clonesCount,
    bool? isStaffPick,
    DateTime? createdAt,
  }) {
    return WalloraScreenBlueprint(
      id: id ?? this.id,
      title: title ?? this.title,
      creatorName: creatorName ?? this.creatorName,
      creatorAvatarColorValue:
          creatorAvatarColorValue ?? this.creatorAvatarColorValue,
      description: description ?? this.description,
      wallpaper: wallpaper ?? this.wallpaper,
      customQuote: customQuote ?? this.customQuote,
      auraConfig: auraConfig ?? this.auraConfig,
      particleConfig: particleConfig ?? this.particleConfig,
      parallaxConfig: parallaxConfig ?? this.parallaxConfig,
      auroraConfig: auroraConfig ?? this.auroraConfig,
      tags: tags ?? this.tags,
      likesCount: likesCount ?? this.likesCount,
      clonesCount: clonesCount ?? this.clonesCount,
      isStaffPick: isStaffPick ?? this.isStaffPick,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'creatorName': creatorName,
      'creatorAvatarColorValue': creatorAvatarColorValue,
      'description': description,
      'wallpaper': wallpaper.toJson(),
      'customQuote': customQuote,
      'auraConfig': auraConfig.toJson(),
      'particleConfig': particleConfig.toJson(),
      'parallaxConfig': parallaxConfig.toJson(),
      'auroraConfig': auroraConfig.toJson(),
      'tags': tags,
      'likesCount': likesCount,
      'clonesCount': clonesCount,
      'isStaffPick': isStaffPick,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WalloraScreenBlueprint.fromJson(Map<String, dynamic> json) {
    return WalloraScreenBlueprint(
      id: json['id'] as String? ?? 'bp_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] as String? ?? 'Untitled Blueprint',
      creatorName: json['creatorName'] as String? ?? 'Wallora Creator',
      creatorAvatarColorValue:
          json['creatorAvatarColorValue'] as int? ?? 0xFF00E5FF,
      description: json['description'] as String? ?? '',
      wallpaper: MotivationalShort.fromJson(
        json['wallpaper'] as Map<String, dynamic>? ??
            CuratedShortsData.shorts.first.toJson(),
      ),
      customQuote: json['customQuote'] as String? ?? '',
      auraConfig: json['auraConfig'] != null
          ? AuraPaletteConfig.fromJson(
              json['auraConfig'] as Map<String, dynamic>)
          : AuraPaletteConfig.defaultConfig,
      particleConfig: json['particleConfig'] != null
          ? ParticleEffectConfig.fromJson(
              json['particleConfig'] as Map<String, dynamic>)
          : ParticleEffectConfig.defaultConfig,
      parallaxConfig: json['parallaxConfig'] != null
          ? ParallaxEffectConfig.fromJson(
              json['parallaxConfig'] as Map<String, dynamic>)
          : ParallaxEffectConfig.defaultConfig,
      auroraConfig: json['auroraConfig'] != null
          ? AuroraSynthesizerConfig.fromJson(
              json['auroraConfig'] as Map<String, dynamic>)
          : AuroraSynthesizerConfig.defaultConfig,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      likesCount: json['likesCount'] as int? ?? 0,
      clonesCount: json['clonesCount'] as int? ?? 0,
      isStaffPick: json['isStaffPick'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory WalloraScreenBlueprint.fromJsonString(String source) =>
      WalloraScreenBlueprint.fromJson(
          jsonDecode(source) as Map<String, dynamic>);

  @override
  List<Object?> get props => [
        id,
        title,
        creatorName,
        creatorAvatarColorValue,
        description,
        wallpaper,
        customQuote,
        auraConfig,
        particleConfig,
        parallaxConfig,
        auroraConfig,
        tags,
        likesCount,
        clonesCount,
        isStaffPick,
        createdAt,
      ];

  /// Curated showcase blueprints crafted for Wallora Community Exchange.
  static List<WalloraScreenBlueprint> get curatedBlueprints {
    final shorts = CuratedShortsData.shorts;
    final ippo = shorts.firstWhere((s) => s.id == 'ippo_hard_work');
    final solo = shorts.firstWhere((s) => s.id == 'solo_shadow_monarch');
    final cyber = shorts.firstWhere((s) => s.id == 'cyber_netrunner_terminal');
    final cosmos = shorts.firstWhere((s) => s.id == 'nature_aurora');
    final amoled = shorts.firstWhere((s) => s.id == 'minimal_amoled');

    return [
      WalloraScreenBlueprint(
        id: 'bp_cyber_ronin',
        title: 'Cyberpunk Neon Ronin',
        creatorName: 'KageKaze',
        creatorAvatarColorValue: 0xFFD500F9,
        description:
            'High-voltage electric violet & cyan theme with drifting spark physics and gyroscopic 3D tilt.',
        wallpaper: cyber,
        customQuote: 'The neon never sleeps. Neither does ambition.',
        auraConfig: const AuraPaletteConfig(
          preset: AuraThemePreset.cyberAurora,
          isDynamicThemingEnabled: true,
          syncParticles: true,
          syncKineticQuotes: true,
        ),
        particleConfig: const ParticleEffectConfig(
          preset: ParticlePreset.electricSparks,
          particleCount: 80,
          speedMultiplier: 1.6,
          glowIntensity: 0.9,
        ),
        parallaxConfig: const ParallaxEffectConfig(
          preset: ParallaxPreset.cinematic3D,
          sensitivity: 1.5,
          maxAngleDegrees: 15.0,
          isEnabled: true,
        ),
        auroraConfig: const AuroraSynthesizerConfig(
          waveStyle: AuroraWaveStyle.cyberpunkRibbon,
          colorMode: AuroraColorMode.cyanViolet,
          waveCount: 4,
          waveSpeed: 1.4,
          crestAmplitude: 55.0,
          frequency: 2.0,
          isEnabled: true,
        ),
        tags: const ['Cyberpunk', 'Live', 'Neon', 'StaffPick'],
        likesCount: 1420,
        clonesCount: 890,
        isStaffPick: true,
        createdAt: DateTime(2026, 10, 1),
      ),
      WalloraScreenBlueprint(
        id: 'bp_shadow_monarch',
        title: 'Shadow Monarch Dominion',
        creatorName: 'SungJinWoo',
        creatorAvatarColorValue: 0xFF7C4DFF,
        description:
            'Midnight indigo aesthetic with velvet stardust and stoic monarch affirmation.',
        wallpaper: solo,
        customQuote: 'Protect what matters. Arise and conquer.',
        auraConfig: const AuraPaletteConfig(
          preset: AuraThemePreset.velvetTwilight,
          isDynamicThemingEnabled: true,
        ),
        particleConfig: const ParticleEffectConfig(
          preset: ParticlePreset.neonStardust,
          particleCount: 65,
          speedMultiplier: 1.1,
          glowIntensity: 0.8,
        ),
        parallaxConfig: const ParallaxEffectConfig(
          preset: ParallaxPreset.deepSpatial,
          sensitivity: 1.8,
          maxAngleDegrees: 18.0,
          isEnabled: true,
        ),
        auroraConfig: const AuroraSynthesizerConfig(
          waveStyle: AuroraWaveStyle.bioluminescentDeepSea,
          colorMode: AuroraColorMode.cyanViolet,
          waveCount: 3,
          waveSpeed: 1.0,
          crestAmplitude: 50.0,
          isEnabled: true,
        ),
        tags: const ['Anime', 'Velvet', 'Monarch', 'AMOLED'],
        likesCount: 2310,
        clonesCount: 1560,
        isStaffPick: true,
        createdAt: DateTime(2026, 10, 5),
      ),
      WalloraScreenBlueprint(
        id: 'bp_unbreakable_spirit',
        title: 'Unbreakable Boxing Creed',
        creatorName: 'CoachKamogawa',
        creatorAvatarColorValue: 0xFFFF5722,
        description:
            'Relentless hard work and fighting spirit wrapped in fiery solar coronal waves.',
        wallpaper: ippo,
        customQuote:
            'Not everyone who works hard is rewarded. But all who succeed worked hard.',
        auraConfig: const AuraPaletteConfig(
          preset: AuraThemePreset.solarEclipse,
          isDynamicThemingEnabled: true,
        ),
        particleConfig: const ParticleEffectConfig(
          preset: ParticlePreset.electricSparks,
          particleCount: 50,
          speedMultiplier: 1.2,
        ),
        parallaxConfig: const ParallaxEffectConfig(
          preset: ParallaxPreset.cinematic3D,
          sensitivity: 1.3,
          isEnabled: true,
        ),
        auroraConfig: const AuroraSynthesizerConfig(
          waveStyle: AuroraWaveStyle.solarFlarePlasma,
          colorMode: AuroraColorMode.amberEmerald,
          waveCount: 4,
          waveSpeed: 1.5,
          crestAmplitude: 60.0,
          isEnabled: true,
        ),
        tags: const ['Motivation', 'Solar', 'FightingSpirit', 'StaffPick'],
        likesCount: 3105,
        clonesCount: 2180,
        isStaffPick: true,
        createdAt: DateTime(2026, 9, 20),
      ),
      WalloraScreenBlueprint(
        id: 'bp_celestial_aurora',
        title: 'Celestial Aurora Borealis',
        creatorName: 'NordicZen',
        creatorAvatarColorValue: 0xFF00E5FF,
        description:
            'Mesmerizing celestial northern lights, deep emerald matrix waves, and tranquil stardust.',
        wallpaper: cosmos,
        customQuote: 'In the silence of the cosmos, find your true velocity.',
        auraConfig: const AuraPaletteConfig(
          preset: AuraThemePreset.emeraldMatrix,
          isDynamicThemingEnabled: true,
        ),
        particleConfig: const ParticleEffectConfig(
          preset: ParticlePreset.auroraVortex,
          particleCount: 70,
          speedMultiplier: 0.9,
          glowIntensity: 0.85,
        ),
        parallaxConfig: const ParallaxEffectConfig(
          preset: ParallaxPreset.subtleBreath,
          sensitivity: 0.8,
          isEnabled: true,
        ),
        auroraConfig: const AuroraSynthesizerConfig(
          waveStyle: AuroraWaveStyle.cosmicNorthernLights,
          colorMode: AuroraColorMode.auraSync,
          waveCount: 5,
          waveSpeed: 1.2,
          crestAmplitude: 65.0,
          frequency: 2.2,
          blurSpread: 32.0,
          isEnabled: true,
        ),
        tags: const ['Aurora', 'Cosmic', 'Zen', 'Borealis'],
        likesCount: 1890,
        clonesCount: 1120,
        isStaffPick: true,
        createdAt: DateTime(2026, 10, 10),
      ),
      WalloraScreenBlueprint(
        id: 'bp_amoled_noir',
        title: 'AMOLED Minimalist Noir',
        creatorName: 'OledPurist',
        creatorAvatarColorValue: 0xFFE0E0E0,
        description:
            'Pure 0% black OLED battery conservation with crisp titanium silver line aesthetics.',
        wallpaper: amoled,
        customQuote: 'Simplicity is the ultimate sophistication.',
        auraConfig: const AuraPaletteConfig(
          preset: AuraThemePreset.obsidianMonochrome,
          isDynamicThemingEnabled: false,
        ),
        particleConfig: const ParticleEffectConfig(
          preset: ParticlePreset.none,
        ),
        parallaxConfig: const ParallaxEffectConfig(
          preset: ParallaxPreset.off,
          isEnabled: false,
        ),
        auroraConfig: const AuroraSynthesizerConfig(
          waveStyle: AuroraWaveStyle.monochromeOled,
          colorMode: AuroraColorMode.auraSync,
          waveCount: 2,
          waveSpeed: 0.6,
          crestAmplitude: 35.0,
          blurSpread: 12.0,
          isEnabled: true,
        ),
        tags: const ['AMOLED', 'Minimalist', 'BatterySaver', 'Noir'],
        likesCount: 2750,
        clonesCount: 1980,
        isStaffPick: false,
        createdAt: DateTime(2026, 10, 8),
      ),
    ];
  }
}
