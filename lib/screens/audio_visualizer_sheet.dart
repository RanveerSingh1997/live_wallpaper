import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/wallpaper_bloc.dart';
import '../blocs/wallpaper_intent.dart';
import '../blocs/wallpaper_state.dart';
import '../core/core.dart';
import '../models/audio_visualizer_config.dart';
import '../widgets/audio_visualizer_meter.dart';

/// Modal bottom sheet allowing users to configure real-time audio-reactive spectrum analysis,
/// select frequency focus, tune temporal smoothing, and select audio capture mode.
///
/// Adheres strictly to Wallora design principles:
/// - Adaptive switches: [activeThumbColor] and [activeTrackColor] on [Switch.adaptive]
/// - Safe modal popping: checks [mounted] and [NavigatorState.canPop]
/// - Material ancestors for ink response display
/// - Bounded simulation previews with [Flexible] and [TextOverflow.ellipsis]
class AudioVisualizerSheet extends StatefulWidget {
  const AudioVisualizerSheet({super.key});

  /// Presents the [AudioVisualizerSheet] modal bottom sheet.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AudioVisualizerSheet(),
    );
  }

  @override
  State<AudioVisualizerSheet> createState() => _AudioVisualizerSheetState();
}

class _AudioVisualizerSheetState extends State<AudioVisualizerSheet> {
  late AudioVisualizerConfig _config;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<WallpaperBloc>();
    _config = bloc.state.audioVisualizerConfig;
  }

  void _safePop() {
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _updateConfig(AudioVisualizerConfig newConfig) {
    setState(() {
      _config = newConfig;
    });
    context.read<WallpaperBloc>().add(UpdateAudioVisualizerConfigIntent(newConfig));
  }

  void _onToggleEnabled(bool isEnabled) {
    final updated = _config.copyWith(isEnabled: isEnabled);
    setState(() {
      _config = updated;
    });
    context.read<WallpaperBloc>().add(ToggleAudioVisualizerIntent(isEnabled));
  }

  void _onSelectPreset(AudioVisualizerPreset preset) {
    final updated = AudioVisualizerConfig.forPreset(preset).copyWith(
      mode: _config.mode,
      isEnabled: _config.isEnabled,
    );
    setState(() {
      _config = updated;
    });
    context.read<WallpaperBloc>().add(SetAudioVisualizerPresetIntent(preset));
  }

  void _onSelectMode(AudioCaptureMode mode) {
    final updated = _config.copyWith(
      mode: mode,
      preset: AudioVisualizerPreset.custom,
    );
    setState(() {
      _config = updated;
    });
    context.read<WallpaperBloc>().add(SetAudioCaptureModeIntent(mode));
  }

  void _onResetDefaults() {
    const defaultConfig = AudioVisualizerConfig.defaultConfig;
    setState(() {
      _config = defaultConfig;
    });
    context.read<WallpaperBloc>().add(const ResetAudioVisualizerConfigIntent());
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.88;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: AppColors.surfacePureBlack,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.glassBorder, width: 1.0),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.glassBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.neonCyan.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.graphic_eq_rounded,
                      color: AppColors.neonCyan,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Audio-Reactive Visualizer',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                        Text(
                          'Live spectrum-driven wave and particle dynamics',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _safePop,
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                    splashRadius: 20,
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.glassBorder, height: 1),

            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // Real-time VU Equalizer Meter
                  BlocBuilder<WallpaperBloc, WallpaperState>(
                    buildWhen: (prev, curr) =>
                        prev.audioSpectrumMetrics != curr.audioSpectrumMetrics,
                    builder: (context, state) {
                      return AudioVisualizerMeter(
                        metrics: state.audioSpectrumMetrics,
                        config: _config,
                        height: 120,
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                      // Master Activation Switch
                      Material(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        child: SwitchListTile.adaptive(
                          value: _config.isEnabled,
                          onChanged: _onToggleEnabled,
                          activeThumbColor: AppColors.neonCyan,
                          activeTrackColor: AppColors.neonCyan.withValues(alpha: 0.35),
                          title: const Text(
                            'Enable Audio Reactivity',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: const Text(
                            'Modulate Aurora waves and particle FX with sound energy',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: AppColors.glassBorder),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Section: Audio Capture Mode
                      const _SectionHeader(
                        title: 'CAPTURE SOURCE',
                        icon: Icons.settings_input_composite_rounded,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: AudioCaptureMode.values.map((mode) {
                          final isSelected = _config.mode == mode;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: mode == AudioCaptureMode.values.first ? 6 : 0,
                                left: mode == AudioCaptureMode.values.last ? 6 : 0,
                              ),
                              child: Material(
                                color: isSelected
                                    ? AppColors.neonCyan.withValues(alpha: 0.15)
                                    : AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  onTap: () => _onSelectMode(mode),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.neonCyan
                                            : AppColors.glassBorder,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          mode.icon,
                                          color: isSelected ? AppColors.neonCyan : AppColors.textMuted,
                                          size: 20,
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                mode.label,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? AppColors.neonCyan
                                                      : AppColors.textPrimary,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Section: Curated Presets
                      const _SectionHeader(
                        title: 'REACTIVE PRESETS',
                        icon: Icons.auto_awesome_rounded,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: AudioVisualizerPreset.values.map((preset) {
                          final isSelected = _config.preset == preset;
                          return Material(
                            color: isSelected
                                ? AppColors.auroraViolet.withValues(alpha: 0.2)
                                : AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              onTap: () => _onSelectPreset(preset),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.auroraViolet
                                        : AppColors.glassBorder,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      preset.icon,
                                      size: 14,
                                      color: isSelected ? AppColors.auroraViolet : AppColors.textMuted,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      preset.label,
                                      style: TextStyle(
                                        color: isSelected
                                            ? AppColors.textPrimary
                                            : AppColors.textSecondary,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Section: Frequency Focus
                      const _SectionHeader(
                        title: 'FREQUENCY FOCUS',
                        icon: Icons.tune_rounded,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: AudioFrequencyFocus.values.map((focus) {
                          final isSelected = _config.frequencyFocus == focus;
                          return Material(
                            color: isSelected
                                ? AppColors.sunsetAmber.withValues(alpha: 0.2)
                                : AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              onTap: () {
                                _updateConfig(_config.copyWith(
                                  frequencyFocus: focus,
                                  preset: AudioVisualizerPreset.custom,
                                ));
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.sunsetAmber
                                        : AppColors.glassBorder,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      focus.icon,
                                      size: 14,
                                      color: isSelected ? AppColors.sunsetAmber : AppColors.textMuted,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      focus.label,
                                      style: TextStyle(
                                        color: isSelected
                                            ? AppColors.textPrimary
                                            : AppColors.textSecondary,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Section: Dynamics Tuning Sliders
                      const _SectionHeader(
                        title: 'DYNAMICS TUNING',
                        icon: Icons.tune_rounded,
                      ),
                      const SizedBox(height: 12),

                      // Sensitivity Slider
                      _SliderRow(
                        label: 'Input Sensitivity',
                        value: _config.sensitivity,
                        min: AudioVisualizerConfig.minSensitivity,
                        max: AudioVisualizerConfig.maxSensitivity,
                        displayValue: '${_config.sensitivity.toStringAsFixed(1)}x',
                        activeColor: AppColors.neonCyan,
                        onChanged: (val) {
                          _updateConfig(_config.copyWith(
                            sensitivity: val,
                            preset: AudioVisualizerPreset.custom,
                          ));
                        },
                      ),
                      const SizedBox(height: 12),

                      // Smoothing Factor Slider
                      _SliderRow(
                        label: 'Temporal Smoothing',
                        value: _config.smoothingFactor,
                        min: AudioVisualizerConfig.minSmoothingFactor,
                        max: AudioVisualizerConfig.maxSmoothingFactor,
                        displayValue: '${(_config.smoothingFactor * 100).toInt()}%',
                        activeColor: AppColors.auroraViolet,
                        onChanged: (val) {
                          _updateConfig(_config.copyWith(
                            smoothingFactor: val,
                            preset: AudioVisualizerPreset.custom,
                          ));
                        },
                      ),
                      const SizedBox(height: 12),

                      // Reactive Intensity Slider
                      _SliderRow(
                        label: 'Visual Wave Gain',
                        value: _config.reactiveIntensity,
                        min: AudioVisualizerConfig.minReactiveIntensity,
                        max: AudioVisualizerConfig.maxReactiveIntensity,
                        displayValue: '${_config.reactiveIntensity.toStringAsFixed(1)}x',
                        activeColor: AppColors.sunsetAmber,
                        onChanged: (val) {
                          _updateConfig(_config.copyWith(
                            reactiveIntensity: val,
                            preset: AudioVisualizerPreset.custom,
                          ));
                        },
                      ),
                      const SizedBox(height: 24),

                      // Section: Battery & Zero Sleep Overhead
                      const _SectionHeader(
                        title: 'BATTERY & ZERO SLEEP OVERHEAD',
                        icon: Icons.battery_charging_full_rounded,
                      ),
                      const SizedBox(height: 10),

                      Material(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          children: [
                            SwitchListTile.adaptive(
                              value: _config.isSilenceDetectionEnabled,
                              onChanged: (val) {
                                _updateConfig(_config.copyWith(
                                  isSilenceDetectionEnabled: val,
                                ));
                              },
                              activeThumbColor: AppColors.auroraEmerald,
                              activeTrackColor: AppColors.auroraEmerald.withValues(alpha: 0.35),
                              title: const Text(
                                'Auto-Halt on Silence',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: const Text(
                                'Halts FFT engine to 0 CPU cycles after 3.0s of continuous silence',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            if (_config.isSilenceDetectionEnabled) ...[
                              const Divider(color: AppColors.glassBorder, height: 1),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                                child: _SliderRow(
                                  label: 'Silence Threshold',
                                  value: _config.silenceThreshold,
                                  min: 0.005,
                                  max: 0.050,
                                  displayValue: _config.silenceThreshold.toStringAsFixed(3),
                                  activeColor: AppColors.auroraEmerald,
                                  onChanged: (val) {
                                    _updateConfig(_config.copyWith(
                                      silenceThreshold: val,
                                    ));
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Reset to Factory Defaults Button
                      Center(
                        child: OutlinedButton.icon(
                          onPressed: _onResetDefaults,
                          icon: const Icon(Icons.restore_rounded, size: 16),
                          label: const Text('Reset Visualizer to Defaults'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textMuted,
                            side: const BorderSide(color: AppColors.glassBorder),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.neonCyan),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final String displayValue;
  final Color activeColor;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.displayValue,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              displayValue,
              style: TextStyle(
                color: activeColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: activeColor,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
            thumbColor: activeColor,
            overlayColor: activeColor.withValues(alpha: 0.15),
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
