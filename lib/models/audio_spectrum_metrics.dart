import 'dart:math' as math;
import 'package:equatable/equatable.dart';
import 'audio_visualizer_config.dart';

/// Instantaneous spectrum metrics emitted by the audio analysis engine.
class AudioSpectrumMetrics extends Equatable {
  final double bass;
  final double mid;
  final double treble;
  final double overallAmplitude;
  final bool peakDetected;
  final bool isSilent;
  final int timestampMs;

  const AudioSpectrumMetrics({
    this.bass = 0.0,
    this.mid = 0.0,
    this.treble = 0.0,
    this.overallAmplitude = 0.0,
    this.peakDetected = false,
    this.isSilent = true,
    this.timestampMs = 0,
  });

  /// Canonical zero / silent state.
  static const AudioSpectrumMetrics zero = AudioSpectrumMetrics(
    bass: 0.0,
    mid: 0.0,
    treble: 0.0,
    overallAmplitude: 0.0,
    peakDetected: false,
    isSilent: true,
    timestampMs: 0,
  );

  /// Constructs metrics with all numeric values clamped to [0.0, 1.0].
  factory AudioSpectrumMetrics.clamped({
    required double bass,
    required double mid,
    required double treble,
    required double overallAmplitude,
    bool peakDetected = false,
    bool isSilent = false,
    int timestampMs = 0,
  }) {
    return AudioSpectrumMetrics(
      bass: bass.clamp(0.0, 1.0),
      mid: mid.clamp(0.0, 1.0),
      treble: treble.clamp(0.0, 1.0),
      overallAmplitude: overallAmplitude.clamp(0.0, 1.0),
      peakDetected: peakDetected,
      isSilent: isSilent,
      timestampMs: timestampMs,
    );
  }

