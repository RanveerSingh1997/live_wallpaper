import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Typography fonts available for the lock screen clock simulation.
enum LockScreenClockFont {
  modern('Modern Sans', Icons.font_download_rounded),
  editorial('Editorial Serif', Icons.menu_book_rounded),
  cyber('Cyber Mono', Icons.terminal_rounded),
  stencil('Bold Stencil', Icons.format_bold_rounded),
  neon('Aurora Neon', Icons.blur_on_rounded);

  final String label;
  final IconData icon;
  const LockScreenClockFont(this.label, this.icon);
}

/// Structural layout format of the lock screen clock.
enum LockScreenClockLayout {
  horizontal('Classic Inline', Icons.view_headline_rounded),
  stacked('Stacked Modern', Icons.view_agenda_rounded),
  compact('Minimalist Badge', Icons.subtitles_rounded);

  final String label;
  final IconData icon;
  const LockScreenClockLayout(this.label, this.icon);
}

/// Glanceable lock screen widget pill options.
enum LockScreenWidgetType {
  circadianSlot('Circadian Solar Phase', Icons.brightness_auto_rounded),
  quotePill('Motivational Philosophy', Icons.format_quote_rounded),
  batteryGlance('Battery & Power Status', Icons.battery_charging_full_rounded),
  weatherMinimal('Weather & Sky', Icons.wb_sunny_rounded),
  none('Clean / None', Icons.visibility_off_rounded);

  final String label;
  final IconData icon;
  const LockScreenWidgetType(this.label, this.icon);
}

/// Configuration model for personalized lock screen clock & widget simulation.
class LockScreenStyleConfig extends Equatable {
  final LockScreenClockFont clockFont;
  final LockScreenClockLayout clockLayout;
  final LockScreenWidgetType widgetType;
  final bool useWallpaperAccentColor;
  final Color customColor;
  final bool showDate;
  final bool showShortcuts;
  final double clockSize;

  const LockScreenStyleConfig({
    this.clockFont = LockScreenClockFont.modern,
    this.clockLayout = LockScreenClockLayout.horizontal,
    this.widgetType = LockScreenWidgetType.circadianSlot,
    this.useWallpaperAccentColor = true,
    this.customColor = Colors.white,
    this.showDate = true,
    this.showShortcuts = true,
    this.clockSize = 82.0,
  });

  static const LockScreenStyleConfig defaultConfig = LockScreenStyleConfig();

  static const LockScreenStyleConfig pixelStackedPreset = LockScreenStyleConfig(
    clockFont: LockScreenClockFont.stencil,
    clockLayout: LockScreenClockLayout.stacked,
    widgetType: LockScreenWidgetType.circadianSlot,
    useWallpaperAccentColor: true,
    clockSize: 88.0,
  );

  static const LockScreenStyleConfig editorialSerifPreset = LockScreenStyleConfig(
    clockFont: LockScreenClockFont.editorial,
    clockLayout: LockScreenClockLayout.horizontal,
    widgetType: LockScreenWidgetType.quotePill,
    useWallpaperAccentColor: false,
    customColor: Colors.white,
    clockSize: 76.0,
  );

  static const LockScreenStyleConfig cyberMatrixPreset = LockScreenStyleConfig(
    clockFont: LockScreenClockFont.cyber,
    clockLayout: LockScreenClockLayout.stacked,
    widgetType: LockScreenWidgetType.batteryGlance,
    useWallpaperAccentColor: false,
    customColor: Color(0xFF00E676),
    clockSize: 84.0,
  );

  static const LockScreenStyleConfig auroraNeonPreset = LockScreenStyleConfig(
    clockFont: LockScreenClockFont.neon,
    clockLayout: LockScreenClockLayout.horizontal,
    widgetType: LockScreenWidgetType.circadianSlot,
    useWallpaperAccentColor: false,
    customColor: Color(0xFF00E5FF),
    clockSize: 80.0,
  );

  /// Resolves the effective color for the clock text given the wallpaper's accent.
  Color resolveClockColor(Color wallpaperAccent) {
    if (useWallpaperAccentColor) {
      return wallpaperAccent;
    }
    return customColor;
  }

