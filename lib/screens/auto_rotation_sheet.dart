import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/wallpaper_bloc.dart';
import '../blocs/wallpaper_intent.dart';
import '../blocs/wallpaper_state.dart';
import '../data/curated_shorts_data.dart';

class AutoRotationSheet extends StatelessWidget {
  const AutoRotationSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AutoRotationSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WallpaperBloc, WallpaperState>(
      builder: (context, state) {
        return DraggableScrollableSheet(
          initialChildSize: 0.92,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF101014),
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
                                color: const Color(0xFFFF5722).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFFF5722), width: 0.8),
                              ),
                              child: const Icon(
                                Icons.autorenew_rounded,
                                size: 18,
                                color: Color(0xFFFF5722),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AURORA AUTO-ROTATION',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Automatic Wallpaper Rotation Engine',
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
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),

                  const Divider(color: Colors.white10, height: 1),

                  // Body
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      children: [
                        // Master Activation Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: state.isAutoRotationEnabled
                                  ? [
                                      const Color(0xFF1B0B2E),
                                      const Color(0xFF311B92),
                                      const Color(0xFF0D061A),
                                    ]
                                  : [
                                      const Color(0xFF18181C),
                                      const Color(0xFF131316),
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: state.isAutoRotationEnabled
                                  ? const Color(0xFF7C4DFF).withValues(alpha: 0.6)
                                  : Colors.white12,
                            ),
                            boxShadow: state.isAutoRotationEnabled
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF7C4DFF).withValues(alpha: 0.3),
                                      blurRadius: 18,
                                      offset: const Offset(0, 6),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: state.isAutoRotationEnabled
                                      ? const Color(0xFF7C4DFF).withValues(alpha: 0.25)
                                      : Colors.white10,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  state.isAutoRotationEnabled
                                      ? Icons.sync_rounded
                                      : Icons.sync_disabled_rounded,
                                  color: state.isAutoRotationEnabled
                                      ? const Color(0xFF7C4DFF)
                                      : Colors.white38,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      state.isAutoRotationEnabled
                                          ? 'Auto-Rotation Active'
                                          : 'Auto-Rotation Paused',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      state.isAutoRotationEnabled
                                          ? 'Cycles wallpapers automatically'
                                          : 'Turn on to refresh wallpaper periodically',
                                      style: const TextStyle(
                                        color: Colors.white60,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch.adaptive(
                                value: state.isAutoRotationEnabled,
                                activeThumbColor: const Color(0xFFFF5722),
                                activeTrackColor: const Color(0xFFFF5722).withValues(alpha: 0.4),
                                onChanged: (val) {
                                  HapticFeedback.mediumImpact();
                                  context.read<WallpaperBloc>().add(
                                        ToggleAutoRotationIntent(val),
                                      );
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Section 1: Frequency Interval
                        const Text(
                          'ROTATION FREQUENCY',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildIntervalChip(context, state, 60, '1 Hour'),
                            _buildIntervalChip(context, state, 180, '3 Hours'),
                            _buildIntervalChip(context, state, 360, '6 Hours'),
                            _buildIntervalChip(context, state, 720, '12 Hours'),
                            _buildIntervalChip(context, state, 1440, 'Daily (24h)'),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Section 2: Playlist Source Pool
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'PLAYLIST SOURCE POOL',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                                color: Colors.white54,
                              ),
                            ),
                            Text(
                              '${state.rotationPoolShorts.length} Canvases in Pool',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFFF5722),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Option A: My Favorites
                        _buildSourceTile(
                          context: context,
                          id: 'favorites',
                          title: 'My Favorites',
                          subtitle: '${state.favoriteIds.length} favorited canvases',
                          icon: Icons.favorite_rounded,
                          accentColor: const Color(0xFFFF1744),
                          isSelected: state.autoRotationSource == 'favorites',
                        ),
                        const SizedBox(height: 8),

                        // Option B: My Custom Playlists (if any)
                        if (state.customCollections.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'MY PLAYLISTS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: Color(0xFF00E5FF),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...state.customCollections.map((col) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _buildSourceTile(
                                context: context,
                                id: col.id,
                                title: col.title,
                                subtitle: '${col.wallpaperIds.length} canvases • ${col.subtitle}',
                                icon: col.icon,
                                accentColor: col.gradientColors.first,
                                isSelected: state.autoRotationSource == col.id,
                              ),
                            );
                          }),
                        ],

                        // Option C: Curated Collections
                        const SizedBox(height: 8),
                        const Text(
                          'CURATED COLLECTIONS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...CuratedShortsData.collections.map((col) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _buildSourceTile(
                              context: context,
                              id: col.id,
                              title: col.title,
                              subtitle: '${col.wallpaperIds.length} canvases • ${col.badge}',
                              icon: col.icon,
                              accentColor: col.gradientColors[1],
                              isSelected: state.autoRotationSource == col.id,
                            ),
                          );
                        }),

                        // Option C: All Library
                        _buildSourceTile(
                          context: context,
                          id: 'all',
                          title: 'Complete Wallora Catalog',
                          subtitle: 'All ${state.allShorts.length} static & live wallpapers',
                          icon: Icons.auto_awesome_rounded,
                          accentColor: const Color(0xFFFF5722),
                          isSelected: state.autoRotationSource == 'all',
                        ),

                        const SizedBox(height: 24),

                        // Section 3: Target Screen
                        const Text(
                          'APPLY DESTINATION',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildTargetOption(context, state, 'both', 'Home & Lock', Icons.smartphone_rounded),
                            const SizedBox(width: 8),
                            _buildTargetOption(context, state, 'home', 'Home Only', Icons.home_rounded),
                            const SizedBox(width: 8),
                            _buildTargetOption(context, state, 'lock', 'Lock Only', Icons.lock_rounded),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Section 4: Battery & Network Guards
                        const Text(
                          'INTELLIGENCE & BATTERY GUARDS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF18181C),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.wifi_rounded, color: Colors.white70, size: 18),
                                      SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Wi-Fi Only Rotation',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Text(
                                            'Preserves mobile data allowance',
                                            style: TextStyle(color: Colors.white38, fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Switch.adaptive(
                                    value: state.autoRotationWifiOnly,
                                    activeThumbColor: const Color(0xFFFF5722),
                                    onChanged: (val) {
                                      HapticFeedback.selectionClick();
                                      context.read<WallpaperBloc>().add(
                                            UpdateAutoRotationWifiOnlyIntent(val),
                                          );
                                    },
                                  ),
                                ],
                              ),
                              const Divider(color: Colors.white10, height: 20),
                              const Row(
                                children: [
                                  Icon(Icons.battery_charging_full_rounded, color: Color(0xFF69F0AE), size: 18),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Zero Sleep Wake-Locks',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          'Rotation triggers only during active unlock; never drains battery while display is asleep.',
                                          style: TextStyle(color: Colors.white38, fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Section 5: Rotate Wallpaper Now (Immediate Test Action)
                        SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              HapticFeedback.heavyImpact();
                              context.read<WallpaperBloc>().add(
                                    RotateWallpaperNowIntent(),
                                  );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF5722),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                            ),
                            icon: const Icon(Icons.cached_rounded, size: 20),
                            label: const Text(
                              'ROTATE WALLPAPER NOW',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
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

  Widget _buildIntervalChip(
    BuildContext context,
    WallpaperState state,
    int minutes,
    String label,
  ) {
    final isSelected = state.autoRotationIntervalMinutes == minutes;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          HapticFeedback.selectionClick();
          context.read<WallpaperBloc>().add(
                UpdateAutoRotationIntervalIntent(minutes),
              );
        }
      },
      selectedColor: const Color(0xFFFF5722).withValues(alpha: 0.2),
      backgroundColor: const Color(0xFF1E1E22),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFFFF5722) : Colors.white70,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        fontSize: 12,
      ),
      side: BorderSide(
        color: isSelected ? const Color(0xFFFF5722) : Colors.white12,
      ),
    );
  }

  Widget _buildSourceTile({
    required BuildContext context,
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        context.read<WallpaperBloc>().add(
              UpdateAutoRotationSourceIntent(id),
            );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withValues(alpha: 0.12) : const Color(0xFF18181C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accentColor : Colors.white10,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accentColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 1),
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
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: accentColor, size: 20)
            else
              const Icon(Icons.radio_button_unchecked_rounded, color: Colors.white24, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetOption(
    BuildContext context,
    WallpaperState state,
    String target,
    String label,
    IconData icon,
  ) {
    final isSelected = state.autoRotationTarget == target;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          context.read<WallpaperBloc>().add(
                UpdateAutoRotationTargetIntent(target),
              );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFFF5722).withValues(alpha: 0.15)
                : const Color(0xFF18181C),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? const Color(0xFFFF5722) : Colors.white10,
              width: isSelected ? 1.2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? const Color(0xFFFF5722) : Colors.white60,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
