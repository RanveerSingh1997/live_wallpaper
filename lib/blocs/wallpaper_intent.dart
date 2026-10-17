import 'package:equatable/equatable.dart';
import '../models/aura_palette_config.dart';
import '../models/battery_telemetry_config.dart';
import '../models/day_night_schedule_config.dart';
import '../models/gesture_control_config.dart';
import '../models/lock_screen_style_config.dart';
import '../models/motivational_short.dart';
import '../models/parallax_effect_config.dart';
import '../models/particle_effect_config.dart';
import '../models/smart_filter_config.dart';
import '../models/wallpaper_collection.dart';
import '../models/wallpaper_effect_config.dart';
import '../models/wallora_backup_bundle.dart';

abstract class WallpaperIntent extends Equatable {
  const WallpaperIntent();

  @override
  List<Object?> get props => [];
}

/// Intent to load the initial shorts feed, cached quotes, favorites, and downloads.
class LoadFeedIntent extends WallpaperIntent {
  const LoadFeedIntent();
}

/// Intent triggered when user swipes to a new vertical short in the live feed.
class ChangeActiveShortIntent extends WallpaperIntent {
  final int index;
  const ChangeActiveShortIntent(this.index);

  @override
  List<Object?> get props => [index];
}

/// Intent to switch bottom navigation destination tab (0: Discover, 1: Live, 2: Categories, 3: Favorites, 4: Downloads).
class ChangeNavigationTabIntent extends WallpaperIntent {
  final int tabIndex;
  const ChangeNavigationTabIntent(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}

/// Intent to toggle in-app feed preview audio.
class ToggleFeedMuteIntent extends WallpaperIntent {}

/// Intent to favorite or unfavorite a short.
class ToggleFavoriteIntent extends WallpaperIntent {
  final String shortId;
  const ToggleFavoriteIntent(this.shortId);

  @override
  List<Object?> get props => [shortId];
}

/// Intent to download a wallpaper for offline use.
class DownloadWallpaperIntent extends WallpaperIntent {
  final MotivationalShort short;
  const DownloadWallpaperIntent(this.short);

  @override
  List<Object?> get props => [short];
}

/// Intent to delete a downloaded wallpaper to reclaim disk space.
class DeleteDownloadIntent extends WallpaperIntent {
  final String shortId;
  const DeleteDownloadIntent(this.shortId);

  @override
  List<Object?> get props => [shortId];
}

/// Intent to clear all offline downloads.
class ClearAllDownloadsIntent extends WallpaperIntent {}

/// Intent to search wallpapers by query string.
class SearchWallpapersIntent extends WallpaperIntent {
  final String query;
  const SearchWallpapersIntent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Intent to filter the feed by category (e.g. All, Nature, Minimal, Cars).
class FilterByCategoryIntent extends WallpaperIntent {
  final String category;
  const FilterByCategoryIntent(this.category);

  @override
  List<Object?> get props => [category];
}

/// Intent to update user preferred categories.
class UpdateUserPreferencesIntent extends WallpaperIntent {
  final Set<String> preferences;
  const UpdateUserPreferencesIntent(this.preferences);

  @override
  List<Object?> get props => [preferences];
}

/// Intent to toggle kinetic text overlay visibility on screen.
class ToggleTextOverlayVisibilityIntent extends WallpaperIntent {}

/// Intent to update or customize the quote on a specific short.
class UpdateCustomQuoteIntent extends WallpaperIntent {
  final String shortId;
  final String newQuote;
  const UpdateCustomQuoteIntent({
    required this.shortId,
    required this.newQuote,
  });

  @override
  List<Object?> get props => [shortId, newQuote];
}

/// Intent to reset quote to original default.
class ResetCustomQuoteIntent extends WallpaperIntent {
  final String shortId;
  const ResetCustomQuoteIntent(this.shortId);

  @override
  List<Object?> get props => [shortId];
}

/// Intent to apply the chosen short as a looping live wallpaper.
class ApplyLiveWallpaperIntent extends WallpaperIntent {
  final MotivationalShort short;
  final bool isMuted;

