import 'app_translations.dart';

/// French translations for Wallora.
class AppTranslationsFr implements AppTranslations {
  const AppTranslationsFr();

  @override
  String get appName => 'Wallora';

  @override
  String get appTagline => 'Faites de chaque écran le vôtre.';

  @override
  String get navFeed => 'Flux';

  @override
  String get navCategories => 'Catégories';

  @override
  String get navDiscover => 'Découvrir';

  @override
  String get navDownloads => 'Téléchargements';

  @override
  String get navFavorites => 'Favoris';

  @override
  String get navPlaylists => 'Listes de lecture';

  @override
  String get actionApply => 'Appliquer';

  @override
  String get actionApplyLiveMotion => 'Appliquer le Mouvement en Direct';

  @override
  String get actionApplyStatic => 'Appliquer en Statique';

  @override
  String get actionDownload => 'Télécharger';

  @override
  String get actionFavorite => 'Favori';

  @override
  String get actionShare => 'Partager';

  @override
  String get actionEdit => 'Modifier';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get actionClose => 'Fermer';

  @override
  String get actionReset => 'Réinitialiser';

  @override
  String get actionResetDefaults => 'Rétablir les valeurs par défaut';

  @override
  String get actionVerifyAndRestore => 'Vérifier et restaurer la configuration';

  @override
  String get actionFactoryReset => 'Réinitialiser tous les paramètres et listes';

  @override
  String get actionClearCache => 'Vider le cache vidéo hors ligne';

  @override
  String get actionDismiss => 'IGNORER';

  @override
  String get actionExport => 'Exporter';

  @override
  String get actionImport => 'Importer';

  @override
  String get titleQuoteStudio => 'STUDIO DE CITATIONS';

  @override
  String get titleWallpaperEffects => 'EFFETS ET FILTRES DE FOND D\'ÉCRAN';

  @override
  String get titleAutoRotation => 'CENTRE D\'AUTO-ROTATION';

  @override
  String get titleLockScreenStudio => 'DYNAMIQUE D\'ÉCRAN DE VERROUILLAGE';

  @override
  String get titleParallaxStudio => 'PARALLAXE SPATIALE 3D';

  @override
  String get titleBatteryTelemetry => 'TÉLÉMÉTRIE DE BATTERIE ET SYSTÈME';

  @override
  String get titleAuraHarmonizer => 'HARMONISATEUR CHROMATIQUE AURA';

  @override
  String get titleStandbyDock => 'STATION D\'ACCUEIL VEILLE';

  @override
  String get titleAuroraSynthesizer => 'SYNTHÉTISEUR D\'ONDES D\'AURORE';

  @override
  String get titleWeatherAtmosphere => 'STUDIO MÉTÉO ATMOSPHÉRIQUE';

  @override
  String get titleWallazaCloud => 'DÉCOUVERTE CLOUD WALLAZA';

  @override
  String get titleDataPortability => 'PORTABILITÉ ET SAUVEGARDE';

  @override
  String get titleSmartDiscovery => 'DÉCOUVERTE INTELLIGENTE ET FILTRES';

  @override
  String get titleCommunityExchange => 'ÉCHANGE COMMUNAUTAIRE';

  @override
  String get titlePreferences => 'PRÉFÉRENCES ESTHÉTIQUES';

  @override
  String get errorInvalidBackupJson =>
      'Format de sauvegarde Wallora invalide ou version manquante.';

  @override
  String get errorProvideValidJson =>
      'Veuillez fournir un JSON de sauvegarde Wallora valide.';

  @override
  String get successBackupCopied =>
      'Archive de sauvegarde copiée dans le presse-papiers !';

  @override
  String get successRestored => 'Configuration restaurée avec succès !';

  @override
  String get emptyFavoritesTitle => 'Aucun favori pour le moment';

  @override
  String get emptyFavoritesSubtitle =>
      'Appuyez deux fois ou touchez l\'icône de cœur sur n\'importe quel fond d\'écran pour l\'ajouter à votre collection.';

  @override
  String get emptyDownloadsTitle => 'Aucun téléchargement';

  @override
  String get emptyDownloadsSubtitle =>
      'Les fonds d\'écran enregistrés pour une utilisation hors ligne seront stockés ici.';

  @override
  String itemsCount(int count) => '$count ${count == 1 ? 'élément' : 'éléments'}';

  @override
  String durationSeconds(int seconds) => '${seconds}s';

  @override
  String appliedSuccess(String title) => '✨ "$title" appliqué avec succès !';
}
