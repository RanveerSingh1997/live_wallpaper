import 'package:flutter/widgets.dart';
import 'app_localizations_delegate.dart';
import 'translations/app_translations.dart';
import 'translations/app_translations_de.dart';
import 'translations/app_translations_en.dart';
import 'translations/app_translations_es.dart';
import 'translations/app_translations_fr.dart';
import 'translations/app_translations_hi.dart';
import 'translations/app_translations_ja.dart';

/// Centralized localization service for Wallora.
class AppLocalizations implements AppTranslations {
  final Locale locale;
  final AppTranslations _translations;

  AppLocalizations(this.locale)
      : _translations = _resolveTranslations(locale);

  static AppTranslations _resolveTranslations(Locale locale) {
    return switch (locale.languageCode) {
      'es' => const AppTranslationsEs(),
      'ja' => const AppTranslationsJa(),
      'de' => const AppTranslationsDe(),
      'fr' => const AppTranslationsFr(),
      'hi' => const AppTranslationsHi(),
      _ => const AppTranslationsEn(),
    };
  }

  /// Accessor from BuildContext with safe fallback.
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  /// Official delegate instance.
  static const LocalizationsDelegate<AppLocalizations> delegate =
      AppLocalizationsDelegate();

  /// Supported locales in Wallora.
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('es'),
    Locale('ja'),
    Locale('de'),
    Locale('fr'),
    Locale('hi'),
  ];

  @override
  String get appName => _translations.appName;

  @override
  String get appTagline => _translations.appTagline;

  @override
  String get navFeed => _translations.navFeed;

  @override
  String get navCategories => _translations.navCategories;

  @override
  String get navDiscover => _translations.navDiscover;

  @override
  String get navDownloads => _translations.navDownloads;

  @override
  String get navFavorites => _translations.navFavorites;

  @override
  String get navPlaylists => _translations.navPlaylists;

  @override
  String get actionApply => _translations.actionApply;

  @override
  String get actionApplyLiveMotion => _translations.actionApplyLiveMotion;

  @override
  String get actionApplyStatic => _translations.actionApplyStatic;

  @override
  String get actionDownload => _translations.actionDownload;

  @override
  String get actionFavorite => _translations.actionFavorite;

  @override
  String get actionShare => _translations.actionShare;

  @override
  String get actionEdit => _translations.actionEdit;

  @override
  String get actionSave => _translations.actionSave;

  @override
  String get actionCancel => _translations.actionCancel;

  @override
  String get actionDelete => _translations.actionDelete;

  @override
  String get actionClose => _translations.actionClose;

  @override
  String get actionReset => _translations.actionReset;

  @override
  String get actionResetDefaults => _translations.actionResetDefaults;

  @override
  String get actionVerifyAndRestore => _translations.actionVerifyAndRestore;

  @override
  String get actionFactoryReset => _translations.actionFactoryReset;

  @override
  String get actionClearCache => _translations.actionClearCache;

  @override
  String get actionDismiss => _translations.actionDismiss;

  @override
  String get actionExport => _translations.actionExport;

  @override
  String get actionImport => _translations.actionImport;

  @override
  String get titleQuoteStudio => _translations.titleQuoteStudio;

  @override
  String get titleWallpaperEffects => _translations.titleWallpaperEffects;

  @override
  String get titleAutoRotation => _translations.titleAutoRotation;

  @override
  String get titleLockScreenStudio => _translations.titleLockScreenStudio;

  @override
  String get titleParallaxStudio => _translations.titleParallaxStudio;

  @override
  String get titleBatteryTelemetry => _translations.titleBatteryTelemetry;

  @override
  String get titleAuraHarmonizer => _translations.titleAuraHarmonizer;

  @override
  String get titleStandbyDock => _translations.titleStandbyDock;

  @override
  String get titleAuroraSynthesizer => _translations.titleAuroraSynthesizer;

  @override
  String get titleWeatherAtmosphere => _translations.titleWeatherAtmosphere;

  @override
  String get titleWallazaCloud => _translations.titleWallazaCloud;

  @override
  String get titleDataPortability => _translations.titleDataPortability;

  @override
  String get titleSmartDiscovery => _translations.titleSmartDiscovery;

  @override
  String get titleCommunityExchange => _translations.titleCommunityExchange;

  @override
  String get titlePreferences => _translations.titlePreferences;

  @override
  String get errorInvalidBackupJson => _translations.errorInvalidBackupJson;

  @override
  String get errorProvideValidJson => _translations.errorProvideValidJson;

  @override
  String get successBackupCopied => _translations.successBackupCopied;

  @override
  String get successRestored => _translations.successRestored;

  @override
  String get emptyFavoritesTitle => _translations.emptyFavoritesTitle;

  @override
  String get emptyFavoritesSubtitle => _translations.emptyFavoritesSubtitle;

  @override
  String get emptyDownloadsTitle => _translations.emptyDownloadsTitle;

  @override
  String get emptyDownloadsSubtitle => _translations.emptyDownloadsSubtitle;

  @override
  String itemsCount(int count) => _translations.itemsCount(count);

  @override
  String durationSeconds(int seconds) => _translations.durationSeconds(seconds);

  @override
  String appliedSuccess(String title) => _translations.appliedSuccess(title);
}
