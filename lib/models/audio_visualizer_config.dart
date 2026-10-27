import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Audio capture input source mode.
enum AudioCaptureMode {
  simulated(
    label: 'Procedural Simulated Stream',
    description: 'Hardware-independent procedural audio generator for testing and ambient effects',
    icon: Icons.graphic_eq_rounded,
  ),
  live(
    label: 'Live Device Audio Input',
    description: 'Real-time hardware microphone / audio capture feed',
    icon: Icons.mic_rounded,
  );

  final String label;
  final String description;
  final IconData icon;

  const AudioCaptureMode({
    required this.label,
    required this.description,
    required this.icon,
  });

  String get displayName => label;
  bool get isLive => this == AudioCaptureMode.live;
  bool get isSimulated => this == AudioCaptureMode.simulated;
}

/// Curated tuning presets for Wallora audio visualizer dynamics.
enum AudioVisualizerPreset {
  cosmicPulse(
    label: 'Cosmic Pulse',
    description: 'Signature Wallora balanced reactive pulse with dynamic color waves',
    icon: Icons.auto_awesome_rounded,
  ),
  clubBassDrop(
    label: 'Club Bass Drop',
    description: 'Punchy low-end sub-bass transients with rapid explosive response',
    icon: Icons.speaker_group_rounded,
  ),
  ambientChill(
    label: 'Ambient Chill',
    description: 'Silky smooth temporal dampening and gentle harmonic waves',
    icon: Icons.spa_rounded,
  ),
  vocalAcoustic(
    label: 'Vocal Acoustic',
    description: 'Mid-range melodic focus tracking vocal presence and timbre',
    icon: Icons.record_voice_over_rounded,
  ),
  minimalistNoir(
    label: 'Minimalist Noir',
    description: 'Subtle low-profile reaction for OLED dark-mode immersion',
    icon: Icons.dark_mode_rounded,
  ),
  custom(
    label: 'Custom Studio Configuration',
    description: 'Fine-tuned user-defined audio sensitivity and reactive dynamics',
    icon: Icons.tune_rounded,
  );

  final String label;
  final String description;
  final IconData icon;

  const AudioVisualizerPreset({
    required this.label,
    required this.description,
    required this.icon,
  });

  String get displayName => label;
  bool get isCustom => this == AudioVisualizerPreset.custom;
}

/// Frequency band focus for reactive visualizer weighting.
enum AudioFrequencyFocus {
  allFrequencies(
    label: 'Full Spectrum Balanced',
    description: 'Uniform response across Bass, Mid, and Treble frequency bands',
    icon: Icons.all_inclusive_rounded,
  ),
  bassCentric(
    label: 'Bass & Sub-Bass (20-250 Hz)',
    description: 'Amplified responsiveness to kick drums, 808s, and deep low frequencies',
    icon: Icons.graphic_eq_rounded,
  ),
  midVocal(
    label: 'Mid & Vocals (250-4000 Hz)',
    description: 'Targeted sensitivity for acoustic melodies, guitars, and human vocals',
    icon: Icons.voice_chat_rounded,
  ),
  trebleShimmer(
    label: 'Treble Shimmer (4000-20000 Hz)',
    description: 'Elevated tracking of cymbals, hi-hats, snares, and crisp transients',
    icon: Icons.star_rounded,
  );

  final String label;
  final String description;
  final IconData icon;

  const AudioFrequencyFocus({
    required this.label,
    required this.description,
    required this.icon,
  });

  String get displayName => label;
}

/// Configuration model governing Wallora's Live Audio-Reactive Visualizer.
class AudioVisualizerConfig extends Equatable {
  static const double minSensitivity = 0.1;
  static const double maxSensitivity = 3.0;
  static const double defaultSensitivity = 1.0;

  static const double minSmoothingFactor = 0.0;
  static const double maxSmoothingFactor = 0.95;
  static const double defaultSmoothingFactor = 0.65;

  static const double minReactiveIntensity = 0.0;
  static const double maxReactiveIntensity = 2.0;
  static const double defaultReactiveIntensity = 1.0;

  static const double minSilenceThreshold = 0.001;
  static const double maxSilenceThreshold = 0.1;
  static const double defaultSilenceThreshold = 0.015;

  final bool isEnabled;
  final AudioCaptureMode mode;
  final AudioVisualizerPreset preset;
  final double sensitivity;
  final double smoothingFactor;
  final AudioFrequencyFocus frequencyFocus;
  final double reactiveIntensity;
  final bool isSilenceDetectionEnabled;
  final double silenceThreshold;

