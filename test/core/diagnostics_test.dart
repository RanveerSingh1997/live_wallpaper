import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/core/core.dart';

void main() {
  group('AppDiagnostics Unit Tests', () {
    setUp(() {
      AppDiagnostics.clear();
      AppDiagnostics.init(registerFlutterHandlers: false);
    });

    test('DiagnosticBreadcrumb serializes to JSON and parses correctly', () {
      final now = DateTime.now();
      final breadcrumb = DiagnosticBreadcrumb(
        timestamp: now,
        category: 'NETWORK',
        message: 'GET /wallpapers/curated',
        metadata: {'status': 200},
      );

      final json = breadcrumb.toJson();
      expect(json['category'], 'NETWORK');
      expect(json['message'], 'GET /wallpapers/curated');
      expect(json['metadata']['status'], 200);

      final parsed = DiagnosticBreadcrumb.fromJson(json);
      expect(parsed.category, 'NETWORK');
      expect(parsed.message, 'GET /wallpapers/curated');
      expect(parsed.metadata?['status'], 200);

      final formatted = breadcrumb.toFormattedString();
      expect(formatted, contains('[NETWORK]'));
      expect(formatted, contains('GET /wallpapers/curated'));
    });

    test('records breadcrumbs and respects 100-event FIFO capacity ring buffer', () {
      expect(AppDiagnostics.breadcrumbCount, 0);

      for (int i = 0; i < 120; i++) {
        AppDiagnostics.record('TEST', 'Event #$i', {'index': i});
      }

      expect(AppDiagnostics.breadcrumbCount, AppDiagnostics.maxBreadcrumbs);
      final breadcrumbs = AppDiagnostics.getBreadcrumbs();
      expect(breadcrumbs.first.message, 'Event #20');
      expect(breadcrumbs.last.message, 'Event #119');
    });

    test('recordError captures exception and stack trace excerpt', () {
      try {
        throw StateError('Simulated runtime exception');
      } catch (e, stack) {
        AppDiagnostics.recordError(e, stack, category: 'TEST_ERROR', context: 'TestContext');
      }

      final breadcrumbs = AppDiagnostics.getBreadcrumbs();
      expect(breadcrumbs.length, 1);
      expect(breadcrumbs.first.category, 'TEST_ERROR');
      expect(breadcrumbs.first.message, contains('Simulated runtime exception'));
      expect(breadcrumbs.first.metadata?['context'], 'TestContext');
    });

    test('exportDiagnosticReport builds formatted ASCII report', () {
      AppDiagnostics.record('BOOT', 'App booted successfully');
      final report = AppDiagnostics.exportDiagnosticReport();

      expect(report, contains('Wallora System Diagnostics & Telemetry Report'));
      expect(report, contains('Application: Wallora'));
      expect(report, contains('BOOT'));
      expect(report, contains('App booted successfully'));
      expect(report, contains('END OF REPORT'));
    });

    test('buildErrorWidget produces ProductionCrashFallbackWidget', () {
      final details = FlutterErrorDetails(
        exception: Exception('Widget failed layout'),
        library: 'widgets library',
      );

      final widget = AppDiagnostics.buildErrorWidget(details);
      expect(widget, isA<ProductionCrashFallbackWidget>());
    });

    test('DiagnosticNetworkInterceptor logs request, response, and error', () async {
      const interceptor = DiagnosticNetworkInterceptor();
      const request = NetworkRequest(method: HttpMethod.get, path: 'https://api.wallora.app/test');

      await interceptor.onRequest(request);
      final reqBreadcrumb = AppDiagnostics.getBreadcrumbs().last;
      expect(reqBreadcrumb.category, 'NETWORK');
      expect(reqBreadcrumb.message, contains('HTTP GET https://api.wallora.app/test'));

      await interceptor.onResponse(
        request,
        const NetworkResponse(statusCode: 200, data: {'ok': true}),
      );
      final resBreadcrumb = AppDiagnostics.getBreadcrumbs().last;
      expect(resBreadcrumb.category, 'NETWORK');
      expect(resBreadcrumb.message, contains('HTTP 200'));

      await interceptor.onError(
        request,
        const ConnectionNetworkException('Network down'),
      );
      final errBreadcrumb = AppDiagnostics.getBreadcrumbs().last;
      expect(errBreadcrumb.category, 'NETWORK');
      expect(errBreadcrumb.message, contains('HTTP error'));
    });
  });

  group('ProductionCrashFallbackWidget Tests', () {
    testWidgets('renders fallback UI with obsidian styling and retry button', (tester) async {
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: ProductionCrashFallbackWidget(
            onRetry: () => retried = true,
          ),
        ),
      );

      expect(find.text('Something unexpected occurred'), findsOneWidget);
      expect(find.text('Reload Interface'), findsOneWidget);
      expect(find.byIcon(Icons.report_problem_rounded), findsOneWidget);

      await tester.tap(find.text('Reload Interface'));
      await tester.pump();
      expect(retried, isTrue);
    });
  });
}
