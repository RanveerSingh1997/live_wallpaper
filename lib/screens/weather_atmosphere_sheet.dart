import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/wallpaper_bloc.dart';
import '../blocs/wallpaper_intent.dart';
import '../blocs/wallpaper_state.dart';
import '../core/core.dart';
import '../models/weather_atmosphere_config.dart';
import '../widgets/weather_atmosphere_canvas.dart';

/// Modal studio sheet allowing users to configure real-time atmospheric
/// weather and climate visual effects (cyberpunk rain, cosmic snow, neon thunderstorm,
/// solar god rays, ethereal nebula mist, and meteor starfall showers).
class WeatherAtmosphereSheet extends StatefulWidget {
  const WeatherAtmosphereSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const WeatherAtmosphereSheet(),
    );
  }

  @override
  State<WeatherAtmosphereSheet> createState() => _WeatherAtmosphereSheetState();
}

class _WeatherAtmosphereSheetState extends State<WeatherAtmosphereSheet> {
  late WeatherAtmosphereConfig _config;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<WallpaperBloc>();
    _config = bloc.state.weatherConfig;
  }

  void _safePop() {
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _updateConfig(WeatherAtmosphereConfig newConfig) {
    setState(() {
      _config = newConfig;
    });
    context.read<WallpaperBloc>().add(UpdateWeatherAtmosphereIntent(newConfig));
  }

  void _applyPreset(WeatherEffectType type) {
    HapticFeedback.lightImpact();
    WeatherAtmosphereConfig presetConfig;
    switch (type) {
      case WeatherEffectType.none:
        presetConfig = _config.copyWith(effectType: WeatherEffectType.none);
        break;
      case WeatherEffectType.cyberRain:
        presetConfig = WeatherAtmosphereConfig.cyberRainPreset;
        break;
      case WeatherEffectType.cosmicSnow:
        presetConfig = WeatherAtmosphereConfig.cosmicSnowPreset;
        break;
      case WeatherEffectType.thunderstorm:
        presetConfig = WeatherAtmosphereConfig.thunderstormPreset;
        break;
      case WeatherEffectType.solarSunbeams:
        presetConfig = WeatherAtmosphereConfig.solarSunbeamsPreset;
        break;
      case WeatherEffectType.etherealMist:
        presetConfig = WeatherAtmosphereConfig.etherealMistPreset;
        break;
      case WeatherEffectType.meteorShower:
        presetConfig = WeatherAtmosphereConfig.meteorShowerPreset;
        break;
    }
    _updateConfig(presetConfig);
  }

  void _resetToDefaults() {
    HapticFeedback.mediumImpact();
    _updateConfig(WeatherAtmosphereConfig.defaultConfig);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.restore_rounded, color: AppColors.auroraCyan),
            SizedBox(width: 10),
            Text('Weather Atmosphere FX restored to defaults.'),
          ],
        ),
        backgroundColor: AppColors.surfaceMedium,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.92,
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: AppColors.cardHighlight, width: 1.5),
          left: BorderSide(color: AppColors.cardHighlight, width: 1.0),
          right: BorderSide(color: AppColors.cardHighlight, width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black87,
            blurRadius: 30,
            spreadRadius: 10,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.auroraCyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.auroraCyan.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.cloud_sync_rounded,
                    color: AppColors.auroraCyan,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Atmospheric Weather Studio',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        'Dynamic particle overlays & gyroscopic tilt',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _safePop,
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  tooltip: 'Close Studio',
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.cardHighlight, height: 1),

          // Scrollable body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                // Live 16:9 interactive canvas preview
                _buildLivePreviewCard(context),

                const SizedBox(height: 24),

                // Presets Title
                const Text(
                  'WEATHER EFFECT PRESETS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppColors.auroraCyan,
                  ),
                ),
                const SizedBox(height: 12),

                // Preset Cards Grid
                _buildPresetCardsGrid(),

                const SizedBox(height: 24),

                // Sliders Section
                if (_config.isEnabled) ...[
                  const Text(
                    'CLIMATE DYNAMICS & VELOCITY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AppColors.auroraViolet,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildSliderCard(
                    title: 'Particle Density (Intensity)',
                    subtitle: 'Controls particle volume and storm coverage',
                    value: _config.intensity,
                    min: 0.1,
                    max: 1.0,
                    divisions: 18,
                    displayValue: '${(_config.intensity * 100).toInt()}%',
                    activeColor: AppColors.auroraCyan,
                    onChanged: (val) {
                      _updateConfig(_config.copyWith(intensity: val));
                    },
                  ),
                  const SizedBox(height: 10),

                  _buildSliderCard(
                    title: 'Fall Velocity & Speed',
                    subtitle: 'Rate of precipitation and particle travel',
                    value: _config.speedMultiplier,
                    min: 0.3,
                    max: 2.5,
                    divisions: 22,
                    displayValue: '${_config.speedMultiplier.toStringAsFixed(1)}x',
                    activeColor: AppColors.auroraViolet,
                    onChanged: (val) {
                      _updateConfig(_config.copyWith(speedMultiplier: val));
                    },
                  ),
                  const SizedBox(height: 10),

                  _buildSliderCard(
                    title: 'Wind Slant Angle',
                    subtitle: 'Angle of trajectory and atmospheric drift',
                    value: _config.windAngleDegrees,
                    min: 20.0,
                    max: 90.0,
                    divisions: 14,
                    displayValue: '${_config.windAngleDegrees.toInt()}°',
                    activeColor: AppColors.auroraAmber,
                    onChanged: (val) {
                      _updateConfig(_config.copyWith(windAngleDegrees: val));
                    },
                  ),

                  const SizedBox(height: 24),

                  // Hardware & Environmental Toggles
                  const Text(
                    'HARDWARE SENSORS & BATTERY GUARD',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AppColors.auroraEmerald,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildToggleCard(
                    icon: Icons.screen_rotation_rounded,
                    title: 'Gyroscopic Tilt Adaptation',
                    subtitle: 'Particles slant organically with phone orientation',
                    value: _config.isGyroTiltEnabled,
                    accentColor: AppColors.auroraCyan,
                    onChanged: (val) {
                      _updateConfig(_config.copyWith(isGyroTiltEnabled: val));
                    },
                  ),
                  const SizedBox(height: 10),

                  _buildToggleCard(
                    icon: Icons.flash_on_rounded,
                    title: 'Lightning & Luminous Bursts',
                    subtitle: 'Periodic high-contrast aurora flash illuminations',
                    value: _config.isLightningEnabled,
                    accentColor: AppColors.auroraViolet,
                    onChanged: (val) {
                      _updateConfig(_config.copyWith(isLightningEnabled: val));
                    },
                  ),
                  const SizedBox(height: 10),

                  _buildToggleCard(
                    icon: Icons.battery_charging_full_rounded,
                    title: 'Zero Sleep Overhead & Battery Guard',
                    subtitle: 'Clamps particles and sleeps completely when display off',
                    value: _config.isBatteryGuardEnabled,
                    accentColor: AppColors.auroraEmerald,
                    onChanged: (val) {
                      _updateConfig(_config.copyWith(isBatteryGuardEnabled: val));
                    },
                  ),

                  const SizedBox(height: 28),
                ],

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _resetToDefaults,
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Reset Defaults'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          side: const BorderSide(color: AppColors.cardHighlight),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: const LinearGradient(
                            colors: [AppColors.auroraCyan, AppColors.auroraViolet],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.auroraCyan.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _safePop();
                          },
                          icon: const Icon(Icons.check_rounded, color: Colors.black, size: 18),
                          label: const Text(
                            'Apply to Live Canvas',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLivePreviewCard(BuildContext context) {
    return BlocBuilder<WallpaperBloc, WallpaperState>(
      builder: (context, state) {
        final current = state.currentShort;
        final previewTitle = current?.title ?? 'Wallora Preview';

        return Container(
          height: 210,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _config.isEnabled
                  ? _config.effectType.accentColor.withValues(alpha: 0.4)
                  : AppColors.cardHighlight,
              width: 1.5,
            ),
            boxShadow: [
              if (_config.isEnabled)
                BoxShadow(
                  color: _config.effectType.accentColor.withValues(alpha: 0.15),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background gradient mimicking active wallpaper
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: current?.gradientColors ?? const [
                      AppColors.darkSurface,
                      AppColors.darkBackground,
                      AppColors.obsidianBlack,
                    ],
                  ),
                ),
              ),

              // Decorative wallpaper silhouette
              Center(
                child: Opacity(
                  opacity: 0.25,
                  child: Icon(
                    Icons.landscape_rounded,
                    size: 90,
                    color: _config.effectType.accentColor,
                  ),
                ),
              ),

              // Active Weather Atmosphere Dynamic FX Canvas
              WeatherAtmosphereCanvas(
                config: _config,
                child: const SizedBox.expand(),
              ),

              // Top preview overlay info pill
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _config.effectType.accentColor.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _config.effectType.icon,
                            color: _config.effectType.accentColor,
                            size: 13,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _config.effectType.displayName,
                            style: TextStyle(
                              color: _config.effectType.accentColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _config.isBatteryGuardEnabled
                                ? Icons.energy_savings_leaf_rounded
                                : Icons.bolt_rounded,
                            color: AppColors.auroraEmerald,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _config.isBatteryGuardEnabled ? 'Eco 60Hz' : 'Max FX',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom label showing current wallpaper context
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Text(
                  previewTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPresetCardsGrid() {
    return Column(
      children: WeatherEffectType.values.map((type) {
        final isSelected = _config.effectType == type;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Material(
            color: isSelected
                ? type.accentColor.withValues(alpha: 0.12)
                : AppColors.cardSurface,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: () => _applyPreset(type),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? type.accentColor.withValues(alpha: 0.6)
                        : AppColors.surfaceMedium,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: type.accentColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        type.icon,
                        color: type.accentColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            type.label,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontSize: 14,
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            type.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isSelected ? Colors.white60 : Colors.white38,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle_rounded,
                        color: type.accentColor,
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

  Widget _buildSliderCard({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String displayValue,
    required Color activeColor,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: activeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  displayValue,
                  style: TextStyle(
                    color: activeColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: activeColor,
              inactiveTrackColor: AppColors.cardHighlight,
              thumbColor: activeColor,
              overlayColor: activeColor.withValues(alpha: 0.2),
              trackHeight: 3.5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.5),
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

  Widget _buildToggleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Color accentColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceMedium),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 20),
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
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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
          Switch.adaptive(
            value: value,
            activeThumbColor: accentColor,
            activeTrackColor: accentColor.withValues(alpha: 0.35),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
