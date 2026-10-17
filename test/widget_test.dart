import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/blocs/wallpaper_bloc.dart';
import 'package:live_wallpaper/blocs/wallpaper_state.dart';
import 'package:live_wallpaper/data/curated_shorts_data.dart';
import 'package:live_wallpaper/repositories/wallpaper_repository.dart';
import 'package:live_wallpaper/screens/auto_rotation_sheet.dart';
import 'package:live_wallpaper/screens/categories_screen.dart';
import 'package:live_wallpaper/screens/custom_wallpaper_import_sheet.dart';
import 'package:live_wallpaper/screens/discover_screen.dart';
import 'package:live_wallpaper/screens/downloads_screen.dart';
import 'package:live_wallpaper/screens/favorites_screen.dart';
import 'package:live_wallpaper/screens/ipad_wallpaper_dialog.dart';
import 'package:live_wallpaper/screens/main_navigation_shell.dart';
import 'package:live_wallpaper/screens/onboarding_sheet.dart';
import 'package:live_wallpaper/screens/quote_studio_sheet.dart';
import 'package:live_wallpaper/screens/settings_sheet.dart';
import 'package:live_wallpaper/screens/splash_screen.dart';
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

    testWidgets('DiscoverScreen displays Curated Editorial Collections and opens detail sheet',
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

      expect(find.text('CURATED COLLECTIONS'), findsOneWidget);
      expect(find.text('OLED Obsidian Abyss'), findsOneWidget);

      // Tap on the first collection
      await tester.tap(find.text('OLED Obsidian Abyss'));
      await tester.pumpAndSettle();

      // Verify CollectionDetailSheet opened
      expect(find.text('Pure blacks & luminous geometry optimized for battery saving on AMOLED displays'), findsOneWidget);
    });

    testWidgets('DiscoverScreen displays search suggestions when no results match',
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
          searchQuery: 'nonexistentquery123xyz',
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

      expect(find.text('No wallpapers match "nonexistentquery123xyz"'), findsOneWidget);
      expect(find.text('Try one of these popular aesthetics:'), findsOneWidget);
      expect(find.byType(ActionChip), findsWidgets);
      expect(find.widgetWithText(ActionChip, 'Anime'), findsOneWidget);
    });

    testWidgets('SplashScreen renders Wallora branding, tagline, and loading bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(
            duration: Duration(seconds: 10),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pump(const Duration(milliseconds: 800));

      expect(find.text('WALLORA'), findsOneWidget);
      expect(find.text('Make every screen yours.'), findsOneWidget);
      expect(find.text('PREPARING CANVASES'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('SplashScreen navigates to next screen on tap or duration completion',
        (WidgetTester tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            duration: const Duration(milliseconds: 500),
            nextScreen: const Scaffold(
              body: Center(child: Text('HOME_SCREEN_REACHED')),
            ),
            onAnimationComplete: () {
              completed = true;
            },
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.byType(SplashScreen));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
      expect(find.text('HOME_SCREEN_REACHED'), findsOneWidget);
    });

    testWidgets('QuoteStudioSheet renders studio title, typography styles, and preview',
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
        ),
      );
      addTearDown(bloc.close);

      final short = CuratedShortsData.shorts.first;

      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: MaterialApp(
            home: Scaffold(
              body: QuoteStudioSheet(
                short: short,
                currentQuote: short.quote,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('QUOTE STUDIO'), findsOneWidget);
      expect(find.text('CANVAS WALLPAPER'), findsOneWidget);
      expect(find.text('TYPOGRAPHIC AESTHETIC'), findsOneWidget);
      expect(find.text('Modern Sans'), findsOneWidget);
      expect(find.text('Editorial Serif'), findsOneWidget);
      expect(find.text('SAVE TYPOGRAPHY'), findsOneWidget);
      expect(find.text('APPLY TO SCREEN'), findsOneWidget);
    });

    testWidgets('QuoteStudioSheet randomizes quote when Surprise Me is tapped',
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
        ),
      );
      addTearDown(bloc.close);

      final short = CuratedShortsData.shorts.first;

      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: MaterialApp(
            home: Scaffold(
              body: QuoteStudioSheet(
                short: short,
                currentQuote: 'Initial Quote Text',
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Surprise Me'), findsOneWidget);

      await tester.tap(find.text('Surprise Me'));
      await tester.pumpAndSettle();

      expect(find.text('Initial Quote Text'), findsNothing);
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

    testWidgets('DownloadsScreen displays offline filter chips and switches segments',
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
          downloadedIds: const {'ippo_hard_work', 'static_amoled_nebula'},
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

      expect(find.widgetWithText(ChoiceChip, 'All (2)'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Live (1)'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Static (1)'), findsOneWidget);

      // Switch to Live segment
      await tester.tap(find.widgetWithText(ChoiceChip, 'Live (1)'));
      await tester.pump();

      expect(find.text('Hajime no Ippo: Makunouchi Creed'), findsOneWidget);
    });

    testWidgets('FavoritesScreen displays filter chips and filters live and static favorites',
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
          favoriteIds: const {'ippo_hard_work', 'static_nature_solitude'},
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

      expect(find.widgetWithText(ChoiceChip, 'All (2)'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Live (1)'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Static (1)'), findsOneWidget);

      // Switch to Static segment
      await tester.tap(find.widgetWithText(ChoiceChip, 'Static (1)'));
      await tester.pump();

      expect(find.text('Alpine Solitude & Misty Ridge'), findsOneWidget);
    });

    testWidgets('AutoRotationSheet displays auto rotation controls, intervals, and source options',
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
          favoriteIds: const {'ippo_hard_work'},
          isAutoRotationEnabled: true,
          autoRotationIntervalMinutes: 60,
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: const MaterialApp(
            home: Scaffold(
              body: AutoRotationSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('AURORA AUTO-ROTATION'), findsOneWidget);
      expect(find.text('Auto-Rotation Active'), findsOneWidget);
      expect(find.text('ROTATION FREQUENCY'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, '1 Hour'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Daily (24h)'), findsOneWidget);
      expect(find.text('ROTATE WALLPAPER NOW'), findsOneWidget);

      // Select 3 Hours interval
      await tester.tap(find.widgetWithText(ChoiceChip, '3 Hours'));
      await tester.pump();
    });

    testWidgets('CustomWallpaperImportSheet renders creator controls, formats, and handles import',
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
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: const MaterialApp(
            home: Scaffold(
              body: CustomWallpaperImportSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify UI elements
      expect(find.text('CREATOR STUDIO'), findsOneWidget);
      expect(find.text('WALLPAPER FORMAT'), findsOneWidget);
      expect(find.text('Live Video (MP4)'), findsOneWidget);
      expect(find.text('Static 4K Image'), findsOneWidget);
      expect(find.text('QUICK SAMPLE PRESETS'), findsOneWidget);
      expect(find.text('Apex Live Video'), findsOneWidget);
      expect(find.text('Glass Canvas 4K'), findsOneWidget);
      expect(find.text('FILE PATH OR ASSET URI'), findsOneWidget);
      expect(find.text('WALLPAPER TITLE'), findsOneWidget);
      expect(find.text('CREATOR / ARTIST'), findsOneWidget);
      expect(find.text('CATEGORY'), findsOneWidget);
      expect(find.text('AURORA ACCENT PALETTE'), findsOneWidget);
      expect(find.text('IMPORT TO LIBRARY'), findsOneWidget);
      expect(find.text('IMPORT & APPLY'), findsOneWidget);

      // Tap preset
      await tester.tap(find.text('Glass Canvas 4K'));
      await tester.pumpAndSettle();

      // Switch to Static 4K Image
      await tester.tap(find.text('Static 4K Image'));
      await tester.pumpAndSettle();

      // Tap IMPORT TO LIBRARY
      await tester.tap(find.text('IMPORT TO LIBRARY'));
      await tester.pumpAndSettle();

      // Verify imported wallpaper is in bloc state
      expect(bloc.state.allShorts.any((s) => s.title.contains('Wallora Obsidian Canvas') || s.title.contains('Custom')), isTrue);
    });
  });
}
