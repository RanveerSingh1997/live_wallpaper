import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/models/day_night_schedule_config.dart';

void main() {
  group('DayNightScheduleConfig Model Tests', () {
    test('default configuration provides valid baseline', () {
      const config = DayNightScheduleConfig.defaultConfig;
      expect(config.isEnabled, false);
      expect(config.morningHour, 6);
      expect(config.afternoonHour, 12);
      expect(config.eveningHour, 18);
      expect(config.nightHour, 22);
      expect(config.morningWallpaperId, 'ippo_hard_work');
      expect(config.afternoonWallpaperId, 'cyber_netrunner_terminal');
      expect(config.eveningWallpaperId, 'silent_ambition');
      expect(config.nightWallpaperId, 'minimal_monolith');
      expect(config.autoAmoledAtNight, true);
    });

    test('getSlotForTime correctly resolves 4 solar periods', () {
      const config = DayNightScheduleConfig.defaultConfig;

      // Morning (06:00 - 11:59)
      expect(config.getSlotForTime(DateTime(2026, 1, 1, 6, 0)), DayNightSlot.morning);
      expect(config.getSlotForTime(DateTime(2026, 1, 1, 10, 30)), DayNightSlot.morning);
      expect(config.getSlotForTime(DateTime(2026, 1, 1, 11, 59)), DayNightSlot.morning);

      // Afternoon (12:00 - 17:59)
      expect(config.getSlotForTime(DateTime(2026, 1, 1, 12, 0)), DayNightSlot.afternoon);
      expect(config.getSlotForTime(DateTime(2026, 1, 1, 15, 0)), DayNightSlot.afternoon);

      // Evening (18:00 - 21:59)
      expect(config.getSlotForTime(DateTime(2026, 1, 1, 18, 0)), DayNightSlot.evening);
      expect(config.getSlotForTime(DateTime(2026, 1, 1, 21, 59)), DayNightSlot.evening);

      // Night (22:00 - 05:59)
      expect(config.getSlotForTime(DateTime(2026, 1, 1, 22, 0)), DayNightSlot.night);
      expect(config.getSlotForTime(DateTime(2026, 1, 1, 23, 30)), DayNightSlot.night);
      expect(config.getSlotForTime(DateTime(2026, 1, 1, 2, 0)), DayNightSlot.night);
      expect(config.getSlotForTime(DateTime(2026, 1, 1, 5, 59)), DayNightSlot.night);
    });

    test('getWallpaperIdForTime and getWallpaperIdForSlot return configured IDs', () {
      const config = DayNightScheduleConfig(
        morningWallpaperId: 'custom_dawn',
        afternoonWallpaperId: 'custom_day',
        eveningWallpaperId: 'custom_sunset',
        nightWallpaperId: 'custom_amoled',
      );

      expect(config.getWallpaperIdForSlot(DayNightSlot.morning), 'custom_dawn');
      expect(config.getWallpaperIdForSlot(DayNightSlot.afternoon), 'custom_day');
      expect(config.getWallpaperIdForSlot(DayNightSlot.evening), 'custom_sunset');
      expect(config.getWallpaperIdForSlot(DayNightSlot.night), 'custom_amoled');

      expect(config.getWallpaperIdForTime(DateTime(2026, 1, 1, 8, 0)), 'custom_dawn');
      expect(config.getWallpaperIdForTime(DateTime(2026, 1, 1, 14, 0)), 'custom_day');
      expect(config.getWallpaperIdForTime(DateTime(2026, 1, 1, 19, 0)), 'custom_sunset');
      expect(config.getWallpaperIdForTime(DateTime(2026, 1, 1, 23, 0)), 'custom_amoled');
    });

    test('copyWith modifies specified fields while preserving others', () {
      const config = DayNightScheduleConfig.defaultConfig;
      final updated = config.copyWith(
        isEnabled: true,
        morningWallpaperId: 'new_dawn',
        autoAmoledAtNight: false,
      );

      expect(updated.isEnabled, true);
      expect(updated.morningWallpaperId, 'new_dawn');
      expect(updated.autoAmoledAtNight, false);
      expect(updated.afternoonWallpaperId, config.afternoonWallpaperId);
      expect(updated.nightHour, config.nightHour);
    });

    test('toJson and fromJson correctly serialize and deserialize', () {
      const original = DayNightScheduleConfig(
        isEnabled: true,
        morningHour: 7,
        afternoonHour: 13,
        eveningHour: 19,
        nightHour: 23,
        morningWallpaperId: 'dawn_1',
        afternoonWallpaperId: 'day_2',
        eveningWallpaperId: 'sunset_3',
        nightWallpaperId: 'night_4',
        autoAmoledAtNight: false,
      );

      final json = original.toJson();
      final reconstructed = DayNightScheduleConfig.fromJson(json);

      expect(reconstructed, equals(original));
      expect(reconstructed.isEnabled, true);
      expect(reconstructed.morningHour, 7);
      expect(reconstructed.nightHour, 23);
      expect(reconstructed.autoAmoledAtNight, false);
    });

    test('Equatable equality works as expected', () {
      const config1 = DayNightScheduleConfig(isEnabled: true, morningHour: 6);
      const config2 = DayNightScheduleConfig(isEnabled: true, morningHour: 6);
      const config3 = DayNightScheduleConfig(isEnabled: false, morningHour: 6);

      expect(config1, equals(config2));
      expect(config1 == config3, false);
    });
  });
}