  const ApplyLiveWallpaperIntent({
    required this.short,
    this.isMuted = true,
  });

  @override
  List<Object?> get props => [short, isMuted];
}

/// Intent to share video or invoke native iPad "Use as Wallpaper" share sheet.
class ShareVideoIntent extends WallpaperIntent {
  final MotivationalShort short;
  const ShareVideoIntent(this.short);

  @override
  List<Object?> get props => [short];
}

/// Intent to open the Photos app on iPad/iOS.
class OpenPhotosIntent extends WallpaperIntent {}

/// Intent to check if the wallpaper is currently active on the device.
class CheckWallpaperStatusIntent extends WallpaperIntent {}

/// Intent to clear temporary status messages / snackbars.
class ClearStatusMessageIntent extends WallpaperIntent {}

/// Intent to apply a static wallpaper directly on Android (home, lock, or both).
class ApplyStaticWallpaperIntent extends WallpaperIntent {
  final MotivationalShort short;
  final String targetScreen; // 'home', 'lock', 'both'
  final String? customQuote;

  const ApplyStaticWallpaperIntent({
    required this.short,
    this.targetScreen = 'both',
    this.customQuote,
  });

  @override
  List<Object?> get props => [short, targetScreen, customQuote];
}

/// Intent to record that a wallpaper was viewed in the preview sheet or feed.
class RecordWallpaperViewedIntent extends WallpaperIntent {
  final String wallpaperId;
  const RecordWallpaperViewedIntent(this.wallpaperId);

  @override
  List<Object?> get props => [wallpaperId];
}

/// Intent to report inappropriate or infringing content.
class ReportWallpaperIntent extends WallpaperIntent {
  final String wallpaperId;
  final String reason;

  const ReportWallpaperIntent({
    required this.wallpaperId,
    required this.reason,
  });

  @override
  List<Object?> get props => [wallpaperId, reason];
}

/// Intent to complete the onboarding process and persist preferences.
class CompleteOnboardingIntent extends WallpaperIntent {
  final Set<String> selectedPreferences;
  const CompleteOnboardingIntent(this.selectedPreferences);

  @override
  List<Object?> get props => [selectedPreferences];
}

/// Intent to reset onboarding status so user can experience setup again.
class ResetOnboardingIntent extends WallpaperIntent {}

/// Intent to toggle auto wallpaper rotation on or off.
class ToggleAutoRotationIntent extends WallpaperIntent {
  final bool enabled;
  const ToggleAutoRotationIntent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Intent to update auto wallpaper rotation frequency interval in minutes.
class UpdateAutoRotationIntervalIntent extends WallpaperIntent {
  final int minutes;
  const UpdateAutoRotationIntervalIntent(this.minutes);

  @override
  List<Object?> get props => [minutes];
}

/// Intent to update auto wallpaper rotation source pool (e.g. 'favorites', 'all', or collection ID).
class UpdateAutoRotationSourceIntent extends WallpaperIntent {
  final String source;
  const UpdateAutoRotationSourceIntent(this.source);

  @override
  List<Object?> get props => [source];
}

/// Intent to update auto wallpaper rotation Wi-Fi only guard.
class UpdateAutoRotationWifiOnlyIntent extends WallpaperIntent {
  final bool wifiOnly;
  const UpdateAutoRotationWifiOnlyIntent(this.wifiOnly);

  @override
  List<Object?> get props => [wifiOnly];
}

/// Intent to update auto wallpaper rotation target screen ('both', 'home', 'lock').
class UpdateAutoRotationTargetIntent extends WallpaperIntent {
  final String target;
  const UpdateAutoRotationTargetIntent(this.target);

  @override
  List<Object?> get props => [target];
}

/// Intent to rotate to the next wallpaper in the active pool immediately on-demand.
class RotateWallpaperNowIntent extends WallpaperIntent {
  const RotateWallpaperNowIntent();
}

/// Intent to import a creator or custom wallpaper into the personal library.
class ImportCustomWallpaperIntent extends WallpaperIntent {
  final MotivationalShort wallpaper;
  const ImportCustomWallpaperIntent(this.wallpaper);

