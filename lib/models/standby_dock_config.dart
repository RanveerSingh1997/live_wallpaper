import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Available typography styles for Wallora Horizon Standby & Desk Dock.
enum DockClockStyle {
  modernSans(
    label: 'Modern Sans-Serif',
    description: 'Clean, bold, ultra-legible Swiss typography',
    icon: Icons.font_download_rounded,
  ),
  cyberpunkTech(
    label: 'Cyberpunk Mono',
    description: 'High-tech futuristic monospace terminal font',
    icon: Icons.terminal_rounded,
  ),
  minimalSerif(
    label: 'Editorial Serif',
    description: 'Refined, high-fashion luxury serif elegance',
    icon: Icons.auto_stories_rounded,
  ),
  oledMatrix(
    label: 'OLED Dot Matrix',
    description: 'Crisp dot-matrix LED glyphs with true-black contrast',
    icon: Icons.grid_view_rounded,
  );

  final String label;
  final String description;
  final IconData icon;

  const DockClockStyle({
    required this.label,
    required this.description,
    required this.icon,
  });

  String get displayName => label;
}

/// Available visual layout arrangements for the Standby Desk Dock screen.
enum DockLayoutMode {
  dualPaneSplit(
    label: 'Dual-Pane Split',
    description: 'Cinematic wallpaper canvas on left, glanceable HUD on right',
    icon: Icons.view_column_rounded,
  ),
  centeredZen(
    label: 'Centered Minimalist',
    description: 'Balanced glanceable clock & quote over subtle blurred background',
    icon: Icons.center_focus_strong_rounded,
  ),
  fullscreenHUD(
    label: 'Fullscreen Floating HUD',
    description: 'Full-bleed edge-to-edge wallpaper with floating translucent widgets',
    icon: Icons.fullscreen_rounded,
  );

  final String label;
  final String description;
  final IconData icon;

  const DockLayoutMode({
    required this.label,
    required this.description,
    required this.icon,
  });

  String get displayName => label;
}

/// Configuration for Wallora Horizon Standby & Ambient Desk Dock HUD.
class StandbyDockConfig extends Equatable {
  final DockClockStyle clockStyle;
  final DockLayoutMode layoutMode;
  final bool isNightModeEnabled;
  final bool isAutoNightModeEnabled;
  final bool isBurnInProtectionEnabled;
  final bool showBatteryPill;
  final bool showMotivationalQuote;
  final bool showDateAndSolarSlot;
  final bool is24HourFormat;
  final double nightDimLevel;

  const StandbyDockConfig({
    this.clockStyle = DockClockStyle.modernSans,
    this.layoutMode = DockLayoutMode.dualPaneSplit,
    this.isNightModeEnabled = false,
    this.isAutoNightModeEnabled = true,
    this.isBurnInProtectionEnabled = true,
    this.showBatteryPill = true,
    this.showMotivationalQuote = true,
    this.showDateAndSolarSlot = true,
    this.is24HourFormat = false,
    this.nightDimLevel = 0.20,
  });

  static const StandbyDockConfig defaultConfig = StandbyDockConfig();

  /// Evaluates whether night standby mode should be active right now based on
  /// manual toggle or automatic circadian schedule (10:00 PM - 6:00 AM).
  bool isNightActiveNow(DateTime now) {
    if (isNightModeEnabled) return true;
    if (!isAutoNightModeEnabled) return false;
    final hour = now.hour;
    // Between 10 PM (22) and 6 AM (06)
    return hour >= 22 || hour < 6;
  }

  StandbyDockConfig copyWith({
    DockClockStyle? clockStyle,
    DockLayoutMode? layoutMode,
    bool? isNightModeEnabled,
    bool? isAutoNightModeEnabled,
    bool? isBurnInProtectionEnabled,
    bool? showBatteryPill,
    bool? showMotivationalQuote,
    bool? showDateAndSolarSlot,
    bool? is24HourFormat,
    double? nightDimLevel,
  }) {
    return StandbyDockConfig(
      clockStyle: clockStyle ?? this.clockStyle,
      layoutMode: layoutMode ?? this.layoutMode,
      isNightModeEnabled: isNightModeEnabled ?? this.isNightModeEnabled,
      isAutoNightModeEnabled:
          isAutoNightModeEnabled ?? this.isAutoNightModeEnabled,
      isBurnInProtectionEnabled:
          isBurnInProtectionEnabled ?? this.isBurnInProtectionEnabled,
      showBatteryPill: showBatteryPill ?? this.showBatteryPill,
      showMotivationalQuote:
          showMotivationalQuote ?? this.showMotivationalQuote,
      showDateAndSolarSlot: showDateAndSolarSlot ?? this.showDateAndSolarSlot,
      is24HourFormat: is24HourFormat ?? this.is24HourFormat,
      nightDimLevel: nightDimLevel ?? this.nightDimLevel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clockStyle': clockStyle.name,
      'layoutMode': layoutMode.name,
      'isNightModeEnabled': isNightModeEnabled,
      'isAutoNightModeEnabled': isAutoNightModeEnabled,
      'isBurnInProtectionEnabled': isBurnInProtectionEnabled,
      'showBatteryPill': showBatteryPill,
      'showMotivationalQuote': showMotivationalQuote,
      'showDateAndSolarSlot': showDateAndSolarSlot,
      'is24HourFormat': is24HourFormat,
      'nightDimLevel': nightDimLevel,
    };
  }

  factory StandbyDockConfig.fromJson(Map<String, dynamic> json) {
    DockClockStyle parseClockStyle(String? name) {
      if (name == null) return DockClockStyle.modernSans;
      return DockClockStyle.values.firstWhere(
        (e) => e.name == name,
        orElse: () => DockClockStyle.modernSans,
      );
    }

    DockLayoutMode parseLayoutMode(String? name) {
      if (name == null) return DockLayoutMode.dualPaneSplit;
      return DockLayoutMode.values.firstWhere(
        (e) => e.name == name,
        orElse: () => DockLayoutMode.dualPaneSplit,
      );
    }

    return StandbyDockConfig(
      clockStyle: parseClockStyle(json['clockStyle'] as String?),
      layoutMode: parseLayoutMode(json['layoutMode'] as String?),
      isNightModeEnabled: json['isNightModeEnabled'] as bool? ?? false,
      isAutoNightModeEnabled:
          json['isAutoNightModeEnabled'] as bool? ?? true,
      isBurnInProtectionEnabled:
          json['isBurnInProtectionEnabled'] as bool? ?? true,
      showBatteryPill: json['showBatteryPill'] as bool? ?? true,
      showMotivationalQuote:
          json['showMotivationalQuote'] as bool? ?? true,
      showDateAndSolarSlot:
          json['showDateAndSolarSlot'] as bool? ?? true,
      is24HourFormat: json['is24HourFormat'] as bool? ?? false,
      nightDimLevel: (json['nightDimLevel'] as num?)?.toDouble() ?? 0.20,
    );
  }

  @override
  List<Object?> get props => [
        clockStyle,
        layoutMode,
        isNightModeEnabled,
        isAutoNightModeEnabled,
        isBurnInProtectionEnabled,
        showBatteryPill,
        showMotivationalQuote,
        showDateAndSolarSlot,
        is24HourFormat,
        nightDimLevel,
      ];
}
