import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/wallpaper_bloc.dart';
import '../blocs/wallpaper_intent.dart';
import '../blocs/wallpaper_state.dart';
import '../models/motivational_short.dart';
import 'create_collection_sheet.dart';

class AddToCollectionSheet extends StatelessWidget {
  final MotivationalShort short;

  const AddToCollectionSheet({
    super.key,
    required this.short,
  });

  static Future<void> show(BuildContext context, MotivationalShort short) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddToCollectionSheet(short: short),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WallpaperBloc, WallpaperState>(
      builder: (context, state) {
        final collections = state.customCollections;

        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF101014),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  // Drag Handle
                  Container(
                    margin: const EdgeInsets.only(top: 14, bottom: 12),
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header with Wallpaper Info & New Playlist CTA
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        // Mini Wallpaper Thumbnail
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              colors: short.gradientColors.isNotEmpty
                                  ? short.gradientColors
                                  : [const Color(0xFF2A163B), Colors.black],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Icon(
                            short.isLive ? Icons.loop_rounded : Icons.image_rounded,
                            color: short.accentColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                short.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Add to Playlists',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            CreateCollectionSheet.show(
                              context,
                              initialWallpaperId: short.id,
                            );
                          },
                          icon: const Icon(Icons.add_rounded, size: 16, color: Color(0xFF00E5FF)),
                          label: const Text(
                            'NEW',
                            style: TextStyle(
                              color: Color(0xFF00E5FF),
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(color: Colors.white10, height: 20),

                  // Playlists List or Empty State
                  Expanded(
                    child: collections.isEmpty
                        ? _buildEmptyState(context)
                        : ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            itemCount: collections.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final col = collections[index];
                              final isIncluded = col.wallpaperIds.contains(short.id);

                              return Material(
                                color: const Color(0xFF16161C),
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    context.read<WallpaperBloc>().add(
                                          ToggleWallpaperInCollectionIntent(
                                            collectionId: col.id,
                                            wallpaperId: short.id,
                                          ),
                                        );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    child: Row(
                                      children: [
                                        // Playlist Icon Container
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: col.gradientColors,
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(col.icon, color: Colors.white, size: 20),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                col.title,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 14,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${col.wallpaperIds.length} canvases • ${col.subtitle}',
                                                style: const TextStyle(
                                                  color: Colors.white54,
                                                  fontSize: 11,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: isIncluded
                                                ? const Color(0xFF00E5FF)
                                                : Colors.transparent,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isIncluded
                                                  ? const Color(0xFF00E5FF)
                                                  : Colors.white30,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: isIncluded
                                              ? const Icon(
                                                  Icons.check_rounded,
                                                  color: Colors.black,
                                                  size: 18,
                                                )
                                              : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  // Bottom Done Button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          if (mounted(context) && Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF22222A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'DONE',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
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

  bool mounted(BuildContext context) {
    try {
      return Navigator.of(context).context.mounted;
    } catch (_) {
      return true;
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.playlist_add_rounded,
                color: Color(0xFF00E5FF),
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Custom Playlists Yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Create personal wallpaper playlists to curate and auto-rotate your favorite canvases.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.selectionClick();
                CreateCollectionSheet.show(
                  context,
                  initialWallpaperId: short.id,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text(
                'CREATE PLAYLIST',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
