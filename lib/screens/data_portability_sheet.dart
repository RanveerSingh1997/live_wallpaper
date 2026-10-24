import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/wallpaper_bloc.dart';
import '../blocs/wallpaper_intent.dart';
import '../blocs/wallpaper_state.dart';
import '../models/wallora_backup_bundle.dart';

/// Modal bottom sheet providing data portability, backup export, and JSON restore.
class DataPortabilitySheet extends StatefulWidget {
  const DataPortabilitySheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const DataPortabilitySheet(),
    );
  }

  @override
  State<DataPortabilitySheet> createState() => _DataPortabilitySheetState();
}

class _DataPortabilitySheetState extends State<DataPortabilitySheet> {
  final TextEditingController _jsonInputController = TextEditingController();
  bool _mergeWithExisting = true;
  String? _jsonValidationError;

  @override
  void dispose() {
    _jsonInputController.dispose();
    super.dispose();
  }

  void _safePop() {
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleExportToClipboard() async {
    final bloc = context.read<WallpaperBloc>();
    final bundle = await bloc.repository.createBackupBundle();
    final jsonStr = bundle.toJsonString(pretty: true);

    await Clipboard.setData(ClipboardData(text: jsonStr));
    unawaited(HapticFeedback.selectionClick());

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Backup archive copied to clipboard! (${bundle.summary})'),
        backgroundColor: const Color(0xFF1E1E28),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: const Color(0xFF00E5FF),
          onPressed: () {},
        ),
      ),
    );
  }

  Future<void> _handlePasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data != null && data.text != null && data.text!.isNotEmpty) {
      setState(() {
        _jsonInputController.text = data.text!;
        _validateJson(data.text!);
      });
      unawaited(HapticFeedback.selectionClick());
    }
  }

  void _validateJson(String val) {
    if (val.trim().isEmpty) {
      setState(() {
        _jsonValidationError = null;
      });
      return;
    }

    if (!WalloraBackupBundle.isValidJson(val)) {
      setState(() {
        _jsonValidationError = 'Invalid Wallora backup format or missing version.';
      });
    } else {
      setState(() {
        _jsonValidationError = null;
      });
    }
  }

  Future<void> _handleRestore() async {
    final raw = _jsonInputController.text.trim();
    if (!WalloraBackupBundle.isValidJson(raw)) {
      setState(() {
        _jsonValidationError = 'Please provide a valid Wallora backup JSON.';
      });
      return;
    }

    try {
      final bundle = WalloraBackupBundle.fromJsonString(raw);
      unawaited(HapticFeedback.heavyImpact());

      context.read<WallpaperBloc>().add(
            RestoreBackupIntent(
              bundle: bundle,
              mergeWithExisting: _mergeWithExisting,
            ),
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Restored: ${bundle.summary}'),
          backgroundColor: const Color(0xFF00E676),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _safePop();
    } catch (e) {
      setState(() {
        _jsonValidationError = 'Failed to parse backup archive: $e';
      });
    }
  }

  void _confirmFactoryReset() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFFF5722)),
            SizedBox(width: 8),
            Text(
              'Factory Reset Data?',
              style: TextStyle(color: Colors.white, fontSize: 17),
            ),
          ],
        ),
        content: const Text(
          'This will permanently reset all favorites, playlists, custom quotes, particle effects, and themes to initial factory defaults.\n\nDownloaded offline files will be preserved.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (ctx.mounted && Navigator.of(ctx).canPop()) {
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5722),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (ctx.mounted && Navigator.of(ctx).canPop()) {
                Navigator.of(ctx).pop();
              }
              HapticFeedback.heavyImpact();
              context.read<WallpaperBloc>().add(const ResetFactoryDefaultsIntent());
              _safePop();
            },
            child: const Text('Reset Everything'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WallpaperBloc, WallpaperState>(
      builder: (context, state) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.90,
          decoration: const BoxDecoration(
            color: Color(0xFF0F0F14),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 28,
                spreadRadius: 8,
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                // Modal Drag Handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),

                // Header Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00E5FF), Color(0xFF00E676)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.cloud_sync_rounded,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Data Portability & Backup',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Export, restore & manage your Wallora setup',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.65),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: _safePop,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(color: Colors.white10, height: 1),

                // Scrollable Content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    children: [
                      // SECTION 1: Active Setup Snapshot
                      _buildActiveSnapshotCard(state),
                      const SizedBox(height: 22),

                      // SECTION 2: Restore & Import Setup
                      const Text(
                        'RESTORE & IMPORT SETUP',
                        style: TextStyle(
                          color: Color(0xFF00E5FF),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildRestoreCard(),
                      const SizedBox(height: 22),

                      // SECTION 3: Storage & Factory Reset
                      const Text(
                        'STORAGE RECLAMATION & RESET',
                        style: TextStyle(
                          color: Color(0xFF00E5FF),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildStorageAndResetCard(state),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveSnapshotCard(WallpaperState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16161F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.inventory_2_rounded,
                size: 16,
                color: Color(0xFF00E5FF),
              ),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'WALLORA ACTIVE SETUP SNAPSHOT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Badges Grid
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMetricChip(
                icon: Icons.favorite_rounded,
                label: '${state.favoriteIds.length} Favorites',
                color: const Color(0xFFFF5252),
              ),
              _buildMetricChip(
                icon: Icons.playlist_play_rounded,
                label: '${state.customCollections.length} Playlists',
                color: const Color(0xFF00E5FF),
              ),
              _buildMetricChip(
                icon: Icons.format_quote_rounded,
                label: '${state.customizedQuotes.length} Quotes',
                color: const Color(0xFFD500F9),
              ),
              _buildMetricChip(
                icon: Icons.tune_rounded,
                label: '${state.customEffects.length} Effects',
                color: const Color(0xFFFFD600),
              ),
              _buildMetricChip(
                icon: Icons.palette_rounded,
                label: state.auraConfig.preset.displayName,
                color: state.auraConfig.preset.primaryAccent,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Export Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _handleExportToClipboard,
              icon: const Icon(Icons.copy_all_rounded, size: 18),
              label: const Text(
                'Copy Backup Archive (JSON)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestoreCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16161F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Paste Backup Archive',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                icon: const Icon(Icons.paste_rounded, size: 16),
                label: const Text('Paste from Clipboard'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF00E5FF),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: _handlePasteFromClipboard,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // JSON Input field
          TextField(
            controller: _jsonInputController,
            maxLines: 4,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
            decoration: InputDecoration(
              hintText: '{\n  "version": 1,\n  "appName": "Wallora", ...\n}',
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.25),
                fontSize: 11,
                fontFamily: 'monospace',
              ),
              filled: true,
              fillColor: const Color(0xFF101018),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF00E5FF)),
              ),
            ),
            onChanged: _validateJson,
          ),

          if (_jsonValidationError != null) ...[
            const SizedBox(height: 8),
            Text(
              _jsonValidationError!,
              style: const TextStyle(
                color: Color(0xFFFF5252),
                fontSize: 11,
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Merge Toggle
          Material(
            color: const Color(0xFF121218),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Merge with current setup',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Preserves existing favorites and playlists',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _mergeWithExisting,
                    activeThumbColor: const Color(0xFF00E5FF),
                    activeTrackColor:
                        const Color(0xFF00E5FF).withValues(alpha: 0.35),
                    onChanged: (val) {
                      setState(() {
                        _mergeWithExisting = val;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Restore Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E676),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _handleRestore,
              icon: const Icon(Icons.file_download_done_rounded, size: 18),
              label: const Text(
                'Verify & Restore Setup',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageAndResetCard(WallpaperState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16161F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sd_storage_rounded, size: 18, color: Colors.white70),
              const SizedBox(width: 8),
              const Text(
                'Offline Video Cache',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                state.storageFormatted,
                style: const TextStyle(
                  color: Color(0xFF00E5FF),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Clear Downloads button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: const BorderSide(color: Colors.white12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              context.read<WallpaperBloc>().add(ClearAllDownloadsIntent());
            },
            icon: const Icon(Icons.delete_sweep_rounded, size: 16),
            label: const Text('Clear Offline Video Cache'),
          ),
          const SizedBox(height: 10),

          // Factory Reset button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFFF5252),
              side: BorderSide(color: const Color(0xFFFF5252).withValues(alpha: 0.4)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _confirmFactoryReset,
            icon: const Icon(Icons.restart_alt_rounded, size: 16),
            label: const Text('Factory Reset All Settings & Playlists'),
          ),
        ],
      ),
    );
  }
}