  /// Resolves the TextStyle for the clock given the configuration and effective color.
  TextStyle resolveClockTextStyle(Color effectiveColor) {
    switch (clockFont) {
      case LockScreenClockFont.modern:
        return TextStyle(
          color: effectiveColor,
          fontSize: clockSize,
          fontWeight: FontWeight.w200,
          letterSpacing: -1.5,
          height: clockLayout == LockScreenClockLayout.stacked ? 0.9 : 1.0,
          shadows: const [
            Shadow(color: Colors.black87, blurRadius: 16),
          ],
        );
      case LockScreenClockFont.editorial:
        return TextStyle(
          fontFamily: 'serif',
          color: effectiveColor,
          fontSize: clockSize * 0.95,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          height: clockLayout == LockScreenClockLayout.stacked ? 0.92 : 1.0,
          shadows: const [
            Shadow(color: Colors.black87, blurRadius: 16),
          ],
        );
      case LockScreenClockFont.cyber:
        return TextStyle(
          fontFamily: 'monospace',
          color: effectiveColor,
          fontSize: clockSize * 0.9,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          height: clockLayout == LockScreenClockLayout.stacked ? 0.95 : 1.0,
          shadows: [
            Shadow(color: effectiveColor.withValues(alpha: 0.6), blurRadius: 18),
            const Shadow(color: Colors.black, blurRadius: 14),
          ],
        );
      case LockScreenClockFont.stencil:
        return TextStyle(
          color: effectiveColor,
          fontSize: clockSize * 1.05,
          fontWeight: FontWeight.w900,
          letterSpacing: -2.0,
          height: clockLayout == LockScreenClockLayout.stacked ? 0.88 : 1.0,
          shadows: const [
            Shadow(color: Colors.black, blurRadius: 20),
          ],
        );
      case LockScreenClockFont.neon:
        return TextStyle(
          color: effectiveColor,
          fontSize: clockSize * 0.92,
          fontWeight: FontWeight.w400,
          letterSpacing: 4.0,
          height: clockLayout == LockScreenClockLayout.stacked ? 0.95 : 1.0,
          shadows: [
            Shadow(color: effectiveColor, blurRadius: 24),
            Shadow(color: effectiveColor.withValues(alpha: 0.5), blurRadius: 40),
            const Shadow(color: Colors.black87, blurRadius: 12),
          ],
        );
    }
  }

  LockScreenStyleConfig copyWith({
    LockScreenClockFont? clockFont,
    LockScreenClockLayout? clockLayout,
    LockScreenWidgetType? widgetType,
    bool? useWallpaperAccentColor,
    Color? customColor,
    bool? showDate,
    bool? showShortcuts,
    double? clockSize,
  }) {
    return LockScreenStyleConfig(
      clockFont: clockFont ?? this.clockFont,
      clockLayout: clockLayout ?? this.clockLayout,
      widgetType: widgetType ?? this.widgetType,
      useWallpaperAccentColor:
          useWallpaperAccentColor ?? this.useWallpaperAccentColor,
      customColor: customColor ?? this.customColor,
      showDate: showDate ?? this.showDate,
      showShortcuts: showShortcuts ?? this.showShortcuts,
      clockSize: clockSize ?? this.clockSize,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clockFont': clockFont.name,
      'clockLayout': clockLayout.name,
      'widgetType': widgetType.name,
      'useWallpaperAccentColor': useWallpaperAccentColor,
      'customColor': customColor.toARGB32(),
      'showDate': showDate,
      'showShortcuts': showShortcuts,
      'clockSize': clockSize,
    };
  }

  factory LockScreenStyleConfig.fromJson(Map<String, dynamic> json) {
    return LockScreenStyleConfig(
      clockFont: LockScreenClockFont.values.firstWhere(
        (e) => e.name == json['clockFont'],
        orElse: () => LockScreenClockFont.modern,
      ),
      clockLayout: LockScreenClockLayout.values.firstWhere(
        (e) => e.name == json['clockLayout'],
        orElse: () => LockScreenClockLayout.horizontal,
      ),
      widgetType: LockScreenWidgetType.values.firstWhere(
        (e) => e.name == json['widgetType'],
        orElse: () => LockScreenWidgetType.circadianSlot,
      ),
      useWallpaperAccentColor: json['useWallpaperAccentColor'] as bool? ?? true,
      customColor: json['customColor'] != null
          ? Color(json['customColor'] as int)
          : Colors.white,
      showDate: json['showDate'] as bool? ?? true,
      showShortcuts: json['showShortcuts'] as bool? ?? true,
      clockSize: (json['clockSize'] as num?)?.toDouble() ?? 82.0,
    );
  }

  @override
  List<Object?> get props => [
        clockFont,
        clockLayout,
        widgetType,
        useWallpaperAccentColor,
        customColor.toARGB32(),
        showDate,
        showShortcuts,
        clockSize,
      ];
}
