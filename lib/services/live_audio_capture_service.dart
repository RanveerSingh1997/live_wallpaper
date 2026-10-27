import 'dart:async';
import 'package:flutter/services.dart';
import '../core/platform/app_platform.dart';
import '../models/audio_spectrum_metrics.dart';
import '../models/audio_visualizer_config.dart';
import 'audio_capture_service.dart';
import 'simulated_audio_capture_service.dart';

/// Real-time live audio capture bridge communicating with native platform channels
/// on Android/iOS, featuring automatic, graceful fallback to [SimulatedAudioCaptureService]
/// when microphone access is denied, unsupported, or unavailable.
class LiveAudioCaptureService implements AudioCaptureService {
  static const MethodChannel _defaultChannel =
      MethodChannel('com.example.live_wallpaper/audio_capture');

  final MethodChannel _channel;
  final SimulatedAudioCaptureService _fallbackService;

  final StreamController<AudioSpectrumMetrics> _controller =
      StreamController<AudioSpectrumMetrics>.broadcast();

  StreamSubscription<AudioSpectrumMetrics>? _fallbackSubscription;

  bool _isRunning = false;
  bool _isPaused = false;
  bool _isDisposed = false;
  bool _isFallbackActive = false;
  String? _fallbackReason;

  // Test simulation overrides
  bool simulatePermissionDenied;
  bool simulateDeviceUnavailable;

  LiveAudioCaptureService({
    SimulatedAudioCaptureService? fallbackService,
    MethodChannel? channel,
    this.simulatePermissionDenied = false,
    this.simulateDeviceUnavailable = false,
  })  : _fallbackService = fallbackService ?? SimulatedAudioCaptureService(),
        _channel = channel ?? _defaultChannel;

  @override
  Stream<AudioSpectrumMetrics> get spectrumStream => _controller.stream;

  @override
  bool get isRunning => _isRunning;

  @override
  bool get isPaused => _isPaused;

  /// Whether this service has been disposed.
  bool get isDisposed => _isDisposed;

  /// Whether the service is currently operating in simulated fallback mode.
  bool get isFallbackActive => _isFallbackActive;

  /// The reason why fallback mode was activated, if active.
  String? get fallbackReason => _fallbackReason;

  /// Underlying fallback simulated service.
  SimulatedAudioCaptureService get fallbackService => _fallbackService;

  @override
  Future<void> start() async {
    if (_isDisposed || _isRunning) return;
    _isRunning = true;
    _isPaused = false;

    // Check test simulations first
    if (simulatePermissionDenied) {
      _activateFallback('Microphone permission denied by simulation');
      return;
    }
    if (simulateDeviceUnavailable) {
      _activateFallback('Audio capture hardware unavailable by simulation');
      return;
    }

    // Platform validation: only Android and iOS have native audio capture bridges
    if (!AppPlatform.isAndroid && !AppPlatform.isIOS) {
      _activateFallback('Live microphone capture unsupported on current platform');
      return;
    }

    try {
      final bool? hasPermission =
          await _channel.invokeMethod<bool>('checkPermission');
      if (hasPermission != true) {
        final bool? granted =
            await _channel.invokeMethod<bool>('requestPermission');
        if (granted != true) {
          _activateFallback('Microphone permission denied by user');
          return;
        }
      }

      await _channel.invokeMethod<void>('startAudioCapture');
      _isFallbackActive = false;
      _fallbackReason = null;
    } catch (e) {
      _activateFallback('Native audio capture initialization failed: $e');
    }
  }

  void _activateFallback(String reason) {
    _isFallbackActive = true;
    _fallbackReason = reason;

    _fallbackSubscription?.cancel();
    _fallbackSubscription = _fallbackService.spectrumStream.listen(
      (metrics) {
        if (!_controller.isClosed) {
          _controller.add(metrics);
        }
      },
      onError: (Object error, StackTrace stack) {
        if (!_controller.isClosed) {
          _controller.addError(error, stack);
        }
      },
    );

    unawaited(_fallbackService.start());
  }

  @override
  Future<void> stop() async {
    _isRunning = false;
    _isPaused = false;
    if (_isFallbackActive) {
      await _fallbackService.stop();
      await _fallbackSubscription?.cancel();
      _fallbackSubscription = null;
    } else {
      try {
        await _channel.invokeMethod<void>('stopAudioCapture');
      } catch (_) {}
    }
  }

  @override
  Future<void> pause() async {
    _isPaused = true;
    if (_isFallbackActive) {
      await _fallbackService.pause();
    } else {
      try {
        await _channel.invokeMethod<void>('pauseAudioCapture');
      } catch (_) {}
    }
  }

  @override
  Future<void> resume() async {
    _isPaused = false;
    if (_isFallbackActive) {
      await _fallbackService.resume();
    } else {
      try {
        await _channel.invokeMethod<void>('resumeAudioCapture');
      } catch (_) {}
    }
  }

  @override
  void updateConfig(AudioVisualizerConfig config) {
    _fallbackService.updateConfig(config);
    if (!_isFallbackActive && _isRunning) {
      try {
        unawaited(_channel.invokeMethod<void>('updateConfig', config.toJson()));
      } catch (_) {}
    }
  }

  @override
  Future<void> dispose() async {
    _isDisposed = true;
    _isRunning = false;
    _isPaused = false;
    await _fallbackSubscription?.cancel();
    _fallbackSubscription = null;
    await _fallbackService.dispose();
    await _controller.close();
  }
}
