import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/wallpaper_bloc.dart';
import '../blocs/wallpaper_intent.dart';
import '../blocs/wallpaper_state.dart';
import '../models/aurora_synthesizer_config.dart';
import '../models/motivational_short.dart';
import '../widgets/aurora_synthesizer_canvas.dart';

/// Modal bottom sheet allowing users to synthesize, fine-tune, and generate
/// procedural fluid aurora waves, cosmic ribbons, and celestial light patterns.
class AuroraSynthesizerSheet extends StatefulWidget {
  const AuroraSynthesizerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AuroraSynthesizerSheet(),
    );
  }

  @override
  State<AuroraSynthesizerSheet> createState() =>
      _AuroraSynthesizerSheetState();
}

class _AuroraSynthesizerSheetState extends State<AuroraSynthesizerSheet> {
  late AuroraSynthesizerConfig _config;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<WallpaperBloc>();
    _config = bloc.state.auroraSynthesizerConfig;
  }

  void _safePop() {
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _updateConfig(AuroraSynthesizerConfig newConfig) {
    setState(() {
      _config = newConfig;
    });
    context.read<WallpaperBloc>().add(UpdateAuroraSynthesizerIntent(newConfig));
  }

  void _saveAsCreatorWallpaper(WallpaperState state) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final shortId = 'aurora_synth_$timestamp';
    final title = '${_config.waveStyle.displayName} Wave';

    final short = MotivationalShort(
      id: shortId,
      title: title,
      quote: 'Flow like the aurora through infinite space.',
      author: 'Wallora Synthesizer',
      category: 'Anime & Gaming',
      videoAssetPath: 'assets/videos/ippo_hard_work.mp4',
      accentColor: const Color(0xFF00E5FF),
      tags: '#aurora #procedural #synthesizer #glow',
      mood: 'Energizing',
      isLive: false,
      resolution: 'Procedural Wave Canvas',
      gradientColors: const [
        Color(0xFF00E5FF),
        Color(0xFFD500F9),
        Color(0xFF000000),
      ],
      trueBlackPercentage: 45,
    );

    context.read<WallpaperBloc>().add(ImportCustomWallpaperIntent(short));
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF00E676)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Synthesized "$title" saved to your library!',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E2028),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WallpaperBloc, WallpaperState>(
      listener: (context, state) {
        if (state.auroraSynthesizerConfig != _config) {
          setState(() {
            _config = state.auroraSynthesizerConfig;
          });
        }
      },
      builder: (context, state) {
        return Material(
          color: const Color(0xFF0D0F18),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.90,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Header with Close
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Color(0xFF00E5FF),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Aurora Wave Synthesizer',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                            Text(
                              'Generative fluid aurora waves & procedural light ribbons',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.65),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white70),
                        onPressed: _safePop,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Scrollable Studio Controls
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        // Live Interactive Viewport
                        _buildInteractiveViewport(state),
                        const SizedBox(height: 18),

                        // Section 1: Procedural Wave Styles
                        _buildSectionHeader('PROCEDURAL WAVE STYLE'),
                        const SizedBox(height: 8),
                        _buildStyleGrid(),
                        const SizedBox(height: 18),

                        // Section 2: Color Harmony Modes
                        _buildSectionHeader('COLOR HARMONY MODE'),
                        const SizedBox(height: 8),
                        _buildColorModeSelector(),
                        const SizedBox(height: 18),

                        // Section 3: Fluid Wave Physics Tuning
                        _buildSectionHeader('FLUID WAVE DYNAMICS'),
                        const SizedBox(height: 8),
                        _buildWavePhysicsCard(),
                        const SizedBox(height: 16),

                        // Section 4: Interactive Touch & Master Toggle
                        _buildSectionHeader('TOUCH & ENGINE CONTROLS'),
                        const SizedBox(height: 8),
                        _buildSwitchTile(
                          title: 'Interactive Touch Ripples',
                          subtitle: 'Warp and displace wave crests dynamically when touching the screen',
                          icon: Icons.touch_app_rounded,
                          value: _config.isTouchReactive,
                          onChanged: (val) {
                            _updateConfig(_config.copyWith(isTouchReactive: val));
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildSwitchTile(
                          title: 'Synthesizer Active',
                          subtitle: 'Toggle procedural wave rendering engine',
                          icon: Icons.power_settings_new_rounded,
                          value: _config.isEnabled,
                          onChanged: (val) {
                            _updateConfig(_config.copyWith(isEnabled: val));
                          },
                        ),
                        const SizedBox(height: 20),

                        // Action Button: Save as Creator Wallpaper
                        Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00E5FF), Color(0xFFD500F9)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () => _saveAsCreatorWallpaper(state),
                            icon: const Icon(
                              Icons.bookmark_add_rounded,
                              color: Colors.black,
                              size: 20,
                            ),
                            label: const Text(
                              'Save Synthesized Aurora to Library',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Reset to Defaults
                        Center(
                          child: TextButton.icon(
                            onPressed: () {
                              context
                                  .read<WallpaperBloc>()
                                  .add(const ResetAuroraSynthesizerIntent());
                            },
                            icon: const Icon(
                              Icons.restart_alt_rounded,
                              size: 16,
                              color: Colors.white54,
                            ),
                            label: const Text(
                              'Reset Synthesizer to Defaults',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
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
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: const Color(0xFF00E5FF).withValues(alpha: 0.85),
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildInteractiveViewport(WallpaperState state) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AuroraSynthesizerCanvas(
                config: _config,
                auraConfig: state.auraConfig,
                interactive: true,
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _config.waveStyle.icon,
                            size: 14,
                            color: const Color(0xFF00E5FF),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _config.waveStyle.displayName.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.touch_app_rounded,
                            size: 12,
                            color: Colors.white70,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Touch to warp',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStyleGrid() {
    return Column(
      children: AuroraWaveStyle.values.map((style) {
        final isSelected = _config.waveStyle == style;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: isSelected
                ? const Color(0xFF00E5FF).withValues(alpha: 0.12)
                : const Color(0xFF141724),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                _updateConfig(_config.copyWith(waveStyle: style));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF00E5FF)
                        : Colors.white.withValues(alpha: 0.08),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      style.icon,
                      color: isSelected
                          ? const Color(0xFF00E5FF)
                          : Colors.white70,
                      size: 22,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            style.displayName,
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF00E5FF)
                                  : Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            style.description,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF00E5FF),
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColorModeSelector() {
    return Column(
      children: AuroraColorMode.values.map((mode) {
        final isSelected = _config.colorMode == mode;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: isSelected
                ? const Color(0xFFD500F9).withValues(alpha: 0.12)
                : const Color(0xFF141724),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                _updateConfig(_config.copyWith(colorMode: mode));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFD500F9)
                        : Colors.white.withValues(alpha: 0.08),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      mode.icon,
                      color: isSelected
                          ? const Color(0xFFD500F9)
                          : Colors.white70,
                      size: 22,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mode.displayName,
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFFD500F9)
                                  : Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            mode.description,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFFD500F9),
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWavePhysicsCard() {
    return Material(
      color: const Color(0xFF141724),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Wave Count Slider
            _buildSliderRow(
              label: 'Harmonic Wave Count',
              displayValue: '${_config.waveCount} Waves',
              value: _config.waveCount.toDouble(),
              min: 1,
              max: 6,
              divisions: 5,
              onChanged: (val) {
                _updateConfig(_config.copyWith(waveCount: val.round()));
              },
            ),
            const Divider(color: Colors.white10, height: 20),

            // Wave Speed Slider
            _buildSliderRow(
              label: 'Fluid Wave Speed',
              displayValue: '${_config.waveSpeed.toStringAsFixed(1)}x',
              value: _config.waveSpeed,
              min: 0.2,
              max: 2.5,
              onChanged: (val) {
                _updateConfig(_config.copyWith(waveSpeed: val));
              },
            ),
            const Divider(color: Colors.white10, height: 20),

            // Crest Amplitude Slider
            _buildSliderRow(
              label: 'Crest Amplitude / Height',
              displayValue: '${(_config.crestAmplitude * 100).round()}%',
              value: _config.crestAmplitude,
              min: 0.2,
              max: 2.0,
              onChanged: (val) {
                _updateConfig(_config.copyWith(crestAmplitude: val));
              },
            ),
            const Divider(color: Colors.white10, height: 20),

            // Wave Frequency Slider
            _buildSliderRow(
              label: 'Wave Frequency',
              displayValue: _config.frequency.toStringAsFixed(1),
              value: _config.frequency,
              min: 0.5,
              max: 3.0,
              onChanged: (val) {
                _updateConfig(_config.copyWith(frequency: val));
              },
            ),
            const Divider(color: Colors.white10, height: 20),

            // Glow Diffusion / Blur Spread
            _buildSliderRow(
              label: 'Glow Diffusion / Blur',
              displayValue: '${_config.blurSpread.round()} px',
              value: _config.blurSpread,
              min: 4.0,
              max: 32.0,
              onChanged: (val) {
                _updateConfig(_config.copyWith(blurSpread: val));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderRow({
    required String label,
    required String displayValue,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              displayValue,
              style: const TextStyle(
                color: Color(0xFF00E5FF),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: const Color(0xFF00E5FF),
            inactiveTrackColor: Colors.white12,
            thumbColor: const Color(0xFF00E5FF),
            overlayColor: const Color(0xFF00E5FF).withValues(alpha: 0.2),
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Material(
      color: const Color(0xFF141724),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              activeThumbColor: const Color(0xFF00E5FF),
              activeTrackColor: const Color(0xFF00E5FF).withValues(alpha: 0.35),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
