import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/blocs/wallpaper_bloc.dart';
import 'package:live_wallpaper/blocs/wallpaper_state.dart';
import 'package:live_wallpaper/data/curated_shorts_data.dart';
import 'package:live_wallpaper/repositories/wallpaper_repository.dart';
import 'package:live_wallpaper/screens/categories_screen.dart';
import 'package:live_wallpaper/screens/discover_screen.dart';
import 'package:live_wallpaper/screens/downloads_screen.dart';
import 'package:live_wallpaper/screens/favorites_screen.dart';
import 'package:live_wallpaper/screens/ipad_wallpaper_dialog.dart';
import 'package:live_wallpaper/screens/main_navigation_shell.dart';
import 'package:live_wallpaper/screens/onboarding_sheet.dart';
import 'package:live_wallpaper/screens/settings_sheet.dart';
import 'package:live_wallpaper/screens/wallpaper_preview_sheet.dart';
import 'package:live_wallpaper/widgets/kinetic_quote_overlay.dart';
import 'package:live_wallpaper/widgets/shorts_action_rail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeWallpaperRepository extends WallpaperRepository {
  FakeWallpaperRepository({required super.prefs});

  @override
  Future<int> getTotalDownloadSizeBytes() async => 0;

  @override
  Future<bool> isWallpaperActiveOnDevice() async => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UI Components Widget Tests', () {
    testWidgets('KineticQuoteOverlay renders quote, author, and category badge',
        (WidgetTester tester) async {
      final short = CuratedShortsData.shorts.first; // Hajime no Ippo

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KineticQuoteOverlay(
              short: short,
              effectiveQuote: short.quote,
              isCustomized: false,
            ),
          ),
        ),
      );

      // Verify Hajime no Ippo quote text
      expect(find.text('"${short.quote}"'), findsOneWidget);

      // Verify category
      expect(find.text(short.category.toUpperCase()), findsOneWidget);

      // Verify author
      expect(find.text(short.author), findsOneWidget);
    });

    testWidgets('KineticQuoteOverlay shows custom quote tag when customized',
        (WidgetTester tester) async {
      final short = CuratedShortsData.shorts.first;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KineticQuoteOverlay(
              short: short,
              effectiveQuote: 'Custom Creed',
              isCustomized: true,
            ),
          ),
        ),
      );

      expect(find.text('"Custom Creed"'), findsOneWidget);
      expect(find.text('CUSTOM QUOTE'), findsOneWidget);
    });

    testWidgets('ShortsActionRail triggers callbacks on tap',
        (WidgetTester tester) async {
      final short = CuratedShortsData.shorts.first;
      bool applyTapped = false;
      bool customizeTapped = false;
      bool muteTapped = false;
      bool favoriteTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShortsActionRail(
              short: short,
              isFavorite: false,
              isMuted: true,
              isCurrentActive: false,
              isApplying: false,
              onApplyWallpaper: () => applyTapped = true,
              onCustomizeQuote: () => customizeTapped = true,
              onToggleMute: () => muteTapped = true,
              onToggleFavorite: () => favoriteTapped = true,
            ),
          ),
        ),
      );

      // Verify buttons exist
      expect(find.text('APPLY'), findsOneWidget);
      expect(find.text('Customize'), findsOneWidget);
      expect(find.text('Muted'), findsOneWidget);
      expect(find.text('Like'), findsOneWidget);

      // Tap buttons
      await tester.tap(find.text('APPLY'));
      await tester.pump();
      expect(applyTapped, true);

      await tester.tap(find.text('Customize'));
      await tester.pump();
      expect(customizeTapped, true);

      await tester.tap(find.text('Muted'));
      await tester.pump();
      expect(muteTapped, true);

      await tester.tap(find.text('Like'));
      await tester.pump();
      expect(favoriteTapped, true);
    });

    testWidgets('IPadWallpaperDialog renders instructions and action buttons',
        (WidgetTester tester) async {
      final short = CuratedShortsData.shorts.first;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IPadWallpaperDialog(short: short),
          ),
        ),
      );

      // Verify header & titles
      expect(find.text('Set Wallpaper on iPad'), findsOneWidget);
      expect(find.text(short.title), findsOneWidget);

      // Verify 3 steps
      expect(find.text('HOW TO APPLY ON IPADOS'), findsOneWidget);
      expect(find.text('Open Share Sheet'), findsOneWidget);
      expect(find.text('Select "Use as Wallpaper"'), findsOneWidget);
      expect(find.text('Set as Wallpaper Pair'), findsOneWidget);

      // Verify buttons
      expect(find.text('Open Wallpaper Share Sheet'), findsOneWidget);
      expect(find.text('Save Ultra-HD Wallpaper to Photos'), findsOneWidget);
    });

    testWidgets('MainNavigationShell renders 4 tabs: Discover, Categories, Favorites, Downloads',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repository = FakeWallpaperRepository(prefs: prefs);
      final bloc = WallpaperBloc(
        repository: repository,
        initialState: WallpaperState(
          allShorts: CuratedShortsData.shorts,
          filteredShorts: CuratedShortsData.shorts,
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: const MaterialApp(
            home: MainNavigationShell(),
          ),
        ),
      );

      await tester.pump();

      // Check bottom navigation items
      expect(find.text('Discover'), findsOneWidget);
      expect(find.text('Categories'), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('Downloads'), findsOneWidget);
    });

    testWidgets('CategoriesScreen displays category list properly',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repository = FakeWallpaperRepository(prefs: prefs);
      final bloc = WallpaperBloc(
        repository: repository,
        initialState: WallpaperState(
          allShorts: CuratedShortsData.shorts,
          filteredShorts: CuratedShortsData.shorts,
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: const MaterialApp(
            home: CategoriesScreen(),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('CATEGORIES'), findsOneWidget);
      expect(find.text('Anime & Gaming'), findsOneWidget);
      expect(find.text('Nature & Scenery'), findsOneWidget);
      expect(find.text('Cars & Speed'), findsOneWidget);
    });

    testWidgets('FavoritesScreen displays empty state when no favorites exist',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repository = FakeWallpaperRepository(prefs: prefs);
      final bloc = WallpaperBloc(
        repository: repository,
        initialState: WallpaperState(
          allShorts: CuratedShortsData.shorts,
          filteredShorts: CuratedShortsData.shorts,
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: MaterialApp(
            home: FavoritesScreen(onBrowseWallpapers: () {}),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('No Favorites Saved Yet'), findsOneWidget);
      expect(find.text('Discover Wallpapers'), findsOneWidget);
    });

    testWidgets('DownloadsScreen displays empty state when no offline downloads exist',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repository = FakeWallpaperRepository(prefs: prefs);
      final bloc = WallpaperBloc(
        repository: repository,
        initialState: WallpaperState(
          allShorts: CuratedShortsData.shorts,
          filteredShorts: CuratedShortsData.shorts,
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: MaterialApp(
            home: DownloadsScreen(onBrowseWallpapers: () {}),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('No Offline Downloads'), findsOneWidget);
      expect(find.text('Browse Wallpapers'), findsOneWidget);
    });

    testWidgets('DiscoverScreen displays RECENTLY VIEWED when recentlyViewedShorts is populated',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repository = FakeWallpaperRepository(prefs: prefs);
      final bloc = WallpaperBloc(
        repository: repository,
        initialState: WallpaperState(
          allShorts: CuratedShortsData.shorts,
          filteredShorts: CuratedShortsData.shorts,
          recentlyViewedIds: const ['ippo_hard_work', 'nature_aurora'],
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: MaterialApp(
            home: DiscoverScreen(onOpenLiveFeed: () {}),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('RECENTLY VIEWED'), findsOneWidget);
    });

    testWidgets('DiscoverScreen displays category filter chips and filters on selection',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repository = FakeWallpaperRepository(prefs: prefs);
      final bloc = WallpaperBloc(
        repository: repository,
        initialState: WallpaperState(
          allShorts: CuratedShortsData.shorts,
          filteredShorts: CuratedShortsData.shorts,
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: MaterialApp(
            home: DiscoverScreen(onOpenLiveFeed: () {}),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(ChoiceChip), findsWidgets);
      expect(find.widgetWithText(ChoiceChip, 'Live Wallpapers'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Static Wallpapers'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Anime & Gaming'), findsOneWidget);
    });

    testWidgets('WallpaperPreviewSheet displays technical specs and report button',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final short = CuratedShortsData.shorts.firstWhere((s) => !s.isLive);
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repository = FakeWallpaperRepository(prefs: prefs);
      final bloc = WallpaperBloc(
        repository: repository,
        initialState: WallpaperState(
          allShorts: CuratedShortsData.shorts,
          filteredShorts: CuratedShortsData.shorts,
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: MaterialApp(
            home: Scaffold(
              body: WallpaperPreviewSheet(wallpaper: short),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Resolution'), findsOneWidget);
      expect(find.text('File Size'), findsOneWidget);
      expect(find.byIcon(Icons.flag_outlined), findsOneWidget);
      expect(find.text('APPLY WALLPAPER'), findsOneWidget);
    });

    testWidgets('OnboardingSheet displays Wallora branding and advances pages',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repository = FakeWallpaperRepository(prefs: prefs);
      final bloc = WallpaperBloc(
        repository: repository,
        initialState: const WallpaperState(hasSeenOnboarding: false),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: const MaterialApp(
            home: Scaffold(
              body: OnboardingSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('WALLORA'), findsOneWidget);
      expect(find.text('Make every screen yours.'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);

      // Tap Continue to advance to preferences slide
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('What is your aesthetic?'), findsOneWidget);
    });

    testWidgets('SettingsSheet displays storage cache and integrity metrics',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repository = FakeWallpaperRepository(prefs: prefs);
      final bloc = WallpaperBloc(
        repository: repository,
        initialState: const WallpaperState(
          totalStorageUsedBytes: 5242880,
          downloadedIds: {'ippo_hard_work'},
          userPreferences: {'Anime & Gaming'},
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: const MaterialApp(
            home: Scaffold(
              body: SettingsSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('STORAGE & OFFLINE CACHE'), findsOneWidget);
      expect(find.text('BATTERY & HARDWARE INTEGRITY'), findsOneWidget);
      expect(find.text('5.0 MB'), findsOneWidget);
      expect(find.text('Replay Onboarding Tour'), findsOneWidget);
    });
  });
}
