import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/wallpaper_bloc.dart';
import '../blocs/wallpaper_intent.dart';
import '../blocs/wallpaper_state.dart';
import '../models/lock_screen_style_config.dart';
import '../models/motivational_short.dart';
import '../widgets/interactive_particle_overlay.dart';
import '../widgets/video_player_item.dart';
import '../widgets/weather_atmosphere_canvas.dart';
import 'aura_palette_sheet.dart';
import 'battery_telemetry_sheet.dart';
import 'ipad_wallpaper_dialog.dart';
import 'lock_screen_studio_sheet.dart';
import 'parallax_studio_sheet.dart';
import 'particle_effect_sheet.dart';
import 'wallpaper_effects_sheet.dart';
import 'wallpaper_export_sheet.dart';
import 'weather_atmosphere_sheet.dart';

enum ScreenSimulationMode {
  clean('Clean View', Icons.visibility_rounded),
  lockScreen('Lock Screen', Icons.lock_outline_rounded),
  homeScreen('Home Screen', Icons.grid_view_rounded);

  final String label;
  final IconData icon;
  const ScreenSimulationMode(this.label, this.icon);
}

/// Fullscreen Immersive Wallpaper Viewer & Screen Simulator.
///
/// Features:
/// - Edge-to-edge immersive view of live and static wallpapers
/// - Horizontal swipe navigation between wallpapers
/// - Interactive simulated Lock Screen overlay (clock, date, flashlight, camera)
/// - Interactive simulated Home Screen overlay (frosted app icons, dock, search bar)
/// - Tap anywhere to toggle UI chrome for pure visual enjoyment
/// - Direct Apply (Home, Lock, Both), Favorite, and specs inspection
class FullScreenWallpaperViewer extends StatefulWidget {
  final List<MotivationalShort> wallpapers;
  final int initialIndex;

  const FullScreenWallpaperViewer({
    super.key,
    required this.wallpapers,
    this.initialIndex = 0,
  });

