import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import '../models/audio_spectrum_metrics.dart';
import '../models/audio_visualizer_config.dart';
import 'audio_capture_service.dart';
import 'audio_fft_engine.dart';

/// Predefined procedural synthetic audio presets for 100% deterministic simulation.
enum SimulatedAudioPreset {
  technoBeat,
  ambientCosmic,
  melodicFlow,
  silence,
}

/// Convenience alias for testing interoperability.
typedef SyntheticAudioPreset = SimulatedAudioPreset;

/// Deterministic, hardware-independent audio stream generator for Wallora.
///
/// Implements [AudioCaptureService] with pure Dart procedural wave synthesis.
/// Ensures 100% headless CI determinism without microphone or platform hardware.
class SimulatedAudioCaptureService implements AudioCaptureService {
  final AudioFftEngine _fftEngine;
  final StreamController<AudioSpectrumMetrics> _controller =
      StreamController<AudioSpectrumMetrics>.broadcast();

  final Float32List _pcmBuffer = Float32List(AudioFftEngine.fftSize);

  AudioVisualizerConfig _config;
  /// Active synthetic audio preset.
  SimulatedAudioPreset preset;
  bool _isRunning = false;
  bool _isPaused = false;
  bool _isDisposed = false;
  Timer? _timer;
  int _frameIndex = 0;

  /// Creates a [SimulatedAudioCaptureService] with optional presets,
  /// configs, and custom [fftEngine].
  SimulatedAudioCaptureService({
    SimulatedAudioPreset? initialPreset,
    SimulatedAudioPreset? syntheticPreset,
    AudioVisualizerConfig? initialConfig,
    AudioVisualizerConfig? config,
    AudioFftEngine? fftEngine,
  })  : preset = initialPreset ?? syntheticPreset ?? SimulatedAudioPreset.technoBeat,
        _config = initialConfig ?? config ?? AudioVisualizerConfig.defaultConfig,
        _fftEngine = fftEngine ?? AudioFftEngine();

  @override
  Stream<AudioSpectrumMetrics> get spectrumStream => _controller.stream;

  @override
  bool get isRunning => _isRunning;

  @override
  bool get isPaused => _isPaused;

  /// Whether this service has been disposed.
  bool get isDisposed => _isDisposed;

  /// Alias for test compatibility.
  SimulatedAudioPreset get syntheticPreset => preset;
  set syntheticPreset(SimulatedAudioPreset newPreset) {
    preset = newPreset;
  }

  /// Current visualizer configuration.
  AudioVisualizerConfig get config => _config;

  /// Frame counter for deterministic simulation.
  int get frameIndex => _frameIndex;

