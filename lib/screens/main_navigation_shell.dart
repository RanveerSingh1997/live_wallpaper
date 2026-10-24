import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/wallpaper_bloc.dart';
import '../blocs/wallpaper_intent.dart';
import '../blocs/wallpaper_state.dart';
import '../core/core.dart';
import 'categories_screen.dart';
import 'discover_screen.dart';
import 'downloads_screen.dart';
import 'favorites_screen.dart';
import 'onboarding_sheet.dart';
import 'shorts_feed_screen.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  bool _isOnboardingShown = false;

  void _navigateToTab(int index) {
    HapticFeedback.selectionClick();
    context.read<WallpaperBloc>().add(ChangeNavigationTabIntent(index));
  }

  void _openLiveFeed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ShortsFeedScreen(),
      ),
    );
  }

  void _checkAndShowOnboarding(WallpaperState state) {
    if (!state.hasSeenOnboarding && !_isOnboardingShown && state.allShorts.isNotEmpty) {
      _isOnboardingShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !context.read<WallpaperBloc>().state.hasSeenOnboarding) {
          OnboardingSheet.show(context).then((_) {
            _isOnboardingShown = false;
          });
        } else {
          _isOnboardingShown = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WallpaperBloc, WallpaperState>(
      listenWhen: (prev, curr) => !curr.hasSeenOnboarding && prev.hasSeenOnboarding != curr.hasSeenOnboarding,
      listener: (context, state) {
        _checkAndShowOnboarding(state);
      },
      builder: (context, state) {
        _checkAndShowOnboarding(state);
        final currentIndex = state.currentNavigationTab;

        final screens = [
          DiscoverScreen(onOpenLiveFeed: _openLiveFeed),
          const CategoriesScreen(),
          FavoritesScreen(onBrowseWallpapers: () => _navigateToTab(0)),
          DownloadsScreen(onBrowseWallpapers: () => _navigateToTab(0)),
        ];

        return Scaffold(
          backgroundColor: Colors.black,
          extendBody: true,
          body: IndexedStack(
            index: currentIndex,
            children: screens,
          ),
          bottomNavigationBar: SafeArea(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.14),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: AppColors.neonCyan.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(27),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: BottomNavigationBar(
                  currentIndex: currentIndex,
                  onTap: _navigateToTab,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.transparent,
                  selectedItemColor: AppColors.neonCyan,
                  unselectedItemColor: Colors.white38,
                  selectedLabelStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  elevation: 0,
                  items: [
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.explore_outlined),
                      activeIcon: Icon(Icons.explore_rounded, color: AppColors.neonCyan),
                      label: AppStrings.navDiscover,
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.grid_view_outlined),
                      activeIcon: Icon(Icons.grid_view_rounded, color: AppColors.neonCyan),
                      label: AppStrings.navCategories,
                    ),
                    BottomNavigationBarItem(
                      icon: Badge(
                        isLabelVisible: state.favoriteIds.isNotEmpty,
                        label: Text('${state.favoriteIds.length}'),
                        backgroundColor: AppColors.favoriteRed,
                        child: const Icon(Icons.favorite_border_rounded),
                      ),
                      activeIcon: Badge(
                        isLabelVisible: state.favoriteIds.isNotEmpty,
                        label: Text('${state.favoriteIds.length}'),
                        backgroundColor: AppColors.favoriteRed,
                        child: const Icon(Icons.favorite_rounded, color: AppColors.favoriteRed),
                      ),
                      label: AppStrings.navFavorites,
                    ),
                    BottomNavigationBarItem(
                      icon: Badge(
                        isLabelVisible: state.downloadedIds.isNotEmpty,
                        label: Text('${state.downloadedIds.length}'),
                        backgroundColor: AppColors.cyberEmerald,
                        textColor: Colors.black,
                        child: const Icon(Icons.file_download_outlined),
                      ),
                      activeIcon: Badge(
                        isLabelVisible: state.downloadedIds.isNotEmpty,
                        label: Text('${state.downloadedIds.length}'),
                        backgroundColor: AppColors.cyberEmerald,
                        textColor: Colors.black,
                        child: const Icon(Icons.download_done_rounded, color: AppColors.auroraEmerald),
                      ),
                      label: AppStrings.navDownloads,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      },
    );
  }
}