  @override
  List<Object?> get props => [wallpaper];
}

/// Intent to create a new user custom collection / playlist.
class CreateCustomCollectionIntent extends WallpaperIntent {
  final WallpaperCollection collection;
  const CreateCustomCollectionIntent(this.collection);

  @override
  List<Object?> get props => [collection];
}

/// Intent to delete a user custom collection.
class DeleteCustomCollectionIntent extends WallpaperIntent {
  final String collectionId;
  const DeleteCustomCollectionIntent(this.collectionId);

  @override
  List<Object?> get props => [collectionId];
}

/// Intent to add or remove a wallpaper from a user custom collection.
class ToggleWallpaperInCollectionIntent extends WallpaperIntent {
  final String collectionId;
  final String wallpaperId;
  const ToggleWallpaperInCollectionIntent({
    required this.collectionId,
    required this.wallpaperId,
  });

  @override
  List<Object?> get props => [collectionId, wallpaperId];
}

/// Intent to toggle AMOLED True-Black battery saver mode.
class ToggleAmoledSaverModeIntent extends WallpaperIntent {
  const ToggleAmoledSaverModeIntent();
}

/// Intent to update visual effects (blur, vignette, contrast, filters) for a given wallpaper.
class UpdateWallpaperEffectIntent extends WallpaperIntent {
  final String wallpaperId;
  final WallpaperEffectConfig effectConfig;

  const UpdateWallpaperEffectIntent({
    required this.wallpaperId,
    required this.effectConfig,
  });

  @override
  List<Object?> get props => [wallpaperId, effectConfig];
}

/// Intent to reset visual effects for a given wallpaper to default.
class ResetWallpaperEffectIntent extends WallpaperIntent {
  final String wallpaperId;

  const ResetWallpaperEffectIntent(this.wallpaperId);

  @override
  List<Object?> get props => [wallpaperId];
}

/// Intent to update the Day & Night solar dynamic schedule configuration.
class UpdateDayNightScheduleIntent extends WallpaperIntent {
  final DayNightScheduleConfig config;
  const UpdateDayNightScheduleIntent(this.config);

  @override
  List<Object?> get props => [config];
}

/// Intent to toggle the Day & Night solar schedule on or off.
class ToggleDayNightScheduleIntent extends WallpaperIntent {
  const ToggleDayNightScheduleIntent();
}

/// Intent to evaluate time transition and apply scheduled wallpaper if active.
class CheckDayNightTransitionIntent extends WallpaperIntent {
  final DateTime? currentTime;
  const CheckDayNightTransitionIntent([this.currentTime]);

  @override
  List<Object?> get props => [currentTime];
}

/// Intent to update the Lock Screen clock & widget simulation style.
class UpdateLockScreenStyleIntent extends WallpaperIntent {
  final LockScreenStyleConfig config;
  const UpdateLockScreenStyleIntent(this.config);

  @override
  List<Object?> get props => [config];
}

/// Intent to reset the Lock Screen clock & widget simulation style to default.
class ResetLockScreenStyleIntent extends WallpaperIntent {
  const ResetLockScreenStyleIntent();
}

/// Intent to update the 3D Spatial Parallax motion configuration.
class UpdateParallaxConfigIntent extends WallpaperIntent {
  final ParallaxEffectConfig config;
  const UpdateParallaxConfigIntent(this.config);

  @override
  List<Object?> get props => [config];
}

/// Intent to toggle the 3D Spatial Parallax motion engine on or off.
class ToggleParallaxIntent extends WallpaperIntent {
  const ToggleParallaxIntent();
}

/// Intent to reset the 3D Spatial Parallax configuration to default.
class ResetParallaxConfigIntent extends WallpaperIntent {
  const ResetParallaxConfigIntent();
}

/// Intent to update the Smart Semantic Discovery & Mood Filter configuration.
class UpdateSmartFilterIntent extends WallpaperIntent {
  final SmartFilterConfig config;
  const UpdateSmartFilterIntent(this.config);

