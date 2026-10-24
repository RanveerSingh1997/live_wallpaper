import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/wallpaper_bloc.dart';
import '../blocs/wallpaper_intent.dart';
import '../blocs/wallpaper_state.dart';
import '../core/core.dart';
import '../models/motivational_short.dart';
import '../models/particle_effect_config.dart';
import '../widgets/interactive_particle_overlay.dart';

class ParticleEffectSheet extends StatefulWidget {
  final MotivationalShort? wallpaper;

  const ParticleEffectSheet({
    super.key,
    this.wallpaper,
  });

  static Future<void> show(BuildContext context, {MotivationalShort? wallpaper}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ParticleEffectSheet(wallpaper: wallpaper),
    );
  }

  @override
  State<ParticleEffectSheet> createState() => _ParticleEffectSheetState();
}

class _ParticleEffectSheetState extends State<ParticleEffectSheet> {
  late ParticleEffectConfig _config;

  @override
  void initState() {
    super.initState();
    final current = context.read<WallpaperBloc>().state.particleConfig;
    _config = current;
  }

  void _safePop() {
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final maxSheetHeight = MediaQuery.of(context).size.height * 0.88;

    return BlocBuilder<WallpaperBloc, WallpaperState>(
      builder: (context, state) {
        final currentWallpaper = widget.wallpaper ?? state.currentShort;

        return SizedBox(
          height: maxSheetHeight,
          child: Container(
            padding: EdgeInsets.only(bottom: bottomInset),
            decoration: const BoxDecoration(
              color: AppColors.modalBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black87,
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                // Top Grab Handle
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Header with Aurora Gradient
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.neonCyan, AppColors.auroraViolet],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.auroraViolet.withValues(alpha: 0.35),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Interactive Particle FX',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Real-time touch ripples & stardust physics',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.65),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: _safePop,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(color: Colors.white10, height: 1),

                // Scrollable Content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    children: [
                      // Interactive Sandbox Preview Canvas
                      _buildSandboxPreview(currentWallpaper),
                      const SizedBox(height: 22),

                      // Particle Preset Selector
                      const Text(
                        'PARTICLE PRESETS',
                        style: TextStyle(
                          color: AppColors.neonCyan,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...ParticlePreset.values.map((preset) => _buildPresetTile(preset)),

                      const SizedBox(height: 22),

                      // Fine-Tuning Physics Sliders
                      const Text(
                        'PHYSICS & VISUAL TUNING',
                        style: TextStyle(
                          color: AppColors.neonCyan,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),

                      _buildSliderTile(
                        label: 'Particle Density',
                        valueDisplay: '${_config.particleCount} particles',
                        value: _config.particleCount.toDouble(),
                        min: 15,
                        max: 100,
                        divisions: 17,
                        onChanged: (val) {
                          setState(() {
                            _config = _config.copyWith(particleCount: val.round());
                          });
                        },
                      ),
                      const SizedBox(height: 12),

                      _buildSliderTile(
                        label: 'Touch Velocity & Speed',
                        valueDisplay: '${_config.speedMultiplier.toStringAsFixed(1)}x',
                        value: _config.speedMultiplier,
                        min: 0.5,
                        max: 2.5,
                        divisions: 20,
                        onChanged: (val) {
                          setState(() {
                            _config = _config.copyWith(speedMultiplier: val);
                          });
                        },
                      ),
                      const SizedBox(height: 12),

                      _buildSliderTile(
                        label: 'Particle Lifespan',
                        valueDisplay: '${_config.lifespanSeconds.toStringAsFixed(1)}s',
                        value: _config.lifespanSeconds,
                        min: 0.8,
                        max: 4.0,
                        divisions: 16,
                        onChanged: (val) {
                          setState(() {
                            _config = _config.copyWith(lifespanSeconds: val);
                          });
                        },
                      ),
                      const SizedBox(height: 12),

                      _buildSliderTile(
                        label: 'Ambient Glow Intensity',
                        valueDisplay: '${(_config.glowIntensity * 100).round()}%',
                        value: _config.glowIntensity,
                        min: 0.2,
                        max: 1.0,
                        divisions: 16,
                        onChanged: (val) {
                          setState(() {
                            _config = _config.copyWith(glowIntensity: val);
                          });
                        },
                      ),

                      const SizedBox(height: 22),

                      // Hardware & Battery Controls
                      const Text(
                        'HARDWARE CONTROLS',
                        style: TextStyle(
                          color: AppColors.neonCyan,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),

                      _buildSwitchTile(
                        icon: Icons.vibration_rounded,
                        accentColor: AppColors.neonCyan,
                        title: 'Touch Haptic Feedback',
                        subtitle: 'Generate subtle haptic pulse when tapping interactive particles.',
                        value: _config.isHapticsEnabled,
                        onChanged: (val) {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _config = _config.copyWith(isHapticsEnabled: val);
                          });
                        },
                      ),
                      const SizedBox(height: 10),

                      _buildSwitchTile(
                        icon: Icons.battery_saver_rounded,
                        accentColor: AppColors.auroraEmerald,
                        title: 'Low-Battery Auto-Pause (<15%)',
                        subtitle: 'Automatically suspends particle simulation when device battery is critical.',
                        value: _config.isBatteryGuardEnabled,
                        onChanged: (val) {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _config = _config.copyWith(isBatteryGuardEnabled: val);
                          });
                        },
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // Bottom Action Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: const BoxDecoration(
                    color: AppColors.darkBackground,
                    border: Border(top: BorderSide(color: Colors.white10)),
                  ),
                  child: Row(
                    children: [
                      // Reset to Default button
                      TextButton.icon(
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Reset Defaults'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white70,
                        ),
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          setState(() {
                            _config = ParticleEffectConfig.defaultConfig;
                          });
                        },
                      ),
                      const Spacer(),

                      // Apply button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.neonCyan,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        onPressed: () {
                          HapticFeedback.heavyImpact();
                          context
                              .read<WallpaperBloc>()
                              .add(UpdateParticleConfigIntent(_config));
                          _safePop();
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_rounded, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Save Particle FX',
                              style: TextStyle(fontWeight: FontWeight.bold),
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
        );
      },
    );
  }

