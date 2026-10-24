import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/wallpaper_bloc.dart';
import '../blocs/wallpaper_state.dart';
import '../core/core.dart';
import '../models/motivational_short.dart';
import '../services/wallpaper_renderer_service.dart';

class WallpaperExportSheet extends StatefulWidget {
  final MotivationalShort wallpaper;

  const WallpaperExportSheet({
    super.key,
    required this.wallpaper,
  });

  static Future<void> show(BuildContext context, MotivationalShort wallpaper) {
    unawaited(HapticFeedback.mediumImpact());
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => WallpaperExportSheet(wallpaper: wallpaper),
    );
  }

  @override
  State<WallpaperExportSheet> createState() => _WallpaperExportSheetState();
}

class _WallpaperExportSheetState extends State<WallpaperExportSheet> {
  int _selectedLayoutIndex = 0; // 0: Editorial Story, 1: Clean Art, 2: Typography Focus
  bool _isExporting = false;

  Future<void> _exportAndShare({required bool isDirectShare}) async {
    unawaited(HapticFeedback.mediumImpact());
    setState(() => _isExporting = true);

    try {
      final bloc = context.read<WallpaperBloc>();
      final customQuote = bloc.state.getEffectiveQuote(widget.wallpaper);
      final effects = bloc.state.getEffectiveEffects(widget.wallpaper.id);

      final file = await WallpaperRendererService.renderWallpaperToFile(
        wallpaper: widget.wallpaper,
        quoteOverride: _selectedLayoutIndex == 1 ? '' : customQuote,
        effectConfig: effects,
      );

      if (!mounted) return;
      setState(() => _isExporting = false);

      if (isDirectShare) {
        await bloc.repository.shareVideo(widget.wallpaper);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.cardSurface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: AppColors.auroraEmerald, width: 0.8),
            ),
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.auroraEmerald),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '✨ Exported to ${file.path.split('/').last}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isExporting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.cardSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.error, width: 0.8),
          ),
          content: Text(
            'Failed to export poster: $e',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WallpaperBloc, WallpaperState>(
      builder: (context, state) {
        final quote = state.getEffectiveQuote(widget.wallpaper);

        return DraggableScrollableSheet(
          initialChildSize: 0.88,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.sunsetAmber.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.share_rounded,
                              color: AppColors.sunsetAmber,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'EXPORT STORY & POSTER',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              Text(
                                'Lossless 9:16 4K canvas for social sharing',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: const Text(
                          '4K UHD',
                          style: TextStyle(
                            color: AppColors.sunsetAmber,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Poster Mockup Preview
                  Center(
                    child: Container(
                      width: 180,
                      height: 280,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: widget.wallpaper.accentColor.withValues(alpha: 0.25),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: widget.wallpaper.gradientColors.isNotEmpty
                                      ? widget.wallpaper.gradientColors
                                      : [widget.wallpaper.accentColor.withValues(alpha: 0.4), Colors.black],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            // Vignette
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
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Category Tag
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: widget.wallpaper.accentColor.withValues(alpha: 0.6),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      widget.wallpaper.category.toUpperCase(),
                                      style: TextStyle(
                                        color: widget.wallpaper.accentColor,
                                        fontSize: 8,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),

                                  // Quote / Mantra
                                  if (_selectedLayoutIndex != 1 && quote.isNotEmpty)
                                    Text(
                                      '"$quote"',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        fontStyle: FontStyle.italic,
                                        height: 1.25,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                  // Brand Watermark Footer
                                  Column(
                                    children: [
                                      if (_selectedLayoutIndex == 0) ...[
                                        Text(
                                          widget.wallpaper.author.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 7,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                      ],
                                      const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.auto_awesome_rounded,
                                              size: 10, color: AppColors.neonCyan),
                                          SizedBox(width: 4),
                                          Text(
                                            'WALLORA',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Layout Template Selector
                  const Text(
                    'STORY TEMPLATE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildLayoutChip('Editorial Story', 0),
                      const SizedBox(width: 8),
                      _buildLayoutChip('Clean Canvas', 1),
                      const SizedBox(width: 8),
                      _buildLayoutChip('Quote Focus', 2),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isExporting
                              ? null
                              : () => _exportAndShare(isDirectShare: false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.file_download_outlined, size: 18),
                          label: const Text(
                            'SAVE POSTER',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isExporting
                              ? null
                              : () => _exportAndShare(isDirectShare: true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.wallpaper.accentColor,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: _isExporting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : const Icon(Icons.send_rounded, size: 18),
                          label: const Text(
                            'SHARE STORY',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLayoutChip(String title, int index) {
    final isSelected = _selectedLayoutIndex == index;
    return Expanded(
      child: ChoiceChip(
        label: Text(title),
        selected: isSelected,
        onSelected: (val) {
          if (val) {
            HapticFeedback.selectionClick();
            setState(() => _selectedLayoutIndex = index);
          }
        },
        backgroundColor: AppColors.cardSurface,
        selectedColor: widget.wallpaper.accentColor.withValues(alpha: 0.25),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontSize: 10,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? widget.wallpaper.accentColor : Colors.white10,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      ),
    );
  }
}
