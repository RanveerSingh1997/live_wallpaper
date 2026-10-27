import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/audio_spectrum_metrics.dart';
import '../../models/audio_visualizer_config.dart';
import '../../repositories/wallpaper_repository.dart';
import '../../services/audio_capture_service.dart';
import '../../services/live_audio_capture_service.dart';
import '../../services/simulated_audio_capture_service.dart';
import '../wallpaper_intent.dart';
import '../wallpaper_state.dart';

/// BLoC handler mixin orchestrating the Live Audio-Reactive Visualizer subsystem.
///
/// Ensures Unidirectional Data Flow (UDF), seamless switching between simulated
/// and live audio capture streams, and strict Zero Sleep Overhead battery protection.
mixin AudioVisualizerHandlers on Bloc<WallpaperIntent, WallpaperState> {
  WallpaperFacadeRepository get repository;

  AudioCaptureService? _audioCaptureService;
  StreamSubscription<AudioSpectrumMetrics>? _audioSpectrumSubscription;

  /// Exposes active [AudioCaptureService] or creates a default instance lazily.
  AudioCaptureService get audioCaptureService {
    return _audioCaptureService ??= _createAudioCaptureService(state.audioVisualizerConfig);
  }

  /// Injects a custom [AudioCaptureService] for unit and headless CI testing.
  void setAudioCaptureService(AudioCaptureService service) {
    _audioCaptureService?.stop();
    _audioSpectrumSubscription?.cancel();
    _audioSpectrumSubscription = null;
    _audioCaptureService = service;

    if (state.audioVisualizerConfig.isEnabled) {
      _startAudioCaptureService();
    }
  }

  AudioCaptureService _createAudioCaptureService(AudioVisualizerConfig config) {
    if (config.mode == AudioCaptureMode.live) {
      final service = LiveAudioCaptureService();
      service.updateConfig(config);
      return service;
    } else {
      return SimulatedAudioCaptureService(initialConfig: config);
    }
  }

  void _startAudioCaptureService() {
    _audioSpectrumSubscription?.cancel();
    _audioSpectrumSubscription = audioCaptureService.spectrumStream.listen((metrics) {
      if (!isClosed && state.audioVisualizerConfig.isEnabled) {
        add(AudioSpectrumUpdatedIntent(metrics));
      }
    });

    audioCaptureService.start();
  }

  Future<void> _stopAudioCaptureService() async {
    final sub = _audioSpectrumSubscription;
    _audioSpectrumSubscription = null;
    unawaited(sub?.cancel());
    await _audioCaptureService?.stop();
  }

  void _switchCaptureSourceIfNeeded(AudioCaptureMode newMode, AudioVisualizerConfig config) {
    final currentIsLive = _audioCaptureService is LiveAudioCaptureService;
    final targetIsLive = newMode == AudioCaptureMode.live;

    if (currentIsLive != targetIsLive) {
      final wasRunning = _audioCaptureService?.isRunning ?? false;
      _audioSpectrumSubscription?.cancel();
      _audioSpectrumSubscription = null;
      final oldService = _audioCaptureService;
      _audioCaptureService = _createAudioCaptureService(config);
      unawaited(oldService?.dispose());

      if (config.isEnabled && wasRunning) {
        _startAudioCaptureService();
      }
    } else {
      _audioCaptureService?.updateConfig(config);
    }
  }

  /// Toggles audio visualizer active state.
  Future<void> onToggleAudioVisualizer(
    ToggleAudioVisualizerIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    final updatedConfig = state.audioVisualizerConfig.copyWith(
      isEnabled: event.isEnabled,
    );

    await repository.saveAudioVisualizerConfig(updatedConfig);

    if (event.isEnabled) {
      _startAudioCaptureService();
      emit(state.copyWith(
        audioVisualizerConfig: updatedConfig,
        isAudioCaptureRunning: true,
        message: 'Audio-Reactive Visualizer activated.',
      ));
    } else {
      await _stopAudioCaptureService();
      emit(state.copyWith(
        audioVisualizerConfig: updatedConfig,
        isAudioCaptureRunning: false,
        audioSpectrumMetrics: AudioSpectrumMetrics.zero,
        message: 'Audio-Reactive Visualizer paused.',
      ));
    }
  }

  /// Updates active configuration parameters (sensitivity, smoothing, focus, etc.).
  Future<void> onUpdateAudioVisualizerConfig(
    UpdateAudioVisualizerConfigIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await repository.saveAudioVisualizerConfig(event.config);
    _switchCaptureSourceIfNeeded(event.config.mode, event.config);

    emit(state.copyWith(
      audioVisualizerConfig: event.config,
      message: 'Visualizer settings updated.',
    ));
  }

  /// Switches audio capture mode between simulated and live microphone.
  Future<void> onSetAudioCaptureMode(
    SetAudioCaptureModeIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    final updatedConfig = state.audioVisualizerConfig.copyWith(
      mode: event.mode,
      preset: AudioVisualizerPreset.custom,
    );

    await repository.saveAudioVisualizerConfig(updatedConfig);
    _switchCaptureSourceIfNeeded(event.mode, updatedConfig);

    emit(state.copyWith(
      audioVisualizerConfig: updatedConfig,
      message: 'Capture source switched to ${event.mode.label}.',
    ));
  }

  /// Applies a predefined visualizer preset profile.
  Future<void> onSetAudioVisualizerPreset(
    SetAudioVisualizerPresetIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    final basePresetConfig = AudioVisualizerConfig.forPreset(event.preset);
    final updatedConfig = basePresetConfig.copyWith(
      mode: state.audioVisualizerConfig.mode,
      isEnabled: state.audioVisualizerConfig.isEnabled,
    );

    await repository.saveAudioVisualizerConfig(updatedConfig);
    _audioCaptureService?.updateConfig(updatedConfig);

    emit(state.copyWith(
      audioVisualizerConfig: updatedConfig,
      message: 'Visualizer preset "${event.preset.label}" applied.',
    ));
  }

  /// Resets visualizer configuration to factory defaults.
  Future<void> onResetAudioVisualizerConfig(
    ResetAudioVisualizerConfigIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    const defaultConfig = AudioVisualizerConfig.defaultConfig;
    emit(state.copyWith(
      audioVisualizerConfig: defaultConfig,
      audioSpectrumMetrics: AudioSpectrumMetrics.zero,
      isAudioCaptureRunning: false,
      message: 'Audio Visualizer reset to defaults.',
    ));

    await repository.saveAudioVisualizerConfig(defaultConfig);
    await _stopAudioCaptureService();
    _switchCaptureSourceIfNeeded(defaultConfig.mode, defaultConfig);
  }

  /// Updates state with real-time frequency spectrum analysis metrics.
  void onAudioSpectrumUpdated(
    AudioSpectrumUpdatedIntent event,
    Emitter<WallpaperState> emit,
  ) {
    if (state.audioVisualizerConfig.isEnabled) {
      emit(state.copyWith(
        audioSpectrumMetrics: event.metrics,
      ));
    }
  }

  /// Pauses audio capture loop for zero CPU battery savings on background / sleep.
  Future<void> onPauseAudioCapture(
    PauseAudioCaptureIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    await _audioCaptureService?.pause();
    emit(state.copyWith(
      isAudioCaptureRunning: false,
    ));
  }

  /// Resumes audio capture loop when returning to foreground.
  Future<void> onResumeAudioCapture(
    ResumeAudioCaptureIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    if (state.audioVisualizerConfig.isEnabled) {
      await _audioCaptureService?.resume();
      emit(state.copyWith(
        isAudioCaptureRunning: true,
      ));
    }
  }

  /// Cleanly terminates capture services and stream subscriptions on bloc close.
  Future<void> stopAudioCapture() async {
    await _stopAudioCaptureService();
    await _audioCaptureService?.dispose();
    _audioCaptureService = null;
  }
}
