import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/wallpaper_bloc.dart';
import '../blocs/wallpaper_intent.dart';
import '../blocs/wallpaper_state.dart';
import '../core/core.dart';
import '../models/standby_dock_config.dart';
import 'standby_dock_screen.dart';

/// Modal bottom sheet for customizing Wallora Horizon Standby & Ambient Desk Dock settings.
class StandbyDockSheet extends StatefulWidget {
  const StandbyDockSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const StandbyDockSheet(),
    );
  }

  @override
  State<StandbyDockSheet> createState() => _StandbyDockSheetState();
}

class _StandbyDockSheetState extends State<StandbyDockSheet> {
  late StandbyDockConfig _config;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<WallpaperBloc>();
    _config = bloc.state.standbyDockConfig;
  }

  void _safePop() {
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _updateConfig(StandbyDockConfig newConfig) {
    setState(() {
      _config = newConfig;
    });
    context.read<WallpaperBloc>().add(UpdateStandbyDockIntent(newConfig));
  }

  void _launchDock() {
    _safePop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const StandbyDockScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WallpaperBloc, WallpaperState>(
      listener: (context, state) {
        if (state.standbyDockConfig != _config) {
          setState(() {
            _config = state.standbyDockConfig;
          });
        }
      },
      builder: (context, state) {
        return Material(
          color: AppColors.backgroundDark,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.88,
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
                  const SizedBox(height: 16),

                  // Header with Close & Reset
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.auroraCyan.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.auroraCyan.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.desktop_windows_rounded,
                          color: AppColors.auroraCyan,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Horizon Standby Studio',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                            Text(
                              'Ambient desk dock & nightstand OLED hub',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.65),
                                fontSize: 12,
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
                  const SizedBox(height: 16),

                  // Scrollable Settings
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        // Section: Typography Style
                        _buildSectionHeader('CLOCK TYPOGRAPHY'),
                        const SizedBox(height: 8),
                        _buildClockStyleGrid(),
                        const SizedBox(height: 20),

                        // Section: Layout Modes
                        _buildSectionHeader('LAYOUT ARRANGEMENT'),
                        const SizedBox(height: 8),
                        _buildLayoutModeSelector(),
                        const SizedBox(height: 20),

                        // Section: OLED Longevity & Burn-In Protection
                        _buildSectionHeader('OLED LONGEVITY & PROTECTION'),
                        const SizedBox(height: 8),
                        _buildBurnInProtectionTile(),
                        const SizedBox(height: 10),
                        _buildNightStandbyTile(),
                        const SizedBox(height: 10),
                        _buildAutoNightModeTile(),
                        const SizedBox(height: 20),

                        // Section: Glanceable HUD Elements
                        _buildSectionHeader('GLANCEABLE HUD ELEMENTS'),
                        const SizedBox(height: 8),
                        _buildSwitchTile(
                          title: '24-Hour Time Format',
                          subtitle: 'Display 24h military time instead of 12h AM/PM',
                          icon: Icons.schedule_rounded,
                          value: _config.is24HourFormat,
                          onChanged: (val) {
                            _updateConfig(_config.copyWith(is24HourFormat: val));
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildSwitchTile(
                          title: 'Circadian Solar Slot Badge',
                          subtitle: 'Live indicator for Dawn, Zenith, Golden Hour, Midnight',
                          icon: Icons.wb_twilight_rounded,
                          value: _config.showDateAndSolarSlot,
                          onChanged: (val) {
                            _updateConfig(_config.copyWith(showDateAndSolarSlot: val));
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildSwitchTile(
                          title: 'Battery & Charging Status',
                          subtitle: 'Real-time charging icon and percentage pill',
                          icon: Icons.battery_charging_full_rounded,
                          value: _config.showBatteryPill,
                          onChanged: (val) {
                            _updateConfig(_config.copyWith(showBatteryPill: val));
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildSwitchTile(
                          title: 'Motivational Quote Widget',
                          subtitle: 'Display animated inspirational mantra under clock',
                          icon: Icons.format_quote_rounded,
                          value: _config.showMotivationalQuote,
                          onChanged: (val) {
                            _updateConfig(
                                _config.copyWith(showMotivationalQuote: val));
                          },
                        ),
                        const SizedBox(height: 24),

                        // Reset to Defaults
                        Center(
                          child: TextButton.icon(
                            onPressed: () {
                              context
                                  .read<WallpaperBloc>()
                                  .add(const ResetStandbyDockIntent());
                            },
                            icon: const Icon(
                              Icons.restart_alt_rounded,
                              size: 16,
                              color: Colors.white54,
                            ),
                            label: const Text(
                              'Reset Dock Settings to Default',
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

                  // Bottom Launch Button
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.auroraCyan, AppColors.auroraViolet],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.auroraCyan.withValues(alpha: 0.3),
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
                      onPressed: _launchDock,
                      icon: const Icon(
                        Icons.fullscreen_rounded,
                        color: Colors.black,
                        size: 22,
                      ),
                      label: const Text(
                        'Launch Horizon Desk Dock',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
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
        color: AppColors.auroraCyan.withValues(alpha: 0.8),
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildClockStyleGrid() {
    return Column(
      children: DockClockStyle.values.map((style) {
        final isSelected = _config.clockStyle == style;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: isSelected
                ? AppColors.auroraCyan.withValues(alpha: 0.12)
                : AppColors.cardSurface,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                _updateConfig(_config.copyWith(clockStyle: style));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.auroraCyan
                        : Colors.white.withValues(alpha: 0.08),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      style.icon,
                      color: isSelected
                          ? AppColors.auroraCyan
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
                                  ? AppColors.auroraCyan
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
                        color: AppColors.auroraCyan,
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

  Widget _buildLayoutModeSelector() {
    return Row(
      children: DockLayoutMode.values.map((mode) {
        final isSelected = _config.layoutMode == mode;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Material(
              color: isSelected
                  ? AppColors.auroraViolet.withValues(alpha: 0.15)
                  : AppColors.cardSurface,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  _updateConfig(_config.copyWith(layoutMode: mode));
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.auroraViolet
                          : Colors.white.withValues(alpha: 0.08),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        mode.icon,
                        color: isSelected
                            ? AppColors.auroraViolet
                            : Colors.white70,
                        size: 24,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        mode.displayName,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.auroraViolet
                              : Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
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
    );
  }

  Widget _buildBurnInProtectionTile() {
    return Material(
      color: AppColors.cardSurface,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.auroraEmerald.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.shield_rounded,
                color: AppColors.auroraEmerald,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Anti-Burn-In Subpixel Shift',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Subtly micro-shifts UI elements in orbit to protect AMOLED screens during overnight docking.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: _config.isBurnInProtectionEnabled,
              activeThumbColor: AppColors.auroraEmerald,
              activeTrackColor: AppColors.auroraEmerald.withValues(alpha: 0.35),
              onChanged: (val) {
                _updateConfig(
                    _config.copyWith(isBurnInProtectionEnabled: val));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNightStandbyTile() {
    return Material(
      color: AppColors.cardSurface,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.nightCrimson.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.bedtime_rounded,
                color: AppColors.nightCrimson,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Manual OLED Night Standby',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Ultra-dim pure crimson red (#FF3B30) palette eliminating blue light emission for sleep.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: _config.isNightModeEnabled,
              activeThumbColor: AppColors.nightCrimson,
              activeTrackColor: AppColors.nightCrimson.withValues(alpha: 0.35),
              onChanged: (val) {
                _updateConfig(_config.copyWith(isNightModeEnabled: val));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoNightModeTile() {
    return Material(
      color: AppColors.cardSurface,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.auroraAmber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.timelapse_rounded,
                color: AppColors.auroraAmber,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Circadian Night Schedule',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Automatically shifts to Night Standby between 10:00 PM and 6:00 AM.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: _config.isAutoNightModeEnabled,
              activeThumbColor: AppColors.auroraAmber,
              activeTrackColor: AppColors.auroraAmber.withValues(alpha: 0.35),
              onChanged: (val) {
                _updateConfig(
                    _config.copyWith(isAutoNightModeEnabled: val));
              },
            ),
          ],
        ),
      ),
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
      color: AppColors.cardSurface,
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
              activeThumbColor: AppColors.auroraCyan,
              activeTrackColor: AppColors.auroraCyan.withValues(alpha: 0.35),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
