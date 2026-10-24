import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/wallpaper_bloc.dart';
import '../blocs/wallpaper_intent.dart';
import '../blocs/wallpaper_state.dart';
import '../core/core.dart';
import '../data/curated_shorts_data.dart';
import '../models/wallpaper_collection.dart';
import 'collection_detail_sheet.dart';
import 'create_collection_sheet.dart';
import 'wallpaper_preview_sheet.dart';
import 'wallpaper_quick_actions_sheet.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  int _selectedTabIndex = 0; // 0: Genres, 1: Playlists & Collections

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Anime & Gaming':
        return Icons.sports_mma_rounded;
      case 'Nature & Scenery':
        return Icons.landscape_rounded;
      case 'Cyberpunk & Tech':
        return Icons.terminal_rounded;
      case 'Cars & Speed':
        return Icons.speed_rounded;
      case 'Minimal & AMOLED':
        return Icons.dark_mode_rounded;
      case 'Fitness & Grind':
        return Icons.fitness_center_rounded;
      case 'Motivation & Mindset':
        return Icons.psychology_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Anime & Gaming':
        return AppColors.sunsetAmber;
      case 'Nature & Scenery':
        return AppColors.cyberEmerald;
      case 'Cyberpunk & Tech':
        return AppColors.auroraViolet;
      case 'Cars & Speed':
        return AppColors.favoriteRed;
      case 'Minimal & AMOLED':
        return AppColors.deepPurple;
      case 'Fitness & Grind':
        return AppColors.warning;
      case 'Motivation & Mindset':
        return AppColors.neonCyan;
      default:
        return Colors.white70;
    }
  }

  void _confirmDeletePlaylist(BuildContext context, WallpaperCollection col) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.modalBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Playlist?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${col.title}"? Wallpapers inside will remain in your library.',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (mounted && Navigator.of(ctx).canPop()) {
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              if (mounted && Navigator.of(ctx).canPop()) {
                Navigator.of(ctx).pop();
              }
              context.read<WallpaperBloc>().add(DeleteCustomCollectionIntent(col.id));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted playlist "${col.title}"'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'DELETE',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WallpaperBloc, WallpaperState>(
      builder: (context, state) {
        final categories = CuratedShortsData.availablePreferences;

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            title: Row(
              children: [
                const Icon(Icons.grid_view_rounded, color: AppColors.sunsetAmber, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'CATEGORIES',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                if (_selectedTabIndex == 1)
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded,
                        color: AppColors.neonCyan, size: 22),
                    tooltip: 'New Playlist',
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      CreateCollectionSheet.show(context);
                    },
                  ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedTabIndex = 0);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: _selectedTabIndex == 0
                                  ? AppColors.sunsetAmber
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'GENRES',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                                color: _selectedTabIndex == 0
                                    ? Colors.black
                                    : Colors.white60,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedTabIndex = 1);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: _selectedTabIndex == 1
                                  ? AppColors.neonCyan
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'PLAYLISTS (${state.allCollections.length})',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                                color: _selectedTabIndex == 1
                                    ? Colors.black
                                    : Colors.white60,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: _selectedTabIndex == 0
              ? _buildGenresGrid(context, state, categories)
              : _buildPlaylistsTab(context, state),
        );
      },
    );
  }

  Widget _buildGenresGrid(
    BuildContext context,
    WallpaperState state,
    List<String> categories,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.15,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final count = state.allShorts.where((s) => s.category == category).length;
          final color = _getCategoryColor(category);
          final icon = _getCategoryIcon(category);

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              _showCategoryItemsSheet(context, category, color);
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: color.withValues(alpha: 0.25)),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$count Wallpapers',
                        style: TextStyle(
                          color: color.withValues(alpha: 0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaylistsTab(BuildContext context, WallpaperState state) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
      children: [
        // Create Playlist Hero Button
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            CreateCollectionSheet.show(context);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.deepPurple, AppColors.neonCyan],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.4)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonCyan.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: AppColors.neonCyan,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Custom Playlist',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Curate & auto-rotate your favorite wallpapers',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white70, size: 14),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Section: User Playlists
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.person_pin_rounded,
                    color: AppColors.neonCyan, size: 18),
                SizedBox(width: 6),
                Text(
                  'MY PLAYLISTS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            Text(
              '${state.customCollections.length} CREATED',
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        if (state.customCollections.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                Icon(Icons.playlist_play_rounded,
                    color: Colors.white24, size: 36),
                const SizedBox(height: 10),
                const Text(
                  'No Custom Playlists Yet',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tap the button above to create your first personal wallpaper playlist.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.95,
            ),
            itemCount: state.customCollections.length,
            itemBuilder: (context, index) {
              final col = state.customCollections[index];
              return _buildPlaylistCard(context, col, isUserCreated: true);
            },
          ),

        const SizedBox(height: 28),

        // Section: Curated Editorial Collections
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_awesome_rounded,
                    color: AppColors.auroraViolet, size: 18),
                SizedBox(width: 6),
                Text(
                  'EDITORIAL COLLECTIONS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            Text(
              '${CuratedShortsData.collections.length} COLLECTIONS',
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.95,
          ),
          itemCount: CuratedShortsData.collections.length,
          itemBuilder: (context, index) {
            final col = CuratedShortsData.collections[index];
            return _buildPlaylistCard(context, col, isUserCreated: false);
          },
        ),
      ],
    );
  }

  Widget _buildPlaylistCard(
    BuildContext context,
    WallpaperCollection col, {
    required bool isUserCreated,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        CollectionDetailSheet.show(context, col);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: col.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white12),
          boxShadow: [
            BoxShadow(
              color: col.gradientColors.first.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24, width: 0.8),
                  ),
                  child: Text(
                    col.badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (isUserCreated)
                  GestureDetector(
                    onTap: () => _confirmDeletePlaylist(context, col),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.white70,
                        size: 16,
                      ),
                    ),
                  )
                else
                  Icon(col.icon, color: Colors.white70, size: 18),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  col.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${col.wallpaperIds.length} Canvases',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryItemsSheet(BuildContext context, String category, Color color) {
    final bloc = context.read<WallpaperBloc>();
    final items = bloc.state.allShorts.where((s) => s.category == category).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (ctx, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.modalBackground,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(_getCategoryIcon(category), color: color, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              category,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white54),
                          onPressed: () {
                            if (mounted && Navigator.of(ctx).canPop()) {
                              Navigator.of(ctx).pop();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: items.length,
                      itemBuilder: (ctx, idx) {
                        final item = items[idx];
                        return GestureDetector(
                          onTap: () {
                            WallpaperPreviewSheet.show(context, item);
                          },
                          onLongPress: () {
                            HapticFeedback.heavyImpact();
                            WallpaperQuickActionsSheet.show(context, item);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: item.gradientColors.isNotEmpty
                                    ? item.gradientColors
                                    : [color.withValues(alpha: 0.3), Colors.black],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              border: Border.all(color: Colors.white12),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
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
                                    if (item.isAmoledCertified) ...[
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.7),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: AppColors.auroraEmerald.withValues(alpha: 0.5),
                                            width: 0.6,
                                          ),
                                        ),
                                        child: Text(
                                          '${item.trueBlackPercentage}% OLED',
                                          style: const TextStyle(
                                            color: AppColors.auroraEmerald,
                                            fontSize: 8,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 6),
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
                              ],
                            ),
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
      },
    );
  }
}