  static Future<void> open(
    BuildContext context, {
    required MotivationalShort wallpaper,
    List<MotivationalShort>? playlist,
  }) {
    final list = playlist != null && playlist.isNotEmpty
        ? playlist
        : [wallpaper];
    final index = list.indexWhere((w) => w.id == wallpaper.id);

    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FullScreenWallpaperViewer(
            wallpapers: list,
            initialIndex: index >= 0 ? index : 0,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  State<FullScreenWallpaperViewer> createState() =>
      _FullScreenWallpaperViewerState();
}

class _FullScreenWallpaperViewerState extends State<FullScreenWallpaperViewer> {
  late PageController _pageController;
  late int _currentIndex;
  bool _isUiVisible = true;
  ScreenSimulationMode _simulationMode = ScreenSimulationMode.clean;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleUi() {
    setState(() {
      _isUiVisible = !_isUiVisible;
    });
  }

  void _showApplyTargetSelector(BuildContext context, MotivationalShort short) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Material(
        color: const Color(0xFF16161A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'APPLY WALLPAPER DESTINATION',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              short.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: short.accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.phone_android_rounded, color: short.accentColor),
              ),
              title: const Text('Home Screen & Lock Screen (Recommended)',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Set on both screens simultaneously',
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
              onTap: () {
                Navigator.of(ctx).pop();
                _applyWallpaper(short, 'both');
              },
            ),
            const Divider(color: Colors.white10),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.home_rounded, color: Colors.white70),
              ),
              title: const Text('Home Screen Only',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Keeps your current lock screen untouched',
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
              onTap: () {
                Navigator.of(ctx).pop();
                _applyWallpaper(short, 'home');
              },
            ),
            const Divider(color: Colors.white10),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.lock_rounded, color: Colors.white70),
              ),
              title: const Text('Lock Screen Only',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Display this aesthetic on wake and lock',
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
              onTap: () {
                Navigator.of(ctx).pop();
                _applyWallpaper(short, 'lock');
              },
            ),
          ],
        ),
      ),
    ),
  );
  }

  void _applyWallpaper(MotivationalShort short, String target) {
    if (Platform.isIOS) {
      IPadWallpaperDialog.show(context, short);
      return;
    }

    final bloc = context.read<WallpaperBloc>();
    if (short.isLive) {
      bloc.add(ApplyLiveWallpaperIntent(short: short, isMuted: true));
    } else {
      bloc.add(ApplyStaticWallpaperIntent(
        short: short,
        targetScreen: target,
        customQuote: short.hasTextByDefault ? short.quote : null,
      ));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Applying "${short.title}" to $target screen...'),
        backgroundColor: const Color(0xFF222226),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentShort = widget.wallpapers[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleUi,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // PageView Canvas Carousel
            PageView.builder(
              controller: _pageController,
              itemCount: widget.wallpapers.length,
              onPageChanged: (index) {
                HapticFeedback.selectionClick();
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final short = widget.wallpapers[index];
                return _buildWallpaperCanvas(short);
              },
            ),

            // Simulated Screen Overlay Layer
            if (_simulationMode == ScreenSimulationMode.lockScreen)
              _buildLockScreenOverlay(currentShort)
            else if (_simulationMode == ScreenSimulationMode.homeScreen)
              _buildHomeScreenOverlay(currentShort),

            // Top Control Bar (Animated with UI visibility)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              top: _isUiVisible ? 0 : -120,
              left: 0,
              right: 0,
              child: _buildTopControlBar(currentShort),
            ),

            // Bottom Control Dock (Animated with UI visibility)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              bottom: _isUiVisible ? 0 : -140,
              left: 0,
              right: 0,
              child: _buildBottomControlDock(currentShort),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWallpaperCanvas(MotivationalShort short) {
    return BlocBuilder<WallpaperBloc, WallpaperState>(
      builder: (context, state) {
        final effects = state.getEffectiveEffects(short.id);
        ColorFilter? colorFilter;
        switch (effects.colorFilterPreset) {
          case 'noir':
            colorFilter = const ColorFilter.mode(Colors.black, BlendMode.saturation);
            break;
          case 'cyber_cyan':
            colorFilter = ColorFilter.mode(
                const Color(0xFF00E5FF).withValues(alpha: 0.35), BlendMode.color);
            break;
          case 'sunset_amber':
            colorFilter = ColorFilter.mode(
                const Color(0xFFFF5722).withValues(alpha: 0.35), BlendMode.color);
            break;
          case 'matrix_emerald':
            colorFilter = ColorFilter.mode(
                const Color(0xFF00E676).withValues(alpha: 0.35), BlendMode.color);
            break;
          case 'aurora_violet':
            colorFilter = ColorFilter.mode(
                const Color(0xFFD500F9).withValues(alpha: 0.35), BlendMode.color);
            break;
          default:
            colorFilter = null;
        }

        Widget canvas;
        if (short.isLive) {
          canvas = VideoPlayerItem(
            key: ValueKey('fullscreen_${short.id}'),
            videoAssetPath: short.videoAssetPath,
            isActive: true,
            isMuted: true,
            onDoubleTapLike: () {
              context.read<WallpaperBloc>().add(ToggleFavoriteIntent(short.id));
            },
          );
        } else {
          canvas = Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: short.gradientColors.isNotEmpty
                    ? short.gradientColors
                    : [
                        short.accentColor.withValues(alpha: 0.45),
                        Colors.black,
                      ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.wallpaper_rounded,
                size: 96,
                color: short.accentColor.withValues(alpha: 0.5),
              ),
            ),
          );
        }

        if (colorFilter != null) {
          canvas = ColorFiltered(colorFilter: colorFilter, child: canvas);
        }

        if (effects.vignetteStrength > 0.0) {
          canvas = Stack(
            fit: StackFit.expand,
            children: [
              canvas,
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.0,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(
                          alpha: (effects.vignetteStrength * 0.75).clamp(0.0, 0.95)),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        if (state.particleConfig.isEnabled) {
          canvas = InteractiveParticleOverlay(
            config: state.particleConfig,
            child: canvas,
          );
        }

        if (state.weatherConfig.isEnabled) {
          canvas = WeatherAtmosphereCanvas(
            config: state.weatherConfig,
            child: canvas,
          );
        }

        return canvas;
      },
    );
  }

  Widget _buildTopControlBar(MotivationalShort short) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, MediaQuery.of(context).padding.top + 8, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.85),
            Colors.black.withValues(alpha: 0.4),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),

          // Simulation Mode Segmented Toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: ScreenSimulationMode.values.map((mode) {
                final isSelected = _simulationMode == mode;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _simulationMode = mode);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? short.accentColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          mode.icon,
                          size: 14,
                          color: isSelected ? Colors.black : Colors.white70,
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 4),
                          Text(
                            mode.label,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Counter Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Text(
              '${_currentIndex + 1}/${widget.wallpapers.length}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControlDock(MotivationalShort short) {
    return BlocBuilder<WallpaperBloc, WallpaperState>(
      builder: (context, state) {
        final isFav = state.favoriteIds.contains(short.id);

        return Container(
          padding: EdgeInsets.fromLTRB(
              20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withValues(alpha: 0.9),
                Colors.black.withValues(alpha: 0.5),
                Colors.transparent,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Info Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          short.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${short.category} • ${short.resolution}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            BatteryTelemetrySheet.show(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E676)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFF00E676)
                                    .withValues(alpha: 0.3),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.bolt_rounded,
                                    size: 11, color: Color(0xFF00E676)),
                                const SizedBox(width: 3),
                                Text(
                                  '${state.batteryTelemetry.calculateHourlyDrainPercent(short)}%/hr • ${state.batteryTelemetry.targetFps.fps > 0 ? "${state.batteryTelemetry.targetFps.fps} FPS" : "Auto FPS"}',
                                  style: const TextStyle(
                                    color: Color(0xFF00E676),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      // Favorite Button
                      IconButton(
                        icon: Icon(
                          isFav
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFav
                              ? const Color(0xFFFF1744)
                              : Colors.white,
                        ),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          context
                              .read<WallpaperBloc>()
                              .add(ToggleFavoriteIntent(short.id));
                        },
                      ),
                      const SizedBox(width: 4),
                      // Download Button
                      IconButton(
                        icon: Icon(
                          state.downloadedIds.contains(short.id)
                              ? Icons.check_circle_rounded
                              : Icons.download_rounded,
                          color: state.downloadedIds.contains(short.id)
                              ? const Color(0xFF00E676)
                              : Colors.white,
                        ),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          context
                              .read<WallpaperBloc>()
                              .add(DownloadWallpaperIntent(short));
                        },
                      ),
                      const SizedBox(width: 4),
                      // Visual Effects Studio Button
                      IconButton(
                        icon: const Icon(Icons.tune_rounded, color: Color(0xFF00E5FF)),
                        tooltip: 'Visual Effects Studio',
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          WallpaperEffectsSheet.show(context, short);
                        },
                      ),
                      const SizedBox(width: 4),
                      // Export Story Poster Button
                      IconButton(
                        icon: const Icon(Icons.ios_share_rounded, color: Color(0xFFFF5722)),
                        tooltip: 'Export Story Poster',
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          WallpaperExportSheet.show(context, short);
                        },
                      ),
                      const SizedBox(width: 4),
                      // Lock Screen Studio Button
                      IconButton(
                        icon: const Icon(Icons.lock_clock_rounded, color: Color(0xFFD500F9)),
                        tooltip: 'Lock Screen Studio',
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          LockScreenStudioSheet.show(context, wallpaper: short);
                        },
                      ),
                      const SizedBox(width: 4),
                      // 3D Spatial Parallax Studio Button
                      IconButton(
                        icon: const Icon(Icons.view_in_ar_rounded, color: Color(0xFF00E5FF)),
                        tooltip: '3D Spatial Parallax Studio',
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (ctx) => ParallaxStudioSheet(wallpaper: short),
                          );
                        },
                      ),
                      const SizedBox(width: 4),
                      // Interactive Particle FX Studio Button
                      IconButton(
                        icon: const Icon(Icons.grain_rounded, color: Color(0xFF00E676)),
                        tooltip: 'Interactive Particle FX',
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          ParticleEffectSheet.show(context, wallpaper: short);
                        },
                      ),
                      const SizedBox(width: 4),
                      // Aura Chromatic Harmonizer Button
                      IconButton(
                        icon: const Icon(Icons.palette_rounded, color: Color(0xFFD500F9)),
                        tooltip: 'Aura Chromatic Harmonizer',
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          AuraPaletteSheet.show(context);
                        },
                      ),
                      const SizedBox(width: 4),
                      // Atmospheric Weather & Climate FX Studio Button
                      IconButton(
                        icon: const Icon(Icons.cloud_sync_rounded, color: Color(0xFF00E5FF)),
                        tooltip: 'Atmospheric Weather Studio',
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          WeatherAtmosphereSheet.show(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Apply Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    _showApplyTargetSelector(context, short);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: short.accentColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                  ),
                  icon: const Icon(Icons.wallpaper_rounded, size: 20),
                  label: const Text(
                    'APPLY TO DEVICE',
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
  }

  Widget _buildLockScreenOverlay(MotivationalShort short) {
    final topPadding = MediaQuery.of(context).padding.top;

    return BlocBuilder<WallpaperBloc, WallpaperState>(
      builder: (context, state) {
        final style = state.lockScreenStyle;
        final effectiveColor = style.resolveClockColor(short.accentColor);
        final clockTextStyle = style.resolveClockTextStyle(effectiveColor);

        return IgnorePointer(
          child: Container(
            color: Colors.black.withValues(alpha: 0.15),
            padding: EdgeInsets.fromLTRB(24, topPadding + 16, 24, 24),
            child: Column(
              children: [
                // Status bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '09:41',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: const [
                        Icon(Icons.wifi_rounded, color: Colors.white, size: 14),
                        SizedBox(width: 6),
                        Icon(Icons.battery_full_rounded, color: Colors.white, size: 14),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 36),

                // Date
                if (style.showDate) ...[
                  const Text(
                    'Sunday, October 18',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                      shadows: [
                        Shadow(color: Colors.black87, blurRadius: 10),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                ],

                // Dynamic Clock Typography
                if (style.clockLayout == LockScreenClockLayout.stacked)
                  Column(
                    children: [
                      Text('09', style: clockTextStyle),
                      Text('41', style: clockTextStyle),
                    ],
                  )
                else if (style.clockLayout == LockScreenClockLayout.compact)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: effectiveColor.withValues(alpha: 0.4),
                          width: 1.0),
                    ),
                    child: Text(
                      '09:41 AM',
                      style: clockTextStyle.copyWith(
                          fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  )
                else
                  Text('09:41', style: clockTextStyle),

                const Spacer(),

                // Dynamic Glanceable Widget Capsule
                _buildLockScreenWidgetCapsule(style, short, state),

                // Bottom Shortcuts (Torch & Camera)
                if (style.showShortcuts)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(Icons.flashlight_on_rounded,
                            color: Colors.white, size: 22),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text(
                          'Swipe up to unlock',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            color: Colors.white, size: 22),
                      ),
                    ],
                  ),

                const SizedBox(height: 12),

                // Home Indicator Bar
                Center(
                  child: Container(
                    width: 120,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(2),
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

  Widget _buildLockScreenWidgetCapsule(
    LockScreenStyleConfig style,
    MotivationalShort short,
    WallpaperState state,
  ) {
    switch (style.widgetType) {
      case LockScreenWidgetType.circadianSlot:
        final slot = state.activeScheduleSlot;
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: slot.accentColor.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(slot.icon, color: slot.accentColor, size: 16),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Solar Slot: ${slot.label}',
                  style: TextStyle(
                    color: slot.accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        );
      case LockScreenWidgetType.quotePill:
        final quote = state.getEffectiveQuote(short);
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: short.accentColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.auto_awesome_rounded,
                    color: short.accentColor, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  quote,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      case LockScreenWidgetType.batteryGlance:
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: const Color(0xFF00E676).withValues(alpha: 0.4)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bolt_rounded, color: Color(0xFF00E676), size: 16),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  '98% • Ultra-Fast Charging • AMOLED Saver Active',
                  style: TextStyle(
                    color: Color(0xFF00E676),
                    fontSize: 12,
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
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: const Color(0xFFFFD600).withValues(alpha: 0.4)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wb_sunny_rounded, color: Color(0xFFFFD600), size: 16),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  '72°F • Luminous Clear Sky',
                  style: TextStyle(
                    color: Color(0xFFFFD600),
                    fontSize: 12,
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

  Widget _buildHomeScreenOverlay(MotivationalShort short) {
    final topPadding = MediaQuery.of(context).padding.top;

    return IgnorePointer(
      child: Container(
        color: Colors.black.withValues(alpha: 0.1),
        padding: EdgeInsets.fromLTRB(24, topPadding + 16, 24, 24),
        child: Column(
          children: [
            // Status bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '09:41',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: const [
                    Icon(Icons.wifi_rounded, color: Colors.white, size: 14),
                    SizedBox(width: 6),
                    Icon(Icons.battery_full_rounded, color: Colors.white, size: 14),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Search Bar Capsule
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white30),
              ),
              child: Row(
                children: const [
                  Icon(Icons.search_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 10),
                  Text(
                    'Search apps, contacts, web...',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  Spacer(),
                  Icon(Icons.mic_rounded, color: Colors.white, size: 18),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // App Icons Grid (4x3)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 24,
              crossAxisSpacing: 16,
              children: [
                _buildAppIcon(Icons.phone_rounded, 'Phone', const Color(0xFF00E676)),
                _buildAppIcon(Icons.chat_bubble_rounded, 'Messages', const Color(0xFF2979FF)),
                _buildAppIcon(Icons.camera_alt_rounded, 'Camera', const Color(0xFF424242)),
                _buildAppIcon(Icons.language_rounded, 'Browser', const Color(0xFFFF9100)),
                _buildAppIcon(Icons.music_note_rounded, 'Music', const Color(0xFFFF1744)),
                _buildAppIcon(Icons.photo_library_rounded, 'Photos', const Color(0xFFD500F9)),
                _buildAppIcon(Icons.settings_rounded, 'Settings', const Color(0xFF78909C)),
                _buildAppIcon(Icons.auto_awesome_rounded, 'Wallora', short.accentColor),
              ],
            ),

            const Spacer(),

            // Frosted Bottom Dock Container
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDockIcon(Icons.phone_rounded, const Color(0xFF00E676)),
                  _buildDockIcon(Icons.chat_bubble_rounded, const Color(0xFF2979FF)),
                  _buildDockIcon(Icons.language_rounded, const Color(0xFFFF9100)),
                  _buildDockIcon(Icons.camera_alt_rounded, const Color(0xFF424242)),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Home Indicator Bar
            Center(
              child: Container(
                width: 120,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppIcon(IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(color: Colors.black87, blurRadius: 4),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDockIcon(IconData icon, Color color) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }
}
