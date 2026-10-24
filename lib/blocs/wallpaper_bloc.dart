import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/wallpaper_repository.dart';
import 'handlers/auto_rotation_handlers.dart';
import 'handlers/cloud_handlers.dart';
import 'handlers/community_handlers.dart';
import 'handlers/feed_handlers.dart';
import 'handlers/playlist_handlers.dart';
import 'handlers/portability_handlers.dart';
import 'handlers/studio_handlers.dart';
import 'handlers/wallpaper_action_handlers.dart';
import 'wallpaper_intent.dart';
import 'wallpaper_state.dart';

export 'handlers/wallpaper_feed_filter.dart';

/// Central BLoC orchestrating Wallora's wallpaper lifecycle, visual studio,
/// auto-rotation, community blueprints, and cloud feeds.
///
/// Refactored into cohesive domain mixins adhering to Single Responsibility Principle (SRP)
/// and Interface Segregation Principle (ISP).
class WallpaperBloc extends Bloc<WallpaperIntent, WallpaperState>
    with
        FeedHandlers,
        PlaylistHandlers,
        WallpaperActionHandlers,
        AutoRotationHandlers,
        StudioHandlers,
        CommunityHandlers,
        PortabilityHandlers,
        CloudHandlers {
  @override
  final WallpaperFacadeRepository repository;

  WallpaperBloc({
    required this.repository,
    WallpaperState? initialState,
  }) : super(initialState ?? const WallpaperState()) {
    // Feed & Navigation Events
    on<LoadFeedIntent>(onLoadFeed);
    on<ChangeActiveShortIntent>(onChangeActiveShort);
    on<ChangeNavigationTabIntent>(onChangeNavigationTab);
    on<ToggleFeedMuteIntent>(onToggleFeedMute);
    on<SearchWallpapersIntent>(onSearchWallpapers);
    on<FilterByCategoryIntent>(onFilterByCategory);
    on<ToggleAmoledSaverModeIntent>(onToggleAmoledSaverMode);
    on<UpdateUserPreferencesIntent>(onUpdateUserPreferences);
    on<ClearStatusMessageIntent>(onClearStatusMessage);
    on<CompleteOnboardingIntent>(onCompleteOnboarding);
    on<ResetOnboardingIntent>(onResetOnboarding);
    on<HandleDeepLinkIntent>(onHandleDeepLink);

    // Playlist, Favorites & Collection Events
    on<ToggleFavoriteIntent>(onToggleFavorite);
    on<ImportCustomWallpaperIntent>(onImportCustomWallpaper);
    on<CreateCustomCollectionIntent>(onCreateCustomCollection);
    on<DeleteCustomCollectionIntent>(onDeleteCustomCollection);
    on<ToggleWallpaperInCollectionIntent>(onToggleWallpaperInCollection);

    // Wallpaper Actions & Downloads Events
    on<DownloadWallpaperIntent>(onDownloadWallpaper);
    on<DeleteDownloadIntent>(onDeleteDownload);
    on<ClearAllDownloadsIntent>(onClearAllDownloads);
    on<ToggleTextOverlayVisibilityIntent>(onToggleTextOverlayVisibility);
    on<UpdateCustomQuoteIntent>(onUpdateCustomQuote);
    on<ResetCustomQuoteIntent>(onResetCustomQuote);
    on<ApplyLiveWallpaperIntent>(onApplyLiveWallpaper);
    on<ApplyStaticWallpaperIntent>(onApplyStaticWallpaper);
    on<RecordWallpaperViewedIntent>(onRecordWallpaperViewed);
    on<ReportWallpaperIntent>(onReportWallpaper);
    on<ShareVideoIntent>(onShareVideo);
    on<OpenPhotosIntent>(onOpenPhotos);
    on<CheckWallpaperStatusIntent>(onCheckWallpaperStatus);
    on<SyncHardwareBatteryIntent>(onSyncHardwareBattery);

    // Auto-Rotation Events
    on<ToggleAutoRotationIntent>(onToggleAutoRotation);
    on<UpdateAutoRotationIntervalIntent>(onUpdateAutoRotationInterval);
    on<UpdateAutoRotationSourceIntent>(onUpdateAutoRotationSource);
    on<UpdateAutoRotationWifiOnlyIntent>(onUpdateAutoRotationWifiOnly);
    on<UpdateAutoRotationTargetIntent>(onUpdateAutoRotationTarget);
    on<RotateWallpaperNowIntent>(onRotateWallpaperNow);

    // Studio Engine Events (12 Customization Engines)
    on<UpdateWallpaperEffectIntent>(onUpdateWallpaperEffect);
    on<ResetWallpaperEffectIntent>(onResetWallpaperEffect);
    on<UpdateDayNightScheduleIntent>(onUpdateDayNightSchedule);
    on<ToggleDayNightScheduleIntent>(onToggleDayNightSchedule);
    on<CheckDayNightTransitionIntent>(onCheckDayNightTransition);
    on<UpdateLockScreenStyleIntent>(onUpdateLockScreenStyle);
    on<ResetLockScreenStyleIntent>(onResetLockScreenStyle);
    on<UpdateParallaxConfigIntent>(onUpdateParallaxConfig);
    on<ToggleParallaxIntent>(onToggleParallax);
    on<ResetParallaxConfigIntent>(onResetParallaxConfig);
    on<UpdateSmartFilterIntent>(onUpdateSmartFilter);
    on<ResetSmartFilterIntent>(onResetSmartFilter);
    on<UpdateBatteryTelemetryIntent>(onUpdateBatteryTelemetry);
    on<ToggleEcoModeIntent>(onToggleEcoMode);
    on<ResetBatteryTelemetryIntent>(onResetBatteryTelemetry);
    on<UpdateParticleConfigIntent>(onUpdateParticleConfig);
    on<ToggleParticleEffectIntent>(onToggleParticleEffect);
    on<ResetParticleConfigIntent>(onResetParticleConfig);
    on<UpdateAuraPaletteIntent>(onUpdateAuraPalette);
    on<SetAuraThemePresetIntent>(onSetAuraThemePreset);
    on<ResetAuraPaletteIntent>(onResetAuraPalette);
    on<UpdateGestureControlIntent>(onUpdateGestureControl);
    on<ResetGestureControlIntent>(onResetGestureControl);
    on<ToggleCleanCanvasIntent>(onToggleCleanCanvas);
    on<ExecuteGestureActionIntent>(onExecuteGestureAction);
    on<UpdateStandbyDockIntent>(onUpdateStandbyDock);
    on<ResetStandbyDockIntent>(onResetStandbyDock);
    on<ToggleNightStandbyModeIntent>(onToggleNightStandbyMode);
    on<UpdateAuroraSynthesizerIntent>(onUpdateAuroraSynthesizer);
    on<ResetAuroraSynthesizerIntent>(onResetAuroraSynthesizer);
    on<ToggleAuroraSynthesizerIntent>(onToggleAuroraSynthesizer);
    on<UpdateWeatherAtmosphereIntent>(onUpdateWeatherAtmosphere);
    on<ResetWeatherAtmosphereIntent>(onResetWeatherAtmosphere);
    on<ToggleWeatherAtmosphereIntent>(onToggleWeatherAtmosphere);
    on<SetWeatherEffectPresetIntent>(onSetWeatherEffectPreset);

    // Community Blueprint Events
    on<ApplyScreenBlueprintIntent>(onApplyScreenBlueprint);
    on<PublishCurrentSetupIntent>(onPublishCurrentSetup);
    on<ToggleBlueprintLikeIntent>(onToggleBlueprintLike);
    on<FilterCommunityBlueprintsIntent>(onFilterCommunityBlueprints);

    // Portability & Backup Events
    on<RestoreBackupIntent>(onRestoreBackup);
    on<ResetFactoryDefaultsIntent>(onResetFactoryDefaults);

    // Cloud & Wallaza Discovery Events
    on<FetchCloudWallpapersIntent>(onFetchCloudWallpapers);
    on<SearchCloudWallpapersIntent>(onSearchCloudWallpapers);
    on<ImportCloudWallpaperIntent>(onImportCloudWallpaper);
    on<ClearCloudSearchIntent>(onClearCloudSearch);
    on<UpdateCloudSortIntent>(onUpdateCloudSort);
    on<FilterCloudByAuthorIntent>(onFilterCloudByAuthor);
  }
}
