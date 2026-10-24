import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:live_wallpaper/core/core.dart';
import 'package:live_wallpaper/main.dart';
import 'package:live_wallpaper/repositories/wallpaper_repository.dart';
import 'package:live_wallpaper/screens/diagnostic_logs_sheet.dart';
import 'package:live_wallpaper/screens/main_navigation_shell.dart';
import 'package:live_wallpaper/screens/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Wallora Production End-to-End Integration Tests', () {
    testWidgets('Full cold-boot, splash transition, tab navigation, and diagnostics inspection',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Set clean initial preferences
      SharedPreferences.setMockInitialValues({
        AppConstants.keyHasSeenOnboarding: true,
      });
      final prefs = await SharedPreferences.getInstance();
      final repository = WallpaperRepository(prefs: prefs);

      ServiceLocator.reset();
      ServiceLocator.registerSingleton<LocalCacheService>(repository.cache);
      ServiceLocator.registerSingleton<LruStorageManager>(repository.lruManager);
      ServiceLocator.registerSingleton<NetworkConnectivityService>(repository.connectivity);
      ServiceLocator.registerSingleton<FeedPrefetchManager>(repository.feedPrefetchManager);
      ServiceLocator.registerSingleton<WallpaperFacadeRepository>(repository);

      // Boot application
      await tester.pumpWidget(LiveWallpaperApp(repository: repository));

      // 1. Verify animated splash screen mounts
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('WALLORA'), findsOneWidget);

      // 2. Advance time past splash delay to transition to MainNavigationShell
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 2300));
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.byType(MainNavigationShell), findsOneWidget);

      // 3. Verify Bottom Navigation Tabs
      expect(find.text('Discover'), findsOneWidget);
      expect(find.text('Categories'), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('Downloads'), findsOneWidget);

      // 4. Navigate to Categories Tab
      await tester.tap(find.text('Categories'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 5. Navigate to Favorites Tab
      await tester.tap(find.text('Favorites'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 6. Navigate to Downloads Tab
      await tester.tap(find.text('Downloads'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 7. Navigate back to Discover Tab
      await tester.tap(find.text('Discover'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 7. Open Diagnostic Logs Sheet directly to inspect telemetry
      final navContext = tester.element(find.byType(MainNavigationShell));
      unawaited(DiagnosticLogsSheet.show(navContext));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('System Diagnostics'), findsOneWidget);
      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);

      // Close modal sheet safely
      if (navContext.mounted && Navigator.of(navContext).canPop()) {
        Navigator.of(navContext).pop();
      }
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
