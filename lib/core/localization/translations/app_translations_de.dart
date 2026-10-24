import 'app_translations.dart';

/// German (Deutsch) translations for Wallora.
class AppTranslationsDe implements AppTranslations {
  const AppTranslationsDe();

  @override
  String get appName => 'Wallora';

  @override
  String get appTagline => 'Mach jeden Bildschirm zu deinem.';

  @override
  String get navFeed => 'Feed';

  @override
  String get navCategories => 'Kategorien';

  @override
  String get navDiscover => 'Entdecken';

  @override
  String get navDownloads => 'Downloads';

  @override
  String get navFavorites => 'Favoriten';

  @override
  String get navPlaylists => 'Playlists';

  @override
  String get actionApply => 'Anwenden';

  @override
  String get actionApplyLiveMotion => 'Live Motion Anwenden';

  @override
  String get actionApplyStatic => 'Statisch Anwenden';

  @override
  String get actionDownload => 'Herunterladen';

  @override
  String get actionFavorite => 'Favorit';

  @override
  String get actionShare => 'Teilen';

  @override
  String get actionEdit => 'Bearbeiten';

  @override
  String get actionSave => 'Speichern';

  @override
  String get actionCancel => 'Abbrechen';

  @override
  String get actionDelete => 'Löschen';

  @override
  String get actionClose => 'Schließen';

  @override
  String get actionReset => 'Zurücksetzen';

  @override
  String get actionResetDefaults => 'Standardeinstellungen';

  @override
  String get actionVerifyAndRestore => 'Prüfen & Wiederherstellen';

  @override
  String get actionFactoryReset => 'Auf Werkseinstellungen zurücksetzen';

  @override
  String get actionClearCache => 'Offline-Video-Cache leeren';

  @override
  String get actionDismiss => 'SCHLIESSEN';

  @override
  String get actionExport => 'Exportieren';

  @override
  String get actionImport => 'Importieren';

  @override
  String get titleQuoteStudio => 'ZITAT-STUDIO';

  @override
  String get titleWallpaperEffects => 'HINTERGRUND-EFFEKTE & FILTER';

  @override
  String get titleAutoRotation => 'AUTO-ROTATIONS-ZENTRALE';

  @override
  String get titleLockScreenStudio => 'SPERRBILDSCHIRM-DYNAMIK';

  @override
  String get titleParallaxStudio => 'RÄUMLICHE 3D-PARALLAXE';

  @override
  String get titleBatteryTelemetry => 'BATTERIE- & SYSTEMTELEMETRIE';

  @override
  String get titleAuraHarmonizer => 'AURA-FARBHARMONISIERER';

  @override
  String get titleStandbyDock => 'STANDBY-SCHREIBTISCH-DOCK';

  @override
  String get titleAuroraSynthesizer => 'AURORA-WELLENSYNTHESIZER';

  @override
  String get titleWeatherAtmosphere => 'ATMOSPHÄRISCHES WETTER-STUDIO';

  @override
  String get titleWallazaCloud => 'WALLAZA-CLOUD-ENTDECKUNG';

  @override
  String get titleDataPortability => 'DATENPORTABILITÄT & BACKUP-HUB';

  @override
  String get titleSmartDiscovery => 'INTELLIGENTE ENTDECKUNG & FILTER';

  @override
  String get titleCommunityExchange => 'COMMUNITY-AUSTAUSCH';

  @override
  String get titlePreferences => 'ÄSTHETISCHE PRÄFERENZEN';

  @override
  String get errorInvalidBackupJson => 'Ungültiges Wallora-Backup-Format oder fehlende Version.';

  @override
  String get errorProvideValidJson => 'Bitte gültiges Wallora-Backup-JSON angeben.';

  @override
  String get successBackupCopied => 'Backup-Archiv in die Zwischenablage kopiert!';

  @override
  String get successRestored => 'Konfiguration erfolgreich wiederhergestellt!';

  @override
  String get emptyFavoritesTitle => 'Noch keine Favoriten';

  @override
  String get emptyFavoritesSubtitle => 'Tippe doppelt oder auf das Herz-Symbol, um Hintergründe deiner Sammlung hinzuzufügen.';

  @override
  String get emptyDownloadsTitle => 'Noch keine Downloads';

  @override
  String get emptyDownloadsSubtitle => 'Hier findest du für die Offline-Nutzung gespeicherte Hintergründe.';

  @override
  String itemsCount(int count) => '$count ${count == 1 ? 'Element' : 'Elemente'}';

  @override
  String durationSeconds(int seconds) => '${seconds}s';

  @override
  String appliedSuccess(String title) => '✨ "$title" erfolgreich angewendet!';
}
