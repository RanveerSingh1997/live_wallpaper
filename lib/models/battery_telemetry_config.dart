import 'package:equatable/equatable.dart';
import 'motivational_short.dart';

/// Target frame-rate modes for live wallpaper rendering.
enum TargetFpsMode {
  fps60(
    label: '60 FPS Ultra-Smooth',
    description: 'Full-refresh fluid rendering for 90Hz & 120Hz AMOLED displays',
    fps: 60,
  ),
  fps30(
    label: '30 FPS Balanced Eco',
    description: 'Halves GPU surface draw cycles, cutting video decoding power by 45%',
    fps: 30,
  ),
  fpsAuto(
    label: 'Adaptive Eco-Scaling',
    description: 'Runs at 60 FPS normally; automatically throttles to 15 FPS when battery < 20%',
    fps: 0,
  );

  final String label;
  final String description;
  final int fps;

  const TargetFpsMode({
    required this.label,
    required this.description,
    required this.fps,
  });

  String get displayName => label;
}

/// Configuration for Wallora battery efficiency, OLED burn-in prevention, and hardware governor.
class BatteryTelemetryConfig extends Equatable {
  final TargetFpsMode targetFps;
  final bool isEcoModeEnabled;
  final bool isPixelShiftEnabled;
  final bool isHardwareDecodingPreferred;
  final bool isBackgroundZeroSleepVerified;

  const BatteryTelemetryConfig({
    this.targetFps = TargetFpsMode.fps60,
    this.isEcoModeEnabled = false,
    this.isPixelShiftEnabled = true,
    this.isHardwareDecodingPreferred = true,
    this.isBackgroundZeroSleepVerified = true,
  });

  static const BatteryTelemetryConfig defaultConfig = BatteryTelemetryConfig();

  /// Calculates estimated battery drain per hour (in percentage) based on wallpaper characteristics.
  double calculateHourlyDrainPercent(MotivationalShort? short) {
    if (short == null) return 0.25;

    // Base drain depending on whether it is Live or Static
    double baseDrain = short.isLive ? 0.70 : 0.15;

    // Frame rate governor impact
    switch (targetFps) {
      case TargetFpsMode.fps60:
        baseDrain *= 1.0;
        break;
      case TargetFpsMode.fps30:
        baseDrain *= 0.60;
        break;
      case TargetFpsMode.fpsAuto:
        baseDrain *= isEcoModeEnabled ? 0.45 : 0.85;
        break;
    }

    // OLED subpixel savings deduction based on true black percentage
    if (short.trueBlackPercentage > 0) {
      final oledSavingsFactor = 1.0 - ((short.trueBlackPercentage / 100.0) * 0.65);
      baseDrain *= oledSavingsFactor;
    }

    // Hardware decoding discount
    if (isHardwareDecodingPreferred) {
      baseDrain *= 0.88;
    }

    return double.parse(baseDrain.clamp(0.05, 1.8).toStringAsFixed(2));
  }

  /// Calculates estimated daily milliampere-hours (mAh) saved on a standard 4500mAh phone.
  int calculateDailyMahSaved(MotivationalShort? short) {
    final standardDrain = short?.isLive == true ? 1.4 : 0.5;
    final currentDrain = calculateHourlyDrainPercent(short);
    final savedPercentPerHour = (standardDrain - currentDrain).clamp(0.0, 1.2);

    // Assuming 4.5 hours of average daily screen-on wallpaper interactions
    final totalDailyPercentSaved = savedPercentPerHour * 4.5;
    return (totalDailyPercentSaved * 45).round().clamp(10, 480);
  }

  BatteryTelemetryConfig copyWith({
    TargetFpsMode? targetFps,
    bool? isEcoModeEnabled,
    bool? isPixelShiftEnabled,
    bool? isHardwareDecodingPreferred,
    bool? isBackgroundZeroSleepVerified,
  }) {
    return BatteryTelemetryConfig(
      targetFps: targetFps ?? this.targetFps,
      isEcoModeEnabled: isEcoModeEnabled ?? this.isEcoModeEnabled,
      isPixelShiftEnabled: isPixelShiftEnabled ?? this.isPixelShiftEnabled,
      isHardwareDecodingPreferred:
          isHardwareDecodingPreferred ?? this.isHardwareDecodingPreferred,
      isBackgroundZeroSleepVerified:
          isBackgroundZeroSleepVerified ?? this.isBackgroundZeroSleepVerified,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'targetFps': targetFps.name,
      'isEcoModeEnabled': isEcoModeEnabled,
      'isPixelShiftEnabled': isPixelShiftEnabled,
      'isHardwareDecodingPreferred': isHardwareDecodingPreferred,
      'isBackgroundZeroSleepVerified': isBackgroundZeroSleepVerified,
    };
  }

  factory BatteryTelemetryConfig.fromJson(Map<String, dynamic> json) {
    TargetFpsMode parseFps(String? name) {
      if (name == null) return TargetFpsMode.fps60;
      return TargetFpsMode.values.firstWhere(
        (e) => e.name == name,
        orElse: () => TargetFpsMode.fps60,
      );
    }

    return BatteryTelemetryConfig(
      targetFps: parseFps(json['targetFps'] as String?),
      isEcoModeEnabled: json['isEcoModeEnabled'] as bool? ?? false,
      isPixelShiftEnabled: json['isPixelShiftEnabled'] as bool? ?? true,
      isHardwareDecodingPreferred:
          json['isHardwareDecodingPreferred'] as bool? ?? true,
      isBackgroundZeroSleepVerified:
          json['isBackgroundZeroSleepVerified'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        targetFps,
        isEcoModeEnabled,
        isPixelShiftEnabled,
        isHardwareDecodingPreferred,
        isBackgroundZeroSleepVerified,
      ];
}
