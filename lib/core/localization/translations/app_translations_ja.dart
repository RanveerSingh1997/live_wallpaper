import 'app_translations.dart';

/// Japanese (日本語) translations for Wallora.
class AppTranslationsJa implements AppTranslations {
  const AppTranslationsJa();

  @override
  String get appName => 'Wallora';

  @override
  String get appTagline => 'すべての画面を、あなたらしく。';

  @override
  String get navFeed => 'フィード';

  @override
  String get navCategories => 'カテゴリー';

  @override
  String get navDiscover => '見つける';

  @override
  String get navDownloads => 'ダウンロード';

  @override
  String get navFavorites => 'お気に入り';

  @override
  String get navPlaylists => 'プレイリスト';

  @override
  String get actionApply => '適用';

  @override
  String get actionApplyLiveMotion => 'ライブモーションを適用';

  @override
  String get actionApplyStatic => '静止画を適用';

  @override
  String get actionDownload => 'ダウンロード';

  @override
  String get actionFavorite => 'お気に入り';

  @override
  String get actionShare => '共有';

  @override
  String get actionEdit => '編集';

  @override
  String get actionSave => '保存';

  @override
  String get actionCancel => 'キャンセル';

  @override
  String get actionDelete => '削除';

  @override
  String get actionClose => '閉じる';

  @override
  String get actionReset => 'リセット';

  @override
  String get actionResetDefaults => 'デフォルトに戻す';

  @override
  String get actionVerifyAndRestore => '設定を検証して復元';

  @override
  String get actionFactoryReset => 'すべての設定とプレイリストを初期化';

  @override
  String get actionClearCache => 'オフライン動画キャッシュを消去';

  @override
  String get actionDismiss => '閉じる';

  @override
  String get actionExport => 'エクスポート';

  @override
  String get actionImport => 'インポート';

  @override
  String get titleQuoteStudio => '引用スタジオ';

  @override
  String get titleWallpaperEffects => '壁紙エフェクト＆フィルター';

  @override
  String get titleAutoRotation => '自動切り替えハブ';

  @override
  String get titleLockScreenStudio => 'ロック画面ダイナミクス';

  @override
  String get titleParallaxStudio => '3D空間視差';

  @override
  String get titleBatteryTelemetry => 'バッテリー＆システムテレメトリ';

  @override
  String get titleAuraHarmonizer => 'オーラ・クロマティック・ハーモナイザー';

  @override
  String get titleStandbyDock => 'スタンバイ・デスクドック';

  @override
  String get titleAuroraSynthesizer => 'オーロラ・ウェーブ・シンセサイザー';

  @override
  String get titleWeatherAtmosphere => '大気ウェザースタジオ';

  @override
  String get titleWallazaCloud => 'Wallazaクラウド探索';

  @override
  String get titleDataPortability => 'データ移行＆バックアップハブ';

  @override
  String get titleSmartDiscovery => 'スマート探索＆フィルタリング';

  @override
  String get titleCommunityExchange => 'コミュニティ・エクスチェンジ';

  @override
  String get titlePreferences => 'ビジュアル設定';

  @override
  String get errorInvalidBackupJson => '無効なWalloraバックアップ形式またはバージョンがありません。';

  @override
  String get errorProvideValidJson => '有効なWalloraバックアップJSONを入力してください。';

  @override
  String get successBackupCopied => 'バックアップがクリップボードにコピーされました！';

  @override
  String get successRestored => '設定が正常に復元されました！';

  @override
  String get emptyFavoritesTitle => 'お気に入りはまだありません';

  @override
  String get emptyFavoritesSubtitle => '壁紙をダブルタップまたはハートをタップしてコレクションに追加しましょう。';

  @override
  String get emptyDownloadsTitle => 'ダウンロードはまだありません';

  @override
  String get emptyDownloadsSubtitle => 'オフライン保存した壁紙がここに表示されます。';

  @override
  String itemsCount(int count) => '$count 件';

  @override
  String durationSeconds(int seconds) => '$seconds 秒';

  @override
  String appliedSuccess(String title) => '✨ 「$title」を適用しました！';
}
