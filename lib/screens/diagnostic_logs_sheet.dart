import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/core.dart';

/// Interactive diagnostic logs viewer allowing QA and users to inspect runtime events,
/// copy an anonymized diagnostic report to the clipboard, and clear in-memory logs.
class DiagnosticLogsSheet extends StatefulWidget {
  const DiagnosticLogsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const DiagnosticLogsSheet(),
    );
  }

  @override
  State<DiagnosticLogsSheet> createState() => _DiagnosticLogsSheetState();
}

class _DiagnosticLogsSheetState extends State<DiagnosticLogsSheet> {
  late List<DiagnosticBreadcrumb> _breadcrumbs;

  @override
  void initState() {
    super.initState();
    _refreshLogs();
  }

  void _refreshLogs() {
    setState(() {
      _breadcrumbs = AppDiagnostics.getBreadcrumbs().reversed.toList();
    });
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'CRASH':
      case 'FLUTTER_ERROR':
        return AppColors.error;
      case 'NETWORK':
        return AppColors.neonCyan;
      case 'BLOC':
        return AppColors.auroraViolet;
      case 'LIFECYCLE':
        return AppColors.auroraEmerald;
      default:
        return AppColors.solarGold;
    }
  }

  void _copyReportToClipboard() {
    HapticFeedback.mediumImpact();
    final report = AppDiagnostics.exportDiagnosticReport();
    Clipboard.setData(ClipboardData(text: report));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.auroraEmerald, size: 18),
            SizedBox(width: AppDimensions.space8),
            Text('Diagnostic report copied to clipboard'),
          ],
        ),
        backgroundColor: AppColors.cardSurface,
        behavior: SnackBarBehavior.floating,
        duration: AppConstants.snackBarDisplayDuration,
      ),
    );
  }

  void _confirmClearLogs() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.modalBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius16),
        ),
        title: const Text('Clear Diagnostic Logs?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will purge all in-memory breadcrumbs and crash traces from this session.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (ctx.mounted && Navigator.of(ctx).canPop()) {
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              AppDiagnostics.clear();
              if (ctx.mounted && Navigator.of(ctx).canPop()) {
                Navigator.of(ctx).pop();
              }
              _refreshLogs();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radius28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: AppDimensions.space12),
              // Drag Handle
              Center(
                child: Container(
                  width: AppDimensions.sheetGrabberWidth,
                  height: AppDimensions.sheetGrabberHeight,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.space16),

              // Header Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.space8),
                      decoration: BoxDecoration(
                        color: AppColors.neonCyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppDimensions.radius12),
                      ),
                      child: const Icon(
                        Icons.bug_report_rounded,
                        color: AppColors.neonCyan,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'System Diagnostics',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                          Text(
                            '${_breadcrumbs.length} events • ${_formatUptime(AppDiagnostics.sessionUptime)} uptime',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, color: AppColors.neonCyan, size: 20),
                      tooltip: 'Copy Report',
                      onPressed: _copyReportToClipboard,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.white54, size: 20),
                      tooltip: 'Clear Logs',
                      onPressed: _confirmClearLogs,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.space12),
              const Divider(color: Colors.white10, height: 1),

              // Logs List
              Expanded(
                child: _breadcrumbs.isEmpty
                    ? const Center(
                        child: Text(
                          'No diagnostic events recorded yet.',
                          style: TextStyle(color: Colors.white38, fontSize: 13),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.space16,
                          vertical: AppDimensions.space12,
                        ),
                        itemCount: _breadcrumbs.length,
                        separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.space8),
                        itemBuilder: (context, index) {
                          final item = _breadcrumbs[index];
                          final categoryColor = _getCategoryColor(item.category);
                          final timeStr = item.timestamp.toIso8601String().substring(11, 19);

                          return Material(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(AppDimensions.radius12),
                            child: Padding(
                              padding: const EdgeInsets.all(AppDimensions.space12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppDimensions.space8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: categoryColor.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(AppDimensions.radius8),
                                          border: Border.all(
                                            color: categoryColor.withValues(alpha: 0.4),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          item.category,
                                          style: TextStyle(
                                            color: categoryColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        timeStr,
                                        style: const TextStyle(
                                          color: Colors.white38,
                                          fontSize: 10,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppDimensions.space8),
                                  Text(
                                    item.message,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (item.metadata != null && item.metadata!.isNotEmpty) ...[
                                    const SizedBox(height: AppDimensions.space4),
                                    Text(
                                      item.metadata.toString(),
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 11,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
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

  String _formatUptime(Duration uptime) {
    if (uptime.inMinutes == 0) {
      return '${uptime.inSeconds}s';
    }
    return '${uptime.inMinutes}m ${uptime.inSeconds % 60}s';
  }
}