  @override
  List<Object?> get props => [config];
}

/// Intent to reset the Smart Semantic Discovery & Mood Filter configuration.
class ResetSmartFilterIntent extends WallpaperIntent {
  const ResetSmartFilterIntent();
}

/// Intent to update the Battery & Display Telemetry configuration.
class UpdateBatteryTelemetryIntent extends WallpaperIntent {
  final BatteryTelemetryConfig config;
  const UpdateBatteryTelemetryIntent(this.config);

  @override
  List<Object?> get props => [config];
}

/// Intent to toggle Adaptive Eco Mode on or off.
class ToggleEcoModeIntent extends WallpaperIntent {
  const ToggleEcoModeIntent();
}

/// Intent to reset the Battery & Display Telemetry configuration to defaults.
class ResetBatteryTelemetryIntent extends WallpaperIntent {
  const ResetBatteryTelemetryIntent();
}

/// Intent to update the Interactive Particle FX configuration.
class UpdateParticleConfigIntent extends WallpaperIntent {
  final ParticleEffectConfig config;
  const UpdateParticleConfigIntent(this.config);

  @override
  List<Object?> get props => [config];
}

/// Intent to toggle Interactive Particle FX on or off.
class ToggleParticleEffectIntent extends WallpaperIntent {
  const ToggleParticleEffectIntent();
}

/// Intent to reset Interactive Particle FX configuration to defaults.
class ResetParticleConfigIntent extends WallpaperIntent {
  const ResetParticleConfigIntent();
}

/// Intent to update the Aura Chromatic Harmonizer & Dynamic Palette configuration.
class UpdateAuraPaletteIntent extends WallpaperIntent {
  final AuraPaletteConfig config;
  const UpdateAuraPaletteIntent(this.config);

  @override
  List<Object?> get props => [config];
}

/// Intent to switch to a predefined Aura Theme Preset.
class SetAuraThemePresetIntent extends WallpaperIntent {
  final AuraThemePreset preset;
  const SetAuraThemePresetIntent(this.preset);

  @override
  List<Object?> get props => [preset];
}

/// Intent to reset the Aura Chromatic Harmonizer configuration to defaults.
class ResetAuraPaletteIntent extends WallpaperIntent {
  const ResetAuraPaletteIntent();
}

/// Intent to restore user configurations, playlists, and presets from a WalloraBackupBundle.
class RestoreBackupIntent extends WallpaperIntent {
  final WalloraBackupBundle bundle;
  final bool mergeWithExisting;

  const RestoreBackupIntent({
    required this.bundle,
    this.mergeWithExisting = false,
  });

  @override
  List<Object?> get props => [bundle, mergeWithExisting];
}

/// Intent to wipe user custom data and restore Wallora to factory defaults.
class ResetFactoryDefaultsIntent extends WallpaperIntent {
  const ResetFactoryDefaultsIntent();
}

/// Intent to update the Gesture Controls & Dynamic Haptics configuration.
class UpdateGestureControlIntent extends WallpaperIntent {
  final GestureControlConfig config;
  const UpdateGestureControlIntent(this.config);

  @override
  List<Object?> get props => [config];
}

/// Intent to reset the Gesture Controls & Dynamic Haptics configuration to defaults.
class ResetGestureControlIntent extends WallpaperIntent {
  const ResetGestureControlIntent();
}

/// Intent to trigger an action from a touch gesture.
class ExecuteGestureActionIntent extends WallpaperIntent {
  final GestureAction action;
  const ExecuteGestureActionIntent(this.action);

  @override
  List<Object?> get props => [action];
}

/// Intent to toggle Clean Canvas (Zen Mode) overlay visibility.
class ToggleCleanCanvasIntent extends WallpaperIntent {
  const ToggleCleanCanvasIntent();
}



