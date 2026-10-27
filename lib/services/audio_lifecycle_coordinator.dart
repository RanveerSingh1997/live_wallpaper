import 'package:flutter/widgets.dart';
import '../blocs/wallpaper_bloc.dart';
import '../blocs/wallpaper_intent.dart';
import 'audio_capture_service.dart';
import 'silence_detection_watchdog.dart';

/// App lifecycle coordinator governing Wallora's Zero Sleep Overhead mandate
/// for the Live Audio-Reactive Visualizer subsystem.
///
/// Automatically halts hardware audio capture and periodic synthetic timers
/// when the application is backgrounded, the screen is turned off, or detached.
/// Resumes processing instantaneously upon returning to foreground.
class AudioLifecycleCoordinator with WidgetsBindingObserver {
  final WallpaperBloc? bloc;
  final AudioCaptureService? captureService;
  final SilenceDetectionWatchdog? silenceWatchdog;
  bool isScreenOn = true;
  AppLifecycleState appState = AppLifecycleState.resumed;
  bool _isDisposed = false;

  AudioLifecycleCoordinator({
    this.bloc,
    this.captureService,
    this.silenceWatchdog,
  }) {
    if (bloc != null) {
      WidgetsBinding.instance.addObserver(this);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    onLifecycleStateChanged(state);
  }

  Future<void> onLifecycleStateChanged(AppLifecycleState newState) async {
    if (_isDisposed) return;
    appState = newState;

    switch (newState) {
      case AppLifecycleState.resumed:
        if (isScreenOn) {
          bloc?.add(const ResumeAudioCaptureIntent());
          await captureService?.start();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        bloc?.add(const PauseAudioCaptureIntent());
        await captureService?.stop();
        silenceWatchdog?.reset();
        break;
    }
  }

  Future<void> onScreenStateChanged(bool screenOn) async {
    if (_isDisposed) return;
    isScreenOn = screenOn;
    if (!isScreenOn) {
      bloc?.add(const PauseAudioCaptureIntent());
      await captureService?.stop();
      silenceWatchdog?.reset();
    } else if (appState == AppLifecycleState.resumed) {
      bloc?.add(const ResumeAudioCaptureIntent());
      await captureService?.start();
    }
  }

  /// Disposes lifecycle listener and detaches from Flutter binding.
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    if (bloc != null) {
      WidgetsBinding.instance.removeObserver(this);
    }
  }
}
