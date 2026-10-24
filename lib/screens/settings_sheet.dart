import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/wallpaper_bloc.dart';
import '../blocs/wallpaper_intent.dart';
import '../blocs/wallpaper_state.dart';
import '../core/core.dart';
import 'aura_palette_sheet.dart';
import 'aurora_synthesizer_sheet.dart';
import 'auto_rotation_sheet.dart';
import 'battery_telemetry_sheet.dart';
import 'community_exchange_sheet.dart';
import 'data_portability_sheet.dart';
import 'day_night_schedule_sheet.dart';
import 'gesture_control_sheet.dart';
import 'lock_screen_studio_sheet.dart';
import 'onboarding_sheet.dart';
import 'parallax_studio_sheet.dart';
import 'particle_effect_sheet.dart';
import 'preferences_modal_sheet.dart';
import 'standby_dock_sheet.dart';
import 'weather_atmosphere_sheet.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const SettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WallpaperBloc, WallpaperState>(
      builder: (context, state) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.darkSurface,
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
                  const SizedBox(height: 18),

                  // Brand Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.sunsetAmber, AppColors.auroraViolet],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'WALLORA',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'v1.0.0',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.sunsetAmber,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Make every screen yours.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white60,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // SECTION: Storage & Cache Management
                  _buildSectionHeader('STORAGE & OFFLINE CACHE'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
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
                            const Row(
                              children: [
                                Icon(Icons.storage_rounded, color: AppColors.neonCyan, size: 20),
                                SizedBox(width: 10),
                                Text(
                                  'Offline Wallpaper Cache',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              state.storageFormatted,
                              style: const TextStyle(
                                color: AppColors.neonCyan,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${state.downloadedIds.length} wallpapers saved for instant offline rendering without data consumption.',
                          style: const TextStyle(color: Colors.white54, fontSize: 11, height: 1.4),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: state.downloadedIds.isEmpty
                                ? null
                                : () => _confirmClearCache(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: BorderSide(
                                color: state.downloadedIds.isEmpty
                                    ? Colors.white12
                                    : AppColors.error.withValues(alpha: 0.5),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                            label: const Text(
                              'CLEAR OFFLINE CACHE',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // SECTION: Preferences & Onboarding
                  _buildSectionHeader('PERSONALIZATION'),
                  const SizedBox(height: 10),
                  _buildSettingTile(
                    icon: Icons.tune_rounded,
                    iconColor: AppColors.sunsetAmber,
                    title: 'Aesthetic Preferences',
                    subtitle: '${state.userPreferences.length} categories prioritized in feed',
                    onTap: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (ctx) => PreferencesModalSheet(
                          initialPreferences: state.userPreferences,
                          initialTextOverlayEnabled: state.isTextOverlayVisible,
                        ),
                      );
                    },
                  ),
                  _buildSettingTile(
                    icon: Icons.autorenew_rounded,
                    iconColor: AppColors.neonCyan,
                    title: 'Aurora Auto-Rotation',
                    subtitle: state.isAutoRotationEnabled
                        ? 'Active • Every ${state.autoRotationIntervalMinutes >= 60 ? "${state.autoRotationIntervalMinutes ~/ 60}h" : "${state.autoRotationIntervalMinutes}m"}'
                        : 'Off • Automatically change wallpaper',
                    onTap: () {
                      AutoRotationSheet.show(context);
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildSettingTile(
                    icon: Icons.brightness_auto_rounded,
                    iconColor: AppColors.solarGold,
                    title: 'Day & Night Solar Schedule',
                    subtitle: state.dayNightSchedule.isEnabled
                        ? 'Active • Slot: ${state.activeScheduleSlot.label}'
                        : 'Off • Dynamic circadian wallpaper shifts',
                    onTap: () {
                      DayNightScheduleSheet.show(context);
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildSettingTile(
                    icon: Icons.lock_clock_rounded,
                    iconColor: AppColors.auroraViolet,
                    title: 'Lock Screen Clock & Widgets',
                    subtitle: '${state.lockScreenStyle.clockFont.label} • ${state.lockScreenStyle.clockLayout.label}',
                    onTap: () {
                      LockScreenStudioSheet.show(context);
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildSettingTile(
                    icon: Icons.view_in_ar_rounded,
                    iconColor: AppColors.neonCyan,
                    title: '3D Spatial Parallax Studio',
                    subtitle: state.parallaxConfig.isEnabled
                        ? '${state.parallaxConfig.preset.label} (${state.parallaxConfig.sensitivity.toStringAsFixed(1)}x)'
                        : 'Paused / Disabled',
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (ctx) => const ParallaxStudioSheet(),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildSettingTile(
                    icon: Icons.grain_rounded,
                    iconColor: AppColors.neonCyan,
                    title: 'Interactive Particle FX Studio',
                    subtitle: state.particleConfig.isEnabled
                        ? '${state.particleConfig.preset.label} • ${state.particleConfig.particleCount} particles'
                        : 'Paused / Clean Canvas',
                    onTap: () {
                      ParticleEffectSheet.show(context);
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildSettingTile(
                    icon: Icons.palette_rounded,
                    iconColor: AppColors.auroraViolet,
                    title: 'Aura Chromatic Harmonizer',
                    subtitle:
                        '${state.auraConfig.preset.displayName} • Dynamic color sync',
                    onTap: () {
                      AuraPaletteSheet.show(context);
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildSettingTile(
                    icon: Icons.touch_app_rounded,
                    iconColor: AppColors.neonCyan,
                    title: 'Interactive Gesture Controls',
                    subtitle: state.gestureConfig.isGesturesEnabled
                        ? '${state.gestureConfig.doubleTapAction.displayName} • ${state.gestureConfig.hapticProfile.displayName} Haptics'
                        : 'Disabled / Touch Pass-Through',
                    onTap: () {
                      GestureControlSheet.show(context);
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildSettingTile(
                    icon: Icons.desktop_windows_rounded,
                    iconColor: AppColors.neonCyan,
                    title: 'Horizon Standby & Desk Dock Studio',
                    subtitle:
                        '${state.standbyDockConfig.layoutMode.displayName} • ${state.standbyDockConfig.clockStyle.displayName}',
                    onTap: () {
                      StandbyDockSheet.show(context);
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildSettingTile(
                    icon: Icons.waves_rounded,
                    iconColor: AppColors.neonCyan,
                    title: 'Aurora Wave Synthesizer Studio',
                    subtitle:
                        '${state.auroraSynthesizerConfig.waveStyle.displayName} • ${state.auroraSynthesizerConfig.colorMode.displayName}',
                    onTap: () {
                      AuroraSynthesizerSheet.show(context);
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildSettingTile(
                    icon: Icons.hub_rounded,
                    iconColor: AppColors.neonCyan,
                    title: 'Community Blueprint Showcase & Exchange',
                    subtitle:
                        '${state.communityBlueprints.length} blueprints • Explore, like & publish complete aesthetics',
                    onTap: () {
                      CommunityExchangeSheet.show(context);
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildSettingTile(
                    icon: Icons.cloud_sync_rounded,
                    iconColor: AppColors.neonCyan,
                    title: 'Atmospheric Weather & Climate FX Studio',
                    subtitle: state.weatherConfig.isEnabled
                        ? '${state.weatherConfig.effectType.displayName} • Gyro & lightning active'
                        : 'Clean Canvas • Procedural rain, snow & starfall',
                    onTap: () {
                      WeatherAtmosphereSheet.show(context);
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildSettingTile(
                    icon: Icons.auto_awesome_motion_rounded,
                    iconColor: AppColors.auroraViolet,
                    title: 'Replay Onboarding Tour',
                    subtitle: 'Re-run the first-time setup experience & intro',
                    onTap: () {
                      if (context.mounted && Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                      OnboardingSheet.show(context);
                    },
                  ),

                  const SizedBox(height: 24),

                  // SECTION: Device Engine & Trust
                  _buildSectionHeader('BATTERY & HARDWARE INTEGRITY'),
                  const SizedBox(height: 10),
                  _buildSettingTile(
                    icon: Icons.bolt_rounded,
                    iconColor: AppColors.auroraEmerald,
                    title: 'Battery & Display Hub',
                    subtitle:
                        '${state.batteryTelemetry.targetFps.displayName} • ${state.batteryTelemetry.isEcoModeEnabled ? "Adaptive Eco Active" : "Full Performance"}',
                    onTap: () {
                      BatteryTelemetrySheet.show(context);
                    },
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.auroraEmerald.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.energy_savings_leaf_rounded,
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
                                    'AMOLED True-Black Mode',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    state.isAmoledSaverModeEnabled
                                        ? 'Active • Pure black (#000000) pixels shut off OLED diodes'
                                        : 'Standard • Dynamic color depth enabled',
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              value: state.isAmoledSaverModeEnabled,
                              activeThumbColor: AppColors.auroraEmerald,
                              activeTrackColor: AppColors.auroraEmerald.withValues(alpha: 0.35),
                              onChanged: (val) {
                                HapticFeedback.selectionClick();
                                context.read<WallpaperBloc>().add(
                                      const ToggleAmoledSaverModeIntent(),
                                    );
                              },
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white10, height: 20),
                        _buildStatusRow(
                          title: 'Live Engine Status',
                          value: state.isLiveWallpaperActiveOnDevice ? 'ACTIVE' : 'STANDBY',
                          valueColor: state.isLiveWallpaperActiveOnDevice
                              ? AppColors.auroraEmerald
                              : Colors.white54,
                        ),
                        const Divider(color: Colors.white10, height: 20),
                        _buildStatusRow(
                          title: 'Sleep Power Consumption',
                          value: '0% (Decoders Paused)',
                          valueColor: AppColors.auroraEmerald,
                        ),
                        const Divider(color: Colors.white10, height: 20),
                        _buildStatusRow(
                          title: 'OLED Sub-Pixel Power',
                          value: state.isAmoledSaverModeEnabled ? 'OPTIMIZED (Zero Draw)' : 'STANDARD',
                          valueColor: state.isAmoledSaverModeEnabled
                              ? AppColors.auroraEmerald
                              : Colors.white54,
                        ),
                        const Divider(color: Colors.white10, height: 20),
                        _buildStatusRow(
                          title: 'Local Privacy',
                          value: '100% On-Device',
                          valueColor: AppColors.neonCyan,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // SECTION: Data Portability & Backup
                  _buildSectionHeader('DATA PORTABILITY & BACKUP'),
                  const SizedBox(height: 10),
                  _buildSettingTile(
                    icon: Icons.cloud_sync_rounded,
                    iconColor: AppColors.neonCyan,
                    title: 'Data Portability & Backup Hub',
                    subtitle: 'Export, restore & manage playlists, quotes & setups',
                    onTap: () {
                      DataPortabilitySheet.show(context);
                    },
                  ),

                  const SizedBox(height: 24),

                  // SECTION: Legal & About
                  _buildSectionHeader('ABOUT & ATTRIBUTION'),
                  const SizedBox(height: 10),
                  _buildSettingTile(
                    icon: Icons.privacy_tip_outlined,
                    iconColor: AppColors.neonCyan,
                    title: 'Privacy Policy',
                    subtitle: 'Wallora does not collect or transmit personal identifying data',
                    onTap: () => _showPrivacyDialog(context),
                  ),
                  const SizedBox(height: 8),
                  _buildSettingTile(
                    icon: Icons.verified_outlined,
                    iconColor: AppColors.solarGold,
                    title: 'Content & Licensing Guarantee',
                    subtitle: 'All assets are licensed or curated for personalization',
                    onTap: () => _showLicensingDialog(context),
                  ),

                  const SizedBox(height: 30),
                  const Center(
                    child: Text(
                      'Wallora • Crafted for fluid beauty & zero battery compromise',
                      style: TextStyle(color: Colors.white30, fontSize: 11),
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: Colors.white54,
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.cardSurface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
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
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow({
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _confirmClearCache(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.modalBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Clear Offline Cache?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will delete all locally cached wallpaper files to free disk space. You can re-download them anytime.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (ctx.mounted && Navigator.of(ctx).canPop()) {
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              if (ctx.mounted && Navigator.of(ctx).canPop()) {
                Navigator.of(ctx).pop();
              }
              context.read<WallpaperBloc>().add(ClearAllDownloadsIntent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear Cache'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.modalBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Privacy & Security', style: TextStyle(color: Colors.white)),
        content: const SingleChildScrollView(
          child: Text(
            'Wallora is built on the principle of minimal footprint and zero invasive telemetry.\n\n'
            '• All favorites, downloads, and custom quote customizations remain stored locally on your device.\n'
            '• No microphone, contacts, location, or background surveillance permissions are ever requested.\n'
            '• Android Live Wallpaper rendering runs strictly via the official Android WallpaperService framework.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (ctx.mounted && Navigator.of(ctx).canPop()) {
                Navigator.of(ctx).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sunsetAmber,
              foregroundColor: Colors.white,
            ),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  void _showLicensingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.modalBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Content Integrity & Attribution', style: TextStyle(color: Colors.white)),
        content: const SingleChildScrollView(
          child: Text(
            'Wallora curates high-fidelity visual media designed specifically for smartphone display personalization.\n\n'
            '• If you believe any asset infringes upon your copyright or intellectual property, tap the flag icon on any wallpaper card to immediately submit a takedown report.\n'
            '• We adhere strictly to digital copyright compliance and respect artist rights.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (ctx.mounted && Navigator.of(ctx).canPop()) {
                Navigator.of(ctx).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sunsetAmber,
              foregroundColor: Colors.white,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
