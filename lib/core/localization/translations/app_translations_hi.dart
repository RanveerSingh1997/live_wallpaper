import 'app_translations.dart';

/// Hindi translations for Wallora.
class AppTranslationsHi implements AppTranslations {
  const AppTranslationsHi();

  @override
  String get appName => 'Wallora';

  @override
  String get appTagline => 'हर स्क्रीन को अपना बनाएं।';

  @override
  String get navFeed => 'फ़ीड';

  @override
  String get navCategories => 'श्रेणियां';

  @override
  String get navDiscover => 'खोजें';

  @override
  String get navDownloads => 'डाउनलोड';

  @override
  String get navFavorites => 'पसंदीदा';

  @override
  String get navPlaylists => 'प्लेलिस्ट';

  @override
  String get actionApply => 'लागू करें';

  @override
  String get actionApplyLiveMotion => 'लाइव मोशन लागू करें';

  @override
  String get actionApplyStatic => 'स्टैटिक लागू करें';

  @override
  String get actionDownload => 'डाउनलोड करें';

  @override
  String get actionFavorite => 'पसंदीदा';

  @override
  String get actionShare => 'शेयर करें';

  @override
  String get actionEdit => 'संपादित करें';

  @override
  String get actionSave => 'सहेजें';

  @override
  String get actionCancel => 'रद्द करें';

  @override
  String get actionDelete => 'हटाएं';

  @override
  String get actionClose => 'बंद करें';

  @override
  String get actionReset => 'रीसेट करें';

  @override
  String get actionResetDefaults => 'डिफ़ॉल्ट रीसेट करें';

  @override
  String get actionVerifyAndRestore => 'सत्यापित करें और पुनर्स्थापित करें';

  @override
  String get actionFactoryReset => 'सभी सेटिंग्स और प्लेलिस्ट रीसेट करें';

  @override
  String get actionClearCache => 'ऑफ़लाइन वीडियो कैश साफ़ करें';

  @override
  String get actionDismiss => 'खारिज करें';

  @override
  String get actionExport => 'निर्यात करें';

  @override
  String get actionImport => 'आयात करें';

  @override
  String get titleQuoteStudio => 'कोट स्टूडियो';

  @override
  String get titleWallpaperEffects => 'वॉलपेपर प्रभाव और फ़िल्टर';

  @override
  String get titleAutoRotation => 'ऑटो-रोटेशन हब';

  @override
  String get titleLockScreenStudio => 'लॉक स्क्रीन गतिशीलता';

  @override
  String get titleParallaxStudio => '3D स्पेसियल लंबन';

  @override
  String get titleBatteryTelemetry => 'बैटरी और सिस्टम टेलीमेट्री';

  @override
  String get titleAuraHarmonizer => 'ऑरा क्रोमैटिक हार्मोनाइज़र';

  @override
  String get titleStandbyDock => 'स्टैंडबाय डेस्क डॉक';

  @override
  String get titleAuroraSynthesizer => 'ऑरोरा वेव सिंथेसाइज़र';

  @override
  String get titleWeatherAtmosphere => 'वायुमंडलीय मौसम स्टूडियो';

  @override
  String get titleWallazaCloud => 'वालाज़ा क्लाउड खोज';

  @override
  String get titleDataPortability => 'डेटा पोर्टेबिलिटी और बैकअप हब';

  @override
  String get titleSmartDiscovery => 'स्मार्ट खोज और फ़िल्टरिंग';

  @override
  String get titleCommunityExchange => 'सामुदायिक विनिमय';

  @override
  String get titlePreferences => 'सौंदर्य प्राथमिकताएं';

  @override
  String get errorInvalidBackupJson =>
      'अमान्य Wallora बैकअप प्रारूप या अनुपलब्ध संस्करण।';

  @override
  String get errorProvideValidJson =>
      'कृपया एक मान्य Wallora बैकअप JSON प्रदान करें।';

  @override
  String get successBackupCopied => 'बैकअप संग्रह क्लिपबोर्ड पर कॉपी हो गया!';

  @override
  String get successRestored => 'सेटअप सफलतापूर्वक पुनर्स्थापित हुआ!';

  @override
  String get emptyFavoritesTitle => 'अभी कोई पसंदीदा नहीं';

  @override
  String get emptyFavoritesSubtitle =>
      'किसी भी वॉलपेपर पर डबल-टैप करें या दिल के आइकन को टैप करें।';

  @override
  String get emptyDownloadsTitle => 'कोई डाउनलोड नहीं';

  @override
  String get emptyDownloadsSubtitle =>
      'ऑफ़लाइन उपयोग के लिए सहेजे गए वॉलपेपर यहां प्रदर्शित होंगे।';

  @override
  String itemsCount(int count) => '$count आइटम';

  @override
  String durationSeconds(int seconds) => '$seconds से.';

  @override
  String appliedSuccess(String title) => '✨ "$title" सफलतापूर्वक लागू किया गया!';
}