  Widget _buildSandboxPreview(MotivationalShort? wallpaper) {
    return Container(
      height: 180,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _config.preset.accentColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _config.preset.accentColor.withValues(alpha: 0.1),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Gradient representation
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: wallpaper != null && wallpaper.gradientColors.isNotEmpty
                    ? wallpaper.gradientColors
                    : [
                        AppColors.deepPurple,
                        AppColors.obsidianBlack,
                      ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.touch_app_rounded,
                size: 42,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
          ),

          // Real-time Interactive Particle Overlay Simulation
          InteractiveParticleOverlay(
            config: _config,
            enableTouchGestures: true,
          ),

          // Sandbox Hint Pill
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _config.isEnabled
                          ? Icons.touch_app_rounded
                          : Icons.block_rounded,
                      size: 13,
                      color: _config.preset.accentColor,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _config.isEnabled
                            ? 'Touch or drag to test particle physics'
                            : 'Particle effects currently paused',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetTile(ParticlePreset preset) {
    final isSelected = _config.preset == preset;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _config = _config.copyWith(preset: preset);
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? preset.accentColor.withValues(alpha: 0.12)
                  : AppColors.cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? preset.accentColor : Colors.white10,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: preset.accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(preset.icon, color: preset.accentColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        preset.label,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        preset.description,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: preset.accentColor,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliderTile({
    required String label,
    required String valueDisplay,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.neonCyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  valueDisplay,
                  style: const TextStyle(
                    color: AppColors.neonCyan,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.neonCyan,
              inactiveTrackColor: Colors.white12,
              thumbColor: AppColors.neonCyan,
              overlayColor: AppColors.neonCyan.withValues(alpha: 0.2),
              trackHeight: 3,
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
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color accentColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Switch.adaptive(
              value: value,
              activeThumbColor: accentColor,
              activeTrackColor: accentColor.withValues(alpha: 0.35),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
