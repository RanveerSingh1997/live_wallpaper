import 'app_translations.dart';

/// Spanish (Español) translations for Wallora.
class AppTranslationsEs implements AppTranslations {
  const AppTranslationsEs();

  @override
  String get appName => 'Wallora';

  @override
  String get appTagline => 'Haz que cada pantalla sea tuya.';

  @override
  String get navFeed => 'Feed';

  @override
  String get navCategories => 'Categorías';

  @override
  String get navDiscover => 'Descubrir';

  @override
  String get navDownloads => 'Descargas';

  @override
  String get navFavorites => 'Favoritos';

  @override
  String get navPlaylists => 'Listas';

  @override
  String get actionApply => 'Aplicar';

  @override
  String get actionApplyLiveMotion => 'Aplicar Movimiento en Vivo';

  @override
  String get actionApplyStatic => 'Aplicar Estático';

  @override
  String get actionDownload => 'Descargar';

  @override
  String get actionFavorite => 'Favorito';

  @override
  String get actionShare => 'Compartir';

  @override
  String get actionEdit => 'Editar';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionClose => 'Cerrar';

  @override
  String get actionReset => 'Restablecer';

  @override
  String get actionResetDefaults => 'Restablecer valores predeterminados';

  @override
  String get actionVerifyAndRestore => 'Verificar y restaurar configuración';

  @override
  String get actionFactoryReset => 'Restablecimiento de fábrica de ajustes y listas';

  @override
  String get actionClearCache => 'Borrar caché de videos sin conexión';

  @override
  String get actionDismiss => 'DESCARTAR';

  @override
  String get actionExport => 'Exportar';

  @override
  String get actionImport => 'Importar';

  @override
  String get titleQuoteStudio => 'ESTUDIO DE FRASES';

  @override
  String get titleWallpaperEffects => 'EFECTOS Y FILTROS DE FONDO';

  @override
  String get titleAutoRotation => 'CENTRO DE ROTACIÓN AUTOMÁTICA';

  @override
  String get titleLockScreenStudio => 'DINÁMICAS DE PANTALLA DE BLOQUEO';

  @override
  String get titleParallaxStudio => 'PARALAJE ESPACIAL 3D';

  @override
  String get titleBatteryTelemetry => 'TELEMETRÍA DE BATERÍA Y SISTEMA';

  @override
  String get titleAuraHarmonizer => 'ARMONIZADOR CROMÁTICO AURA';

  @override
  String get titleStandbyDock => 'BASE DE ESCRITORIO STANDBY';

  @override
  String get titleAuroraSynthesizer => 'SINTETIZADOR DE ONDAS AURORA';

  @override
  String get titleWeatherAtmosphere => 'ESTUDIO METEOROLÓGICO ATMOSFÉRICO';

  @override
  String get titleWallazaCloud => 'DESCUBRIMIENTO WALLAZA CLOUD';

  @override
  String get titleDataPortability => 'CENTRO DE PORTABILIDAD Y RESPALDO';

  @override
  String get titleSmartDiscovery => 'DESCUBRIMIENTO INTELIGENTE Y FILTRADO';

  @override
  String get titleCommunityExchange => 'INTERCAMBIO COMUNITARIO';

  @override
  String get titlePreferences => 'PREFERENCIAS ESTÉTICAS';

  @override
  String get errorInvalidBackupJson => 'Formato de respaldo Wallora no válido o falta versión.';

  @override
  String get errorProvideValidJson => 'Proporcione un JSON de respaldo de Wallora válido.';

  @override
  String get successBackupCopied => '¡Archivo de respaldo copiado al portapapeles!';

  @override
  String get successRestored => '¡Configuración restaurada con éxito!';

  @override
  String get emptyFavoritesTitle => 'Sin Favoritos Aún';

  @override
  String get emptyFavoritesSubtitle => 'Toca dos veces o toca el corazón en cualquier fondo de pantalla para añadirlo a tu colección.';

  @override
  String get emptyDownloadsTitle => 'Sin Descargas Aún';

  @override
  String get emptyDownloadsSubtitle => 'Los fondos guardados para uso sin conexión aparecerán aquí.';

  @override
  String itemsCount(int count) => '$count ${count == 1 ? 'elemento' : 'elementos'}';

  @override
  String durationSeconds(int seconds) => '${seconds}s';

  @override
  String appliedSuccess(String title) => '✨ ¡Se aplicó "$title" con éxito!';
}
