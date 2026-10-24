import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/wallpaper_bloc.dart';
import '../blocs/wallpaper_intent.dart';
import '../blocs/wallpaper_state.dart';
import '../core/core.dart';
import '../models/wallaza_cloud_wallpaper.dart';

/// Modal bottom sheet for discovering, searching, and importing millions of
/// high-resolution 4K and Ultra-HD wallpapers from the Wallaza Cloud API.
class WallazaCloudDiscoverySheet extends StatefulWidget {
  const WallazaCloudDiscoverySheet({super.key});

  /// Presents the Wallaza Cloud Discovery Studio sheet.
  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: BlocProvider.of<WallpaperBloc>(context),
        child: const WallazaCloudDiscoverySheet(),
      ),
    );
  }

  @override
  State<WallazaCloudDiscoverySheet> createState() =>
      _WallazaCloudDiscoverySheetState();
}

class _WallazaCloudDiscoverySheetState
    extends State<WallazaCloudDiscoverySheet> {
  final TextEditingController _searchController = TextEditingController();

  static const List<String> _categories = [
    'All',
    'Live',
    'Cyberpunk',
    'Space',
    'Nature',
    'AMOLED',
    'Abstract',
    'Anime',
  ];

  static const List<String> _resolutions = [
    'All',
    '3840x2160',
    '2560x1440',
    '1920x1080',
    'AMOLED',
  ];

  static const List<Map<String, dynamic>> _sortOptions = [
    {
      'id': 'curated',
      'label': 'Featured',
      'icon': Icons.auto_awesome_rounded,
    },
    {
      'id': 'popular',
      'label': 'Popular',
      'icon': Icons.local_fire_department_rounded,
    },
    {
      'id': 'trending',
      'label': 'Trending',
      'icon': Icons.favorite_rounded,
    },
    {
      'id': 'newest',
      'label': 'Newest',
      'icon': Icons.bolt_rounded,
    },
    {
      'id': 'quality',
      'label': '4K Ultra',
      'icon': Icons.high_quality_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    final bloc = context.read<WallpaperBloc>();
    _searchController.text = bloc.state.cloudSearchQuery;
    if (bloc.state.cloudWallpapers.isEmpty && !bloc.state.isCloudLoading) {
      bloc.add(const FetchCloudWallpapersIntent(page: 1));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onCategorySelected(String category) {
    final bloc = context.read<WallpaperBloc>();
    if (bloc.state.cloudSearchQuery.isNotEmpty) {
      _searchController.clear();
      bloc.add(const ClearCloudSearchIntent());
    }
    bloc.add(FetchCloudWallpapersIntent(
      page: 1,
      category: category,
    ));
  }

  String _resolutionLabel(String res) {
    switch (res) {
      case 'All':
        return 'All Resolutions';
      case '3840x2160':
        return '3840x2160';
      case '2560x1440':
        return '2K QHD';
      case '1920x1080':
        return '1920x1080';
      case 'AMOLED':
        return 'AMOLED True-Black';
      default:
        return res;
    }
  }

  void _onSortSelected(String sortId) {
    context.read<WallpaperBloc>().add(UpdateCloudSortIntent(sortId));
  }

  void _onResolutionSelected(String resolution) {
    final bloc = context.read<WallpaperBloc>();
    final q = _searchController.text.trim();
    if (q.isNotEmpty) {
      bloc.add(SearchCloudWallpapersIntent(
        query: q,
        resolution: resolution,
        page: 1,
      ));
    } else {
      bloc.add(SearchCloudWallpapersIntent(
        query: bloc.state.selectedCloudCategory == 'All'
            ? 'wallpaper'
            : bloc.state.selectedCloudCategory,
        resolution: resolution,
        page: 1,
      ));
    }
  }

  void _executeSearch(String query) {
    final bloc = context.read<WallpaperBloc>();
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      bloc.add(const ClearCloudSearchIntent());
    } else {
      bloc.add(SearchCloudWallpapersIntent(
        query: trimmed,
        resolution: bloc.state.selectedCloudResolution,
        page: 1,
      ));
    }
  }

  void _showDetailSheet(WallazaCloudWallpaper item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: BlocProvider.of<WallpaperBloc>(context),
        child: _CloudWallpaperDetailModal(item: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.98,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.modalBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonCyan.withValues(alpha: 0.4),
                blurRadius: 36,
                spreadRadius: -8,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            children: [
              // Sheet Drag Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.neonCyan, AppColors.auroraViolet],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.cloud_download_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'Wallaza Cloud Discovery',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 6),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: AppColors.neonCyan,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(6)),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  child: Text(
                                    '4K PROXY',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Stream & Import millions of Ultra-HD wallpapers',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      onPressed: () {
                        if (mounted && Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white10, height: 1),

              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    onSubmitted: _executeSearch,
                    decoration: InputDecoration(
                      hintText: 'Search 4K wallpapers (neon, nature, cyber)...',
                      hintStyle:
                          const TextStyle(color: Colors.white38, fontSize: 13),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppColors.neonCyan, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded,
                                  color: Colors.white54, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                _executeSearch('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ),

              // Category Filter Chips
              BlocBuilder<WallpaperBloc, WallpaperState>(
                buildWhen: (prev, curr) =>
                    prev.selectedCloudCategory != curr.selectedCloudCategory,
                builder: (context, state) {
                  return SizedBox(
                    height: 38,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = state.selectedCloudCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            selectedColor: AppColors.neonCyan,
                            backgroundColor: AppColors.cardSurface,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.black : Colors.white70,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.neonCyan
                                    : Colors.white10,
                              ),
                            ),
                            onSelected: (_) => _onCategorySelected(cat),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 6),

              // Resolution Filter Chips
              BlocBuilder<WallpaperBloc, WallpaperState>(
                buildWhen: (prev, curr) =>
                    prev.selectedCloudResolution != curr.selectedCloudResolution,
                builder: (context, state) {
                  return SizedBox(
                    height: 32,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _resolutions.length,
                      itemBuilder: (context, index) {
                        final res = _resolutions[index];
                        final isSelected = state.selectedCloudResolution == res;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(
                              _resolutionLabel(res),
                              style: TextStyle(
                                color:
                                    isSelected ? Colors.white : Colors.white54,
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: AppColors.auroraViolet.withAlpha(100),
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.auroraViolet
                                    : Colors.white12,
                              ),
                            ),
                            onSelected: (_) => _onResolutionSelected(res),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 6),

              // Sorting Options Strip
              BlocBuilder<WallpaperBloc, WallpaperState>(
                buildWhen: (prev, curr) =>
                    prev.selectedCloudSort != curr.selectedCloudSort,
                builder: (context, state) {
                  return SizedBox(
                    height: 30,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _sortOptions.length,
                      itemBuilder: (context, index) {
                        final sort = _sortOptions[index];
                        final id = sort['id'] as String;
                        final label = sort['label'] as String;
                        final icon = sort['icon'] as IconData;
                        final isSelected = state.selectedCloudSort == id;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () => _onSortSelected(id),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.neonCyan.withAlpha(35)
                                    : AppColors.cardSurface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.neonCyan
                                      : Colors.white12,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    icon,
                                    size: 13,
                                    color: isSelected
                                        ? AppColors.neonCyan
                                        : Colors.white54,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    label,
                                    style: TextStyle(
                                      color: isSelected
                                          ? AppColors.neonCyan
                                          : Colors.white70,
                                      fontSize: 11,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              // Active Creator Filter Banner
              BlocBuilder<WallpaperBloc, WallpaperState>(
                buildWhen: (prev, curr) =>
                    prev.selectedCloudAuthor != curr.selectedCloudAuthor,
                builder: (context, state) {
                  final author = state.selectedCloudAuthor;
                  if (author == null || author.isEmpty) {
                    return const SizedBox(height: 6);
                  }
                  return Container(
                    margin: const EdgeInsets.fromLTRB(16, 6, 16, 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.deepPurple, AppColors.cardSurface],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColors.auroraViolet.withAlpha(160)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person_pin_circle_rounded,
                            color: AppColors.auroraViolet, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Filtered by Creator: $author',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        InkWell(
                          key: const Key('clear_author_filter_button'),
                          onTap: () {
                            context
                                .read<WallpaperBloc>()
                                .add(const FilterCloudByAuthorIntent(null));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white12,
                            ),
                            child: const Icon(Icons.close_rounded,
                                color: Colors.white70, size: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 8),

              // Wallpaper Grid or Empty / Loading States
              Expanded(
                child: BlocBuilder<WallpaperBloc, WallpaperState>(
                  builder: (context, state) {
                    final displayedWallpapers = state.sortedCloudWallpapers;

                    if (state.isCloudLoading && displayedWallpapers.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.neonCyan,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Connecting to Wallaza Cloud Proxy...',
                              style: TextStyle(color: Colors.white60, fontSize: 13),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state.cloudErrorMessage != null &&
                        displayedWallpapers.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.cloud_off_rounded,
                                  color: Colors.redAccent, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                state.cloudErrorMessage!,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Retry Connection'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.neonCyan,
                                  foregroundColor: Colors.black,
                                ),
                                onPressed: () {
                                  context.read<WallpaperBloc>().add(
                                        const FetchCloudWallpapersIntent(
                                            page: 1),
                                      );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (displayedWallpapers.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.image_not_supported_outlined,
                                color: Colors.white24, size: 48),
                            const SizedBox(height: 12),
                            const Text(
                              'No wallpapers found matching your filters.',
                              style: TextStyle(
                                  color: Colors.white60, fontSize: 14),
                            ),
                            const SizedBox(height: 12),
                            TextButton.icon(
                              icon: const Icon(Icons.clear_all_rounded,
                                  color: AppColors.neonCyan),
                              label: const Text(
                                'Clear Filters',
                                style: TextStyle(color: AppColors.neonCyan),
                              ),
                              onPressed: () {
                                _searchController.clear();
                                context
                                    .read<WallpaperBloc>()
                                    .add(const ClearCloudSearchIntent());
                              },
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.64,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: displayedWallpapers.length,
                      itemBuilder: (context, index) {
                        final item = displayedWallpapers[index];
                        return _CloudWallpaperCard(
                          item: item,
                          onTap: () => _showDetailSheet(item),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Card representing an individual cloud wallpaper in the discovery grid.
class _CloudWallpaperCard extends StatelessWidget {
  final WallazaCloudWallpaper item;
  final VoidCallback onTap;

  const _CloudWallpaperCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image Preview
            Image.network(
              item.thumbnailUrl.isNotEmpty ? item.thumbnailUrl : item.url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: AppColors.cardHighlight,
                child: const Center(
                  child: Icon(Icons.broken_image_rounded,
                      color: Colors.white24, size: 36),
                ),
              ),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: AppColors.modalBackground,
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.neonCyan,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Top Badges (Resolution, Live Motion, AMOLED)
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(190),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: item.is4K
                                ? AppColors.neonCyan.withAlpha(150)
                                : Colors.white24,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.hd_rounded,
                              size: 11,
                              color: item.is4K
                                  ? AppColors.neonCyan
                                  : Colors.white70,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.is4K ? '4K UHD' : 'FHD',
                              style: TextStyle(
                                color: item.is4K
                                    ? AppColors.neonCyan
                                    : Colors.white70,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (item.isVideo) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.neonCyan, AppColors.auroraViolet],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.neonCyan.withValues(alpha: 0.4),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.videocam_rounded,
                                size: 10,
                                color: Colors.white,
                              ),
                              SizedBox(width: 3),
                              Text(
                                'LIVE 60FPS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (item.isAmoled)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(210),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.auroraEmerald.withAlpha(160)),
                      ),
                      child: const Text(
                        'OLED',
                        style: TextStyle(
                          color: AppColors.auroraEmerald,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Live Motion Center Play Indicator
            if (item.isVideo)
              Center(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(150),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.neonCyan.withAlpha(200),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonCyan.withValues(alpha: 0.33),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: AppColors.neonCyan,
                      size: 22,
                    ),
                  ),
                ),
              ),

            // Bottom Gradient Overlay & Meta
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 24, 10, 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                      Colors.black.withValues(alpha: 0.96),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          margin: const EdgeInsets.only(right: 5),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [AppColors.neonCyan, AppColors.auroraViolet],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              item.authorInitials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 7,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            item.authorName ?? item.category,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_downward_rounded,
                            size: 10, color: AppColors.neonCyan),
                        Text(
                          _formatCount(item.downloads),
                          style: const TextStyle(
                            color: AppColors.neonCyan,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}

/// Detailed inspector and 1-tap action modal for a cloud wallpaper.
class _CloudWallpaperDetailModal extends StatelessWidget {
  final WallazaCloudWallpaper item;

  const _CloudWallpaperDetailModal({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.modalBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title & Category
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'By ${item.authorName ?? "Wallaza Cloud Artist"} • ${item.category}',
                            style: const TextStyle(color: Colors.white60, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (item.isVideo) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.neonCyan, AppColors.auroraViolet],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'LIVE MOTION',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white60),
                onPressed: () {
                  if (context.mounted && Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 14),

          // High-Res Image Preview Box
          Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  item.url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: AppColors.cardSurface,
                    child: const Center(
                      child: Icon(Icons.broken_image_rounded,
                          color: Colors.white30, size: 48),
                    ),
                  ),
                ),
                if (item.isVideo)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(160),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.neonCyan,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neonCyan.withValues(alpha: 0.4),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: AppColors.neonCyan,
                        size: 36,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Creator Profile Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.neonCyan.withAlpha(60)),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.neonCyan, AppColors.auroraViolet],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      item.authorInitials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              item.authorName ?? 'Wallaza Cloud Artist',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.verified_rounded,
                              size: 14, color: AppColors.neonCyan),
                        ],
                      ),
                      Text(
                        '@${item.authorUsername ?? "wallaza_artist"}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.art_track_rounded, size: 14),
                  label: const Text('Filter Artist', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.neonCyan,
                    side: const BorderSide(color: AppColors.neonCyan, width: 1.0),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    final author = item.authorUsername ?? item.authorName;
                    if (author != null) {
                      context.read<WallpaperBloc>().add(FilterCloudByAuthorIntent(author));
                    }
                    if (context.mounted && Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Specs Bar
          Row(
            children: [
              if (item.isVideo) ...[
                _buildSpecTile('MOTION', '60 FPS LOOP', Icons.slow_motion_video_rounded),
                _buildSpecTile('DURATION', '${item.durationSeconds}s Stream', Icons.timer_rounded),
                _buildSpecTile('QUALITY', 'Ultra-HD 4K', Icons.high_quality_rounded),
              ] else ...[
                _buildSpecTile('RESOLUTION', item.resolution, Icons.aspect_ratio_rounded),
                _buildSpecTile('SIZE', item.fileSizeFormatted, Icons.sd_storage_rounded),
                _buildSpecTile('DOWNLOADS', item.downloads.toString(), Icons.cloud_download_rounded),
              ],
            ],
          ),

          const SizedBox(height: 18),

          // Download Offline 4K button
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.file_download_rounded, color: Colors.white, size: 20),
              label: Text(
                item.isVideo
                    ? 'Download Live Motion (Save MP4)'
                    : 'Download Offline 4K (Save to Device)',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                  fontSize: 13,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cardSurface,
                side: const BorderSide(color: AppColors.neonCyan, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                final short = item.toMotivationalShort();
                context.read<WallpaperBloc>().add(DownloadWallpaperIntent(short));
                if (context.mounted && Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ),

          const SizedBox(height: 12),

          // Action Buttons: 1-Tap Import and 1-Tap Apply
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add_photo_alternate_rounded,
                      color: AppColors.neonCyan),
                  label: const Text(
                    'Import to Library',
                    style: TextStyle(
                      color: AppColors.neonCyan,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.neonCyan),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    context.read<WallpaperBloc>().add(
                          ImportCloudWallpaperIntent(item, setAsActive: false),
                        );
                    if (context.mounted && Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Imported "${item.title}" into library!'),
                        backgroundColor: AppColors.neonCyan,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: Icon(
                    item.isVideo
                        ? Icons.motion_photos_on_rounded
                        : Icons.wallpaper_rounded,
                    color: Colors.black,
                  ),
                  label: Text(
                    item.isVideo ? 'Apply Live Motion' : 'Apply Wallpaper',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: item.isVideo
                        ? AppColors.auroraEmerald
                        : AppColors.neonCyan,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    context.read<WallpaperBloc>().add(
                          ImportCloudWallpaperIntent(item, setAsActive: true),
                        );
                    if (context.mounted && Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(item.isVideo
                            ? 'Applied live motion "${item.title}" to screen!'
                            : 'Applied "${item.title}" to screen!'),
                        backgroundColor: AppColors.auroraEmerald,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecTile(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white54, size: 16),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
