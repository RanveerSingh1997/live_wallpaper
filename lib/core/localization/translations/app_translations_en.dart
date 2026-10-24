import 'app_translations.dart';

/// English (default) translations for Wallora.
class AppTranslationsEn implements AppTranslations {
  const AppTranslationsEn();

  @override
  String get appName => 'Wallora';

  @override
  String get appTagline => 'Make every screen yours.';

  @override
  String get navFeed => 'Feed';

  @override
  String get navCategories => 'Categories';

  @override
  String get navDiscover => 'Discover';

  @override
  String get navDownloads => 'Downloads';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navPlaylists => 'Playlists';

  @override
  String get actionApply => 'Apply';

  @override
  String get actionApplyLiveMotion => 'Apply Live Motion';

  @override
  String get actionApplyStatic => 'Apply Static';

  @override
  String get actionDownload => 'Download';

  @override
  String get actionFavorite => 'Favorite';

  @override
  String get actionShare => 'Share';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionClose => 'Close';

  @override
  String get actionReset => 'Reset';

  @override
  String get actionResetDefaults => 'Reset Defaults';

  @override
  String get actionVerifyAndRestore => 'Verify & Restore Setup';

  @override
  String get actionFactoryReset => 'Factory Reset All Settings & Playlists';

  @override
  String get actionClearCache => 'Clear Offline Video Cache';

  @override
  String get actionDismiss => 'DISMISS';

  @override
  String get actionExport => 'Export';

  @override
  String get actionImport => 'Import';

  @override
  String get titleQuoteStudio => 'QUOTE STUDIO';

  @override
  String get titleWallpaperEffects => 'WALLPAPER EFFECTS & FILTERS';

  @override
  String get titleAutoRotation => 'AUTO-ROTATION HUB';

  @override
  String get titleLockScreenStudio => 'LOCK SCREEN DYNAMICS';

  @override
  String get titleParallaxStudio => '3D SPATIAL PARALLAX';

  @override
  String get titleBatteryTelemetry => 'BATTERY & SYSTEM TELEMETRY';

  @override
  String get titleAuraHarmonizer => 'AURA CHROMATIC HARMONIZER';

  @override
  String get titleStandbyDock => 'STANDBY DESK DOCK';

  @override
  String get titleAuroraSynthesizer => 'AURORA WAVE SYNTHESIZER';

  @override
  String get titleWeatherAtmosphere => 'ATMOSPHERIC WEATHER STUDIO';

  @override
  String get titleWallazaCloud => 'WALLAZA CLOUD DISCOVERY';

  @override
  String get titleDataPortability => 'DATA PORTABILITY & BACKUP HUB';

  @override
  String get titleSmartDiscovery => 'SMART DISCOVERY & FILTERING';

  @override
  String get titleCommunityExchange => 'COMMUNITY EXCHANGE';

  @override
  String get titlePreferences => 'AESTHETIC PREFERENCES';

  @override
  String get errorInvalidBackupJson => 'Invalid Wallora backup format or missing version.';

  @override
  String get errorProvideValidJson => 'Please provide a valid Wallora backup JSON.';

  @override
  String get successBackupCopied => 'Backup archive copied to clipboard!';

  @override
  String get successRestored => 'Setup restored successfully!';

  @override
  String get emptyFavoritesTitle => 'No Favorites Yet';

  @override
  String get emptyFavoritesSubtitle => 'Double-tap or tap the heart icon on any wallpaper to add it to your curated collection.';

  @override
  String get emptyDownloadsTitle => 'No Downloads Yet';

  @override
  String get emptyDownloadsSubtitle => 'Wallpapers saved for offline use will be stored here.';

  @override
  String itemsCount(int count) => '$count ${count == 1 ? 'item' : 'items'}';

  @override
  String durationSeconds(int seconds) => '${seconds}s';

  @override
  String appliedSuccess(String title) => '✨ Applied "$title" successfully!';
}
