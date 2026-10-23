import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/wallpaper_bloc.dart';
import '../blocs/wallpaper_intent.dart';
import '../blocs/wallpaper_state.dart';
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
    '1920x1080',
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
          decoration: const BoxDecoration(
            color: Color(0xFF0D0D12),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Color(0x6600E5FF),
                blurRadius: 36,
                spreadRadius: -8,
                offset: Offset(0, -6),
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
                          colors: [Color(0xFF00E5FF), Color(0xFFD500F9)],
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
                                  color: Color(0xFF00E5FF),
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
                    color: const Color(0xFF161622),
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
                          color: Color(0xFF00E5FF), size: 20),
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
                            selectedColor: const Color(0xFF00E5FF),
                            backgroundColor: const Color(0xFF1A1A26),
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
                                    ? const Color(0xFF00E5FF)
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
                              res == 'All' ? 'All Resolutions' : res,
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
                            selectedColor: const Color(0xFFD500F9).withAlpha(100),
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: isSelected
                                    ? const Color(0xFFD500F9)
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

              const SizedBox(height: 8),

              // Wallpaper Grid or Empty / Loading States
              Expanded(
                child: BlocBuilder<WallpaperBloc, WallpaperState>(
                  builder: (context, state) {
                    if (state.isCloudLoading && state.cloudWallpapers.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF00E5FF),
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
                        state.cloudWallpapers.isEmpty) {
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
                                  backgroundColor: const Color(0xFF00E5FF),
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

                    if (state.cloudWallpapers.isEmpty) {
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
                                  color: Color(0xFF00E5FF)),
                              label: const Text(
                                'Clear Filters',
                                style: TextStyle(color: Color(0xFF00E5FF)),
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
                      itemCount: state.cloudWallpapers.length,
                      itemBuilder: (context, index) {
                        final item = state.cloudWallpapers[index];
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
          color: const Color(0xFF161622),
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
                color: const Color(0xFF1B1B2A),
                child: const Center(
                  child: Icon(Icons.broken_image_rounded,
                      color: Colors.white24, size: 36),
                ),
              ),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: const Color(0xFF12121B),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF00E5FF),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Top Badges (Resolution & AMOLED)
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(190),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: item.is4K
                            ? const Color(0xFF00E5FF).withAlpha(150)
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
                              ? const Color(0xFF00E5FF)
                              : Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.is4K ? '4K UHD' : 'FHD',
                          style: TextStyle(
                            color: item.is4K
                                ? const Color(0xFF00E5FF)
                                : Colors.white70,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (item.isAmoled)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(210),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xFF00E676).withAlpha(160)),
                      ),
                      child: const Text(
                        'OLED',
                        style: TextStyle(
                          color: Color(0xFF00E676),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Bottom Gradient Overlay & Meta
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 24, 10, 10),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color(0xCC000000),
                      Color(0xF5000000),
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
                            size: 10, color: Color(0xFF00E5FF)),
                        Text(
                          _formatCount(item.downloads),
                          style: const TextStyle(
                            color: Color(0xFF00E5FF),
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
        color: Color(0xFF101018),
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
                    Text(
                      'By ${item.authorName ?? "Wallaza Cloud Artist"} • ${item.category}',
                      style: const TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white60),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
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
            child: Image.network(
              item.url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: const Color(0xFF1A1A24),
                child: const Center(
                  child: Icon(Icons.broken_image_rounded,
                      color: Colors.white30, size: 48),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Specs Bar
          Row(
            children: [
              _buildSpecTile('RESOLUTION', item.resolution, Icons.aspect_ratio_rounded),
              _buildSpecTile('SIZE', item.fileSizeFormatted, Icons.sd_storage_rounded),
              _buildSpecTile('DOWNLOADS', item.downloads.toString(), Icons.cloud_download_rounded),
            ],
          ),

          const SizedBox(height: 18),

          // Download Offline 4K button
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.file_download_rounded, color: Colors.white, size: 20),
              label: const Text(
                'Download Offline 4K (Save to Device)',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                  fontSize: 13,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E1E2C),
                side: const BorderSide(color: Color(0xFF00E5FF), width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                final short = item.toMotivationalShort();
                context.read<WallpaperBloc>().add(DownloadWallpaperIntent(short));
                if (Navigator.of(context).canPop()) {
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
                      color: Color(0xFF00E5FF)),
                  label: const Text(
                    'Import to Library',
                    style: TextStyle(
                      color: Color(0xFF00E5FF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF00E5FF)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    context.read<WallpaperBloc>().add(
                          ImportCloudWallpaperIntent(item, setAsActive: false),
                        );
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Imported "${item.title}" into library!'),
                        backgroundColor: const Color(0xFF00E5FF),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.wallpaper_rounded, color: Colors.black),
                  label: const Text(
                    'Apply Wallpaper',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    context.read<WallpaperBloc>().add(
                          ImportCloudWallpaperIntent(item, setAsActive: true),
                        );
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Applied "${item.title}" to screen!'),
                        backgroundColor: const Color(0xFF00E676),
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
          color: const Color(0xFF181824),
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
