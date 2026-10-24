import 'dart:async';
import 'package:flutter/services.dart';
import '../core/core.dart';

/// Abstract service bridge contract for native Android and iPad/iOS platform operations.
/// Follows Dependency Inversion Principle (DIP).
abstract class WallpaperServiceBridge {
  factory WallpaperServiceBridge() = WallpaperServiceBridgeImpl;

  /// Sets the native live wallpaper using the local MP4 file path.
  Future<Map<String, dynamic>> setLiveWallpaper({
    required String videoPath,
    bool isMuted = true,
  });

  /// Sets a static wallpaper bitmap on Android.
  Future<Map<String, dynamic>> setStaticWallpaper({
    required String filePath,
    String targetScreen = 'both',
  });

  /// Opens the iOS/iPad share sheet with "Use as Wallpaper" option.
  Future<void> shareVideo(String videoPath);

  /// Opens the Photos app directly on iPad/iOS.
  Future<void> openPhotos();

  /// Checks if our live wallpaper service is currently active on Android.
  Future<bool> isWallpaperActive();

  /// Toggles wallpaper audio state.
  Future<void> setAudioMuted(bool isMuted);

  /// Opens the system live wallpaper chooser on Android.
  Future<void> openChooser();

  /// Retrieves initial deep link if app was cold-started from an intent.
  Future<String?> getInitialDeepLink();

  /// Broadcast stream of incoming deep links while app is running.
  Stream<String> get onDeepLinkReceived;

  /// Retrieves real hardware battery telemetry from the device.
  Future<Map<String, dynamic>> getHardwareBatteryInfo();
}

/// Concrete implementation of [WallpaperServiceBridge] communicating via Flutter MethodChannels.
class WallpaperServiceBridgeImpl implements WallpaperServiceBridge {
  static const MethodChannel _channel =
      MethodChannel(AppConstants.wallpaperChannelName);

  final StreamController<String> _deepLinkController =
      StreamController<String>.broadcast();

  WallpaperServiceBridgeImpl() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onDeepLinkReceived' && call.arguments is String) {
        _deepLinkController.add(call.arguments as String);
      }
    });
  }

  @override
  Future<Map<String, dynamic>> setLiveWallpaper({
    required String videoPath,
    bool isMuted = true,
  }) async {
    if (!AppPlatform.isAndroid && !AppPlatform.isIOS) {
      return {
        'status': 'unsupported_platform',
        'isAlreadyActive': false,
        'message': 'Live wallpaper is supported on Android and iPad/iOS.',
      };
    }

    try {
      final dynamic result = await _channel.invokeMethod('setLiveWallpaper', {
        'videoPath': videoPath,
        'isMuted': isMuted,
      });

      if (result is Map) {
        return Map<String, dynamic>.from(result);
      }
      return {'status': 'success', 'isAlreadyActive': false};
    } on PlatformException catch (e) {
      return {
        'status': 'error',
        'isAlreadyActive': false,
        'error': e.message ?? e.code,
      };
    }
  }

  @override
  Future<Map<String, dynamic>> setStaticWallpaper({
    required String filePath,
    String targetScreen = 'both',
  }) async {
    if (!AppPlatform.isAndroid) {
      return {
        'status': 'unsupported_platform',
        'message':
            'Direct static wallpaper setting via WallpaperManager is an Android feature.',
      };
    }

    try {
      final dynamic result = await _channel.invokeMethod('setStaticWallpaper', {
        'filePath': filePath,
        'targetScreen': targetScreen,
      });

      if (result is Map) {
        return Map<String, dynamic>.from(result);
      }
      return {'status': 'applied_static', 'targetScreen': targetScreen};
    } on PlatformException catch (e) {
      return {
        'status': 'error',
        'error': e.message ?? e.code,
      };
    }
  }

  @override
  Future<void> shareVideo(String videoPath) async {
    if (!AppPlatform.isIOS) return;
    try {
      await _channel.invokeMethod('shareVideo', {'videoPath': videoPath});
    } catch (_) {}
  }

  @override
  Future<void> openPhotos() async {
    if (!AppPlatform.isIOS) return;
    try {
      await _channel.invokeMethod('openPhotos');
    } catch (_) {}
  }

  @override
  Future<bool> isWallpaperActive() async {
    if (!AppPlatform.isAndroid) return false;
    try {
      final bool? isActive =
          await _channel.invokeMethod<bool>('isWallpaperActive');
      return isActive ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> setAudioMuted(bool isMuted) async {
    try {
      await _channel.invokeMethod('setAudioMuted', {'isMuted': isMuted});
    } catch (_) {}
  }

  @override
  Future<void> openChooser() async {
    if (!AppPlatform.isAndroid) return;
    try {
      await _channel.invokeMethod('openLiveWallpaperChooser');
    } catch (_) {}
  }

  @override
  Stream<String> get onDeepLinkReceived => _deepLinkController.stream;

  @override
  Future<String?> getInitialDeepLink() async {
    if (!AppPlatform.isAndroid && !AppPlatform.isIOS) return null;
    try {
      final String? link =
          await _channel.invokeMethod<String>('getInitialDeepLink');
      return link;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>> getHardwareBatteryInfo() async {
    if (!AppPlatform.isAndroid) {
      return {
        'batteryPercent': 100,
        'isCharging': false,
        'isPowerSaveMode': false,
      };
    }
    try {
      final dynamic result = await _channel.invokeMethod('getBatteryTelemetry');
      if (result is Map) {
        return Map<String, dynamic>.from(result);
      }
      return {
        'batteryPercent': 100,
        'isCharging': false,
        'isPowerSaveMode': false,
      };
    } catch (_) {
      return {
        'batteryPercent': 100,
        'isCharging': false,
        'isPowerSaveMode': false,
      };
    }
  }
}
