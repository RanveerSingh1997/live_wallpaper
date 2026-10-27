import 'dart:async';
import '../models/audio_spectrum_metrics.dart';
import '../models/audio_visualizer_config.dart';

/// Abstract service contract for audio spectrum capture and analysis.
/// Follows the Dependency Inversion Principle (DIP).
abstract class AudioCaptureService {
  /// Broadcast stream emitting real-time frequency spectrum metrics.
  Stream<AudioSpectrumMetrics> get spectrumStream;

  /// Whether the capture engine is actively capturing and streaming.
  bool get isRunning;

  /// Whether audio processing is currently paused (e.g., app backgrounded or screen off).
  bool get isPaused;

  /// Starts audio capture and periodic spectrum analysis.
  Future<void> start();

  /// Stops audio capture and halts stream emissions.
  Future<void> stop();

  /// Temporarily pauses capture without terminating the stream (used for lifecycle zero sleep).
  Future<void> pause();

  /// Resumes capture from paused state.
  Future<void> resume();

  /// Dynamically updates the visualizer configuration (sensitivity, smoothing, focus, preset).
  void updateConfig(AudioVisualizerConfig config);

  /// Disposes stream controllers, timers, and platform listeners.
  Future<void> dispose();
}
