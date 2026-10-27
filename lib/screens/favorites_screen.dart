import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/wallpaper_bloc.dart';
import '../blocs/wallpaper_intent.dart';
import '../blocs/wallpaper_state.dart';
import '../core/core.dart';
import 'wallpaper_preview_sheet.dart';
import 'wallpaper_quick_actions_sheet.dart';
import '../widgets/fluid_pressable.dart';

class FavoritesScreen extends StatefulWidget {
  final VoidCallback onBrowseWallpapers;

  const FavoritesScreen({
    super.key,
    required this.onBrowseWallpapers,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WallpaperBloc, WallpaperState>(
      builder: (context, state) {
        final favorites = state.favoriteShorts;

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            title: Row(
              children: [
                const Icon(Icons.favorite_rounded, color: AppColors.favoriteRed, size: 20),
                const SizedBox(width: 8),
                Text(
                  'FAVORITES (${favorites.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          body: favorites.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.favoriteRed.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite_border_rounded,
                            size: 48,
                            color: AppColors.favoriteRed,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'No Favorites Saved Yet',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tap the heart icon or double-tap any live video to bookmark your favorite wallpapers here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            widget.onBrowseWallpapers();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.favoriteRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.explore_rounded, size: 18),
                          label: const Text(
                            'Discover Wallpapers',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Filter Chips Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          _buildFilterChip('All', favorites.length),
                          const SizedBox(width: 8),
                          _buildFilterChip('Live', favorites.where((s) => s.isLive).length),
                          const SizedBox(width: 8),
                          _buildFilterChip('Static', favorites.where((s) => !s.isLive).length),
                        ],
                      ),
                    ),
                    Expanded(
                      child: (_filter == 'Live'
                                  ? favorites.where((s) => s.isLive).toList()
                                  : _filter == 'Static'
                                      ? favorites.where((s) => !s.isLive).toList()
                                      : favorites)
                              .isEmpty
                          ? Center(
                              child: Text(
                                'No $_filter favorites found.',
                                style: const TextStyle(color: Colors.white38, fontSize: 13),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: GridView.builder(
                                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                                padding: const EdgeInsets.only(bottom: 96),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      MediaQuery.of(context).size.width >= 1100
                                          ? 5
                                          : MediaQuery.of(context).size.width >=
                                                  750
                                              ? 4
                                              : 3,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 0.63,
                                ),
                                itemCount: (_filter == 'Live'
                                        ? favorites.where((s) => s.isLive).toList()
                                        : _filter == 'Static'
                                            ? favorites.where((s) => !s.isLive).toList()
                                            : favorites)
                                    .length,
                                itemBuilder: (context, index) {
                                  final item = (_filter == 'Live'
                                      ? favorites.where((s) => s.isLive).toList()
                                      : _filter == 'Static'
                                          ? favorites.where((s) => !s.isLive).toList()
                                          : favorites)[index];
                      return FluidPressable(
                        onTap: () {
                          WallpaperPreviewSheet.show(context, item);
                        },
                        onLongPress: () {
                          WallpaperQuickActionsSheet.show(context, item);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: item.gradientColors.isNotEmpty
                                  ? item.gradientColors
                                  : [item.accentColor.withValues(alpha: 0.3), Colors.black],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.85),
                                    ],
                                  ),
                                ),
                              ),
                              // Heart remove button
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    context
                                        .read<WallpaperBloc>()
                                        .add(ToggleFavoriteIntent(item.id));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.favorite_rounded,
                                      color: AppColors.favoriteRed,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                              // Type Badge
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item.isLive ? 'LIVE' : '4K',
                                    style: TextStyle(
                                      color: item.accentColor,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                              // Title & Category
                              Positioned(
                                bottom: 12,
                                left: 12,
                                right: 12,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.category,
                                      style: TextStyle(
                                        color: item.accentColor,
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
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String filterName, int count) {
    final isSelected = _filter == filterName;
    return ChoiceChip(
      label: Text('$filterName ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          HapticFeedback.selectionClick();
          setState(() => _filter = filterName);
        }
      },
      backgroundColor: AppColors.cardBackground,
      selectedColor: AppColors.favoriteRed.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.favoriteRed : Colors.white70,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? AppColors.favoriteRed : Colors.white12,
          width: isSelected ? 1.2 : 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }
}
