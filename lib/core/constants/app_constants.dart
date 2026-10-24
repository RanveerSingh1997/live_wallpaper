/// Application-wide constants for Wallora.
abstract final class AppConstants {
  // Brand & Application Information
  static const String appName = 'Wallora';
  static const String appTagline = 'Make every screen yours.';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  // Platform Channels
  static const String wallpaperChannelName = 'com.example.live_wallpaper/wallpaper';

  // Storage & SharedPreferences Keys
  static const String keyFavorites = 'favorite_short_ids';
  static const String keyDownloads = 'downloaded_wallpaper_ids';
  static const String keyActiveId = 'active_wallpaper_id';
  static const String keyCustomQuotesPrefix = 'custom_quote_';
  static const String keyCustomEffectsPrefix = 'custom_effects_';
  static const String keyUserPreferences = 'user_preferred_categories';
  static const String keyTextOverlayEnabled = 'text_overlay_enabled_by_default';
  static const String keyRecentlyViewed = 'recently_viewed_wallpaper_ids';
  static const String keyReported = 'reported_wallpaper_ids';
  static const String keyHasSeenOnboarding = 'has_seen_onboarding';
  static const String keyAutoRotationEnabled = 'auto_rotation_enabled';
  static const String keyAutoRotationIntervalMinutes = 'auto_rotation_interval_minutes';
  static const String keyAutoRotationSource = 'auto_rotation_source';
  static const String keyAutoRotationWifiOnly = 'auto_rotation_wifi_only';
  static const String keyAutoRotationTarget = 'auto_rotation_target';
  static const String keyCustomImportedWallpapers = 'custom_imported_wallpapers';
  static const String keyCustomCollections = 'custom_user_collections';
  static const String keyAmoledSaverMode = 'amoled_saver_mode_enabled';
  static const String keyDayNightSchedule = 'day_night_schedule_config';
  static const String keyLockScreenStyle = 'lock_screen_style_config';
  static const String keyParallaxConfig = 'parallax_effect_config';
  static const String keyParticleConfig = 'particle_effect_config';
  static const String keySmartFilter = 'smart_filter_config';
  static const String keyBatteryTelemetry = 'battery_telemetry_config';
  static const String keyAuraPalette = 'aura_palette_config';
  static const String keyGestureControl = 'gesture_control_config';
  static const String keyStandbyDock = 'standby_dock_config';
  static const String keyAuroraSynthesizer = 'aurora_synthesizer_config';
  static const String keyWeatherAtmosphere = 'wallora_weather_atmosphere_config';
  static const String keyPublishedBlueprints = 'wallora_published_blueprints';
  static const String keyLikedBlueprintIds = 'wallora_liked_blueprint_ids';

  // Animation Timings & Durations
  static const Duration splashDelay = Duration(milliseconds: 2200);
  static const Duration quickAnimationDuration = Duration(milliseconds: 200);
  static const Duration standardAnimationDuration = Duration(milliseconds: 300);
  static const Duration pageTransitionDuration = Duration(milliseconds: 400);
  static const Duration snackBarDisplayDuration = Duration(seconds: 3);

  // Auto-Rotation Bounds
  static const int minRotationIntervalMinutes = 15;
  static const int maxRotationIntervalMinutes = 1440; // 24 hours
  static const int defaultRotationIntervalMinutes = 60;

  // Visual & Render Constraints
  static const double phonePreviewAspectRatio = 9 / 16;
  static const double wallpaperCardAspectRatio = 9 / 16;
  static const int maxRecentlyViewedHistory = 20;
}
