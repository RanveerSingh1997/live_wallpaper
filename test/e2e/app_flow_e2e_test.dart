import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/core/core.dart';
import 'package:live_wallpaper/main.dart';
import 'package:live_wallpaper/repositories/wallpaper_repository.dart';
import 'package:live_wallpaper/screens/diagnostic_logs_sheet.dart';
import 'package:live_wallpaper/screens/main_navigation_shell.dart';
import 'package:live_wallpaper/screens/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Wallora App Flow End-to-End Simulation Tests', () {
    testWidgets('Cold boot, animated splash screen transition, tab switching, and diagnostic inspection',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Prepare mocked persistent state
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

      // Boot application root widget
      await tester.pumpWidget(LiveWallpaperApp(repository: repository));

      // 1. Splash Screen Verification
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('WALLORA'), findsOneWidget);

      // 2. Animate and settle past splash delay to mount MainNavigationShell
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 2300));
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.byType(MainNavigationShell), findsOneWidget);

      // 3. Bottom Navigation Shell Verification
      expect(find.text('Discover'), findsOneWidget);
      expect(find.text('Categories'), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('Downloads'), findsOneWidget);

      // 4. Tab Transition: Categories
      await tester.tap(find.text('Categories'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 5. Tab Transition: Favorites
      await tester.tap(find.text('Favorites'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 6. Tab Transition: Downloads
      await tester.tap(find.text('Downloads'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 7. Tab Transition: Back to Discover
      await tester.tap(find.text('Discover'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 7. System Diagnostics Verification
      final navContext = tester.element(find.byType(MainNavigationShell));
      unawaited(DiagnosticLogsSheet.show(navContext));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('System Diagnostics'), findsOneWidget);
      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);

      // Close modal safely
      if (navContext.mounted && Navigator.of(navContext).canPop()) {
        Navigator.of(navContext).pop();
      }
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
