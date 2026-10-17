import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/wallpaper_bloc.dart';
import '../blocs/wallpaper_intent.dart';
import '../blocs/wallpaper_state.dart';
import '../models/motivational_short.dart';
import '../models/wallpaper_effect_config.dart';

class WallpaperEffectsSheet extends StatefulWidget {
  final MotivationalShort wallpaper;

  const WallpaperEffectsSheet({
    super.key,
    required this.wallpaper,
  });

  static Future<void> show(BuildContext context, MotivationalShort wallpaper) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => WallpaperEffectsSheet(wallpaper: wallpaper),
    );
  }

  @override
  State<WallpaperEffectsSheet> createState() => _WallpaperEffectsSheetState();
}

class _WallpaperEffectsSheetState extends State<WallpaperEffectsSheet> {
  late double _blurSigma;
  late double _vignetteStrength;
  late double _brightness;
  late double _contrast;
  late String _colorFilterPreset;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<WallpaperBloc>();
    final current = bloc.state.getEffectiveEffects(widget.wallpaper.id);
    _blurSigma = current.blurSigma;
    _vignetteStrength = current.vignetteStrength;
    _brightness = current.brightness;
    _contrast = current.contrast;
    _colorFilterPreset = current.colorFilterPreset;
  }

  void _applyPreset(WallpaperEffectConfig preset) {
    HapticFeedback.selectionClick();
    setState(() {
      _blurSigma = preset.blurSigma;
      _vignetteStrength = preset.vignetteStrength;
      _brightness = preset.brightness;
      _contrast = preset.contrast;
      _colorFilterPreset = preset.colorFilterPreset;
    });
  }

  void _resetToDefault() {
    HapticFeedback.mediumImpact();
    setState(() {
      _blurSigma = 0.0;
      _vignetteStrength = 0.0;
      _brightness = 0.0;
      _contrast = 1.0;
      _colorFilterPreset = 'original';
    });
  }

  void _saveEffects() {
    HapticFeedback.mediumImpact();
    final config = WallpaperEffectConfig(
      blurSigma: _blurSigma,
      vignetteStrength: _vignetteStrength,
      brightness: _brightness,
      contrast: _contrast,
      colorFilterPreset: _colorFilterPreset,
    );

    context.read<WallpaperBloc>().add(
          UpdateWallpaperEffectIntent(
            wallpaperId: widget.wallpaper.id,
            effectConfig: config,
          ),
        );

    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  ColorFilter? _buildColorFilter() {
    switch (_colorFilterPreset) {
      case 'noir':
        return const ColorFilter.mode(Colors.black, BlendMode.saturation);
      case 'cyber_cyan':
        return const ColorFilter.mode(Color(0xFF00E5FF), BlendMode.color);
      case 'sunset_amber':
        return const ColorFilter.mode(Color(0xFFFF5722), BlendMode.color);
      case 'matrix_emerald':
        return const ColorFilter.mode(Color(0xFF00E676), BlendMode.color);
      case 'aurora_violet':
        return const ColorFilter.mode(Color(0xFFD500F9), BlendMode.color);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WallpaperBloc, WallpaperState>(
      builder: (context, state) {
        return DraggableScrollableSheet(
          initialChildSize: 0.90,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF101014),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.auto_fix_high_rounded,
                              color: Color(0xFF00E5FF),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'EFFECTS & FILTERS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              Text(
                                widget.wallpaper.title,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: _resetToDefault,
                        icon: const Icon(Icons.restart_alt_rounded, size: 16, color: Colors.white60),
                        label: const Text(
                          'Reset',
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Interactive Live Simulation Preview Mockup
                  Center(
                    child: Container(
                      width: 160,
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white24, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: widget.wallpaper.accentColor.withValues(alpha: 0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Base Wallpaper Gradient Background
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: widget.wallpaper.gradientColors.isNotEmpty
                                      ? widget.wallpaper.gradientColors
                                      : [widget.wallpaper.accentColor.withValues(alpha: 0.4), Colors.black],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),

                            // Color Filter Layer
                            if (_buildColorFilter() != null)
                              ColorFiltered(
                                colorFilter: _buildColorFilter()!,
                                child: Container(
                                  color: Colors.transparent,
                                ),
                              ),

                            // Blur Layer (Depth of Field)
                            if (_blurSigma > 0.0)
                              BackdropFilter(
                                filter: ui.ImageFilter.blur(
                                  sigmaX: _blurSigma / 2.0,
                                  sigmaY: _blurSigma / 2.0,
                                ),
                                child: Container(color: Colors.transparent),
                              ),

                            // Vignette Shadow Overlay
                            if (_vignetteStrength > 0.0)
                              Container(
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    center: Alignment.center,
                                    radius: 0.85,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: _vignetteStrength.clamp(0.0, 1.0)),
                                    ],
                                  ),
                                ),
                              ),

                            // Simulated Lock Screen Clock & Badges
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      const SizedBox(height: 10),
                                      const Text(
                                        '09:41',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const Text(
                                        'Sunday, October 18',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 8,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.white24, width: 0.8),
                                    ),
                                    child: Text(
                                      _colorFilterPreset.toUpperCase(),
                                      style: TextStyle(
                                        color: widget.wallpaper.accentColor,
                                        fontSize: 8,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Preset Filters Row
                  const Text(
                    'FILTER PRESETS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildPresetChip('Original', WallpaperEffectConfig.defaultPreset),
                        const SizedBox(width: 8),
                        _buildPresetChip('OLED Noir', WallpaperEffectConfig.noirPreset),
                        const SizedBox(width: 8),
                        _buildPresetChip('Cyber Cyan', WallpaperEffectConfig.cyberPreset),
                        const SizedBox(width: 8),
                        _buildPresetChip('Sunset Amber', WallpaperEffectConfig.sunsetPreset),
                        const SizedBox(width: 8),
                        _buildPresetChip('Matrix Emerald', WallpaperEffectConfig.matrixPreset),
                        const SizedBox(width: 8),
                        _buildPresetChip('Aurora Violet', WallpaperEffectConfig.auroraPreset),
                        const SizedBox(width: 8),
                        _buildPresetChip('Soft Depth Blur', WallpaperEffectConfig.softBlurPreset),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Slider 1: Blur (Depth of Field)
                  _buildSliderSection(
                    title: 'Depth Blur',
                    valueDisplay: _blurSigma == 0 ? 'Off' : '${_blurSigma.toStringAsFixed(1)} px',
                    description: 'Softens canvas background to ensure icons & text stand out cleanly',
                    min: 0.0,
                    max: 16.0,
                    value: _blurSigma,
                    activeColor: const Color(0xFF00E5FF),
                    onChanged: (val) => setState(() => _blurSigma = val),
                  ),

                  const Divider(color: Colors.white10, height: 28),

                  // Slider 2: Vignette
                  _buildSliderSection(
                    title: 'Obsidian Vignette',
                    valueDisplay: '${(_vignetteStrength * 100).round()}%',
                    description: 'Darkens frame edges to focus central artwork and optimize OLED power',
                    min: 0.0,
                    max: 0.9,
                    value: _vignetteStrength,
                    activeColor: const Color(0xFFD500F9),
                    onChanged: (val) => setState(() => _vignetteStrength = val),
                  ),

                  const Divider(color: Colors.white10, height: 28),

                  // Slider 3: Dynamic Contrast
                  _buildSliderSection(
                    title: 'Dynamic Contrast',
                    valueDisplay: '${(_contrast * 100).round()}%',
                    description: 'Intensifies deep shadows and amplifies luminous neon highlights',
                    min: 0.7,
                    max: 1.5,
                    value: _contrast,
                    activeColor: const Color(0xFFFF5722),
                    onChanged: (val) => setState(() => _contrast = val),
                  ),

                  const SizedBox(height: 28),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _saveEffects,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.wallpaper.accentColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      icon: const Icon(Icons.check_circle_rounded, size: 20),
                      label: const Text(
                        'APPLY EFFECTS TO CANVAS',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 0.8,
                        ),
                      ),
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

  Widget _buildPresetChip(String name, WallpaperEffectConfig preset) {
    final isSelected = _colorFilterPreset == preset.colorFilterPreset &&
        (_blurSigma - preset.blurSigma).abs() < 0.1 &&
        (_vignetteStrength - preset.vignetteStrength).abs() < 0.1;

    return ChoiceChip(
      label: Text(name),
      selected: isSelected,
      onSelected: (val) {
        if (val) _applyPreset(preset);
      },
      backgroundColor: const Color(0xFF18181E),
      selectedColor: widget.wallpaper.accentColor.withValues(alpha: 0.25),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.white70,
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isSelected ? widget.wallpaper.accentColor : Colors.white10,
        ),
      ),
    );
  }

  Widget _buildSliderSection({
    required String title,
    required String valueDisplay,
    required String description,
    required double min,
    required double max,
    required double value,
    required Color activeColor,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: activeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                valueDisplay,
                style: TextStyle(
                  color: activeColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          description,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: activeColor,
            inactiveTrackColor: Colors.white10,
            thumbColor: activeColor,
            overlayColor: activeColor.withValues(alpha: 0.2),
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
          ),
          child: Slider(
            min: min,
            max: max,
            value: value.clamp(min, max),
            onChanged: (val) {
              HapticFeedback.selectionClick();
              onChanged(val);
            },
          ),
        ),
      ],
    );
  }
}
