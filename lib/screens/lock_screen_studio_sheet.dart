import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/wallpaper_bloc.dart';
import '../blocs/wallpaper_intent.dart';
import '../blocs/wallpaper_state.dart';
import '../core/core.dart';
import '../models/lock_screen_style_config.dart';
import '../models/motivational_short.dart';

/// Modal sheet to customize and preview lock screen clock typography, layouts, and widgets.
class LockScreenStudioSheet extends StatefulWidget {
  final MotivationalShort? wallpaper;

  const LockScreenStudioSheet({super.key, this.wallpaper});

  static Future<void> show(BuildContext context, {MotivationalShort? wallpaper}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LockScreenStudioSheet(wallpaper: wallpaper),
    );
  }

  @override
  State<LockScreenStudioSheet> createState() => _LockScreenStudioSheetState();
}

class _LockScreenStudioSheetState extends State<LockScreenStudioSheet> {
  late LockScreenStyleConfig _draftConfig;

  @override
  void initState() {
    super.initState();
    _draftConfig = context.read<WallpaperBloc>().state.lockScreenStyle;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WallpaperBloc, WallpaperState>(
      builder: (context, state) {
        final targetWallpaper = widget.wallpaper ??
            state.allShorts.cast<MotivationalShort?>().firstWhere(
                  (s) => s?.id == state.activeWallpaperId,
                  orElse: () => null,
                ) ??
            (state.allShorts.isNotEmpty ? state.allShorts.first : null);

        final accentColor = targetWallpaper?.accentColor ?? AppColors.auroraViolet;
        final effectiveClockColor = _draftConfig.resolveClockColor(accentColor);

        return DraggableScrollableSheet(
          initialChildSize: 0.94,
          minChildSize: 0.5,
          maxChildSize: 0.96,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 14, bottom: 8),
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: AppColors.auroraViolet.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.auroraViolet,
                                  width: 0.8,
                                ),
                              ),
                              child: const Icon(
                                Icons.lock_clock_rounded,
                                size: 18,
                                color: AppColors.auroraViolet,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'LOCK SCREEN STUDIO',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Clock Typography & Glanceable Widgets',
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
                                  _draftConfig = LockScreenStyleConfig.defaultConfig;
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

                  // Body
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      children: [
                        // Live Interactive Phone Simulation Preview
                        _buildPhoneMockup(targetWallpaper, effectiveClockColor, state),

                        const SizedBox(height: 20),

                        // Aesthetic Style Presets
                        _buildPresetsSection(),

                        const SizedBox(height: 20),

                        // Section 1: Clock Typography Font
                        _buildFontSection(),

                        const SizedBox(height: 20),

                        // Section 2: Clock Layout Structure
                        _buildLayoutSection(),

                        const SizedBox(height: 20),

                        // Section 3: Color Harmonizer
                        _buildColorHarmonizerSection(accentColor),

                        const SizedBox(height: 20),

                        // Section 4: Scale Slider
                        _buildScaleSliderSection(),

                        const SizedBox(height: 20),

                        // Section 5: Glanceable Widget Pill
                        _buildWidgetSelectionSection(state, targetWallpaper),

                        const SizedBox(height: 20),

                        // Section 6: Options & Toggles
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

  Widget _buildPhoneMockup(
    MotivationalShort? wallpaper,
    Color effectiveClockColor,
    WallpaperState state,
  ) {
    final colors = wallpaper?.gradientColors.isNotEmpty == true
        ? wallpaper!.gradientColors
        : [
            wallpaper?.accentColor.withValues(alpha: 0.6) ?? AppColors.modalBackground,
            Colors.black87,
          ];

    return Center(
      child: Container(
        width: 240,
        height: 380,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white24, width: 2.0),
          boxShadow: [
            BoxShadow(
              color: effectiveClockColor.withValues(alpha: 0.18),
              blurRadius: 28,
              spreadRadius: 2,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Canvas
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            if (wallpaper?.imageUrl != null && wallpaper!.imageUrl!.isNotEmpty)
              Image.asset(
                wallpaper.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),

            // Subtle dark overlay for contrast
            Container(
              color: Colors.black.withValues(alpha: 0.28),
            ),

            // Top Status Bar (Simulated Notch / Time / Battery)
            Positioned(
              top: 10,
              left: 14,
              right: 14,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '09:41',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.wifi_rounded, color: Colors.white, size: 10),
                      const SizedBox(width: 4),
                      const Icon(Icons.signal_cellular_4_bar_rounded, color: Colors.white, size: 10),
                      const SizedBox(width: 4),
                      Icon(
                        state.isAmoledSaverModeEnabled
                            ? Icons.battery_saver_rounded
                            : Icons.battery_full_rounded,
                        color: Colors.white,
                        size: 11,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main Lock Screen Content
            Positioned.fill(
              top: 36,
              bottom: 14,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: [
                    const Icon(Icons.lock_rounded, size: 14, color: Colors.white70),
                    const SizedBox(height: 6),

                    // Date Pill
                    if (_draftConfig.showDate) ...[
                      const Text(
                        'Sunday, October 18',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                          shadows: [
                            Shadow(color: Colors.black87, blurRadius: 8),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],

                    // Clock Typography
                    _buildSimulatedClock(effectiveClockColor),

                    const SizedBox(height: 8),

                    // Glanceable Widget Pill
                    _buildSimulatedWidgetPill(wallpaper, state),

                    const Spacer(),

                    // Bottom Flashlight & Camera Shortcuts
                    if (_draftConfig.showShortcuts)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white24, width: 0.8),
                            ),
                            child: const Icon(Icons.flashlight_on_rounded, size: 13, color: Colors.white),
                          ),
                          Container(
                            width: 36,
                            height: 3,
                            decoration: BoxDecoration(
                              color: Colors.white60,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white24, width: 0.8),
                            ),
                            child: const Icon(Icons.camera_alt_rounded, size: 13, color: Colors.white),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimulatedClock(Color effectiveClockColor) {
    // Scales size appropriately for the mini mockup preview
    final previewScale = 240 / 390;
    final scaledTextStyle = _draftConfig
        .resolveClockTextStyle(effectiveClockColor)
        .copyWith(fontSize: _draftConfig.clockSize * previewScale);

    if (_draftConfig.clockLayout == LockScreenClockLayout.stacked) {
      return Column(
        children: [
          Text('09', style: scaledTextStyle),
          Text('41', style: scaledTextStyle),
        ],
      );
    } else if (_draftConfig.clockLayout == LockScreenClockLayout.compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: effectiveClockColor.withValues(alpha: 0.4), width: 0.8),
        ),
        child: Text(
          '09:41',
          style: scaledTextStyle.copyWith(fontSize: 24, fontWeight: FontWeight.w700),
        ),
      );
    } else {
      return Text('09:41', style: scaledTextStyle);
    }
  }

  Widget _buildSimulatedWidgetPill(MotivationalShort? wallpaper, WallpaperState state) {
    switch (_draftConfig.widgetType) {
      case LockScreenWidgetType.circadianSlot:
        final slot = state.activeScheduleSlot;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: slot.accentColor.withValues(alpha: 0.4), width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(slot.icon, size: 11, color: slot.accentColor),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  slot.label,
                  style: TextStyle(
                    color: slot.accentColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        );
      case LockScreenWidgetType.quotePill:
        final quote = wallpaper != null ? state.getEffectiveQuote(wallpaper) : 'Make every screen yours.';
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24, width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.format_quote_rounded, size: 11, color: AppColors.neonCyan),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  quote,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        );
      case LockScreenWidgetType.batteryGlance:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.auroraEmerald.withValues(alpha: 0.4), width: 0.8),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bolt_rounded, size: 11, color: AppColors.auroraEmerald),
              SizedBox(width: 4),
              Flexible(
                child: Text(
                  '98% • Power Saver',
                  style: TextStyle(
                    color: AppColors.auroraEmerald,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        );
      case LockScreenWidgetType.weatherMinimal:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.solarGold.withValues(alpha: 0.4), width: 0.8),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wb_sunny_rounded, size: 11, color: AppColors.solarGold),
              SizedBox(width: 4),
              Flexible(
                child: Text(
                  '72°F • Clear Sky',
                  style: TextStyle(
                    color: AppColors.solarGold,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        );
      case LockScreenWidgetType.none:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPresetsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('CURATED AESTHETIC PRESETS'),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildPresetChip('Pixel Stacked', LockScreenStyleConfig.pixelStackedPreset),
              const SizedBox(width: 8),
              _buildPresetChip('Modern Clean', LockScreenStyleConfig.defaultConfig),
              const SizedBox(width: 8),
              _buildPresetChip('Editorial Serif', LockScreenStyleConfig.editorialSerifPreset),
              const SizedBox(width: 8),
              _buildPresetChip('Cyber Matrix', LockScreenStyleConfig.cyberMatrixPreset),
              const SizedBox(width: 8),
              _buildPresetChip('Aurora Neon', LockScreenStyleConfig.auroraNeonPreset),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPresetChip(String title, LockScreenStyleConfig preset) {
    final isSelected = _draftConfig == preset;
    return ChoiceChip(
      label: Text(title),
      selected: isSelected,
      selectedColor: AppColors.auroraViolet.withValues(alpha: 0.2),
      backgroundColor: AppColors.cardSurface,
      side: BorderSide(
        color: isSelected ? AppColors.auroraViolet : Colors.white12,
      ),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.auroraViolet : Colors.white70,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
        fontSize: 11,
      ),
      onSelected: (_) {
        setState(() {
          _draftConfig = preset;
        });
      },
    );
  }

  Widget _buildFontSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('CLOCK TYPOGRAPHY FONT'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: LockScreenClockFont.values.map((font) {
            final isSelected = _draftConfig.clockFont == font;
            return ChoiceChip(
              avatar: Icon(
                font.icon,
                size: 14,
                color: isSelected ? AppColors.auroraViolet : Colors.white54,
              ),
              label: Text(font.label),
              selected: isSelected,
              selectedColor: AppColors.auroraViolet.withValues(alpha: 0.2),
              backgroundColor: AppColors.cardSurface,
              side: BorderSide(
                color: isSelected ? AppColors.auroraViolet : Colors.white12,
              ),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.auroraViolet : Colors.white70,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                fontSize: 11,
              ),
              onSelected: (_) {
                setState(() {
                  _draftConfig = _draftConfig.copyWith(clockFont: font);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLayoutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('CLOCK LAYOUT STRUCTURE'),
        const SizedBox(height: 8),
        Row(
          children: LockScreenClockLayout.values.map((layout) {
            final isSelected = _draftConfig.clockLayout == layout;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Material(
                  color: isSelected
                      ? AppColors.auroraViolet.withValues(alpha: 0.15)
                      : AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      setState(() {
                        _draftConfig = _draftConfig.copyWith(clockLayout: layout);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.auroraViolet : Colors.white10,
                          width: isSelected ? 1.2 : 0.8,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            layout.icon,
                            size: 18,
                            color: isSelected ? AppColors.auroraViolet : Colors.white54,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            layout.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? Colors.white : Colors.white60,
                            ),
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
      ],
    );
  }

  Widget _buildColorHarmonizerSection(Color wallpaperAccent) {
    const customColors = [
      Colors.white,
      AppColors.neonCyan,
      AppColors.auroraViolet,
      AppColors.solarGold,
      AppColors.auroraEmerald,
      AppColors.error,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('COLOR HARMONIZER'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: wallpaperAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Harmonize with Wallpaper Accent',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Switch.adaptive(
                    value: _draftConfig.useWallpaperAccentColor,
                    activeThumbColor: AppColors.auroraViolet,
                    activeTrackColor: AppColors.auroraViolet.withValues(alpha: 0.3),
                    onChanged: (val) {
                      setState(() {
                        _draftConfig = _draftConfig.copyWith(useWallpaperAccentColor: val);
                      });
                    },
                  ),
                ],
              ),
              if (!_draftConfig.useWallpaperAccentColor) ...[
                const SizedBox(height: 12),
                const Divider(color: Colors.white10, height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: customColors.map((col) {
                    final isSelected = _draftConfig.customColor.toARGB32() == col.toARGB32();
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _draftConfig = _draftConfig.copyWith(customColor: col);
                        });
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: col,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check_rounded,
                                size: 14,
                                color: col == Colors.white ? Colors.black : Colors.white,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScaleSliderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('CLOCK SIZE SCALE'),
            Text(
              '${_draftConfig.clockSize.toInt()} pt',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.auroraViolet,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.auroraViolet,
            inactiveTrackColor: Colors.white10,
            thumbColor: AppColors.auroraViolet,
            overlayColor: AppColors.auroraViolet.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: _draftConfig.clockSize,
            min: 50.0,
            max: 110.0,
            onChanged: (val) {
              setState(() {
                _draftConfig = _draftConfig.copyWith(clockSize: val);
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWidgetSelectionSection(WallpaperState state, MotivationalShort? wallpaper) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('GLANCEABLE LOCK SCREEN WIDGET PILL'),
        const SizedBox(height: 8),
        ...LockScreenWidgetType.values.map((wType) {
          final isSelected = _draftConfig.widgetType == wType;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: isSelected
                  ? AppColors.auroraViolet.withValues(alpha: 0.12)
                  : AppColors.cardSurface,
              borderRadius: BorderRadius.circular(12),
              child: ListTile(
                dense: true,
                leading: Icon(
                  wType.icon,
                  size: 18,
                  color: isSelected ? AppColors.auroraViolet : Colors.white54,
                ),
                title: Text(
                  wType.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle_rounded, color: AppColors.auroraViolet, size: 18)
                    : const Icon(Icons.circle_outlined, color: Colors.white24, size: 18),
                onTap: () {
                  setState(() {
                    _draftConfig = _draftConfig.copyWith(widgetType: wType);
                  });
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTogglesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('INTERFACE TOGGLES'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Display Date Pill',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Switch.adaptive(
                    value: _draftConfig.showDate,
                    activeThumbColor: AppColors.auroraViolet,
                    activeTrackColor: AppColors.auroraViolet.withValues(alpha: 0.3),
                    onChanged: (val) {
                      setState(() {
                        _draftConfig = _draftConfig.copyWith(showDate: val);
                      });
                    },
                  ),
                ],
              ),
              const Divider(color: Colors.white10, height: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Bottom Shortcuts (Flashlight & Camera)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Switch.adaptive(
                    value: _draftConfig.showShortcuts,
                    activeThumbColor: AppColors.auroraViolet,
                    activeTrackColor: AppColors.auroraViolet.withValues(alpha: 0.3),
                    onChanged: (val) {
                      setState(() {
                        _draftConfig = _draftConfig.copyWith(showShortcuts: val);
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildApplyButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.auroraViolet,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        icon: const Icon(Icons.check_rounded, size: 18),
        label: const Text(
          'SAVE LOCK SCREEN AESTHETIC',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        onPressed: () {
          context.read<WallpaperBloc>().add(UpdateLockScreenStyleIntent(_draftConfig));
          if (mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lock screen clock & widget style saved.'),
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
