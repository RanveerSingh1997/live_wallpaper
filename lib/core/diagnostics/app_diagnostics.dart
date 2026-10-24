import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../constants/app_constants.dart';
import 'diagnostic_breadcrumb.dart';
import 'production_crash_fallback_widget.dart';

/// Centralized diagnostic logging, crash interceptor, and observability manager for Wallora.
///
/// Features:
/// - Fixed-capacity (100) thread-safe FIFO ring buffer for breadcrumbs
/// - Production error boundaries preventing release UI crashes
/// - Anonymized diagnostic report generation for customer support
/// - Zero PII collection
class AppDiagnostics {
  static const int maxBreadcrumbs = 100;
  static final Queue<DiagnosticBreadcrumb> _breadcrumbs = Queue<DiagnosticBreadcrumb>();
  static final DateTime _sessionStartTime = DateTime.now();
  static bool _initialized = false;

  /// Private constructor to prevent instantiation.
  AppDiagnostics._();

  /// Initializes error boundary interceptors and begins session diagnostics.
  static void init({bool registerFlutterHandlers = true}) {
    if (_initialized) return;
    _initialized = true;

    record('LIFECYCLE', 'Wallora diagnostics subsystem initialized', {
      'version': AppConstants.appVersion,
      'build': AppConstants.buildNumber,
    });

    if (registerFlutterHandlers) {
      final originalFlutterError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        recordError(
          details.exception,
          details.stack,
          category: 'FLUTTER_ERROR',
          context: details.context?.toString(),
        );
        originalFlutterError?.call(details);
      };

      PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
        recordError(error, stack, category: 'PLATFORM_DISPATCHER');
        return true;
      };

      ErrorWidget.builder = buildErrorWidget;
    }
  }

  /// Records a diagnostic breadcrumb event into the in-memory ring buffer.
  static void record(
    String category,
    String message, [
    Map<String, dynamic>? metadata,
  ]) {
    final breadcrumb = DiagnosticBreadcrumb(
      timestamp: DateTime.now(),
      category: category.toUpperCase(),
      message: message,
      metadata: metadata,
    );

    if (_breadcrumbs.length >= maxBreadcrumbs) {
      _breadcrumbs.removeFirst();
    }
    _breadcrumbs.addLast(breadcrumb);

    if (kDebugMode) {
      debugPrint('[Wallora Diagnostics] ${breadcrumb.toFormattedString()}');
    }
  }

  /// Records an uncaught exception or fatal error event.
  static void recordError(
    Object error,
    StackTrace? stack, {
    String category = 'CRASH',
    String? context,
  }) {
    final firstStackLine = stack?.toString().split('\n').take(3).join('; ') ?? 'No stack trace';
    final metadata = <String, dynamic>{
      'stackExcerpt': firstStackLine,
    };
    if (context != null) {
      metadata['context'] = context;
    }
    record(category, error.toString(), metadata);
  }

  /// Returns an immutable copy of recent diagnostic breadcrumbs in chronological order.
  static List<DiagnosticBreadcrumb> getBreadcrumbs() {
    return List<DiagnosticBreadcrumb>.unmodifiable(_breadcrumbs);
  }

  /// Returns total count of recorded breadcrumbs currently stored.
  static int get breadcrumbCount => _breadcrumbs.length;

  /// Returns session uptime duration.
  static Duration get sessionUptime => DateTime.now().difference(_sessionStartTime);

  /// Clears in-memory breadcrumbs.
  static void clear() {
    _breadcrumbs.clear();
  }

  /// Builds the production error widget for widget tree layout crashes.
  static Widget buildErrorWidget(FlutterErrorDetails details) {
    return ProductionCrashFallbackWidget(details: details);
  }

  /// Generates an anonymized diagnostic report suitable for sharing or user support.
  static String exportDiagnosticReport() {
    final buffer = StringBuffer();
    buffer.writeln('====================================================');
    buffer.writeln('Wallora System Diagnostics & Telemetry Report');
    buffer.writeln('====================================================');
    buffer.writeln('Application: ${AppConstants.appName} v${AppConstants.appVersion}+${AppConstants.buildNumber}');
    buffer.writeln('Session Start: ${_sessionStartTime.toIso8601String()}');
    buffer.writeln('Session Uptime: ${sessionUptime.inMinutes}m ${sessionUptime.inSeconds % 60}s');
    buffer.writeln('Active Breadcrumbs: ${_breadcrumbs.length} / $maxBreadcrumbs');
    buffer.writeln('Environment: ${kDebugMode ? "Debug" : "Release/Profile"}');
    buffer.writeln('====================================================');
    buffer.writeln('RECENT DIAGNOSTIC EVENTS (CHRONOLOGICAL)');
    buffer.writeln('====================================================');

    if (_breadcrumbs.isEmpty) {
      buffer.writeln('No diagnostic events recorded.');
    } else {
      for (final breadcrumb in _breadcrumbs) {
        buffer.writeln(breadcrumb.toFormattedString());
      }
    }

    buffer.writeln('====================================================');
    buffer.writeln('END OF REPORT');
    buffer.writeln('====================================================');
    return buffer.toString();
  }
}
