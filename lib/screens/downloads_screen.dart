import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/wallpaper_bloc.dart';
import '../blocs/wallpaper_intent.dart';
import '../blocs/wallpaper_state.dart';
import 'wallpaper_preview_sheet.dart';

class DownloadsScreen extends StatefulWidget {
  final VoidCallback onBrowseWallpapers;

  const DownloadsScreen({
    super.key,
    required this.onBrowseWallpapers,
  });

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  String _filter = 'All';

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Reclaim Storage?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This will remove all downloaded offline wallpaper files from your device. You can re-download them anytime.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<WallpaperBloc>().add(ClearAllDownloadsIntent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF1744),
              foregroundColor: Colors.white,
            ),
            child: const Text('RECLAIM STORAGE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WallpaperBloc, WallpaperState>(
      builder: (context, state) {
        final downloads = state.downloadedShorts;

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            title: Row(
              children: [
                const Icon(Icons.download_done_rounded, color: Color(0xFF00E676), size: 20),
                const SizedBox(width: 8),
                Text(
                  'DOWNLOADS (${downloads.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            actions: [
              if (downloads.isNotEmpty)
                TextButton.icon(
                  onPressed: () => _confirmClearAll(context),
                  icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white54, size: 18),
                  label: const Text(
                    'Reclaim',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
            ],
          ),
          body: downloads.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E676).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.cloud_download_rounded,
                            size: 48,
                            color: Color(0xFF00E676),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'No Offline Downloads',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Download your favorite live and static wallpapers so they remain available offline without network.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            widget.onBrowseWallpapers();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E676),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.explore_rounded, size: 18),
                          label: const Text(
                            'Browse Wallpapers',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    // Storage meter header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16161A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E676).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.storage_rounded,
                              color: Color(0xFF00E676),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'OFFLINE DEVICE STORAGE',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  state.storageFormatted.isNotEmpty &&
                                          state.storageFormatted != '0.0 KB'
                                      ? state.storageFormatted
                                      : '${(downloads.length * 2.7).toStringAsFixed(1)} MB occupied',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${downloads.length} Files',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Filter Chips Row
                    Row(
                      children: [
                        _buildFilterChip('All', downloads.length),
                        const SizedBox(width: 8),
                        _buildFilterChip('Live', downloads.where((s) => s.isLive).length),
                        const SizedBox(width: 8),
                        _buildFilterChip('Static', downloads.where((s) => !s.isLive).length),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Downloaded Wallpapers List
                    if ((_filter == 'Live'
                            ? downloads.where((s) => s.isLive).toList()
                            : _filter == 'Static'
                                ? downloads.where((s) => !s.isLive).toList()
                                : downloads)
                        .isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'No $_filter downloads found.',
                            style: const TextStyle(color: Colors.white38, fontSize: 13),
                          ),
                        ),
                      )
                    else
                      ...(_filter == 'Live'
                              ? downloads.where((s) => s.isLive).toList()
                              : _filter == 'Static'
                                  ? downloads.where((s) => !s.isLive).toList()
                                  : downloads)
                          .map((item) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF18181C),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          leading: Container(
                            width: 50,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                colors: item.gradientColors.isNotEmpty
                                    ? item.gradientColors
                                    : [item.accentColor.withValues(alpha: 0.3), Colors.black],
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              item.isLive ? Icons.videocam_rounded : Icons.image_rounded,
                              color: item.accentColor,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            item.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${item.category} • ${item.fileSizeFormatted}',
                            style: const TextStyle(color: Colors.white54, fontSize: 11),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded,
                                    color: Colors.white38, size: 20),
                                tooltip: 'Delete Download',
                                onPressed: () {
                                  HapticFeedback.selectionClick();
                                  context
                                      .read<WallpaperBloc>()
                                      .add(DeleteDownloadIntent(item.id));
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.play_arrow_rounded,
                                  color: item.accentColor,
                                  size: 24,
                                ),
                                tooltip: 'Preview & Apply',
                                onPressed: () {
                                  WallpaperPreviewSheet.show(context, item);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildFilterChip(String filterName, int count) {
    final isSelected = _filter == filterName;
    return ChoiceChip(
      label: Text('$filterName ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          HapticFeedback.selectionClick();
          setState(() => _filter = filterName);
        }
      },
      backgroundColor: const Color(0xFF16161A),
      selectedColor: const Color(0xFF00E676),
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.white70,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? const Color(0xFF00E676) : Colors.white12,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }
}