  const AudioVisualizerConfig({
    this.isEnabled = false,
    this.mode = AudioCaptureMode.simulated,
    this.preset = AudioVisualizerPreset.cosmicPulse,
    this.sensitivity = defaultSensitivity,
    this.smoothingFactor = defaultSmoothingFactor,
    this.frequencyFocus = AudioFrequencyFocus.allFrequencies,
    this.reactiveIntensity = defaultReactiveIntensity,
    this.isSilenceDetectionEnabled = true,
    double silenceThreshold = defaultSilenceThreshold,
  }) : silenceThreshold = (silenceThreshold < minSilenceThreshold)
            ? minSilenceThreshold
            : (silenceThreshold > maxSilenceThreshold
                ? maxSilenceThreshold
                : silenceThreshold);

  static const AudioVisualizerConfig defaultConfig = AudioVisualizerConfig();

  static const AudioVisualizerConfig cosmicPulseConfig = AudioVisualizerConfig(
    isEnabled: true,
    mode: AudioCaptureMode.simulated,
    preset: AudioVisualizerPreset.cosmicPulse,
    sensitivity: 1.2,
    smoothingFactor: 0.70,
    frequencyFocus: AudioFrequencyFocus.allFrequencies,
    reactiveIntensity: 1.0,
    isSilenceDetectionEnabled: true,
    silenceThreshold: 0.015,
  );

  static const AudioVisualizerConfig clubBassDropConfig = AudioVisualizerConfig(
    isEnabled: true,
    mode: AudioCaptureMode.simulated,
    preset: AudioVisualizerPreset.clubBassDrop,
    sensitivity: 1.8,
    smoothingFactor: 0.45,
    frequencyFocus: AudioFrequencyFocus.bassCentric,
    reactiveIntensity: 1.5,
    isSilenceDetectionEnabled: true,
    silenceThreshold: 0.020,
  );

  static const AudioVisualizerConfig ambientChillConfig = AudioVisualizerConfig(
    isEnabled: true,
    mode: AudioCaptureMode.simulated,
    preset: AudioVisualizerPreset.ambientChill,
    sensitivity: 0.8,
    smoothingFactor: 0.90,
    frequencyFocus: AudioFrequencyFocus.allFrequencies,
    reactiveIntensity: 0.6,
    isSilenceDetectionEnabled: true,
    silenceThreshold: 0.010,
  );

  static const AudioVisualizerConfig vocalAcousticConfig = AudioVisualizerConfig(
    isEnabled: true,
    mode: AudioCaptureMode.simulated,
    preset: AudioVisualizerPreset.vocalAcoustic,
    sensitivity: 1.3,
    smoothingFactor: 0.60,
    frequencyFocus: AudioFrequencyFocus.midVocal,
    reactiveIntensity: 1.2,
    isSilenceDetectionEnabled: true,
    silenceThreshold: 0.015,
  );

  static const AudioVisualizerConfig minimalistNoirConfig = AudioVisualizerConfig(
    isEnabled: true,
    mode: AudioCaptureMode.simulated,
    preset: AudioVisualizerPreset.minimalistNoir,
    sensitivity: 0.5,
    smoothingFactor: 0.90,
    frequencyFocus: AudioFrequencyFocus.allFrequencies,
    reactiveIntensity: 0.3,
    isSilenceDetectionEnabled: true,
    silenceThreshold: 0.030,
  );

  /// Creates a configuration preset instance.
  factory AudioVisualizerConfig.forPreset(
    AudioVisualizerPreset preset, {
    bool isEnabled = true,
    AudioCaptureMode mode = AudioCaptureMode.simulated,
  }) {
    switch (preset) {
      case AudioVisualizerPreset.cosmicPulse:
        return cosmicPulseConfig.copyWith(isEnabled: isEnabled, mode: mode);
      case AudioVisualizerPreset.clubBassDrop:
        return clubBassDropConfig.copyWith(isEnabled: isEnabled, mode: mode);
      case AudioVisualizerPreset.ambientChill:
        return ambientChillConfig.copyWith(isEnabled: isEnabled, mode: mode);
      case AudioVisualizerPreset.vocalAcoustic:
        return vocalAcousticConfig.copyWith(isEnabled: isEnabled, mode: mode);
      case AudioVisualizerPreset.minimalistNoir:
        return minimalistNoirConfig.copyWith(isEnabled: isEnabled, mode: mode);
      case AudioVisualizerPreset.custom:
        return AudioVisualizerConfig(
          isEnabled: isEnabled,
          mode: mode,
          preset: AudioVisualizerPreset.custom,
        );
    }
  }

  /// Compatibility helper for preset resolution.
  static AudioVisualizerConfig presetConfig(AudioVisualizerPreset preset) {
    return AudioVisualizerConfig.forPreset(preset);
  }

