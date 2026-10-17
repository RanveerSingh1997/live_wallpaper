import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/wallpaper_bloc.dart';
import '../blocs/wallpaper_intent.dart';
import '../blocs/wallpaper_state.dart';
import '../models/motivational_short.dart';
import '../widgets/video_player_item.dart';
import 'ipad_wallpaper_dialog.dart';
import 'quote_studio_sheet.dart';

class WallpaperPreviewSheet extends StatelessWidget {
  final MotivationalShort wallpaper;

  const WallpaperPreviewSheet({
    super.key,
    required this.wallpaper,
  });

  static Future<void> show(BuildContext context, MotivationalShort wallpaper) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => WallpaperPreviewSheet(wallpaper: wallpaper),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WallpaperBloc, WallpaperState>(
      builder: (context, state) {
        final isFav = state.favoriteIds.contains(wallpaper.id);
        final isDownloaded = state.downloadedIds.contains(wallpaper.id);
        final isActive = state.activeWallpaperId == wallpaper.id &&
            state.isLiveWallpaperActiveOnDevice;
        final effectiveQuote = state.getEffectiveQuote(wallpaper);
        final isCustomized = state.customizedQuotes.containsKey(wallpaper.id);

        final related = state.allShorts
            .where((s) => s.id != wallpaper.id && s.category == wallpaper.category)
            .take(4)
            .toList();

        return DraggableScrollableSheet(
          initialChildSize: 0.92,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF101012),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.only(bottom: 36),
                children: [
                  // Top Drag Handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 14, bottom: 12),
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Wallpaper Visual Preview Canvas
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AspectRatio(
                      aspectRatio: 9 / 13,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (wallpaper.isLive)
                              VideoPlayerItem(
                                key: ValueKey('preview_${wallpaper.id}'),
                                videoAssetPath: wallpaper.videoAssetPath,
                                isActive: true,
                                isMuted: true,
                                onDoubleTapLike: () {
                                  context
                                      .read<WallpaperBloc>()
                                      .add(ToggleFavoriteIntent(wallpaper.id));
                                },
                              )
                            else
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: wallpaper.gradientColors.isNotEmpty
                                        ? wallpaper.gradientColors
                                        : [
                                            wallpaper.accentColor.withValues(alpha: 0.4),
                                            Colors.black,
                                          ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.wallpaper_rounded,
                                    size: 64,
                                    color: wallpaper.accentColor.withValues(alpha: 0.6),
                                  ),
                                ),
                              ),

                            // Ambient Gradient Vignette
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.4),
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.8),
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ),
                              ),
                            ),

                            // Top Badges (Live/Static, Resolution)
                            Positioned(
                              top: 14,
                              left: 14,
                              right: 14,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.7),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: wallpaper.accentColor,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          wallpaper.isLive
                                              ? Icons.videocam_rounded
                                              : Icons.image_rounded,
                                          size: 13,
                                          color: wallpaper.accentColor,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          wallpaper.isLive ? 'LIVE 60FPS' : '4K ULTRA-HD',
                                          style: TextStyle(
                                            color: wallpaper.accentColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                                    onPressed: () => Navigator.of(context).pop(),
                                  ),
                                ],
                              ),
                            ),

                            // Bottom Quote / Title Preview Overlay
                            if (wallpaper.hasTextByDefault || isCustomized)
                              Positioned(
                                left: 16,
                                right: 16,
                                bottom: 16,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.65),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: Colors.white12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '"$effectiveQuote"',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '— ${wallpaper.author}',
                                        style: TextStyle(
                                          color: wallpaper.accentColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Metadata & Specifications Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    wallpaper.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${wallpaper.category} • ${wallpaper.mood}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isActive)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00E676).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFF00E676)),
                                ),
                                child: const Text(
                                  'ACTIVE ON DEVICE',
                                  style: TextStyle(
                                    color: Color(0xFF00E676),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Technical Specs Grid
                        Row(
                          children: [
                            _buildSpecChip(
                              icon: Icons.aspect_ratio_rounded,
                              label: 'Resolution',
                              value: wallpaper.resolution,
                            ),
                            const SizedBox(width: 8),
                            _buildSpecChip(
                              icon: Icons.storage_rounded,
                              label: 'File Size',
                              value: wallpaper.fileSizeFormatted,
                            ),
                            const SizedBox(width: 8),
                            _buildSpecChip(
                              icon: Icons.loop_rounded,
                              label: 'Type',
                              value: wallpaper.isLive ? 'Looping Live' : 'Static Ultra-HD',
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Action Buttons Dock (Apply, Download, Favorite, Share)
                        Row(
                          children: [
                            // Primary CTA: Apply Live Wallpaper
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    HapticFeedback.mediumImpact();
                                    Navigator.of(context).pop();
                                    if (Platform.isIOS) {
                                      IPadWallpaperDialog.show(context, wallpaper);
                                    } else {
                                      context.read<WallpaperBloc>().add(
                                            ApplyLiveWallpaperIntent(
                                              short: wallpaper,
                                              isMuted: true,
                                            ),
                                          );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: wallpaper.accentColor,
                                    foregroundColor: Colors.black,
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  icon: const Icon(Icons.wallpaper_rounded, size: 20),
                                  label: Text(
                                    isActive ? 'RE-APPLY' : 'APPLY WALLPAPER',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            // Offline Download Button
                            _buildIconButton(
                              icon: isDownloaded
                                  ? Icons.check_circle_rounded
                                  : Icons.file_download_outlined,
                              color: isDownloaded
                                  ? const Color(0xFF00E676)
                                  : Colors.white,
                              tooltip: isDownloaded ? 'Downloaded' : 'Download for Offline',
                              onTap: () {
                                HapticFeedback.selectionClick();
                                if (!isDownloaded) {
                                  context.read<WallpaperBloc>().add(
                                        DownloadWallpaperIntent(wallpaper),
                                      );
                                }
                              },
                            ),

                            const SizedBox(width: 8),

                            // Favorite Button
                            _buildIconButton(
                              icon: isFav
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: isFav ? const Color(0xFFFF1744) : Colors.white,
                              tooltip: isFav ? 'Remove Favorite' : 'Save to Favorites',
                              onTap: () {
                                HapticFeedback.selectionClick();
                                context.read<WallpaperBloc>().add(
                                      ToggleFavoriteIntent(wallpaper.id),
                                    );
                              },
                            ),

                            const SizedBox(width: 8),

                            // Customize Quote Button
                            _buildIconButton(
                              icon: Icons.edit_note_rounded,
                              color: Colors.white70,
                              tooltip: 'Customize Quote',
                              onTap: () {
                                HapticFeedback.selectionClick();
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (ctx) => QuoteStudioSheet(
                                    short: wallpaper,
                                    currentQuote: effectiveQuote,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        if (related.isNotEmpty) ...[
                          const SizedBox(height: 28),
                          const Text(
                            'MORE IN THIS CATEGORY',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white54,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 110,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: related.length,
                              separatorBuilder: (context, index) => const SizedBox(width: 10),
                              itemBuilder: (ctx, idx) {
                                final rel = related[idx];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    WallpaperPreviewSheet.show(context, rel);
                                  },
                                  child: Container(
                                    width: 85,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: LinearGradient(
                                        colors: rel.gradientColors.isNotEmpty
                                            ? rel.gradientColors
                                            : [
                                                rel.accentColor.withValues(alpha: 0.3),
                                                Colors.black,
                                              ],
                                      ),
                                      border: Border.all(color: Colors.white12),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          rel.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
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

  Widget _buildSpecChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E22),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 12, color: Colors.white38),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: const Color(0xFF1E1E22),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }
}
