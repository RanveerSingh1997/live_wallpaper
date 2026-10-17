import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/wallpaper_bloc.dart';
import '../blocs/wallpaper_intent.dart';
import '../blocs/wallpaper_state.dart';
import '../models/motivational_short.dart';
import '../models/parallax_effect_config.dart';

/// Interactive 3D Spatial Parallax Motion Studio.
/// Allows customizing gyroscopic sensitivity, multi-layer depth separation,
/// and testing interactive gestures directly on phone simulation mockups.
class ParallaxStudioSheet extends StatefulWidget {
  final MotivationalShort? wallpaper;

  const ParallaxStudioSheet({super.key, this.wallpaper});

  @override
  State<ParallaxStudioSheet> createState() => _ParallaxStudioSheetState();
}

class _ParallaxStudioSheetState extends State<ParallaxStudioSheet>
    with SingleTickerProviderStateMixin {
  late ParallaxEffectConfig _draftConfig;
  double _simulatedPitch = 0.0; // vertical tilt (-1.0 to 1.0)
  double _simulatedRoll = 0.0; // horizontal tilt (-1.0 to 1.0)
  bool _isDragging = false;

  late AnimationController _springBackController;
  late Animation<double> _pitchSpring;
  late Animation<double> _rollSpring;

  @override
  void initState() {
    super.initState();
    final currentConfig = context.read<WallpaperBloc>().state.parallaxConfig;
    _draftConfig = currentConfig;

    _springBackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..addListener(() {
        if (!_isDragging) {
          setState(() {
            _simulatedPitch = _pitchSpring.value;
            _simulatedRoll = _rollSpring.value;
          });
        }
      });
  }

  @override
  void dispose() {
    _springBackController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _isDragging = true;
      // Map drag offset to simulated tilt angles
      _simulatedRoll = (_simulatedRoll + details.delta.dx * 0.008).clamp(-1.0, 1.0);
      _simulatedPitch = (_simulatedPitch - details.delta.dy * 0.008).clamp(-1.0, 1.0);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _isDragging = false;
    _pitchSpring = Tween<double>(begin: _simulatedPitch, end: 0.0).animate(
      CurvedAnimation(parent: _springBackController, curve: Curves.elasticOut),
    );
    _rollSpring = Tween<double>(begin: _simulatedRoll, end: 0.0).animate(
      CurvedAnimation(parent: _springBackController, curve: Curves.elasticOut),
    );
    _springBackController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WallpaperBloc, WallpaperState>(
      builder: (context, state) {
        final targetWallpaper = widget.wallpaper ?? state.currentShort;

        return DraggableScrollableSheet(
          initialChildSize: 0.90,
          minChildSize: 0.50,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0D0D11),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 44,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFF00E5FF),
                                  width: 0.8,
                                ),
                              ),
                              child: const Icon(
                                Icons.view_in_ar_rounded,
                                size: 18,
                                color: Color(0xFF00E5FF),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '3D SPATIAL PARALLAX STUDIO',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Gyroscopic Motion & Depth Hologram',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white54,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _draftConfig = ParallaxEffectConfig.defaultConfig;
                                });
                              },
                              child: const Text(
                                'Reset',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white54,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, color: Colors.white70),
                              onPressed: () {
                                if (mounted && Navigator.of(context).canPop()) {
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Divider(color: Colors.white10, height: 1),

                  // Scrollable Body
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      children: [
                        // Live Interactive 3D Perspective Tilt Mockup
                        _buildInteractive3DMockup(targetWallpaper, state),

                        const SizedBox(height: 14),

                        // Gyroscope Virtual Bubble Level Indicator
                        _buildGyroLevelIndicator(),

                        const SizedBox(height: 20),

                        // Motion Presets Section
                        _buildPresetsSection(),

                        const SizedBox(height: 20),

                        // Fine-Tuning Sliders Section
                        _buildSlidersSection(),

                        const SizedBox(height: 20),

                        // Axis Inversion & Toggles Section
                        _buildTogglesSection(),

                        const SizedBox(height: 28),

                        // Apply Button
                        _buildApplyButton(context),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInteractive3DMockup(MotivationalShort? wallpaper, WallpaperState state) {
    final colors = wallpaper != null
        ? [wallpaper.accentColor.withValues(alpha: 0.85), Colors.black]
        : const [Color(0xFF00E5FF), Color(0xFF0A0A10)];

    final maxRad = _draftConfig.maxAngleDegrees * (math.pi / 180.0);
    final pitchSign = _draftConfig.invertPitch ? -1.0 : 1.0;
    final rollSign = _draftConfig.invertRoll ? -1.0 : 1.0;

    final effectivePitch = _draftConfig.isEnabled
        ? (_simulatedPitch * maxRad * pitchSign * _draftConfig.sensitivity)
        : 0.0;
    final effectiveRoll = _draftConfig.isEnabled
        ? (_simulatedRoll * maxRad * rollSign * _draftConfig.sensitivity)
        : 0.0;

    // Multi-plane translational depth offsets (pixel shift)
    final bgOffset = Offset(effectiveRoll * -18, effectivePitch * 18);
    final auraOffset = Offset(effectiveRoll * 26, effectivePitch * -26);
    final fgOffset = Offset(effectiveRoll * 38, effectivePitch * -38);

    return Column(
      children: [
        GestureDetector(
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: Container(
            height: 330,
            width: double.infinity,
            alignment: Alignment.center,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0018) // perspective focal factor
                ..rotateX(effectivePitch)
                ..rotateY(effectiveRoll),
              child: Container(
                width: 190,
                height: 330,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.45),
                    width: 2.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.22),
                      blurRadius: 30,
                      spreadRadius: -4,
                      offset: Offset(effectiveRoll * 20, effectivePitch * 20),
                    ),
                    const BoxShadow(
                      color: Colors.black87,
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Plane 1: Background Canvas Layer with Zoom Edge-Buffer
                      Transform.translate(
                        offset: bgOffset,
                        child: Transform.scale(
                          scale: _draftConfig.depthZoomScale,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: colors,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: wallpaper?.imageUrl != null && wallpaper!.imageUrl!.isNotEmpty
                                ? Image.asset(
                                    wallpaper.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                                  )
                                : null,
                          ),
                        ),
                      ),

                      // Plane 2: Ambient Aurora Light Mesh Drift
                      Transform.translate(
                        offset: auraOffset,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment.center,
                              radius: 0.75,
                              colors: [
                                (wallpaper?.accentColor ?? const Color(0xFF00E5FF))
                                    .withValues(alpha: 0.35),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Overlay vignette
                      Container(color: Colors.black.withValues(alpha: 0.28)),

                      // Plane 3: Foreground Kinetic Hologram (Clock, Date, Quotes)
                      Transform.translate(
                        offset: fgOffset,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                                    width: 0.8,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.spatial_audio_off_rounded, size: 10, color: Color(0xFF00E5FF)),
                                    SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        '3D SPATIAL PLANE',
                                        style: TextStyle(
                                          color: Color(0xFF00E5FF),
                                          fontSize: 8,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.6,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                '09:41',
                                style: TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w200,
                                  color: Colors.white,
                                  letterSpacing: -1.0,
                                  shadows: [
                                    Shadow(color: Colors.black87, blurRadius: 12),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                wallpaper?.quote ?? 'Make every screen yours.',
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  overflow: TextOverflow.ellipsis,
                                  shadows: [
                                    Shadow(color: Colors.black, blurRadius: 8),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Interactive Pan Hint Pill
                      Positioned(
                        bottom: 10,
                        left: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.touch_app_rounded, size: 10, color: Colors.white54),
                              SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Drag to tilt holographic view',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w600,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGyroLevelIndicator() {
    final pitchDeg = (_simulatedPitch * _draftConfig.maxAngleDegrees).toStringAsFixed(1);
    final rollDeg = (_simulatedRoll * _draftConfig.maxAngleDegrees).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF16161B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.screen_rotation_rounded, size: 14, color: Color(0xFF00E5FF)),
              const SizedBox(width: 8),
              Text(
                'Pitch: $pitchDeg°  •  Roll: $rollDeg°',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _draftConfig.isEnabled
                  ? const Color(0xFF00E676).withValues(alpha: 0.15)
                  : Colors.white10,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _draftConfig.isEnabled ? 'ENGINE ACTIVE' : 'PAUSED',
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: _draftConfig.isEnabled ? const Color(0xFF00E676) : Colors.white38,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('SPATIAL MOTION PRESETS'),
        const SizedBox(height: 8),
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildPresetChip('Subtle Depth', ParallaxEffectConfig.subtlePreset),
              const SizedBox(width: 8),
              _buildPresetChip('Cinematic 3D', ParallaxEffectConfig.cinematicPreset),
              const SizedBox(width: 8),
              _buildPresetChip('Deep Spatial', ParallaxEffectConfig.deepSpatialPreset),
              const SizedBox(width: 8),
              _buildPresetChip('Hyper Float', ParallaxEffectConfig.hyperFloatPreset),
              const SizedBox(width: 8),
              _buildPresetChip('Disabled', ParallaxEffectConfig.disabledPreset),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPresetChip(String label, ParallaxEffectConfig presetConfig) {
    final isSelected = _draftConfig.preset == presetConfig.preset;
    return ChoiceChip(
      selected: isSelected,
      label: Text(label),
      avatar: Icon(
        presetConfig.preset.icon,
        size: 14,
        color: isSelected ? Colors.black : Colors.white70,
      ),
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        color: isSelected ? Colors.black : Colors.white,
      ),
      selectedColor: const Color(0xFF00E5FF),
      backgroundColor: const Color(0xFF1B1B22),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? const Color(0xFF00E5FF) : Colors.white10,
        ),
      ),
      onSelected: (_) {
        setState(() {
          _draftConfig = presetConfig;
        });
      },
    );
  }

  Widget _buildSlidersSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF16161B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSliderRow(
            label: 'Motion Sensitivity',
            displayValue: '${_draftConfig.sensitivity.toStringAsFixed(1)}x',
            value: _draftConfig.sensitivity,
            min: 0.2,
            max: 3.0,
            onChanged: (val) {
              setState(() {
                _draftConfig = _draftConfig.copyWith(
                  sensitivity: val,
                  isEnabled: true,
                );
              });
            },
          ),
          const SizedBox(height: 12),
          _buildSliderRow(
            label: 'Max Tilt Angle',
            displayValue: '${_draftConfig.maxAngleDegrees.toStringAsFixed(0)}°',
            value: _draftConfig.maxAngleDegrees,
            min: 4.0,
            max: 25.0,
            onChanged: (val) {
              setState(() {
                _draftConfig = _draftConfig.copyWith(
                  maxAngleDegrees: val,
                  isEnabled: true,
                );
              });
            },
          ),
          const SizedBox(height: 12),
          _buildSliderRow(
            label: 'Depth Zoom Scale',
            displayValue: '${_draftConfig.depthZoomScale.toStringAsFixed(2)}x',
            value: _draftConfig.depthZoomScale,
            min: 1.0,
            max: 1.25,
            onChanged: (val) {
              setState(() {
                _draftConfig = _draftConfig.copyWith(depthZoomScale: val);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow({
    required String label,
    required String displayValue,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              displayValue,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF00E5FF),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF00E5FF),
            inactiveTrackColor: Colors.white12,
            thumbColor: Colors.white,
            trackHeight: 3.5,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.5),
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

  Widget _buildTogglesSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF16161B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enable 3D Spatial Parallax',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Sensor tilt & touch motion engine',
                    style: TextStyle(fontSize: 10, color: Colors.white54),
                  ),
                ],
              ),
              Switch.adaptive(
                value: _draftConfig.isEnabled,
                activeThumbColor: const Color(0xFF00E5FF),
                activeTrackColor: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                onChanged: (val) {
                  setState(() {
                    _draftConfig = _draftConfig.copyWith(isEnabled: val);
                  });
                },
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Invert Pitch (Vertical Axis)',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
              Switch.adaptive(
                value: _draftConfig.invertPitch,
                activeThumbColor: const Color(0xFF00E5FF),
                activeTrackColor: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                onChanged: (val) {
                  setState(() {
                    _draftConfig = _draftConfig.copyWith(invertPitch: val);
                  });
                },
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Invert Roll (Horizontal Axis)',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
              Switch.adaptive(
                value: _draftConfig.invertRoll,
                activeThumbColor: const Color(0xFF00E5FF),
                activeTrackColor: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                onChanged: (val) {
                  setState(() {
                    _draftConfig = _draftConfig.copyWith(invertRoll: val);
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApplyButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00E5FF),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        icon: const Icon(Icons.check_rounded, size: 18),
        label: const Text(
          'APPLY 3D SPATIAL PARALLAX',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        onPressed: () {
          context.read<WallpaperBloc>().add(UpdateParallaxConfigIntent(_draftConfig));
          if (mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('3D Spatial Parallax motion configuration applied.'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: Colors.white38,
        letterSpacing: 1.1,
      ),
    );
  }
}
