import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'audio_visualizer_config.dart';
import 'aura_palette_config.dart';
import 'aurora_synthesizer_config.dart';
import 'battery_telemetry_config.dart';
import 'day_night_schedule_config.dart';
import 'gesture_control_config.dart';
import 'lock_screen_style_config.dart';
import 'parallax_effect_config.dart';
import 'particle_effect_config.dart';
import 'smart_filter_config.dart';
import 'standby_dock_config.dart';
import 'wallpaper_collection.dart';
import 'wallpaper_effect_config.dart';
import 'weather_atmosphere_config.dart';

/// Versioned, portable backup archive encapsulating the entire Wallora user configuration.
class WalloraBackupBundle extends Equatable {
  static const int currentSchemaVersion = 1;
  static const String currentAppName = 'Wallora';

  final int version;
  final String appName;
  final DateTime exportedAt;
  final Set<String> favoriteIds;
  final List<WallpaperCollection> customCollections;
  final Map<String, String> customizedQuotes;
  final Map<String, WallpaperEffectConfig> customEffects;
  final DayNightScheduleConfig dayNightSchedule;
  final LockScreenStyleConfig lockScreenStyle;
  final ParallaxEffectConfig parallaxConfig;
  final ParticleEffectConfig particleConfig;
  final AuraPaletteConfig auraConfig;
  final GestureControlConfig gestureConfig;
  final StandbyDockConfig standbyDockConfig;
  final AuroraSynthesizerConfig auroraSynthesizerConfig;
  final AudioVisualizerConfig audioVisualizerConfig;
  final BatteryTelemetryConfig batteryTelemetry;
  final SmartFilterConfig smartFilter;
  final WeatherAtmosphereConfig weatherConfig;
  final Set<String> userPreferences;
  final bool isAmoledSaverModeEnabled;

  const WalloraBackupBundle({
    this.version = currentSchemaVersion,
    this.appName = currentAppName,
    required this.exportedAt,
    this.favoriteIds = const {},
    this.customCollections = const [],
    this.customizedQuotes = const {},
    this.customEffects = const {},
    this.dayNightSchedule = DayNightScheduleConfig.defaultConfig,
    this.lockScreenStyle = LockScreenStyleConfig.defaultConfig,
    this.parallaxConfig = ParallaxEffectConfig.defaultConfig,
    this.particleConfig = ParticleEffectConfig.defaultConfig,
    this.auraConfig = AuraPaletteConfig.defaultConfig,
    this.gestureConfig = GestureControlConfig.defaultConfig,
    this.standbyDockConfig = StandbyDockConfig.defaultConfig,
    this.auroraSynthesizerConfig = AuroraSynthesizerConfig.defaultConfig,
    this.audioVisualizerConfig = AudioVisualizerConfig.defaultConfig,
    this.batteryTelemetry = BatteryTelemetryConfig.defaultConfig,
    this.smartFilter = SmartFilterConfig.defaultConfig,
    this.weatherConfig = WeatherAtmosphereConfig.defaultConfig,
    this.userPreferences = const {},
    this.isAmoledSaverModeEnabled = false,
  });

  /// Short summary description of bundle contents.
  String get summary {
    final List<String> parts = [];
    if (favoriteIds.isNotEmpty) parts.add('${favoriteIds.length} favorites');
    if (customCollections.isNotEmpty) parts.add('${customCollections.length} playlists');
    if (customizedQuotes.isNotEmpty) parts.add('${customizedQuotes.length} quotes');
    if (customEffects.isNotEmpty) parts.add('${customEffects.length} effect presets');
    if (parts.isEmpty) return 'Default Wallora setup';
    return parts.join(' • ');
  }