  @override
  Future<void> start() async {
    if (_isDisposed || _isRunning) return;
    _isRunning = true;
    _isPaused = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!_isPaused) {
        stepFrame();
      }
    });
  }

  @override
  Future<void> stop() async {
    _isRunning = false;
    _isPaused = false;
    _timer?.cancel();
    _timer = null;
    _fftEngine.reset();
  }

  @override
  Future<void> pause() async {
    _isPaused = true;
    _timer?.cancel();
    _timer = null;
  }

  @override
  Future<void> resume() async {
    if (!_isRunning) return;
    _isPaused = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      stepFrame();
    });
  }

  @override
  void updateConfig(AudioVisualizerConfig config) {
    _config = config;
  }

  /// Synchronously generates and processes a single synthetic frame.
  ///
  /// Emits the analyzed [AudioSpectrumMetrics] to [spectrumStream] and returns it.
  /// Ideal for instantaneous, deterministic unit tests without timers.
  AudioSpectrumMetrics stepFrame({int? customTimestamp}) {
    final timestamp = customTimestamp ?? (_frameIndex * 16);
    fillPcmBuffer(_frameIndex, preset, _pcmBuffer);
    _frameIndex++;

    final metrics = _fftEngine.process(
      samples: _pcmBuffer,
      config: _config,
      timestampMs: timestamp,
    );

    if (!_controller.isClosed) {
      _controller.add(metrics);
    }

    return metrics;
  }

  /// Convenience tick alias for testing frameworks.
  AudioSpectrumMetrics tick([Duration? elapsed]) {
    final ms = elapsed?.inMilliseconds ?? (_frameIndex * 16);
    return stepFrame(customTimestamp: ms);
  }

  /// Fills [buffer] in-place with synthesized samples for [frame] and [preset].
  static void fillPcmBuffer(
    int frame,
    SimulatedAudioPreset preset,
    Float32List buffer,
  ) {
    const double fs = 44100.0;
    const int n = AudioFftEngine.fftSize;
    final double t0 = frame * (n / fs);

    switch (preset) {
      case SimulatedAudioPreset.technoBeat:
        // 128 BPM -> Beat period = 60 / 128 = 0.46875s
        const double beatDuration = 0.46875;
        const double sixteenth = beatDuration / 4.0;
        final double beatPhase = (t0 % beatDuration) / beatDuration;
        final double kickEnv = math.exp(-beatPhase * 16.0);

        for (int i = 0; i < n; i++) {
          final double t = t0 + i / fs;
          final double tauBeat = t % beatDuration;
          final double tauSnare = (t + beatDuration * 0.5) % beatDuration;
          final double tauHat = t % sixteenth;

          // Kick (Bass 50-145 Hz sweep)
          final double fKick = 50.0 + 95.0 * math.exp(-28.0 * tauBeat);
          final double kick = kickEnv * math.sin(2.0 * math.pi * fKick * tauBeat);

          // Snare (Mid 220 Hz + deterministic noise)
          final double snareEnv = math.exp(-22.0 * tauSnare);
          final double snare = snareEnv *
              (0.4 * math.sin(2.0 * math.pi * 220.0 * tauSnare) +
                  0.6 * _hashNoise(t));

          // Hi-Hat (Treble 8.2k + 10.8k Hz sizzle)
          final double hatEnv = math.exp(-85.0 * tauHat);
          final double hat = hatEnv *
              0.35 *
              (math.sin(2.0 * math.pi * 8200.0 * t) +
                  math.sin(2.0 * math.pi * 10800.0 * t));

          buffer[i] = (0.6 * kick + 0.4 * snare + 0.35 * hat).clamp(-1.0, 1.0);
        }
        break;

      case SimulatedAudioPreset.ambientCosmic:
        // Deep Drone (Bass 54 Hz + 108 Hz) + High Shimmer (Treble 5400 Hz + 8200 Hz)
        for (int i = 0; i < n; i++) {
          final double t = t0 + i / fs;
          final double lfoDrone = 0.7 + 0.3 * math.sin(2.0 * math.pi * 0.15 * t);
          final double drone = lfoDrone *
              (0.55 * math.sin(2.0 * math.pi * 54.0 * t) +
                  0.35 * math.sin(2.0 * math.pi * 108.0 * t));

          final double lfoShimmer =
              0.2 + 0.25 * math.sin(2.0 * math.pi * 0.35 * t).abs();
          final double shimmer = lfoShimmer *
              (math.sin(2.0 * math.pi * 5400.0 * t) +
                  math.sin(2.0 * math.pi * 8200.0 * t));

          buffer[i] = (0.6 * drone + 0.55 * shimmer).clamp(-1.0, 1.0);
        }
        break;

      case SimulatedAudioPreset.melodicFlow:
        // 8-note E-minor pentatonic arpeggio (Mid 329.63 - 783.99 Hz)
        const notes = [
          329.63,
          392.00,
          440.00,
          493.88,
          587.33,
          659.25,
          783.99,
          659.25,
        ];
        const double noteDuration = 0.22;

        for (int i = 0; i < n; i++) {
          final double t = t0 + i / fs;
          final int noteIdx = (t / noteDuration).floor() % notes.length;
          final double freq = notes[noteIdx];
          final double tauNote = t - noteDuration * (t / noteDuration).floor();
          final double env = math.exp(-7.0 * tauNote);

          final double arp = env *
              0.6 *
              (math.sin(2.0 * math.pi * freq * t) +
                  0.3 * math.sin(4.0 * math.pi * freq * t));
          final double bassNote = 0.25 * math.sin(2.0 * math.pi * 110.0 * t);

          buffer[i] = (arp + bassNote).clamp(-1.0, 1.0);
        }
        break;

      case SimulatedAudioPreset.silence:
        buffer.fillRange(0, n, 0.0);
        break;
    }
  }

  /// Generates a `List<double>` buffer for compatibility.
  static List<double> generateBuffer(int frame, SimulatedAudioPreset preset) {
    final buffer = Float32List(AudioFftEngine.fftSize);
    fillPcmBuffer(frame, preset, buffer);
    return buffer;
  }

  static double _hashNoise(double t) {
    final int idx = (t * 44100.0).toInt();
    return ((((idx * 1103515245 + 12345) & 0x7FFFFFFF) / 0x7FFFFFFF) * 2.0) -
        1.0;
  }

  @override
  Future<void> dispose() async {
    _isDisposed = true;
    _isRunning = false;
    _isPaused = false;
    _timer?.cancel();
    _timer = null;
    await _controller.close();
  }
}
