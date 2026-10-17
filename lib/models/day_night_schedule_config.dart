import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum DayNightSlot {
  morning('Morning / Dawn', Icons.wb_twilight_rounded, Color(0xFF00E5FF)),
  afternoon('Afternoon / Focus', Icons.wb_sunny_rounded, Color(0xFFFFD600)),
  evening('Sunset / Twilight', Icons.nights_stay_rounded, Color(0xFFFF5722)),
  night('Night / AMOLED Black', Icons.bedtime_rounded, Color(0xFF00E676));

  final String label;
  final IconData icon;
  final Color accentColor;
  const DayNightSlot(this.label, this.icon, this.accentColor);
}

/// Configuration for automated solar Day & Night dynamic wallpaper transitions.
class DayNightScheduleConfig extends Equatable {
  final bool isEnabled;
  final int morningHour; // 0..23, default 6 (06:00)
  final int afternoonHour; // 0..23, default 12 (12:00)
  final int eveningHour; // 0..23, default 18 (18:00)
  final int nightHour; // 0..23, default 22 (22:00)
  final String morningWallpaperId;
  final String afternoonWallpaperId;
  final String eveningWallpaperId;
  final String nightWallpaperId;
  final bool autoAmoledAtNight;

  const DayNightScheduleConfig({
    this.isEnabled = false,
    this.morningHour = 6,
    this.afternoonHour = 12,
    this.eveningHour = 18,
    this.nightHour = 22,
    this.morningWallpaperId = 'ippo_hard_work',
    this.afternoonWallpaperId = 'cyber_netrunner_terminal',
    this.eveningWallpaperId = 'silent_ambition',
    this.nightWallpaperId = 'minimal_monolith',
    this.autoAmoledAtNight = true,
  });

  static const DayNightScheduleConfig defaultConfig = DayNightScheduleConfig();

  /// Determines which solar time slot a given DateTime falls into.
  DayNightSlot getSlotForTime(DateTime time) {
    final hour = time.hour;
    if (hour >= nightHour || hour < morningHour) {
      return DayNightSlot.night;
    } else if (hour >= eveningHour) {
      return DayNightSlot.evening;
    } else if (hour >= afternoonHour) {
      return DayNightSlot.afternoon;
    } else {
      return DayNightSlot.morning;
    }
  }

  /// Returns the configured wallpaper ID for a given DateTime.
  String getWallpaperIdForTime(DateTime time) {
    switch (getSlotForTime(time)) {
      case DayNightSlot.morning:
        return morningWallpaperId;
      case DayNightSlot.afternoon:
        return afternoonWallpaperId;
      case DayNightSlot.evening:
        return eveningWallpaperId;
      case DayNightSlot.night:
        return nightWallpaperId;
    }
  }

  /// Returns the configured wallpaper ID for a specific slot.
  String getWallpaperIdForSlot(DayNightSlot slot) {
    switch (slot) {
      case DayNightSlot.morning:
        return morningWallpaperId;
      case DayNightSlot.afternoon:
        return afternoonWallpaperId;
      case DayNightSlot.evening:
        return eveningWallpaperId;
      case DayNightSlot.night:
        return nightWallpaperId;
    }
  }

  DayNightScheduleConfig copyWith({
    bool? isEnabled,
    int? morningHour,
    int? afternoonHour,
    int? eveningHour,
    int? nightHour,
    String? morningWallpaperId,
    String? afternoonWallpaperId,
    String? eveningWallpaperId,
    String? nightWallpaperId,
    bool? autoAmoledAtNight,
  }) {
    return DayNightScheduleConfig(
      isEnabled: isEnabled ?? this.isEnabled,
      morningHour: morningHour ?? this.morningHour,
      afternoonHour: afternoonHour ?? this.afternoonHour,
      eveningHour: eveningHour ?? this.eveningHour,
      nightHour: nightHour ?? this.nightHour,
      morningWallpaperId: morningWallpaperId ?? this.morningWallpaperId,
      afternoonWallpaperId: afternoonWallpaperId ?? this.afternoonWallpaperId,
      eveningWallpaperId: eveningWallpaperId ?? this.eveningWallpaperId,
      nightWallpaperId: nightWallpaperId ?? this.nightWallpaperId,
      autoAmoledAtNight: autoAmoledAtNight ?? this.autoAmoledAtNight,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled,
      'morningHour': morningHour,
      'afternoonHour': afternoonHour,
      'eveningHour': eveningHour,
      'nightHour': nightHour,
      'morningWallpaperId': morningWallpaperId,
      'afternoonWallpaperId': afternoonWallpaperId,
      'eveningWallpaperId': eveningWallpaperId,
      'nightWallpaperId': nightWallpaperId,
      'autoAmoledAtNight': autoAmoledAtNight,
    };
  }

  factory DayNightScheduleConfig.fromJson(Map<String, dynamic> json) {
    return DayNightScheduleConfig(
      isEnabled: json['isEnabled'] as bool? ?? false,
      morningHour: json['morningHour'] as int? ?? 6,
      afternoonHour: json['afternoonHour'] as int? ?? 12,
      eveningHour: json['eveningHour'] as int? ?? 18,
      nightHour: json['nightHour'] as int? ?? 22,
      morningWallpaperId: json['morningWallpaperId'] as String? ?? 'ippo_hard_work',
      afternoonWallpaperId:
          json['afternoonWallpaperId'] as String? ?? 'cyber_netrunner_terminal',
      eveningWallpaperId:
          json['eveningWallpaperId'] as String? ?? 'silent_ambition',
      nightWallpaperId:
          json['nightWallpaperId'] as String? ?? 'minimal_monolith',
      autoAmoledAtNight: json['autoAmoledAtNight'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        isEnabled,
        morningHour,
        afternoonHour,
        eveningHour,
        nightHour,
        morningWallpaperId,
        afternoonWallpaperId,
        eveningWallpaperId,
        nightWallpaperId,
        autoAmoledAtNight,
      ];
}
