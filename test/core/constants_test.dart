import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/core/core.dart';

void main() {
  group('AppConstants Unit Tests', () {
    test('App information and metadata constants are defined correctly', () {
      expect(AppConstants.appName, 'Wallora');
      expect(AppConstants.appTagline, 'Make every screen yours.');
      expect(AppConstants.appVersion, '1.0.0');
      expect(AppConstants.buildNumber, '1');
      expect(AppConstants.wallpaperChannelName, 'com.example.live_wallpaper/wallpaper');
    });

    test('Storage keys are distinct and properly formatted', () {
      expect(AppConstants.keyFavorites, isNotEmpty);
      expect(AppConstants.keyDownloads, isNotEmpty);
      expect(AppConstants.keyActiveId, isNotEmpty);
      expect(AppConstants.keyAutoRotationEnabled, isNotEmpty);
      expect(AppConstants.keyDayNightSchedule, isNotEmpty);
      expect(AppConstants.keySmartFilter, isNotEmpty);
      expect(AppConstants.keyAmoledSaverMode, isNotEmpty);
    });

    test('Animation durations and bounds are positive values', () {
      expect(AppConstants.splashDelay.inMilliseconds, greaterThan(0));
      expect(AppConstants.standardAnimationDuration.inMilliseconds, greaterThan(0));
      expect(AppConstants.minRotationIntervalMinutes, 15);
      expect(AppConstants.maxRotationIntervalMinutes, 1440);
      expect(AppConstants.defaultRotationIntervalMinutes, 60);
      expect(AppConstants.phonePreviewAspectRatio, 9 / 16);
    });
  });

  group('AppDimensions Unit Tests', () {
    test('Standard spacings and padding values are consistent', () {
      expect(AppDimensions.space4, 4.0);
      expect(AppDimensions.space8, 8.0);
      expect(AppDimensions.space16, 16.0);
      expect(AppDimensions.space24, 24.0);
      expect(AppDimensions.paddingAll16.top, 16.0);
      expect(AppDimensions.paddingH16V8.horizontal, 32.0);
    });

    test('Border radii are defined correctly', () {
      expect(AppDimensions.radius8, 8.0);
      expect(AppDimensions.radius12, 12.0);
      expect(AppDimensions.radius16, 16.0);
      expect(AppDimensions.radiusFull, 999.0);
      expect(AppDimensions.borderRadius16.topLeft.x, 16.0);
    });

    test('Icon sizes and sheet layout constants are defined', () {
      expect(AppDimensions.iconSm, 18.0);
      expect(AppDimensions.iconMd, 24.0);
      expect(AppDimensions.iconLg, 28.0);
      expect(AppDimensions.sheetGrabberWidth, 40.0);
      expect(AppDimensions.sheetGrabberHeight, 4.0);
    });
  });

  group('AppStrings Unit Tests', () {
    test('Canonical navigation and brand strings match specification', () {
      expect(AppStrings.appName, 'Wallora');
      expect(AppStrings.appTagline, 'Make every screen yours.');
      expect(AppStrings.navFeed, 'Feed');
      expect(AppStrings.navCategories, 'Categories');
      expect(AppStrings.navDiscover, 'Discover');
      expect(AppStrings.navDownloads, 'Downloads');
      expect(AppStrings.navFavorites, 'Favorites');
      expect(AppStrings.navPlaylists, 'Playlists');
    });

    test('Action strings match expected values', () {
      expect(AppStrings.actionApply, 'Apply');
      expect(AppStrings.actionApplyLiveMotion, 'Apply Live Motion');
      expect(AppStrings.actionDownload, 'Download');
      expect(AppStrings.actionResetDefaults, 'Reset Defaults');
      expect(AppStrings.actionVerifyAndRestore, 'Verify & Restore Setup');
    });

    test('Studio titles match existing sheet titles', () {
      expect(AppStrings.titleQuoteStudio, 'QUOTE STUDIO');
      expect(AppStrings.titleWallpaperEffects, 'WALLPAPER EFFECTS & FILTERS');
      expect(AppStrings.titleAutoRotation, 'AUTO-ROTATION HUB');
      expect(AppStrings.titleWallazaCloud, 'WALLAZA CLOUD DISCOVERY');
      expect(AppStrings.titleDataPortability, 'DATA PORTABILITY & BACKUP HUB');
    });
  });
}
