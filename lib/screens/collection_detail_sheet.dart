import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/wallpaper_bloc.dart';
import '../blocs/wallpaper_intent.dart';
import '../blocs/wallpaper_state.dart';
import '../core/core.dart';
import '../models/motivational_short.dart';
import '../models/wallpaper_collection.dart';
import 'wallpaper_preview_sheet.dart';
import 'wallpaper_quick_actions_sheet.dart';

class CollectionDetailSheet extends StatelessWidget {
  final WallpaperCollection collection;

  const CollectionDetailSheet({
    super.key,
    required this.collection,
  });

  static Future<void> show(BuildContext context, WallpaperCollection collection) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CollectionDetailSheet(collection: collection),
    );
  }

  void _confirmDelete(BuildContext context, WallpaperCollection col) {
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
          'Are you sure you want to delete "${col.title}"? Your saved wallpapers will not be deleted.',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (ctx.mounted && Navigator.of(ctx).canPop()) {
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              if (ctx.mounted && Navigator.of(ctx).canPop()) {
                Navigator.of(ctx).pop();
              }
              context.read<WallpaperBloc>().add(DeleteCustomCollectionIntent(col.id));
              if (context.mounted && Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
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
        final currentCollection = state.allCollections.firstWhere(
          (c) => c.id == collection.id,
          orElse: () => collection,
        );

        final wallpapers = state.allShorts
            .where((s) => currentCollection.wallpaperIds.contains(s.id))
            .toList();

        final isCurrentRotationPool = state.autoRotationSource == currentCollection.id;

        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.darkBackground,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.only(bottom: 32),
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 14, bottom: 12),
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Collection Header Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: currentCollection.gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: Colors.white12),
                        boxShadow: [
                          BoxShadow(
                            color: currentCollection.gradientColors[1].withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white24, width: 0.8),
                                ),
                                child: Text(
                                  currentCollection.badge,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  if (currentCollection.isUserCreated)
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded,
                                          color: Colors.white70, size: 22),
                                      tooltip: 'Delete Playlist',
                                      onPressed: () => _confirmDelete(context, currentCollection),
                                    ),
                                  Icon(
                                    currentCollection.icon,
                                    color: Colors.white70,
                                    size: 24,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            currentCollection.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            currentCollection.subtitle,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${wallpapers.length} Curated Canvases',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  context.read<WallpaperBloc>().add(
                                        UpdateAutoRotationSourceIntent(currentCollection.id),
                                      );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isCurrentRotationPool
                                        ? AppColors.auroraEmerald.withValues(alpha: 0.25)
                                        : Colors.black.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isCurrentRotationPool
                                          ? AppColors.auroraEmerald
                                          : Colors.white24,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isCurrentRotationPool
                                            ? Icons.check_circle_rounded
                                            : Icons.sync_rounded,
                                        size: 14,
                                        color: isCurrentRotationPool
                                            ? AppColors.auroraEmerald
                                            : Colors.white70,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        isCurrentRotationPool
                                            ? 'ACTIVE ROTATION'
                                            : 'USE FOR ROTATION',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: isCurrentRotationPool
                                              ? AppColors.auroraEmerald
                                              : Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Empty State or Wallpaper Grid
                  if (wallpapers.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.collections_bookmark_outlined,
                                size: 48, color: Colors.white24),
                            const SizedBox(height: 12),
                            const Text(
                              'Playlist is Empty',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Tap the playlist icon on any wallpaper preview to add it to this collection.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            MediaQuery.of(context).size.width >= 1100
                                ? 5
                                : MediaQuery.of(context).size.width >= 750
                                    ? 4
                                    : 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.64,
                      ),
                      itemCount: wallpapers.length,
                      itemBuilder: (context, index) {
                        final item = wallpapers[index];
                        return _buildWallpaperCard(context, item);
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

  Widget _buildWallpaperCard(BuildContext context, MotivationalShort item) {
    return GestureDetector(
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
            // Dark gradient overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.85)],
                ),
              ),
            ),
            // Type badge
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: item.accentColor, width: 0.8),
                ),
                child: Row(
                  children: [
                    Icon(
                      item.isLive ? Icons.play_arrow_rounded : Icons.image_rounded,
                      color: item.accentColor,
                      size: 10,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      item.isLive ? 'LIVE' : '4K',
                      style: TextStyle(
                        color: item.accentColor,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Title & Author/Category
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
  }
}
