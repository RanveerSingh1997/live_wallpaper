import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/wallpaper_bloc.dart';
import '../blocs/wallpaper_intent.dart';
import '../blocs/wallpaper_state.dart';
import '../core/core.dart';
import '../models/standby_dock_config.dart';
import '../widgets/interactive_gesture_canvas.dart';
import 'standby_dock_sheet.dart';

/// Fullscreen Horizon Standby & Ambient Desk Dock display.
/// Transforms the device into a modern desk clock, nightstand charging hub,
/// or ambient focus companion with OLED anti-burn-in micro-shifting and circadian night mode.
class StandbyDockScreen extends StatefulWidget {
  final DateTime? fixedTime;

  const StandbyDockScreen({
    super.key,
    this.fixedTime,
  });

  @override
  State<StandbyDockScreen> createState() => _StandbyDockScreenState();
}

class _StandbyDockScreenState extends State<StandbyDockScreen> {
  late DateTime _currentTime;
  Timer? _ticker;
  Timer? _overlayHideTimer;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _currentTime = widget.fixedTime ?? DateTime.now();
    if (widget.fixedTime == null) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _currentTime = DateTime.now();
          });
        }
      });
      _scheduleControlsAutoHide();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _overlayHideTimer?.cancel();
    super.dispose();
  }

  void _scheduleControlsAutoHide() {
    _overlayHideTimer?.cancel();
    _overlayHideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _onScreenTapped() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _scheduleControlsAutoHide();
    }
  }

  /// Calculates a subtle micro-shift offset to eliminate OLED static burn-in.
  Offset _computeBurnInOffset(bool isEnabled) {
    if (!isEnabled) return Offset.zero;
    final cycle = (_currentTime.minute * 60 + _currentTime.second) / 3600.0 * 2 * math.pi;
    return Offset(
      math.cos(cycle) * 2.5,
      math.sin(cycle) * 2.5,
    );
  }

  String _formatHours(int hour, bool is24Hour) {
    if (is24Hour) {
      return hour.toString().padLeft(2, '0');
    }
    final h = hour % 12;
    final displayHour = h == 0 ? 12 : h;
    return displayHour.toString().padLeft(2, '0');
  }

  String _formatMinutes(int minute) {
    return minute.toString().padLeft(2, '0');
  }

  String _formatSeconds(int second) {
    return second.toString().padLeft(2, '0');
  }

  String _formatAmPm(int hour) {
    return hour >= 12 ? 'PM' : 'AM';
  }

  String _formatDate(DateTime dt) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final weekday = weekdays[dt.weekday - 1];
    final month = months[dt.month - 1];
    return '$weekday, $month ${dt.day}';
  }

  TextStyle _getClockTextStyle(DockClockStyle style, Color color) {
    switch (style) {
      case DockClockStyle.cyberpunkTech:
        return TextStyle(
          fontFamily: 'Courier',
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0,
          color: color,
        );
      case DockClockStyle.minimalSerif:
        return TextStyle(
          fontFamily: 'Georgia',
          fontWeight: FontWeight.w400,
          letterSpacing: 4.0,
          color: color,
        );
      case DockClockStyle.oledMatrix:
        return TextStyle(
          fontFamily: 'Courier',
          fontWeight: FontWeight.w700,
          letterSpacing: 6.0,
          color: color,
        );
      case DockClockStyle.modernSans:
        return TextStyle(
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
          color: color,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WallpaperBloc, WallpaperState>(
      builder: (context, state) {
        final config = state.standbyDockConfig;
        final isNight = config.isNightActiveNow(_currentTime);
        final burnInOffset = _computeBurnInOffset(config.isBurnInProtectionEnabled);

        // Color theme palette
        final primaryColor = isNight
            ? AppColors.nightCrimson // OLED Red to preserve night vision
            : AppColors.neonCyan; // Electric Cyan
        final secondaryColor = isNight
            ? AppColors.sunsetAmber.withValues(alpha: 0.7) // Dim Amber
            : AppColors.auroraViolet.withValues(alpha: 0.8); // Aurora Violet
        final textPrimary = isNight
            ? AppColors.nightCrimson
            : Colors.white;
        final textSecondary = isNight
            ? AppColors.sunsetAmber.withValues(alpha: 0.6)
            : Colors.white70;
        final backgroundColor = AppColors.obsidianBlack; // True OLED Pitch Black

        return Scaffold(
          backgroundColor: backgroundColor,
          body: InteractiveGestureCanvas(
            config: state.gestureConfig,
            auraConfig: state.auraConfig,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _onScreenTapped,
              child: Stack(
                children: [
                  // 1. Ambient Background Layer
                  _buildBackgroundLayer(state, isNight, config),

                  // 2. Main HUD Content with Micro-Shift Offset for Burn-In Protection
                  Transform.translate(
                    offset: burnInOffset,
                    child: SafeArea(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isLandscape =
                              constraints.maxWidth > constraints.maxHeight;
                          return _buildLayoutByMode(
                            context: context,
                            state: state,
                            config: config,
                            isNight: isNight,
                            isLandscape: isLandscape,
                            primaryColor: primaryColor,
                            secondaryColor: secondaryColor,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                          );
                        },
                      ),
                    ),
                  ),

                  // 3. Floating Overlay Controls (Exit, Night Mode, Settings)
                  AnimatedOpacity(
                    opacity: _showControls ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: IgnorePointer(
                      ignoring: !_showControls,
                      child: _buildFloatingControls(
                        context: context,
                        isNight: isNight,
                        primaryColor: primaryColor,
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

  Widget _buildBackgroundLayer(
    WallpaperState state,
    bool isNight,
    StandbyDockConfig config,
  ) {
    if (isNight) {
      // Pure black canvas for OLED night mode
      return Container(color: Colors.black);
    }

    final currentShort = state.currentShort;
    if (config.layoutMode == DockLayoutMode.centeredZen) {
      return Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              AppColors.darkSurface,
              AppColors.darkBackground,
              AppColors.obsidianBlack,
            ],
          ),
        ),
      );
    }

    if (currentShort != null) {
      final colors = currentShort.gradientColors.isNotEmpty
          ? currentShort.gradientColors
          : [
              currentShort.accentColor.withValues(alpha: 0.35),
              AppColors.obsidianBlack,
            ];
      return Opacity(
        opacity: config.layoutMode == DockLayoutMode.fullscreenHUD ? 0.35 : 0.15,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.darkBackground,
            AppColors.obsidianBlack,
          ],
        ),
      ),
    );
  }

  Widget _buildLayoutByMode({
    required BuildContext context,
    required WallpaperState state,
    required StandbyDockConfig config,
    required bool isNight,
    required bool isLandscape,
    required Color primaryColor,
    required Color secondaryColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    switch (config.layoutMode) {
      case DockLayoutMode.dualPaneSplit:
        return _buildDualPaneLayout(
          state: state,
          config: config,
          isNight: isNight,
          isLandscape: isLandscape,
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        );

      case DockLayoutMode.centeredZen:
        return _buildCenteredZenLayout(
          state: state,
          config: config,
          isNight: isNight,
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        );

      case DockLayoutMode.fullscreenHUD:
        return _buildFullscreenHUDLayout(
          state: state,
          config: config,
          isNight: isNight,
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        );
    }
  }

  Widget _buildDualPaneLayout({
    required WallpaperState state,
    required StandbyDockConfig config,
    required bool isNight,
    required bool isLandscape,
    required Color primaryColor,
    required Color secondaryColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final leftPane = _buildArtPane(state, isNight);
    final rightPane = _buildGlanceableHUD(
      state: state,
      config: config,
      isNight: isNight,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
    );

    if (isLandscape) {
      return Row(
        children: [
          Expanded(flex: 5, child: leftPane),
          Container(
            width: 1,
            margin: const EdgeInsets.symmetric(vertical: 32),
            color: isNight
                ? AppColors.nightCrimson.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.08),
          ),
          Expanded(flex: 6, child: rightPane),
        ],
      );
    } else {
      return Column(
        children: [
          Expanded(flex: 4, child: leftPane),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 32),
            color: isNight
                ? AppColors.nightCrimson.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.08),
          ),
          Expanded(flex: 6, child: rightPane),
        ],
      );
    }
  }

  Widget _buildCenteredZenLayout({
    required WallpaperState state,
    required StandbyDockConfig config,
    required bool isNight,
    required Color primaryColor,
    required Color secondaryColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildClockWidget(
              config: config,
              isNight: isNight,
              primaryColor: primaryColor,
              textPrimary: textPrimary,
              fontSize: 84,
            ),
            if (config.showDateAndSolarSlot) ...[
              const SizedBox(height: 12),
              _buildDateAndSolarRow(
                state: state,
                isNight: isNight,
                primaryColor: primaryColor,
                textSecondary: textSecondary,
              ),
            ],
            if (config.showBatteryPill) ...[
              const SizedBox(height: 16),
              _buildBatteryPill(isNight: isNight, primaryColor: primaryColor),
            ],
            if (config.showMotivationalQuote) ...[
              const SizedBox(height: 24),
              Flexible(
                child: _buildMotivationalQuote(
                  state: state,
                  isNight: isNight,
                  textSecondary: textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFullscreenHUDLayout({
    required WallpaperState state,
    required StandbyDockConfig config,
    required bool isNight,
    required Color primaryColor,
    required Color secondaryColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top bar: solar badge & battery
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (config.showDateAndSolarSlot)
                _buildSolarSlotBadge(
                  state: state,
                  isNight: isNight,
                  primaryColor: primaryColor,
                )
              else
                const SizedBox.shrink(),
              if (config.showBatteryPill)
                _buildBatteryPill(isNight: isNight, primaryColor: primaryColor)
              else
                const SizedBox.shrink(),
            ],
          ),

          // Center: Large Clock
          Center(
            child: _buildClockWidget(
              config: config,
              isNight: isNight,
              primaryColor: primaryColor,
              textPrimary: textPrimary,
              fontSize: 96,
            ),
          ),

          // Bottom: Date and Motivational Quote
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (config.showDateAndSolarSlot)
                Text(
                  _formatDate(_currentTime),
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              if (config.showMotivationalQuote) ...[
                const SizedBox(height: 8),
                _buildMotivationalQuote(
                  state: state,
                  isNight: isNight,
                  textSecondary: textSecondary,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArtPane(WallpaperState state, bool isNight) {
    final currentShort = state.currentShort;
    if (isNight) {
      // In night mode, artwork is deeply dimmed or replaced by an ethereal dark moon crescent
      return Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.nightCrimson.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.bedtime_rounded,
              color: AppColors.nightCrimson,
              size: 48,
            ),
          ),
        ),
      );
    }

    if (currentShort != null) {
      final colors = currentShort.gradientColors.isNotEmpty
          ? currentShort.gradientColors
          : [
              currentShort.accentColor.withValues(alpha: 0.5),
              AppColors.darkBackground,
              AppColors.obsidianBlack,
            ];

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AspectRatio(
            aspectRatio: 9 / 16,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: currentShort.accentColor.withValues(alpha: 0.25),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1.5,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(16),
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: currentShort.accentColor.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        currentShort.category.toUpperCase(),
                        style: TextStyle(
                          color: currentShort.accentColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      currentShort.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
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
    }

    return const Center(
      child: Icon(
        Icons.auto_awesome_rounded,
        color: AppColors.neonCyan,
        size: 56,
      ),
    );
  }

  Widget _buildGlanceableHUD({
    required WallpaperState state,
    required StandbyDockConfig config,
    required bool isNight,
    required Color primaryColor,
    required Color secondaryColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Row 1: Circadian Solar Slot & Battery Pill
          Row(
            children: [
              if (config.showDateAndSolarSlot) ...[
                _buildSolarSlotBadge(
                  state: state,
                  isNight: isNight,
                  primaryColor: primaryColor,
                ),
                const SizedBox(width: 12),
              ],
              if (config.showBatteryPill)
                _buildBatteryPill(isNight: isNight, primaryColor: primaryColor),
            ],
          ),
          const SizedBox(height: 16),

          // Row 2: Clock
          _buildClockWidget(
            config: config,
            isNight: isNight,
            primaryColor: primaryColor,
            textPrimary: textPrimary,
            fontSize: 72,
          ),

          // Row 3: Full Date
          if (config.showDateAndSolarSlot) ...[
            const SizedBox(height: 10),
            Text(
              _formatDate(_currentTime),
              style: TextStyle(
                color: textSecondary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],

          // Row 4: Motivational Quote
          if (config.showMotivationalQuote) ...[
            const SizedBox(height: 20),
            _buildMotivationalQuote(
              state: state,
              isNight: isNight,
              textSecondary: textSecondary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildClockWidget({
    required StandbyDockConfig config,
    required bool isNight,
    required Color primaryColor,
    required Color textPrimary,
    required double fontSize,
  }) {
    final hours = _formatHours(_currentTime.hour, config.is24HourFormat);
    final minutes = _formatMinutes(_currentTime.minute);
    final seconds = _formatSeconds(_currentTime.second);
    final amPm = _formatAmPm(_currentTime.hour);
    final style = _getClockTextStyle(config.clockStyle, textPrimary);

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            '$hours:$minutes',
            style: style.copyWith(
              fontSize: fontSize,
              shadows: isNight
                  ? [
                      Shadow(
                        color: AppColors.nightCrimson.withValues(alpha: 0.6),
                        blurRadius: 16,
                      ),
                    ]
                  : [
                      Shadow(
                        color: AppColors.neonCyan.withValues(alpha: 0.4),
                        blurRadius: 20,
                      ),
                    ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                seconds,
                style: style.copyWith(
                  fontSize: fontSize * 0.35,
                  color: isNight
                      ? AppColors.nightCrimson.withValues(alpha: 0.8)
                      : AppColors.neonCyan,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (!config.is24HourFormat)
                Text(
                  amPm,
                  style: TextStyle(
                    fontSize: fontSize * 0.22,
                    color: textPrimary.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSolarSlotBadge({
    required WallpaperState state,
    required bool isNight,
    required Color primaryColor,
  }) {
    final slot = state.activeScheduleSlot;
    final iconData = isNight ? Icons.nightlight_round : Icons.wb_sunny_rounded;
    final slotTitle = isNight ? 'NIGHTSTAND' : slot.name.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 14, color: primaryColor),
          const SizedBox(width: 6),
          Text(
            slotTitle,
            style: TextStyle(
              color: primaryColor,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatteryPill({
    required bool isNight,
    required Color primaryColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isNight
            ? AppColors.nightCrimson.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNight
              ? AppColors.nightCrimson.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bolt_rounded,
            size: 14,
            color: isNight ? AppColors.nightCrimson : AppColors.auroraEmerald,
          ),
          const SizedBox(width: 4),
          Text(
            '100% CHARGED',
            style: TextStyle(
              color: isNight
                  ? AppColors.nightCrimson.withValues(alpha: 0.9)
                  : Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateAndSolarRow({
    required WallpaperState state,
    required bool isNight,
    required Color primaryColor,
    required Color textSecondary,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSolarSlotBadge(
          state: state,
          isNight: isNight,
          primaryColor: primaryColor,
        ),
        const SizedBox(width: 12),
        Text(
          _formatDate(_currentTime),
          style: TextStyle(
            color: textSecondary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMotivationalQuote({
    required WallpaperState state,
    required bool isNight,
    required Color textSecondary,
  }) {
    final quote = state.currentShort != null
        ? state.getEffectiveQuote(state.currentShort!)
        : 'Make every screen yours.';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isNight
            ? AppColors.nightCrimson.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNight
              ? AppColors.nightCrimson.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Text(
        '"$quote"',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: textSecondary,
          fontSize: 13,
          fontStyle: FontStyle.italic,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildFloatingControls({
    required BuildContext context,
    required bool isNight,
    required Color primaryColor,
  }) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Exit Button
            GestureDetector(
              onTap: () {
                if (mounted && Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),

            // Right Action Controls: Night Standby Toggle & Studio Config
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    context
                        .read<WallpaperBloc>()
                        .add(const ToggleNightStandbyModeIntent());
                    _scheduleControlsAutoHide();
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isNight
                          ? AppColors.nightCrimson.withValues(alpha: 0.25)
                          : Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isNight
                            ? AppColors.nightCrimson
                            : Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isNight
                              ? Icons.bedtime_rounded
                              : Icons.bedtime_outlined,
                          size: 16,
                          color: isNight
                              ? AppColors.nightCrimson
                              : Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isNight ? 'OLED RED' : 'NIGHT MODE',
                          style: TextStyle(
                            color: isNight
                                ? AppColors.nightCrimson
                                : Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    StandbyDockSheet.show(context);
                    _scheduleControlsAutoHide();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
