import 'package:flutter/material.dart';
import '../core/core.dart';
import '../models/audio_spectrum_metrics.dart';
import '../models/audio_visualizer_config.dart';

/// Interactive Aurora neon 3-band VU equalizer meter.
///
/// Visualizes real-time Bass (20-250Hz), Mid (250-4,000Hz), and Treble (4,000-20,000Hz)
/// spectral energy alongside transient peak markers and silence status badges.
class AudioVisualizerMeter extends StatelessWidget {
  final AudioSpectrumMetrics metrics;
  final AudioVisualizerConfig config;
  final double height;
  final bool showLabels;

  const AudioVisualizerMeter({
    super.key,
    required this.metrics,
    required this.config,
    this.height = 120.0,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSilent = metrics.isSilent || !config.isEnabled;
    final double bassLevel = isSilent ? 0.0 : metrics.bass.clamp(0.0, 1.0);
    final double midLevel = isSilent ? 0.0 : metrics.mid.clamp(0.0, 1.0);
    final double trebleLevel = isSilent ? 0.0 : metrics.treble.clamp(0.0, 1.0);
    final double overall = isSilent ? 0.0 : metrics.overallAmplitude.clamp(0.0, 1.0);

    return Semantics(
      label: 'Audio Visualizer Equalizer Meter',
      value: isSilent
          ? 'Silent'
          : 'Bass: ${(bassLevel * 100).toInt()}%, Mid: ${(midLevel * 100).toInt()}%, Treble: ${(trebleLevel * 100).toInt()}%',
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: metrics.peakDetected && !isSilent
                ? AppColors.neonCyan.withValues(alpha: 0.6)
                : AppColors.glassBorder,
            width: metrics.peakDetected && !isSilent ? 1.5 : 1.0,
          ),
          boxShadow: metrics.peakDetected && !isSilent
              ? [
                  BoxShadow(
                    color: AppColors.neonCyan.withValues(alpha: 0.25),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            // Top Row: Silence indicator & Peak flash badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      config.mode == AudioCaptureMode.live
                          ? Icons.mic_rounded
                          : Icons.graphic_eq_rounded,
                      size: 14,
                      color: isSilent ? AppColors.textMuted : AppColors.neonCyan,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      config.mode.label.toUpperCase(),
                      style: TextStyle(
                        color: isSilent ? AppColors.textMuted : AppColors.neonCyan,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                if (metrics.peakDetected && !isSilent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.sunsetAmber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.sunsetAmber, width: 0.8),
                    ),
                    child: const Text(
                      'BEAT PEAK',
                      style: TextStyle(
                        color: AppColors.sunsetAmber,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                  )
                else if (isSilent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'SILENT (0 CPU)',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Middle: 3 Equalizer Columns
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _EqualizerBar(
                      label: 'BASS',
                      frequencyRange: '20-250 Hz',
                      level: bassLevel,
                      gradientColors: const [
                        AppColors.neonCyan,
                        Color(0xFF00B0FF),
                      ],
                      showLabels: showLabels,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _EqualizerBar(
                      label: 'MID',
                      frequencyRange: '250-4k Hz',
                      level: midLevel,
                      gradientColors: const [
                        AppColors.auroraViolet,
                        Color(0xFFAA00FF),
                      ],
                      showLabels: showLabels,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _EqualizerBar(
                      label: 'TREBLE',
                      frequencyRange: '4k-20k Hz',
                      level: trebleLevel,
                      gradientColors: const [
                        AppColors.auroraEmerald,
                        Color(0xFF00E676),
                      ],
                      showLabels: showLabels,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Bottom: Overall RMS Amplitude Track
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: overall,
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                valueColor: AlwaysStoppedAnimation<Color>(
                  overall > 0.8
                      ? AppColors.sunsetAmber
                      : AppColors.neonCyan.withValues(alpha: 0.8),
                ),
                minHeight: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EqualizerBar extends StatelessWidget {
  final String label;
  final String frequencyRange;
  final double level;
  final List<Color> gradientColors;
  final bool showLabels;

  const _EqualizerBar({
    required this.label,
    required this.frequencyRange,
    required this.level,
    required this.gradientColors,
    required this.showLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double barHeight = (constraints.maxHeight * level).clamp(4.0, constraints.maxHeight);
              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Background slot
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Animated Level Fill
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 40),
                    curve: Curves.easeOutCubic,
                    height: barHeight,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: gradientColors,
                      ),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: level > 0.4
                          ? [
                              BoxShadow(
                                color: gradientColors.first.withValues(alpha: 0.4),
                                blurRadius: 6,
                                offset: const Offset(0, -1),
                              ),
                            ]
                          : null,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        if (showLabels) ...[
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            frequencyRange,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 8,
            ),
          ),
        ],
      ],
    );
  }
}
