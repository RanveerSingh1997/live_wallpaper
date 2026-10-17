import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/wallpaper_bloc.dart';
import '../blocs/wallpaper_intent.dart';
import '../blocs/wallpaper_state.dart';
import '../models/motivational_short.dart';
import 'add_to_collection_sheet.dart';
import 'fullscreen_wallpaper_viewer.dart';
import 'ipad_wallpaper_dialog.dart';
import 'quote_studio_sheet.dart';
import 'wallpaper_effects_sheet.dart';
import 'wallpaper_export_sheet.dart';

class WallpaperQuickActionsSheet extends StatelessWidget {
  final MotivationalShort wallpaper;

  const WallpaperQuickActionsSheet({
    super.key,
    required this.wallpaper,
  });

  static Future<void> show(BuildContext context, MotivationalShort wallpaper) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => WallpaperQuickActionsSheet(wallpaper: wallpaper),
    );
  }

  void _showStaticTargetSelector(
    BuildContext context,
    MotivationalShort short,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF16161C),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'APPLY STATIC WALLPAPER',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 16),
              _buildTargetTile(
                context: ctx,
                title: 'Home Screen & Lock Screen (Recommended)',
                icon: Icons.smartphone_rounded,
                target: 'both',
                short: short,
              ),
              const SizedBox(height: 8),
              _buildTargetTile(
                context: ctx,
                title: 'Home Screen Only',
                icon: Icons.home_rounded,
                target: 'home',
                short: short,
              ),
              const SizedBox(height: 8),
              _buildTargetTile(
                context: ctx,
                title: 'Lock Screen Only',
                icon: Icons.lock_rounded,
                target: 'lock',
                short: short,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTargetTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String target,
    required MotivationalShort short,
  }) {
    return Material(
      color: const Color(0xFF22222A),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          HapticFeedback.selectionClick();
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          context.read<WallpaperBloc>().add(
                ApplyStaticWallpaperIntent(
                  short: short,
                  targetScreen: target,
                ),
              );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: short.accentColor, size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white30, size: 12),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WallpaperBloc, WallpaperState>(
      builder: (context, state) {
        final isFav = state.favoriteIds.contains(wallpaper.id);
        final isDownloaded = state.downloadedIds.contains(wallpaper.id);

        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF101014),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 36),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag Handle
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Wallpaper Mini Header Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF18181F),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    // Wallpaper Thumbnail
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: wallpaper.gradientColors.isNotEmpty
                              ? wallpaper.gradientColors
                              : [wallpaper.accentColor.withValues(alpha: 0.3), Colors.black],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Icon(
                        wallpaper.isLive ? Icons.loop_rounded : Icons.image_rounded,
                        color: wallpaper.accentColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            wallpaper.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${wallpaper.category} • ${wallpaper.resolution}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (wallpaper.isAmoledCertified) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E676).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFF00E676).withValues(alpha: 0.4),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                wallpaper.trueBlackPercentage > 0
                                    ? 'AMOLED ${wallpaper.trueBlackPercentage}% BLACK'
                                    : 'AMOLED TRUE BLACK',
                                style: const TextStyle(
                                  color: Color(0xFF00E676),
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Actions List
              // Action 1: Apply to Device
              _buildActionTile(
                context: context,
                icon: Icons.wallpaper_rounded,
                iconColor: wallpaper.accentColor,
                title: 'Apply to Device',
                subtitle: wallpaper.isLive ? 'Continuous 60 FPS motion loop' : 'Ultra-HD static canvas',
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                  if (Platform.isIOS) {
                    IPadWallpaperDialog.show(context, wallpaper);
                  } else if (wallpaper.isLive) {
                    context.read<WallpaperBloc>().add(
                          ApplyLiveWallpaperIntent(
                            short: wallpaper,
                            isMuted: true,
                          ),
                        );
                  } else {
                    _showStaticTargetSelector(context, wallpaper);
                  }
                },
              ),

              const SizedBox(height: 8),

              // Action 2: Interactive Screen Simulator
              _buildActionTile(
                context: context,
                icon: Icons.screenshot_monitor_rounded,
                iconColor: const Color(0xFF00E5FF),
                title: 'Interactive Screen Simulator',
                subtitle: 'Preview behind Lock Screen clock & Home Screen icons',
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                  FullScreenWallpaperViewer.open(
                     context,
                     wallpaper: wallpaper,
                     playlist: state.allShorts,
                   );
                 },
               ),

               const SizedBox(height: 8),

              // Action 3: Canvas Effects & Filters Studio
              _buildActionTile(
                context: context,
                icon: Icons.tune_rounded,
                iconColor: const Color(0xFF00E5FF),
                title: 'Canvas Effects & Filters Studio',
                subtitle: 'Tune OLED Noir, depth blur, Obsidian vignette & contrast',
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                  WallpaperEffectsSheet.show(context, wallpaper);
                },
              ),

              const SizedBox(height: 8),

              // Action 4: Export Story & Poster
              _buildActionTile(
                context: context,
                icon: Icons.ios_share_rounded,
                iconColor: const Color(0xFFFF5722),
                title: 'Export Story & Poster',
                subtitle: 'Generate 9:16 high-res posters with typography templates',
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                  WallpaperExportSheet.show(context, wallpaper);
                },
              ),

              const SizedBox(height: 8),

              // Action 5: Add to Playlist
              _buildActionTile(
                context: context,
                icon: Icons.playlist_add_rounded,
                iconColor: const Color(0xFFD500F9),
                title: 'Add to Playlist',
                subtitle: 'Organize into your custom rotation collections',
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                  AddToCollectionSheet.show(context, wallpaper);
                },
              ),

              const SizedBox(height: 8),

              // Action 4: Customize in Quote Studio
              _buildActionTile(
                context: context,
                icon: Icons.edit_note_rounded,
                iconColor: const Color(0xFFFFD600),
                title: 'Customize in Quote Studio',
                subtitle: 'Personalize quotes, typography, and neon glows',
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                  final customQuote = state.customizedQuotes[wallpaper.id] ?? wallpaper.quote;
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => QuoteStudioSheet(
                      short: wallpaper,
                      currentQuote: customQuote,
                    ),
                  );
                },
              ),

              const SizedBox(height: 8),

              // Action 5: Save / Remove Favorite
              _buildActionTile(
                context: context,
                icon: isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                iconColor: isFav ? const Color(0xFFFF1744) : Colors.white70,
                title: isFav ? 'Remove from Favorites' : 'Save to Favorites',
                subtitle: isFav ? 'Currently in your favorites collection' : 'Add to favorites for quick access',
                onTap: () {
                  context.read<WallpaperBloc>().add(ToggleFavoriteIntent(wallpaper.id));
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
              ),

              const SizedBox(height: 8),

              // Action 6: Download Offline
              _buildActionTile(
                context: context,
                icon: isDownloaded ? Icons.check_circle_rounded : Icons.file_download_outlined,
                iconColor: isDownloaded ? const Color(0xFF00E676) : Colors.white70,
                title: isDownloaded ? 'Downloaded for Offline' : 'Download for Offline',
                subtitle: isDownloaded ? 'Stored on device cache' : 'Save full-resolution video to local cache',
                onTap: () {
                  if (!isDownloaded) {
                    context.read<WallpaperBloc>().add(DownloadWallpaperIntent(wallpaper));
                  }
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
          ),
        );
      },
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFF16161E),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white24, size: 12),
            ],
          ),
        ),
      ),
    );
  }
}
