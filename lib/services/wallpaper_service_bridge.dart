import 'dart:io';
import 'package:flutter/services.dart';

class WallpaperServiceBridge {
  static const MethodChannel _channel =
      MethodChannel('com.example.live_wallpaper/wallpaper');

  /// Sets the native live wallpaper using the local MP4 file path.
  /// On Android: launches the WallpaperService chooser (Lock & Home screen).
  /// On iPad/iOS: saves video to Photos library with wallpaper guide.
  Future<Map<String, dynamic>> setLiveWallpaper({
    required String videoPath,
    bool isMuted = true,
  }) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return {
        'status': 'unsupported_platform',
        'isAlreadyActive': false,
        'message': 'Live wallpaper is supported on Android and iPad/iOS.'
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

  /// Opens the iOS/iPad share sheet with "Use as Wallpaper" option.
  Future<void> shareVideo(String videoPath) async {
    if (!Platform.isIOS) return;
    try {
      await _channel.invokeMethod('shareVideo', {'videoPath': videoPath});
    } catch (_) {}
  }

  /// Opens the Photos app directly on iPad/iOS.
  Future<void> openPhotos() async {
    if (!Platform.isIOS) return;
    try {
      await _channel.invokeMethod('openPhotos');
    } catch (_) {}
  }

  /// Checks if our live wallpaper service is currently active on Android.
  Future<bool> isWallpaperActive() async {
    if (!Platform.isAndroid) return false;
    try {
      final bool? isActive = await _channel.invokeMethod<bool>('isWallpaperActive');
      return isActive ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Toggles wallpaper audio state.
  Future<void> setAudioMuted(bool isMuted) async {
    try {
      await _channel.invokeMethod('setAudioMuted', {'isMuted': isMuted});
    } catch (_) {}
  }

  /// Opens the system live wallpaper chooser on Android.
  Future<void> openChooser() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('openLiveWallpaperChooser');
    } catch (_) {}
  }
}
