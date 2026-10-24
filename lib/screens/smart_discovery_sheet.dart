import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/wallpaper_bloc.dart';
import '../blocs/wallpaper_intent.dart';
import '../blocs/wallpaper_state.dart';
import '../core/core.dart';
import '../models/smart_filter_config.dart';

class SmartDiscoverySheet extends StatefulWidget {
  const SmartDiscoverySheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const SmartDiscoverySheet(),
    );
  }

  @override
  State<SmartDiscoverySheet> createState() => _SmartDiscoverySheetState();
}

class _SmartDiscoverySheetState extends State<SmartDiscoverySheet> {
  late SmartFilterConfig _config;

  @override
  void initState() {
    super.initState();
    final current = context.read<WallpaperBloc>().state.smartFilter;
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
        final matchCount = state.allShorts.where((s) => _config.matches(s)).length;

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
              // Drag Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),

              // Header Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.neonCyan, AppColors.auroraViolet],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Smart Semantic Discovery',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),
                          Text(
                            _config.hasActiveFilters
                                ? '${_config.activeFilterCount} active filter${_config.activeFilterCount > 1 ? "s" : ""}'
                                : 'Filter by vibe, color harmony & format',
                            style: TextStyle(
                              color: _config.hasActiveFilters
                                  ? AppColors.neonCyan
                                  : Colors.white60,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_config.hasActiveFilters)
                      TextButton.icon(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          setState(() {
                            _config = SmartFilterConfig.defaultConfig;
                          });
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.sunsetAmber),
                        label: const Text(
                          'Reset',
                          style: TextStyle(
                            color: AppColors.sunsetAmber,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const Divider(color: Colors.white10, height: 1),

              // Scrollable Options Body
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  children: [
                    // Section 1: Media Format
                    _buildSectionHeader(
                      icon: Icons.video_collection_rounded,
                      title: 'Media Format',
                      subtitle: 'Choose between dynamic 60 FPS live or pristine 4K stills',
                    ),
                    const SizedBox(height: 10),
                    _buildFormatSelector(),

                    const SizedBox(height: 24),

                    // Section 2: Mood & Energy Vibe
                    _buildSectionHeader(
                      icon: Icons.bolt_rounded,
                      title: 'Mood & Energy Vibe',
                      subtitle: 'Select the mindset you want to embody every screen unlock',
                    ),
                    const SizedBox(height: 10),
                    _buildMoodChips(),

                    const SizedBox(height: 24),

                    // Section 3: Color Harmony Palette
                    _buildSectionHeader(
                      icon: Icons.palette_rounded,
                      title: 'Color Harmony Palette',
                      subtitle: 'Match your device setup, case, or current ambiance',
                    ),
                    const SizedBox(height: 12),
                    _buildColorPaletteSelector(),

                    const SizedBox(height: 24),

                    // Section 4: Display Attributes
                    _buildSectionHeader(
                      icon: Icons.tune_rounded,
                      title: 'Display Attributes',
                      subtitle: 'AMOLED pixel efficiency and quote typography preferences',
                    ),
                    const SizedBox(height: 8),
                    _buildAttributesToggles(),
                  ],
                ),
              ),

              const Divider(color: Colors.white10, height: 1),

              // Bottom Action Bar with Real-time Count
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      // Real-time Match Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: matchCount > 0
                                ? AppColors.neonCyan.withAlpha(100)
                                : Colors.redAccent.withAlpha(100),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              matchCount > 0
                                  ? Icons.auto_awesome_rounded
                                  : Icons.search_off_rounded,
                              size: 16,
                              color: matchCount > 0
                                  ? AppColors.neonCyan
                                  : Colors.redAccent,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$matchCount match${matchCount == 1 ? "" : "es"}',
                              style: TextStyle(
                                color: matchCount > 0 ? Colors.white : Colors.white60,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Apply Button
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.neonCyan, AppColors.auroraViolet],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.neonCyan.withAlpha(80),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              context
                                  .read<WallpaperBloc>()
                                  .add(UpdateSmartFilterIntent(_config));
                              _safePop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Apply Discovery Filters',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
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
      );
    },
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.neonCyan),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormatSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: SmartMediaType.values.map((format) {
          final isSelected = _config.mediaType == format;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _config = _config.copyWith(mediaType: format);
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [AppColors.neonCyan, AppColors.auroraViolet],
                        )
                      : null,
                  color: isSelected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    format.displayName,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white60,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMoodChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: SmartMood.values.map((mood) {
        final isSelected = _config.mood == mood;
        return ChoiceChip(
          label: Text(mood.displayName),
          selected: isSelected,
          onSelected: (selected) {
            HapticFeedback.selectionClick();
            setState(() {
              _config = _config.copyWith(
                mood: selected ? mood : SmartMood.any,
              );
            });
          },
          backgroundColor: AppColors.cardSurface,
          selectedColor: AppColors.sunsetAmber,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: isSelected ? AppColors.sunsetAmber : Colors.white10,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        );
      }).toList(),
    );
  }

  Widget _buildColorPaletteSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: SmartPaletteColor.values.map((palette) {
          final isSelected = _config.paletteColor == palette;
          final color = palette.color;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _config = _config.copyWith(
                    paletteColor: palette,
                  );
                });
              },
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color ?? Colors.white12,
                      border: Border.all(
                        color: isSelected
                            ? Colors.white
                            : Colors.white24,
                        width: isSelected ? 3 : 1.5,
                      ),
                      boxShadow: isSelected && color != null
                          ? [
                              BoxShadow(
                                color: color.withAlpha(160),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: color == null
                        ? const Icon(Icons.all_inclusive_rounded, size: 20, color: Colors.white70)
                        : (isSelected
                            ? Icon(
                                Icons.check_rounded,
                                size: 20,
                                color: palette == SmartPaletteColor.amoledBlack
                                    ? Colors.white
                                    : Colors.black,
                              )
                            : null),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    palette.displayName,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white60,
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAttributesToggles() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            SwitchListTile.adaptive(
              value: _config.amoledCertifiedOnly,
              activeThumbColor: AppColors.auroraEmerald,
              activeTrackColor: AppColors.auroraEmerald.withAlpha(120),
              title: const Text(
                'AMOLED Certified Only',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: const Text(
                'Wallpapers with ≥ 70% pure true-black pixels for maximum battery savings',
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
              onChanged: (val) {
                HapticFeedback.selectionClick();
                setState(() {
                  _config = _config.copyWith(amoledCertifiedOnly: val);
                });
              },
            ),
            const Divider(color: Colors.white10, height: 1),
            SwitchListTile.adaptive(
              value: _config.requiresTextOverlay,
              activeThumbColor: AppColors.neonCyan,
              activeTrackColor: AppColors.neonCyan.withAlpha(120),
              title: const Text(
                'Requires Text / Quote Overlay',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: const Text(
                'Only wallpapers containing motivational quotes and typography',
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
              onChanged: (val) {
                HapticFeedback.selectionClick();
                setState(() {
                  _config = _config.copyWith(requiresTextOverlay: val);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
