import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/wallpaper_bloc.dart';
import '../blocs/wallpaper_intent.dart';
import '../blocs/wallpaper_state.dart';
import '../data/curated_shorts_data.dart';
import '../models/motivational_short.dart';
import '../widgets/kinetic_quote_overlay.dart';
import '../widgets/shorts_action_rail.dart';
import '../widgets/video_player_item.dart';
import 'preferences_modal_sheet.dart';
import 'quote_studio_sheet.dart';

class ShortsFeedScreen extends StatefulWidget {
  const ShortsFeedScreen({super.key});

  @override
  State<ShortsFeedScreen> createState() => _ShortsFeedScreenState();
}

class _ShortsFeedScreenState extends State<ShortsFeedScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openQuoteStudio(BuildContext context, MotivationalShort short, String quote) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QuoteStudioSheet(
        short: short,
        currentQuote: quote,
      ),
    );
  }

  void _openPreferencesModal(
    BuildContext context,
    Set<String> currentPrefs,
    bool textOverlayEnabled,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PreferencesModalSheet(
        initialPreferences: currentPrefs,
        initialTextOverlayEnabled: textOverlayEnabled,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<WallpaperBloc, WallpaperState>(
        listener: (context, state) {
          if (state.message != null) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF00E676)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.message!,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFF212124),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                duration: const Duration(seconds: 5),
                action: Platform.isIOS
                    ? SnackBarAction(
                        label: 'OPEN PHOTOS',
                        textColor: const Color(0xFF00E676),
                        onPressed: () {
                          context.read<WallpaperBloc>().add(OpenPhotosIntent());
                        },
                      )
                    : null,
              ),
            );
            context.read<WallpaperBloc>().add(ClearStatusMessageIntent());
          }

          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.redAccent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.errorMessage!,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFF2C1E20),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                duration: const Duration(seconds: 4),
              ),
            );
            context.read<WallpaperBloc>().add(ClearStatusMessageIntent());
          }
        },
        builder: (context, state) {
          if (state.actionStatus == WallpaperActionStatus.loading && state.allShorts.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          }

          if (state.filteredShorts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.filter_list_off_rounded, size: 48, color: Colors.white38),
                  const SizedBox(height: 12),
                  const Text(
                    'No shorts found in this category',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<WallpaperBloc>().add(const FilterByCategoryIntent('All'));
                    },
                    child: const Text('Show All Shorts'),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              // Vertical Swiping Feed
              PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: state.filteredShorts.length,
                onPageChanged: (index) {
                  context.read<WallpaperBloc>().add(ChangeActiveShortIntent(index));
                },
                itemBuilder: (context, index) {
                  final short = state.filteredShorts[index];
                  final isPageActive = state.activeIndex == index;
                  final effectiveQuote = state.getEffectiveQuote(short);
                  final isCustomized = state.customizedQuotes.containsKey(short.id);
                  final isFav = state.favoriteIds.contains(short.id);
                  final isActiveOnDevice =
                      state.activeWallpaperId == short.id && state.isLiveWallpaperActiveOnDevice;

                  final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

                  final content = Stack(
                    fit: StackFit.expand,
                    children: [
                      // Video Player (loops seamlessly)
                      VideoPlayerItem(
                        key: ValueKey(short.id),
                        videoAssetPath: short.videoAssetPath,
                        isActive: isPageActive,
                        isMuted: state.isFeedMuted,
                        onDoubleTapLike: () {
                          context.read<WallpaperBloc>().add(ToggleFavoriteIntent(short.id));
                        },
                      ),

                      // Motivational Typography Overlay (bottom left)
                      if (state.isTextOverlayVisible &&
                          (short.hasTextByDefault || isCustomized))
                        Positioned(
                          left: 0,
                          right: 80,
                          bottom: 0,
                          child: KineticQuoteOverlay(
                            short: short,
                            effectiveQuote: effectiveQuote,
                            isCustomized: isCustomized,
                          ),
                        )
                      else
                        Positioned(
                          left: 20,
                          bottom: 24,
                          right: 90,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: short.accentColor.withValues(alpha: 0.6),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.auto_awesome_rounded,
                                      size: 13,
                                      color: short.accentColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      short.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Action Rail (bottom right)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: ShortsActionRail(
                          short: short,
                          isFavorite: isFav,
                          isMuted: state.isFeedMuted,
                          isCurrentActive: isActiveOnDevice,
                          isApplying: state.actionStatus == WallpaperActionStatus.applying &&
                              isPageActive,
                          onApplyWallpaper: () {
                            context.read<WallpaperBloc>().add(
                                  ApplyLiveWallpaperIntent(
                                    short: short,
                                    isMuted: true, // Default muted for battery
                                  ),
                                );
                          },
                          onCustomizeQuote: () {
                            _openQuoteStudio(context, short, effectiveQuote);
                          },
                          onToggleMute: () {
                            context.read<WallpaperBloc>().add(ToggleFeedMuteIntent());
                          },
                          onToggleFavorite: () {
                            context.read<WallpaperBloc>().add(ToggleFavoriteIntent(short.id));
                          },
                          onShare: () {
                            context.read<WallpaperBloc>().add(ShareVideoIntent(short));
                          },
                        ),
                      ),
                    ],
                  );

                  if (isTablet) {
                    return Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 580),
                        child: content,
                      ),
                    );
                  }
                  return content;
                },
              ),

              // Top Bar: Category Filter Chips & Status Header
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.bolt_rounded, color: Color(0xFFFFD600), size: 22),
                                SizedBox(width: 6),
                                Text(
                                  'LIVE WALLPAPER',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                if (state.isLiveWallpaperActiveOnDevice) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00E676).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFF00E676),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 3,
                                          backgroundColor: Color(0xFF00E676),
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          'ACTIVE',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF00E676),
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                // Quick toggle text overlay
                                IconButton(
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(6),
                                  tooltip: state.isTextOverlayVisible
                                      ? 'Hide Text Overlay'
                                      : 'Show Text Overlay',
                                  icon: Icon(
                                    state.isTextOverlayVisible
                                        ? Icons.subtitles_rounded
                                        : Icons.subtitles_off_rounded,
                                    color: state.isTextOverlayVisible
                                        ? const Color(0xFF00E676)
                                        : Colors.white38,
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    context
                                        .read<WallpaperBloc>()
                                        .add(ToggleTextOverlayVisibilityIntent());
                                  },
                                ),
                                const SizedBox(width: 4),
                                // Preferences tuning button
                                IconButton(
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(6),
                                  tooltip: 'Wallpaper Preferences',
                                  icon: const Icon(
                                    Icons.tune_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    _openPreferencesModal(
                                      context,
                                      state.userPreferences,
                                      state.isTextOverlayVisible,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Horizontally scrollable category pills
                        SizedBox(
                          height: 32,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: CuratedShortsData.categories.length,
                            separatorBuilder: (_, _) => const SizedBox(width: 8),
                            itemBuilder: (context, idx) {
                              final category = CuratedShortsData.categories[idx];
                              final isSelected = state.selectedCategory == category;

                              return GestureDetector(
                                onTap: () {
                                  context.read<WallpaperBloc>().add(FilterByCategoryIntent(category));
                                  if (_pageController.hasClients) {
                                    _pageController.jumpToPage(0);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black.withValues(alpha: 0.45),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white.withValues(alpha: 0.25),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight:
                                          isSelected ? FontWeight.w800 : FontWeight.w600,
                                      color: isSelected ? Colors.black : Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