  bool get isCustom => preset.isCustom;
  bool get isLive => mode.isLive;
  bool get isSimulated => mode.isSimulated;

  AudioVisualizerConfig copyWith({
    bool? isEnabled,
    AudioCaptureMode? mode,
    AudioVisualizerPreset? preset,
    double? sensitivity,
    double? smoothingFactor,
    AudioFrequencyFocus? frequencyFocus,
    double? reactiveIntensity,
    bool? isSilenceDetectionEnabled,
    double? silenceThreshold,
  }) {
    return AudioVisualizerConfig(
      isEnabled: isEnabled ?? this.isEnabled,
      mode: mode ?? this.mode,
      preset: preset ?? this.preset,
      sensitivity: sensitivity != null
          ? sensitivity.clamp(minSensitivity, maxSensitivity)
          : this.sensitivity,
      smoothingFactor: smoothingFactor != null
          ? smoothingFactor.clamp(minSmoothingFactor, maxSmoothingFactor)
          : this.smoothingFactor,
      frequencyFocus: frequencyFocus ?? this.frequencyFocus,
      reactiveIntensity: reactiveIntensity != null
          ? reactiveIntensity.clamp(minReactiveIntensity, maxReactiveIntensity)
          : this.reactiveIntensity,
      isSilenceDetectionEnabled:
          isSilenceDetectionEnabled ?? this.isSilenceDetectionEnabled,
      silenceThreshold: silenceThreshold != null
          ? silenceThreshold.clamp(minSilenceThreshold, maxSilenceThreshold)
          : this.silenceThreshold,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled,
      'mode': mode.name,
      'preset': preset.name,
      'sensitivity': sensitivity,
      'smoothingFactor': smoothingFactor,
      'frequencyFocus': frequencyFocus.name,
      'reactiveIntensity': reactiveIntensity,
      'isSilenceDetectionEnabled': isSilenceDetectionEnabled,
      'silenceThreshold': silenceThreshold,
    };
  }

  factory AudioVisualizerConfig.fromJson(Map<String, dynamic> json) {
    AudioCaptureMode parseMode(String? name) {
      if (name == null) return AudioCaptureMode.simulated;
      return AudioCaptureMode.values.firstWhere(
        (e) => e.name == name,
        orElse: () => AudioCaptureMode.simulated,
      );
    }

    AudioVisualizerPreset parsePreset(String? name) {
      if (name == null) return AudioVisualizerPreset.cosmicPulse;
      return AudioVisualizerPreset.values.firstWhere(
        (e) => e.name == name,
        orElse: () => AudioVisualizerPreset.cosmicPulse,
      );
    }

    AudioFrequencyFocus parseFrequencyFocus(String? name) {
      if (name == null) return AudioFrequencyFocus.allFrequencies;
      return AudioFrequencyFocus.values.firstWhere(
        (e) => e.name == name,
        orElse: () => AudioFrequencyFocus.allFrequencies,
      );
    }

    final rawSensitivity =
        (json['sensitivity'] as num?)?.toDouble() ?? defaultSensitivity;
    final rawSmoothing =
        (json['smoothingFactor'] as num?)?.toDouble() ?? defaultSmoothingFactor;
    final rawIntensity =
        (json['reactiveIntensity'] as num?)?.toDouble() ?? defaultReactiveIntensity;
    final rawSilence =
        (json['silenceThreshold'] as num?)?.toDouble() ?? defaultSilenceThreshold;

    return AudioVisualizerConfig(
      isEnabled: json['isEnabled'] as bool? ?? false,
      mode: parseMode(json['mode'] as String?),
      preset: parsePreset(json['preset'] as String?),
      sensitivity: rawSensitivity.clamp(minSensitivity, maxSensitivity),
      smoothingFactor: rawSmoothing.clamp(minSmoothingFactor, maxSmoothingFactor),
      frequencyFocus: parseFrequencyFocus(json['frequencyFocus'] as String?),
      reactiveIntensity:
          rawIntensity.clamp(minReactiveIntensity, maxReactiveIntensity),
      isSilenceDetectionEnabled:
          json['isSilenceDetectionEnabled'] as bool? ?? true,
      silenceThreshold: rawSilence.clamp(minSilenceThreshold, maxSilenceThreshold),
    );
  }

  @override
  List<Object?> get props => [
        isEnabled,
        mode,
        preset,
        sensitivity,
        smoothingFactor,
        frequencyFocus,
        reactiveIntensity,
        isSilenceDetectionEnabled,
        silenceThreshold,
      ];
}
