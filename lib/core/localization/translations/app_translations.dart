/// Contract defining all localizable strings for Wallora.
abstract class AppTranslations {
  // Brand
  String get appName;
  String get appTagline;

  // Navigation Tabs
  String get navFeed;
  String get navCategories;
  String get navDiscover;
  String get navDownloads;
  String get navFavorites;
  String get navPlaylists;

  // Actions
  String get actionApply;
  String get actionApplyLiveMotion;
  String get actionApplyStatic;
  String get actionDownload;
  String get actionFavorite;
  String get actionShare;
  String get actionEdit;
  String get actionSave;
  String get actionCancel;
  String get actionDelete;
  String get actionClose;
  String get actionReset;
  String get actionResetDefaults;
  String get actionVerifyAndRestore;
  String get actionFactoryReset;
  String get actionClearCache;
  String get actionDismiss;
  String get actionExport;
  String get actionImport;

  // Studio Titles
  String get titleQuoteStudio;
  String get titleWallpaperEffects;
  String get titleAutoRotation;
  String get titleLockScreenStudio;
  String get titleParallaxStudio;
  String get titleBatteryTelemetry;
  String get titleAuraHarmonizer;
  String get titleStandbyDock;
  String get titleAuroraSynthesizer;
  String get titleWeatherAtmosphere;
  String get titleWallazaCloud;
  String get titleDataPortability;
  String get titleSmartDiscovery;
  String get titleCommunityExchange;
  String get titlePreferences;

  // Feedback & Messages
  String get errorInvalidBackupJson;
  String get errorProvideValidJson;
  String get successBackupCopied;
  String get successRestored;
  String get emptyFavoritesTitle;
  String get emptyFavoritesSubtitle;
  String get emptyDownloadsTitle;
  String get emptyDownloadsSubtitle;

  // Parametric Messages
  String itemsCount(int count);
  String durationSeconds(int seconds);
  String appliedSuccess(String title);
}