  /// Constructs normalized metrics from raw FFT or synthetic energy calculations.
  factory AudioSpectrumMetrics.fromRawValues({
    required double rawBass,
    required double rawMid,
    required double rawTreble,
    required double rawAmplitude,
    double maxExpectedEnergy = 1.0,
    double silenceThreshold = 0.015,
    double peakThreshold = 0.85,
    int? timestampMs,
  }) {
    final scale = maxExpectedEnergy > 0.0 ? 1.0 / maxExpectedEnergy : 1.0;
    final b = (rawBass * scale).clamp(0.0, 1.0);
    final m = (rawMid * scale).clamp(0.0, 1.0);
    final t = (rawTreble * scale).clamp(0.0, 1.0);
    final amp = (rawAmplitude * scale).clamp(0.0, 1.0);
    final silent = amp < silenceThreshold;
    final peak = !silent &&
        (b >= peakThreshold ||
            m >= peakThreshold ||
            t >= peakThreshold ||
            amp >= peakThreshold);

    return AudioSpectrumMetrics(
      bass: b,
      mid: m,
      treble: t,
      overallAmplitude: amp,
      peakDetected: peak,
      isSilent: silent,
      timestampMs: timestampMs ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Exponential temporal smoothing between this frame and the previous frame.
  AudioSpectrumMetrics smoothedWith(
    AudioSpectrumMetrics previous,
    double factor,
  ) {
    final alpha = factor.clamp(0.0, 0.95);
    final inv = 1.0 - alpha;
    return AudioSpectrumMetrics(
      bass: (previous.bass * alpha + bass * inv).clamp(0.0, 1.0),
      mid: (previous.mid * alpha + mid * inv).clamp(0.0, 1.0),
      treble: (previous.treble * alpha + treble * inv).clamp(0.0, 1.0),
      overallAmplitude: (previous.overallAmplitude * alpha + overallAmplitude * inv)
          .clamp(0.0, 1.0),
      peakDetected: peakDetected,
      isSilent: isSilent,
      timestampMs: timestampMs,
    );
  }

  /// Scales energies by visualizer sensitivity setting.
  AudioSpectrumMetrics applySensitivity(double sensitivity) {
    final s = sensitivity.clamp(
      AudioVisualizerConfig.minSensitivity,
      AudioVisualizerConfig.maxSensitivity,
    );
    return AudioSpectrumMetrics(
      bass: (bass * s).clamp(0.0, 1.0),
      mid: (mid * s).clamp(0.0, 1.0),
      treble: (treble * s).clamp(0.0, 1.0),
      overallAmplitude: (overallAmplitude * s).clamp(0.0, 1.0),
      peakDetected: peakDetected,
      isSilent: isSilent,
      timestampMs: timestampMs,
    );
  }

  /// Adjusts energy band distributions according to frequency focus.
  AudioSpectrumMetrics applyFocus(AudioFrequencyFocus focus) {
    switch (focus) {
      case AudioFrequencyFocus.allFrequencies:
        return this;
      case AudioFrequencyFocus.bassCentric:
        return AudioSpectrumMetrics(
          bass: (bass * 1.35).clamp(0.0, 1.0),
          mid: (mid * 0.75).clamp(0.0, 1.0),
          treble: (treble * 0.75).clamp(0.0, 1.0),
          overallAmplitude: overallAmplitude,
          peakDetected: peakDetected,
          isSilent: isSilent,
          timestampMs: timestampMs,
        );
      case AudioFrequencyFocus.midVocal:
        return AudioSpectrumMetrics(
          bass: (bass * 0.75).clamp(0.0, 1.0),
          mid: (mid * 1.35).clamp(0.0, 1.0),
          treble: (treble * 0.75).clamp(0.0, 1.0),
          overallAmplitude: overallAmplitude,
          peakDetected: peakDetected,
          isSilent: isSilent,
          timestampMs: timestampMs,
        );
      case AudioFrequencyFocus.trebleShimmer:
        return AudioSpectrumMetrics(
          bass: (bass * 0.70).clamp(0.0, 1.0),
          mid: (mid * 0.85).clamp(0.0, 1.0),
          treble: (treble * 1.35).clamp(0.0, 1.0),
          overallAmplitude: overallAmplitude,
          peakDetected: peakDetected,
          isSilent: isSilent,
          timestampMs: timestampMs,
        );
    }
  }

  /// Mean energy across all 3 frequency bands.
  double get averageEnergy => (bass + mid + treble) / 3.0;

  /// Maximum energy level among the 3 frequency bands.
  double get maxBandEnergy => math.max(bass, math.max(mid, treble));

  /// Whether measurable audible signal is present.
  bool get hasAudibleEnergy => !isSilent && overallAmplitude > 0.0;

  AudioSpectrumMetrics copyWith({
    double? bass,
    double? mid,
    double? treble,
    double? overallAmplitude,
    bool? peakDetected,
    bool? isSilent,
    int? timestampMs,
  }) {
    return AudioSpectrumMetrics(
      bass: bass != null ? bass.clamp(0.0, 1.0) : this.bass,
      mid: mid != null ? mid.clamp(0.0, 1.0) : this.mid,
      treble: treble != null ? treble.clamp(0.0, 1.0) : this.treble,
      overallAmplitude: overallAmplitude != null
          ? overallAmplitude.clamp(0.0, 1.0)
          : this.overallAmplitude,
      peakDetected: peakDetected ?? this.peakDetected,
      isSilent: isSilent ?? this.isSilent,
      timestampMs: timestampMs ?? this.timestampMs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bass': bass,
      'mid': mid,
      'treble': treble,
      'overallAmplitude': overallAmplitude,
      'peakDetected': peakDetected,
      'isSilent': isSilent,
      'timestampMs': timestampMs,
    };
  }

  factory AudioSpectrumMetrics.fromJson(Map<String, dynamic> json) {
    return AudioSpectrumMetrics(
      bass: ((json['bass'] as num?)?.toDouble() ?? 0.0).clamp(0.0, 1.0),
      mid: ((json['mid'] as num?)?.toDouble() ?? 0.0).clamp(0.0, 1.0),
      treble: ((json['treble'] as num?)?.toDouble() ?? 0.0).clamp(0.0, 1.0),
      overallAmplitude:
          ((json['overallAmplitude'] as num?)?.toDouble() ?? 0.0).clamp(0.0, 1.0),
      peakDetected: json['peakDetected'] as bool? ?? false,
      isSilent: json['isSilent'] as bool? ?? true,
      timestampMs: json['timestampMs'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        bass,
        mid,
        treble,
        overallAmplitude,
        peakDetected,
        isSilent,
        timestampMs,
      ];
}
