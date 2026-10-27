import '../models/audio_spectrum_metrics.dart';
import '../models/audio_visualizer_config.dart';

/// Silence detection watchdog governing Wallora's Zero Sleep Overhead mandate.
///
/// Automatically halts audio frequency analysis after continuous silence exceeding
/// [silenceTimeout] (default 3.0s), eliminating CPU/GPU battery drain when no music
/// is playing. Employs hysteresis dead-band ([silenceThreshold] vs [wakeupThreshold])
/// to prevent visual stutter near the noise floor.
class SilenceDetectionWatchdog {
  double silenceThreshold;
  double wakeupThreshold;
  Duration silenceTimeout;
  bool isEnabled;

  bool _isSilent = false;
  Duration _continuousSilenceDuration = Duration.zero;

  void Function(bool isSilent)? onSilenceChanged;
  void Function()? onHaltRequested;
  void Function()? onWakeupRequested;
  void Function()? onSilenceAutoHalt;
  void Function()? onSoundWakeup;

  Duration get haltDuration => silenceTimeout;

  /// Creates a [SilenceDetectionWatchdog] with configurable thresholds.
  SilenceDetectionWatchdog({
    this.silenceThreshold = AudioVisualizerConfig.defaultSilenceThreshold,
    this.wakeupThreshold = 0.025,
    Duration? silenceTimeout,
    Duration? haltDuration,
    this.isEnabled = true,
    this.onSilenceChanged,
    void Function()? onHaltRequested,
    void Function()? onWakeupRequested,
    void Function()? onSilenceAutoHalt,
    void Function()? onSoundWakeup,
  })  : silenceTimeout = silenceTimeout ?? haltDuration ?? const Duration(seconds: 3),
        onHaltRequested = onHaltRequested ?? onSilenceAutoHalt,
        onSilenceAutoHalt = onSilenceAutoHalt ?? onHaltRequested,
        onWakeupRequested = onWakeupRequested ?? onSoundWakeup,
        onSoundWakeup = onSoundWakeup ?? onWakeupRequested;

  /// Whether the input signal is currently evaluated as silent.
  bool get isSilent => _isSilent;

  /// Whether the watchdog has halted processing to achieve zero CPU usage.
  bool isHalted = false;

  /// Total continuous elapsed time below [silenceThreshold].
  Duration get continuousSilenceDuration => _continuousSilenceDuration;

  /// Processes a single frame with RMS amplitude [rawRms] and [elapsed] time step.
  ///
  /// Returns `true` if processing should be halted.
  bool processFrame({
    required double rawRms,
    required Duration elapsed,
  }) {
    if (!isEnabled) {
      if (_isSilent || isHalted) {
        _isSilent = false;
        isHalted = false;
        _continuousSilenceDuration = Duration.zero;
        onWakeupRequested?.call();
        if (onSoundWakeup != null && onSoundWakeup != onWakeupRequested) {
          onSoundWakeup?.call();
        }
        onSilenceChanged?.call(false);
      }
      return false;
    }

    if (isHalted) {
      // While halted, only sound exceeding wakeupThreshold can wake up the engine (hysteresis)
      if (rawRms > wakeupThreshold) {
        isHalted = false;
        _isSilent = false;
        _continuousSilenceDuration = Duration.zero;
        onWakeupRequested?.call();
        if (onSoundWakeup != null && onSoundWakeup != onWakeupRequested) {
          onSoundWakeup?.call();
        }
        onSilenceChanged?.call(false);
      }
    } else {
      // While running, check if signal is below silenceThreshold
      if (rawRms < silenceThreshold) {
        _continuousSilenceDuration += elapsed;
        if (_continuousSilenceDuration >= silenceTimeout) {
          isHalted = true;
          _isSilent = true;
          onSilenceChanged?.call(true);
          onHaltRequested?.call();
          if (onSilenceAutoHalt != null && onSilenceAutoHalt != onHaltRequested) {
            onSilenceAutoHalt?.call();
          }
        }
      } else {
        // Audible sound above silenceThreshold breaks continuous silence
        _continuousSilenceDuration = Duration.zero;
        if (_isSilent) {
          _isSilent = false;
          onSilenceChanged?.call(false);
        }
      }
    }

    return isHalted;
  }

  /// Convenience wrapper inspecting a single audio frame.
  void inspectAudioFrame(double overallRms, {int elapsedMs = 16}) {
    processFrame(rawRms: overallRms, elapsed: Duration(milliseconds: elapsedMs));
  }

  /// Evaluates [metrics] and decorates with watchdog silence and halt status.
  AudioSpectrumMetrics evaluateMetrics(
    AudioSpectrumMetrics metrics,
    Duration elapsed,
  ) {
    processFrame(rawRms: metrics.overallAmplitude, elapsed: elapsed);

    if (isHalted) {
      return metrics.copyWith(
        bass: 0.0,
        mid: 0.0,
        treble: 0.0,
        overallAmplitude: 0.0,
        peakDetected: false,
        isSilent: true,
      );
    }

    final bool frameIsSilent =
        _isSilent || metrics.isSilent || (metrics.overallAmplitude < silenceThreshold);
    return metrics.copyWith(isSilent: frameIsSilent);
  }

  /// Updates watchdog configuration dynamically.
  void updateConfig({
    double? silenceThreshold,
    double? wakeupThreshold,
    Duration? silenceTimeout,
    bool? isEnabled,
  }) {
    if (silenceThreshold != null) this.silenceThreshold = silenceThreshold;
    if (wakeupThreshold != null) this.wakeupThreshold = wakeupThreshold;
    if (silenceTimeout != null) this.silenceTimeout = silenceTimeout;
    if (isEnabled != null) {
      this.isEnabled = isEnabled;
      if (!this.isEnabled) {
        reset();
      }
    }
  }

  /// Resets silence duration and un-halts the watchdog.
  void reset() {
    _continuousSilenceDuration = Duration.zero;
    isHalted = false;
    _isSilent = false;
  }

  /// Disposes callbacks and clears internal state.
  void dispose() {
    reset();
    onSilenceChanged = null;
    onHaltRequested = null;
    onWakeupRequested = null;
    onSilenceAutoHalt = null;
    onSoundWakeup = null;
  }
}
