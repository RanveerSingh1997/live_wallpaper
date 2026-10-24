import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/services/wallpaper_service_bridge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late WallpaperServiceBridge bridge;

  setUp(() {
    bridge = WallpaperServiceBridge();
  });

  group('WallpaperServiceBridge Unit Tests', () {
    test('setLiveWallpaper returns unsupported_platform on host test environment', () async {
      final result = await bridge.setLiveWallpaper(videoPath: '/dummy/path.mp4');
      expect(result['status'], equals('unsupported_platform'));
      expect(result['isAlreadyActive'], isFalse);
    });

    test('setStaticWallpaper returns unsupported_platform on non-Android environment', () async {
      final result = await bridge.setStaticWallpaper(filePath: '/dummy/static.png');
      expect(result['status'], equals('unsupported_platform'));
    });

    test('isWallpaperActive returns false on non-Android environment', () async {
      final isActive = await bridge.isWallpaperActive();
      expect(isActive, isFalse);
    });

    test('shareVideo and openPhotos do not throw on test environment', () async {
      expect(() async => await bridge.shareVideo('/dummy/path.mp4'), returnsNormally);
      expect(() async => await bridge.openPhotos(), returnsNormally);
      expect(() async => await bridge.setAudioMuted(true), returnsNormally);
      expect(() async => await bridge.openChooser(), returnsNormally);
    });

    test('getInitialDeepLink returns null and onDeepLinkReceived emits stream', () async {
      final initial = await bridge.getInitialDeepLink();
      expect(initial, isNull);
      expect(bridge.onDeepLinkReceived, isNotNull);
    });

    test('getHardwareBatteryInfo returns fallback telemetry on host test environment', () async {
      final batteryInfo = await bridge.getHardwareBatteryInfo();
      expect(batteryInfo['batteryPercent'], equals(100));
      expect(batteryInfo['isCharging'], isFalse);
      expect(batteryInfo['isPowerSaveMode'], isFalse);
    });
  });
}
