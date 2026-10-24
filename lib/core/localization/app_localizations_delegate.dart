import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'app_localizations.dart';

/// LocalizationsDelegate enabling Flutter's localization pipeline for Wallora.
class AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es', 'ja', 'de', 'fr', 'hi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
