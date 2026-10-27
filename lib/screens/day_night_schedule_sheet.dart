import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/wallpaper_bloc.dart';
import '../blocs/wallpaper_intent.dart';
import '../blocs/wallpaper_state.dart';
import '../core/core.dart';
import '../models/day_night_schedule_config.dart';
import '../models/motivational_short.dart';
import '../widgets/cached_wallpaper_image.dart';

/// Modal sheet to configure automated solar Day & Night dynamic wallpaper schedules.
class DayNightScheduleSheet extends StatelessWidget {
  const DayNightScheduleSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const DayNightScheduleSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WallpaperBloc, WallpaperState>(
      builder: (context, state) {
        final schedule = state.dayNightSchedule;
        final currentSlot = schedule.getSlotForTime(DateTime.now());

        return DraggableScrollableSheet(
          initialChildSize: 0.92,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.darkBackground,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 14, bottom: 8),
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
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: AppColors.neonCyan.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.neonCyan,
                                  width: 0.8,
                                ),
                              ),
                              child: const Icon(
                                Icons.brightness_auto_rounded,
                                size: 18,
                                color: AppColors.neonCyan,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SOLAR DAY & NIGHT',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Dynamic Circadian Wallpaper Engine',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white54,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white70),
                          onPressed: () {
                            if (context.mounted && Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const Divider(color: Colors.white10, height: 1),

                  // Content
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      children: [
                        // Master Schedule Toggle Card
                        _buildMasterToggleCard(context, schedule, currentSlot, state),

                        const SizedBox(height: 16),

                        // Section Header: Solar Time Slots
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          child: Text(
                            'SOLAR CYCLE SLOTS (4-PHASE)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white38,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // 4 Solar Slots Cards
                        _buildSlotCard(
                          context: context,
                          state: state,
                          slot: DayNightSlot.morning,
                          timeRange: '06:00 – 12:00',
                          wallpaperId: schedule.morningWallpaperId,
                          isCurrentActive: currentSlot == DayNightSlot.morning,
                          onWallpaperSelected: (id) {
                            final updated = schedule.copyWith(morningWallpaperId: id);
                            context.read<WallpaperBloc>().add(UpdateDayNightScheduleIntent(updated));
                          },
                        ),

                        const SizedBox(height: 12),

                        _buildSlotCard(
                          context: context,
                          state: state,
                          slot: DayNightSlot.afternoon,
                          timeRange: '12:00 – 18:00',
                          wallpaperId: schedule.afternoonWallpaperId,
                          isCurrentActive: currentSlot == DayNightSlot.afternoon,
                          onWallpaperSelected: (id) {
                            final updated = schedule.copyWith(afternoonWallpaperId: id);
                            context.read<WallpaperBloc>().add(UpdateDayNightScheduleIntent(updated));
                          },
                        ),

                        const SizedBox(height: 12),

                        _buildSlotCard(
                          context: context,
                          state: state,
                          slot: DayNightSlot.evening,
                          timeRange: '18:00 – 22:00',
                          wallpaperId: schedule.eveningWallpaperId,
                          isCurrentActive: currentSlot == DayNightSlot.evening,
                          onWallpaperSelected: (id) {
                            final updated = schedule.copyWith(eveningWallpaperId: id);
                            context.read<WallpaperBloc>().add(UpdateDayNightScheduleIntent(updated));
                          },
                        ),

                        const SizedBox(height: 12),

                        _buildSlotCard(
                          context: context,
                          state: state,
                          slot: DayNightSlot.night,
                          timeRange: '22:00 – 06:00',
                          wallpaperId: schedule.nightWallpaperId,
                          isCurrentActive: currentSlot == DayNightSlot.night,
                          onWallpaperSelected: (id) {
                            final updated = schedule.copyWith(nightWallpaperId: id);
                            context.read<WallpaperBloc>().add(UpdateDayNightScheduleIntent(updated));
                          },
                        ),

                        const SizedBox(height: 18),

                        // Night AMOLED Saver Option Card
                        _buildNightAmoledOptionCard(context, schedule),

                        const SizedBox(height: 20),

                        // Immediate Sync Action
                        _buildSyncNowButton(context, schedule),
                      ],
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

  Widget _buildMasterToggleCard(
    BuildContext context,
    DayNightScheduleConfig schedule,
    DayNightSlot currentSlot,
    WallpaperState state,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: schedule.isEnabled
              ? AppColors.neonCyan.withValues(alpha: 0.5)
              : Colors.white10,
          width: schedule.isEnabled ? 1.2 : 0.8,
        ),
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
                    Row(
                      children: [
                        Text(
                          'Automate Solar Cycle Transitions',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: schedule.isEnabled
                                ? AppColors.neonCyan
                                : Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Shifts your wallpaper automatically to match your body clock across dawn, focus, twilight, and sleep.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white54,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Switch.adaptive(
                value: schedule.isEnabled,
                activeThumbColor: AppColors.neonCyan,
                activeTrackColor: AppColors.neonCyan.withValues(alpha: 0.3),
                onChanged: (_) {
                  context.read<WallpaperBloc>().add(const ToggleDayNightScheduleIntent());
                },
              ),
            ],
          ),
          if (schedule.isEnabled) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: currentSlot.accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: currentSlot.accentColor.withValues(alpha: 0.4),
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  Icon(currentSlot.icon, size: 16, color: currentSlot.accentColor),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Currently in slot: ${currentSlot.label}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: currentSlot.accentColor,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSlotCard({
    required BuildContext context,
    required WallpaperState state,
    required DayNightSlot slot,
    required String timeRange,
    required String wallpaperId,
    required bool isCurrentActive,
    required ValueChanged<String> onWallpaperSelected,
  }) {
    final wallpaper = state.allShorts.cast<MotivationalShort?>().firstWhere(
          (s) => s?.id == wallpaperId,
          orElse: () => null,
        );

    return Material(
      color: AppColors.cardSurface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openWallpaperPicker(context, state, slot, onWallpaperSelected),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCurrentActive
                  ? slot.accentColor.withValues(alpha: 0.6)
                  : Colors.white10,
              width: isCurrentActive ? 1.2 : 0.8,
            ),
          ),
          child: Row(
            children: [
              // Slot Icon & Timeline indicator
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: slot.accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: slot.accentColor.withValues(alpha: 0.35),
                    width: 0.8,
                  ),
                ),
                child: Icon(slot.icon, color: slot.accentColor, size: 22),
              ),
              const SizedBox(width: 14),

              // Slot Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            slot.label,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        if (isCurrentActive) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: slot.accentColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'NOW',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: slot.accentColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      timeRange,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white38,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.wallpaper_rounded, size: 12, color: Colors.white54),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            wallpaper != null ? wallpaper.title : 'None selected',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: wallpaper != null ? Colors.white70 : Colors.white38,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Wallpaper Mini Thumbnail & Change Indicator
              Stack(
                children: [
                  _buildWallpaperThumbnail(wallpaper),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(Icons.edit_rounded, size: 14, color: Colors.white70),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNightAmoledOptionCard(
    BuildContext context,
    DayNightScheduleConfig schedule,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: schedule.autoAmoledAtNight
              ? AppColors.auroraEmerald.withValues(alpha: 0.35)
              : Colors.white10,
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.auroraEmerald.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.energy_savings_leaf_rounded,
              size: 20,
              color: AppColors.auroraEmerald,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Auto AMOLED True-Black at Night',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Enables zero-power sub-pixel dark mode during sleep hours (22:00 – 06:00).',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white54,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: schedule.autoAmoledAtNight,
            activeThumbColor: AppColors.auroraEmerald,
            activeTrackColor: AppColors.auroraEmerald.withValues(alpha: 0.3),
            onChanged: (val) {
              final updated = schedule.copyWith(autoAmoledAtNight: val);
              context.read<WallpaperBloc>().add(UpdateDayNightScheduleIntent(updated));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSyncNowButton(
    BuildContext context,
    DayNightScheduleConfig schedule,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonCyan,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        icon: const Icon(Icons.sync_rounded, size: 18),
        label: const Text(
          'Evaluate & Apply Current Slot Now',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
        onPressed: () {
          context.read<WallpaperBloc>().add(const CheckDayNightTransitionIntent());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Checking solar time and synchronizing wallpaper...'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  void _openWallpaperPicker(
    BuildContext context,
    WallpaperState state,
    DayNightSlot slot,
    ValueChanged<String> onSelected,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (pickerContext) {
        return Container(
          height: MediaQuery.of(pickerContext).size.height * 0.75,
          decoration: const BoxDecoration(
            color: AppColors.modalBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(slot.icon, color: slot.accentColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Choose for ${slot.label}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white60),
                      onPressed: () {
                        if (pickerContext.mounted && Navigator.of(pickerContext).canPop()) {
                          Navigator.of(pickerContext).pop();
                        }
                      },
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white10, height: 1),

              // Wallpaper list
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.allShorts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (ctx, index) {
                    final item = state.allShorts[index];
                    final isSelected =
                        state.dayNightSchedule.getWallpaperIdForSlot(slot) == item.id;

                    return Material(
                      color: isSelected
                          ? slot.accentColor.withValues(alpha: 0.15)
                          : AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(12),
                      child: ListTile(
                        leading: _buildWallpaperThumbnail(item, width: 44, height: 56),
                        title: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? slot.accentColor : Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          '${item.category.toUpperCase()} • ${item.isLive ? "Live Wallpaper" : "Static 4K"}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white54,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_circle_rounded, color: slot.accentColor)
                            : const Icon(Icons.circle_outlined, color: Colors.white24),
                        onTap: () {
                          onSelected(item.id);
                          if (pickerContext.mounted && Navigator.of(pickerContext).canPop()) {
                            Navigator.of(pickerContext).pop();
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWallpaperThumbnail(
    MotivationalShort? wallpaper, {
    double width = 48,
    double height = 64,
  }) {
    if (wallpaper == null) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Icon(Icons.add_photo_alternate_rounded, size: 18, color: Colors.white38),
        ),
      );
    }

    final colors = wallpaper.gradientColors.isNotEmpty
        ? wallpaper.gradientColors
        : [wallpaper.accentColor.withValues(alpha: 0.7), Colors.black87];

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white24, width: 0.8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (wallpaper.imageUrl != null && wallpaper.imageUrl!.isNotEmpty)
            CachedWallpaperImage.thumbnail(
              imageUrl: wallpaper.imageUrl!,
              fit: BoxFit.cover,
            ),
          Center(
            child: Icon(
              wallpaper.isLive ? Icons.motion_photos_on_rounded : Icons.image_rounded,
              size: width * 0.4,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