  /// Validates whether a raw JSON string is a valid Wallora backup bundle.
  static bool isValidJson(String rawJson) {
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! Map<String, dynamic>) return false;
      return decoded['appName'] == currentAppName &&
          decoded['version'] != null &&
          decoded['exportedAt'] != null;
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'appName': appName,
      'exportedAt': exportedAt.toIso8601String(),
      'favoriteIds': favoriteIds.toList(),
      'customCollections':
          customCollections.map((col) => col.toJson()).toList(),
      'customizedQuotes': customizedQuotes,
      'customEffects': customEffects.map(
        (key, val) => MapEntry(key, val.toJson()),
      ),
      'dayNightSchedule': dayNightSchedule.toJson(),
      'lockScreenStyle': lockScreenStyle.toJson(),
      'parallaxConfig': parallaxConfig.toJson(),
      'particleConfig': particleConfig.toJson(),
      'auraConfig': auraConfig.toJson(),
      'gestureConfig': gestureConfig.toJson(),
      'standbyDockConfig': standbyDockConfig.toJson(),
      'auroraSynthesizerConfig': auroraSynthesizerConfig.toJson(),
      'audioVisualizerConfig': audioVisualizerConfig.toJson(),
      'batteryTelemetry': batteryTelemetry.toJson(),
      'smartFilter': smartFilter.toJson(),
      'weatherConfig': weatherConfig.toJson(),
      'userPreferences': userPreferences.toList(),
      'isAmoledSaverModeEnabled': isAmoledSaverModeEnabled,
    };
  }

  String toJsonString({bool pretty = false}) {
    final map = toJson();
    if (pretty) {
      return const JsonEncoder.withIndent('  ').convert(map);
    }
    return jsonEncode(map);
  }

  factory WalloraBackupBundle.fromJson(Map<String, dynamic> json) {
    final rawCollections = json['customCollections'] as List<dynamic>? ?? [];
    final List<WallpaperCollection> collections = [];
    for (final c in rawCollections) {
      if (c is Map<String, dynamic>) {
        collections.add(WallpaperCollection.fromJson(c));
      }
    }

    final rawEffects = json['customEffects'] as Map<String, dynamic>? ?? {};
    final Map<String, WallpaperEffectConfig> effects = {};
    for (final entry in rawEffects.entries) {
      if (entry.value is Map<String, dynamic>) {
        effects[entry.key] =
            WallpaperEffectConfig.fromJson(entry.value as Map<String, dynamic>);
      }
    }

    final rawQuotes = json['customizedQuotes'] as Map<String, dynamic>? ?? {};
    final Map<String, String> quotes = {
      for (final e in rawQuotes.entries) e.key: e.value.toString()
    };

    final rawFavorites = (json['favoriteIds'] as List<dynamic>?)?.cast<String>() ?? [];
    final rawPreferences =
        (json['userPreferences'] as List<dynamic>?)?.cast<String>() ?? [];

    return WalloraBackupBundle(
      version: json['version'] as int? ?? currentSchemaVersion,
      appName: json['appName'] as String? ?? currentAppName,
      exportedAt: json['exportedAt'] != null
          ? DateTime.tryParse(json['exportedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      favoriteIds: rawFavorites.toSet(),
      customCollections: collections,
      customizedQuotes: quotes,
      customEffects: effects,
      dayNightSchedule: json['dayNightSchedule'] != null
          ? DayNightScheduleConfig.fromJson(
              json['dayNightSchedule'] as Map<String, dynamic>)
          : DayNightScheduleConfig.defaultConfig,
      lockScreenStyle: json['lockScreenStyle'] != null
          ? LockScreenStyleConfig.fromJson(
              json['lockScreenStyle'] as Map<String, dynamic>)
          : LockScreenStyleConfig.defaultConfig,
      parallaxConfig: json['parallaxConfig'] != null
          ? ParallaxEffectConfig.fromJson(
              json['parallaxConfig'] as Map<String, dynamic>)
          : ParallaxEffectConfig.defaultConfig,
      particleConfig: json['particleConfig'] != null
          ? ParticleEffectConfig.fromJson(
              json['particleConfig'] as Map<String, dynamic>)
          : ParticleEffectConfig.defaultConfig,
      auraConfig: json['auraConfig'] != null
          ? AuraPaletteConfig.fromJson(
              json['auraConfig'] as Map<String, dynamic>)
          : AuraPaletteConfig.defaultConfig,
      gestureConfig: json['gestureConfig'] != null
          ? GestureControlConfig.fromJson(
              json['gestureConfig'] as Map<String, dynamic>)
          : GestureControlConfig.defaultConfig,
      standbyDockConfig: json['standbyDockConfig'] != null
          ? StandbyDockConfig.fromJson(
              json['standbyDockConfig'] as Map<String, dynamic>)
          : StandbyDockConfig.defaultConfig,
      auroraSynthesizerConfig: json['auroraSynthesizerConfig'] != null
          ? AuroraSynthesizerConfig.fromJson(
              json['auroraSynthesizerConfig'] as Map<String, dynamic>)
          : AuroraSynthesizerConfig.defaultConfig,
      audioVisualizerConfig: json['audioVisualizerConfig'] != null
          ? AudioVisualizerConfig.fromJson(
              json['audioVisualizerConfig'] as Map<String, dynamic>)
          : AudioVisualizerConfig.defaultConfig,
      batteryTelemetry: json['batteryTelemetry'] != null
          ? BatteryTelemetryConfig.fromJson(
              json['batteryTelemetry'] as Map<String, dynamic>)
          : BatteryTelemetryConfig.defaultConfig,
      smartFilter: json['smartFilter'] != null
          ? SmartFilterConfig.fromJson(
              json['smartFilter'] as Map<String, dynamic>)
          : SmartFilterConfig.defaultConfig,
      weatherConfig: json['weatherConfig'] != null
          ? WeatherAtmosphereConfig.fromJson(
              json['weatherConfig'] as Map<String, dynamic>)
          : WeatherAtmosphereConfig.defaultConfig,
      userPreferences: rawPreferences.toSet(),
      isAmoledSaverModeEnabled:
          json['isAmoledSaverModeEnabled'] as bool? ?? false,
    );
  }

  factory WalloraBackupBundle.fromJsonString(String rawJson) {
    final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
    return WalloraBackupBundle.fromJson(decoded);
  }

  WalloraBackupBundle copyWith({
    int? version,
    String? appName,
    DateTime? exportedAt,
    Set<String>? favoriteIds,
    List<WallpaperCollection>? customCollections,
    Map<String, String>? customizedQuotes,
    Map<String, WallpaperEffectConfig>? customEffects,
    DayNightScheduleConfig? dayNightSchedule,
    LockScreenStyleConfig? lockScreenStyle,
    ParallaxEffectConfig? parallaxConfig,
    ParticleEffectConfig? particleConfig,
    AuraPaletteConfig? auraConfig,
    GestureControlConfig? gestureConfig,
    StandbyDockConfig? standbyDockConfig,
    AuroraSynthesizerConfig? auroraSynthesizerConfig,
    AudioVisualizerConfig? audioVisualizerConfig,
    BatteryTelemetryConfig? batteryTelemetry,
    SmartFilterConfig? smartFilter,
    WeatherAtmosphereConfig? weatherConfig,
    Set<String>? userPreferences,
    bool? isAmoledSaverModeEnabled,
  }) {
    return WalloraBackupBundle(
      version: version ?? this.version,
      appName: appName ?? this.appName,
      exportedAt: exportedAt ?? this.exportedAt,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      customCollections: customCollections ?? this.customCollections,
      customizedQuotes: customizedQuotes ?? this.customizedQuotes,
      customEffects: customEffects ?? this.customEffects,
      dayNightSchedule: dayNightSchedule ?? this.dayNightSchedule,
      lockScreenStyle: lockScreenStyle ?? this.lockScreenStyle,
      parallaxConfig: parallaxConfig ?? this.parallaxConfig,
      particleConfig: particleConfig ?? this.particleConfig,
      auraConfig: auraConfig ?? this.auraConfig,
      gestureConfig: gestureConfig ?? this.gestureConfig,
      standbyDockConfig: standbyDockConfig ?? this.standbyDockConfig,
      auroraSynthesizerConfig:
          auroraSynthesizerConfig ?? this.auroraSynthesizerConfig,
      audioVisualizerConfig:
          audioVisualizerConfig ?? this.audioVisualizerConfig,
      batteryTelemetry: batteryTelemetry ?? this.batteryTelemetry,
      smartFilter: smartFilter ?? this.smartFilter,
      weatherConfig: weatherConfig ?? this.weatherConfig,
      userPreferences: userPreferences ?? this.userPreferences,
      isAmoledSaverModeEnabled:
          isAmoledSaverModeEnabled ?? this.isAmoledSaverModeEnabled,
    );
  }

  @override
  List<Object?> get props => [
        version,
        appName,
        exportedAt,
        favoriteIds,
        customCollections,
        customizedQuotes,
        customEffects,
        dayNightSchedule,
        lockScreenStyle,
        parallaxConfig,
        particleConfig,
        auraConfig,
        gestureConfig,
        standbyDockConfig,
        auroraSynthesizerConfig,
        audioVisualizerConfig,
        batteryTelemetry,
        smartFilter,
        weatherConfig,
        userPreferences,
        isAmoledSaverModeEnabled,
      ];
}
