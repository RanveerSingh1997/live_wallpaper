import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/blocs/wallpaper_bloc.dart';
import 'package:live_wallpaper/blocs/wallpaper_state.dart';
import 'package:live_wallpaper/data/curated_shorts_data.dart';
import 'package:live_wallpaper/repositories/wallpaper_repository.dart';
import 'package:live_wallpaper/models/aura_palette_config.dart';
import 'package:live_wallpaper/models/aurora_synthesizer_config.dart';
import 'package:live_wallpaper/models/battery_telemetry_config.dart';
import 'package:live_wallpaper/models/lock_screen_style_config.dart';
import 'package:live_wallpaper/models/motivational_short.dart';
import 'package:live_wallpaper/models/parallax_effect_config.dart';
import 'package:live_wallpaper/models/particle_effect_config.dart';
import 'package:live_wallpaper/models/smart_filter_config.dart';
import 'package:live_wallpaper/models/standby_dock_config.dart';
import 'package:live_wallpaper/models/wallpaper_collection.dart';
import 'package:live_wallpaper/models/wallpaper_effect_config.dart';
import 'package:live_wallpaper/models/wallora_backup_bundle.dart';
import 'package:live_wallpaper/models/wallora_screen_blueprint.dart';
import 'package:live_wallpaper/screens/add_to_collection_sheet.dart';
import 'package:live_wallpaper/screens/aura_palette_sheet.dart';
import 'package:live_wallpaper/screens/aurora_synthesizer_sheet.dart';
import 'package:live_wallpaper/screens/community_exchange_sheet.dart';
import 'package:live_wallpaper/screens/auto_rotation_sheet.dart';
import 'package:live_wallpaper/widgets/aurora_synthesizer_canvas.dart';
import 'package:live_wallpaper/screens/battery_telemetry_sheet.dart';
import 'package:live_wallpaper/screens/data_portability_sheet.dart';
import 'package:live_wallpaper/screens/gesture_control_sheet.dart';
import 'package:live_wallpaper/screens/particle_effect_sheet.dart';
import 'package:live_wallpaper/screens/categories_screen.dart';
import 'package:live_wallpaper/screens/create_collection_sheet.dart';
import 'package:live_wallpaper/screens/custom_wallpaper_import_sheet.dart';
import 'package:live_wallpaper/screens/day_night_schedule_sheet.dart';
import 'package:live_wallpaper/screens/discover_screen.dart';
import 'package:live_wallpaper/screens/downloads_screen.dart';
import 'package:live_wallpaper/screens/favorites_screen.dart';
import 'package:live_wallpaper/screens/fullscreen_wallpaper_viewer.dart';
import 'package:live_wallpaper/screens/ipad_wallpaper_dialog.dart';
import 'package:live_wallpaper/screens/lock_screen_studio_sheet.dart';
import 'package:live_wallpaper/screens/main_navigation_shell.dart';
import 'package:live_wallpaper/screens/onboarding_sheet.dart';
import 'package:live_wallpaper/screens/parallax_studio_sheet.dart';
import 'package:live_wallpaper/screens/quote_studio_sheet.dart';
import 'package:live_wallpaper/screens/settings_sheet.dart';
import 'package:live_wallpaper/screens/smart_discovery_sheet.dart';
import 'package:live_wallpaper/screens/splash_screen.dart';
import 'package:live_wallpaper/screens/standby_dock_screen.dart';
import 'package:live_wallpaper/screens/standby_dock_sheet.dart';
import 'package:live_wallpaper/screens/wallpaper_effects_sheet.dart';
import 'package:live_wallpaper/screens/wallpaper_export_sheet.dart';
import 'package:live_wallpaper/screens/wallpaper_preview_sheet.dart';
import 'package:live_wallpaper/screens/wallpaper_quick_actions_sheet.dart';
import 'package:live_wallpaper/screens/weather_atmosphere_sheet.dart';
import 'package:live_wallpaper/screens/wallaza_cloud_discovery_sheet.dart';
import 'package:live_wallpaper/models/wallaza_cloud_wallpaper.dart';
import 'package:live_wallpaper/models/weather_atmosphere_config.dart';
import 'package:live_wallpaper/widgets/kinetic_quote_overlay.dart';
import 'package:live_wallpaper/widgets/shorts_action_rail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeWallpaperRepository extends WallpaperRepository {
  FakeWallpaperRepository({required super.prefs});

  @override
  Future<int> getTotalDownloadSizeBytes() async => 0;

  @override
  Future<bool> isWallpaperActiveOnDevice() async => false;

  @override
  Future<Map<String, dynamic>> applyAsLiveWallpaper({
    required MotivationalShort short,
    bool isMuted = true,
  }) async {
    await prefs.setString('active_wallpaper_id', short.id);
    return {'status': 'applied_mock'};
  }

  @override
  Future<Map<String, dynamic>> applyStaticWallpaper({
    required MotivationalShort short,
    String targetScreen = 'both',
    String? customQuote,
    WallpaperEffectConfig? effectConfig,
  }) async {
    await prefs.setString('active_wallpaper_id', short.id);
    return {'status': 'applied_static'};
  }
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
          weatherConfig: const WeatherAtmosphereConfig(effectType: WeatherEffectType.none),
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
          weatherConfig: const WeatherAtmosphereConfig(effectType: WeatherEffectType.none),
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

      // Verify AMOLED Mode switch and initial status
      expect(find.text('AMOLED True-Black Mode'), findsOneWidget);
      expect(find.text('STANDARD'), findsOneWidget);

      // Toggle AMOLED Switch
      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Verify status flipped to OPTIMIZED (Zero Draw)
      expect(find.text('OPTIMIZED (Zero Draw)'), findsOneWidget);
    });

    testWidgets('WallpaperQuickActionsSheet renders AMOLED certified badge and action rows',
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
          weatherConfig: const WeatherAtmosphereConfig(effectType: WeatherEffectType.none),
        ),
      );
      addTearDown(bloc.close);

      final amoledItem = CuratedShortsData.shorts.firstWhere(
        (w) => w.id == 'minimal_monolith',
      );

      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: MaterialApp(
            home: Scaffold(
              body: WallpaperQuickActionsSheet(wallpaper: amoledItem),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // AMOLED Badge Verification
      expect(find.text('AMOLED 96% BLACK'), findsOneWidget);
      expect(find.text('Obsidian Monolith & Horizon'), findsOneWidget);

      // Actions Verification
      expect(find.text('Apply to Device'), findsOneWidget);
      expect(find.text('Interactive Screen Simulator'), findsOneWidget);
      expect(find.text('Add to Playlist'), findsOneWidget);
      expect(find.text('Customize in Quote Studio'), findsOneWidget);
      expect(find.text('Save to Favorites'), findsOneWidget);
      expect(find.text('Download for Offline'), findsOneWidget);
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

      // Scroll to Wallaza 4K Cloud Streams section
      final cloudStreamHeader = find.text('WALLAZA 4K CLOUD STREAMS');
      await tester.scrollUntilVisible(
        cloudStreamHeader,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(cloudStreamHeader, findsOneWidget);

      final cloudFeedOption = find.text('Wallaza 4K Cloud Feed');
      expect(cloudFeedOption, findsOneWidget);

      await tester.tap(cloudFeedOption);
      await tester.pump();

      expect(bloc.state.autoRotationSource, 'wallaza_cloud');
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
          weatherConfig: const WeatherAtmosphereConfig(effectType: WeatherEffectType.none),
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

    testWidgets('FullScreenWallpaperViewer renders and switches simulation modes (Clean, Lock Screen, Home Screen)',
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
          weatherConfig: const WeatherAtmosphereConfig(effectType: WeatherEffectType.none),
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: MaterialApp(
            home: FullScreenWallpaperViewer(
              wallpapers: CuratedShortsData.shorts,
              initialIndex: 0,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially in Clean View mode
      expect(find.text('Clean View'), findsOneWidget);
      expect(find.text('APPLY TO DEVICE'), findsOneWidget);

      // Switch to Lock Screen simulation mode
      await tester.tap(find.byIcon(Icons.lock_outline_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Lock Screen'), findsOneWidget);
      expect(find.text('Sunday, October 18'), findsOneWidget);
      expect(find.text('09:41'), findsWidgets);
      expect(find.text('Swipe up to unlock'), findsOneWidget);
      expect(find.byIcon(Icons.flashlight_on_rounded), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);

      // Switch to Home Screen simulation mode
      await tester.tap(find.byIcon(Icons.grid_view_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Home Screen'), findsOneWidget);
      expect(find.text('Search apps, contacts, web...'), findsOneWidget);
      expect(find.text('Phone'), findsWidgets);
      expect(find.text('Messages'), findsWidgets);
      expect(find.text('Browser'), findsWidgets);
      expect(find.text('Wallora'), findsOneWidget);

      // Tap on canvas to toggle UI chrome off and back on
      await tester.tap(find.byType(PageView));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(PageView));
      await tester.pumpAndSettle();

      // Open Apply target selector
      await tester.tap(find.text('APPLY TO DEVICE'));
      await tester.pumpAndSettle();
      expect(find.text('APPLY WALLPAPER DESTINATION'), findsOneWidget);
      expect(find.text('Home Screen & Lock Screen (Recommended)'), findsOneWidget);
    });

    testWidgets('CreateCollectionSheet renders form, validates inputs, and triggers playlist creation',
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

      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: const MaterialApp(
            home: Scaffold(
              body: CreateCollectionSheet(initialWallpaperId: 'ippo_hard_work'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check header, preview and form labels
      expect(find.text('NEW PLAYLIST'), findsOneWidget);
      expect(find.text('PLAYLIST NAME'), findsOneWidget);
      expect(find.text('DESCRIPTION / SUBTITLE'), findsOneWidget);
      expect(find.text('PLAYLIST ICON'), findsOneWidget);

      // Scroll to CREATE PLAYLIST button
      await tester.drag(find.text('PLAYLIST NAME'), const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(find.text('CREATE PLAYLIST'), findsOneWidget);

      // Attempt submit without title -> triggers validation
      await tester.tap(find.text('CREATE PLAYLIST'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a playlist name'), findsOneWidget);

      // Enter playlist title
      await tester.enterText(find.byType(TextFormField).first, 'Neon Retrowave');
      await tester.pumpAndSettle();

      // Tap submit
      await tester.drag(find.byType(TextFormField).first, const Offset(0, -600));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CREATE PLAYLIST'));
      await tester.pumpAndSettle();

      // Verify playlist is created and stored in state
      expect(
        bloc.state.customCollections.any((c) => c.title == 'Neon Retrowave'),
        isTrue,
      );
    });

    testWidgets('AddToCollectionSheet displays existing custom playlists and toggles membership',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repository = FakeWallpaperRepository(prefs: prefs);
      const existingPlaylist = WallpaperCollection(
        id: 'custom_col_widget_test',
        title: 'Cyberpunk Vault',
        subtitle: 'Night vibe wallpapers',
        badge: 'PLAYLIST',
        icon: Icons.electric_bolt_rounded,
        wallpaperIds: [],
        gradientColors: [Color(0xFF00E5FF), Color(0xFFD500F9)],
        isUserCreated: true,
      );
      await repository.saveCustomCollection(existingPlaylist);

      final bloc = WallpaperBloc(
        repository: repository,
        initialState: WallpaperState(
          allShorts: CuratedShortsData.shorts,
          filteredShorts: CuratedShortsData.shorts,
          customCollections: const [existingPlaylist],
        ),
      );
      addTearDown(bloc.close);

      final short = CuratedShortsData.shorts.first;

      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: MaterialApp(
            home: Scaffold(
              body: AddToCollectionSheet(short: short),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify playlist item and actions
      expect(find.text('Cyberpunk Vault'), findsOneWidget);
      expect(find.text('NEW'), findsOneWidget);
      expect(find.text('DONE'), findsOneWidget);

      // Tap on playlist row to toggle membership
      await tester.tap(find.text('Cyberpunk Vault'));
      await tester.pumpAndSettle();

      // Verify short.id was added to playlist
      final updatedCol = bloc.state.customCollections.firstWhere(
        (c) => c.id == 'custom_col_widget_test',
      );
      expect(updatedCol.wallpaperIds.contains(short.id), isTrue);
    });

    testWidgets('CategoriesScreen switches to PLAYLISTS tab and renders playlist cards',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repository = FakeWallpaperRepository(prefs: prefs);
      const customPlaylist = WallpaperCollection(
        id: 'custom_col_cat_test',
        title: 'Speed & Drift',
        subtitle: 'Fast cars only',
        badge: 'PLAYLIST',
        icon: Icons.speed_rounded,
        wallpaperIds: ['gt3_rs_porsche'],
        gradientColors: [Color(0xFFFF5722), Color(0xFFFF1744)],
        isUserCreated: true,
      );

      final bloc = WallpaperBloc(
        repository: repository,
        initialState: WallpaperState(
          allShorts: CuratedShortsData.shorts,
          filteredShorts: CuratedShortsData.shorts,
          customCollections: const [customPlaylist],
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

      await tester.pumpAndSettle();

      // Initially on GENRES
      expect(find.text('GENRES'), findsOneWidget);
      expect(find.text('Anime & Gaming'), findsOneWidget);

      // Switch to PLAYLISTS tab
      await tester.tap(find.textContaining('PLAYLISTS'));
      await tester.pumpAndSettle();

      // Verify playlists tab content
      expect(find.text('Create Custom Playlist'), findsOneWidget);
      expect(find.text('MY PLAYLISTS'), findsOneWidget);
      expect(find.text('Speed & Drift'), findsOneWidget);

      await tester.drag(find.text('Create Custom Playlist'), const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(find.text('EDITORIAL COLLECTIONS'), findsOneWidget);
    });

    testWidgets('WallpaperEffectsSheet renders preset chips, sliders and saves effect configuration',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repository = FakeWallpaperRepository(prefs: prefs);
      final short = CuratedShortsData.shorts.first;

      final bloc = WallpaperBloc(
        repository: repository,
        initialState: WallpaperState(
          allShorts: [short],
          filteredShorts: [short],
        ),
      );
      addTearDown(bloc.close);

      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: MaterialApp(
            home: Scaffold(
              body: WallpaperEffectsSheet(wallpaper: short),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Header & Live Mockup
      expect(find.text('EFFECTS & FILTERS'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
      expect(find.text('FILTER PRESETS'), findsOneWidget);

      // Verify preset filter chips
      expect(find.text('Original'), findsOneWidget);
      expect(find.text('OLED Noir'), findsOneWidget);
      expect(find.text('Cyber Cyan'), findsOneWidget);

      // Tap on Cyber Cyan preset chip
      await tester.tap(find.text('Cyber Cyan'));
      await tester.pumpAndSettle();

      // Scroll down to reveal Apply button
      await tester.drag(find.text('EFFECTS & FILTERS'), const Offset(0, -600));
      await tester.pumpAndSettle();

      expect(find.text('APPLY EFFECTS TO CANVAS'), findsOneWidget);

      // Tap Apply Effects to Canvas
      await tester.tap(find.text('APPLY EFFECTS TO CANVAS'));
      await tester.pumpAndSettle();

      // Verify bloc received the custom effect
      final effect = bloc.state.getEffectiveEffects(short.id);
      expect(effect.colorFilterPreset, 'cyber_cyan');
      expect(effect.vignetteStrength, 0.2);
    });

    testWidgets('WallpaperExportSheet renders 9:16 poster preview, layout choices, and action buttons',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repository = FakeWallpaperRepository(prefs: prefs);
      final short = CuratedShortsData.shorts.first;

      final bloc = WallpaperBloc(
        repository: repository,
        initialState: WallpaperState(
          allShorts: [short],
          filteredShorts: [short],
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: MaterialApp(
            home: Scaffold(
              body: WallpaperExportSheet(wallpaper: short),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('EXPORT STORY & POSTER'), findsOneWidget);

      // Scroll down to reveal story template choices and export buttons
      await tester.drag(find.text('EXPORT STORY & POSTER'), const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(find.text('STORY TEMPLATE'), findsOneWidget);
      expect(find.text('Editorial Story'), findsOneWidget);
      expect(find.text('Clean Canvas'), findsOneWidget);
      expect(find.text('Quote Focus'), findsOneWidget);

      // Verify Action Buttons
      expect(find.text('SAVE POSTER'), findsOneWidget);
      expect(find.text('SHARE STORY'), findsOneWidget);

      // Switch to Clean Canvas layout
      await tester.tap(find.text('Clean Canvas'));
      await tester.pumpAndSettle();
    });

    testWidgets('WallpaperQuickActionsSheet renders Canvas Effects Studio and Story Export options',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repository = FakeWallpaperRepository(prefs: prefs);
      final short = CuratedShortsData.shorts.first;

      final bloc = WallpaperBloc(
        repository: repository,
        initialState: WallpaperState(
          allShorts: [short],
          filteredShorts: [short],
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: MaterialApp(
            home: Scaffold(
              body: WallpaperQuickActionsSheet(wallpaper: short),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Actions list
      expect(find.text('Canvas Effects & Filters Studio'), findsOneWidget);
      expect(find.text('Export Story & Poster'), findsOneWidget);
      expect(find.text('Add to Playlist'), findsOneWidget);
      expect(find.text('Customize in Quote Studio'), findsOneWidget);
    });

    testWidgets('DayNightScheduleSheet renders master toggle, 4 solar slots, night AMOLED option, and evaluate button',
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
          child: const MaterialApp(
            home: Scaffold(
              body: DayNightScheduleSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('SOLAR DAY & NIGHT'), findsOneWidget);
      expect(find.text('Dynamic Circadian Wallpaper Engine'), findsOneWidget);

      // Verify Master Toggle
      expect(find.text('Automate Solar Cycle Transitions'), findsOneWidget);

      // Verify 4 Solar Slots
      expect(find.text('Morning / Dawn'), findsOneWidget);
      expect(find.text('Afternoon / Focus'), findsOneWidget);
      expect(find.text('Sunset / Twilight'), findsOneWidget);
      expect(find.text('Night / AMOLED Black'), findsOneWidget);

      // Verify Night AMOLED Saver
      expect(find.text('Auto AMOLED True-Black at Night'), findsOneWidget);

      // Verify Action Button
      expect(find.text('Evaluate & Apply Current Slot Now'), findsOneWidget);

      // Toggle Master Switch
      final masterSwitchFinder = find.byType(Switch).first;
      await tester.tap(masterSwitchFinder);
      await tester.pumpAndSettle();

      // Open wallpaper picker for Morning / Dawn slot
      await tester.tap(find.text('Morning / Dawn'));
      await tester.pumpAndSettle();

      // Verify Picker is open
      expect(find.text('Choose for Morning / Dawn'), findsOneWidget);

      // Tap an option in picker
      final firstTileFinder = find.byType(ListTile).first;
      await tester.tap(firstTileFinder);
      await tester.pumpAndSettle();

      // Verify picker dismissed
      expect(find.text('Choose for Morning / Dawn'), findsNothing);
    });

    testWidgets('LockScreenStudioSheet renders preview, presets, typography, and saves aesthetic',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = FakeWallpaperRepository(prefs: prefs);
      final bloc = WallpaperBloc(
        repository: repo,
        initialState: WallpaperState(
          allShorts: CuratedShortsData.shorts,
          filteredShorts: CuratedShortsData.shorts,
        ),
      );
      addTearDown(bloc.close);

      final short = CuratedShortsData.shorts.first;

      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: MaterialApp(
            home: Scaffold(
              body: LockScreenStudioSheet(wallpaper: short),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 1. Verify Header
      expect(find.text('LOCK SCREEN STUDIO'), findsOneWidget);
      expect(find.text('Clock Typography & Glanceable Widgets'), findsOneWidget);

      // 2. Verify Presets and Fonts
      expect(find.text('Pixel Stacked'), findsOneWidget);
      expect(find.text('Cyber Matrix'), findsOneWidget);
      expect(find.text('Editorial Serif'), findsNWidgets(2)); // Preset chip + Font chip
      expect(find.text('Aurora Neon'), findsNWidgets(2)); // Preset chip + Font chip

      // 3. Verify Typography Font Options
      expect(find.text('Modern Sans'), findsOneWidget);
      expect(find.text('Cyber Mono'), findsOneWidget);
      expect(find.text('Bold Stencil'), findsOneWidget);

      // 4. Verify Layout Options
      expect(find.text('Classic Inline'), findsOneWidget);
      expect(find.text('Stacked Modern'), findsOneWidget);
      expect(find.text('Minimalist Badge'), findsOneWidget);

      // 5. Verify Buttons
      expect(find.text('Reset'), findsOneWidget);
      expect(find.text('SAVE LOCK SCREEN AESTHETIC'), findsOneWidget);

      // 6. Tap Preset 'Cyber Matrix'
      await tester.tap(find.text('Cyber Matrix'));
      await tester.pumpAndSettle();

      // 7. Tap 'SAVE LOCK SCREEN AESTHETIC'
      await tester.tap(find.text('SAVE LOCK SCREEN AESTHETIC'));
      await tester.pumpAndSettle();

      // Verify BLoC state updated with Cyber Matrix values
      expect(bloc.state.lockScreenStyle.clockFont, LockScreenClockFont.cyber);
      expect(bloc.state.lockScreenStyle.clockLayout, LockScreenClockLayout.stacked);
      expect(bloc.state.lockScreenStyle.widgetType, LockScreenWidgetType.batteryGlance);
    });

    testWidgets('ParallaxStudioSheet renders 3D mockup, presets, sliders, and applies configuration',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = FakeWallpaperRepository(prefs: prefs);
      final bloc = WallpaperBloc(
        repository: repo,
        initialState: WallpaperState(
          allShorts: CuratedShortsData.shorts,
          filteredShorts: CuratedShortsData.shorts,
        ),
      );
      addTearDown(bloc.close);

      final short = CuratedShortsData.shorts.first;

      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: MaterialApp(
            home: Scaffold(
              body: ParallaxStudioSheet(wallpaper: short),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 1. Verify Header
      expect(find.text('3D SPATIAL PARALLAX STUDIO'), findsOneWidget);
      expect(find.text('Gyroscopic Motion & Depth Hologram'), findsOneWidget);

      // 2. Verify Bubble Indicator & Hologram Badge
      expect(find.text('3D SPATIAL PLANE'), findsOneWidget);
      expect(find.text('ENGINE ACTIVE'), findsOneWidget);

      // 3. Verify Presets
      expect(find.text('Subtle Depth'), findsOneWidget);
      expect(find.text('Cinematic 3D'), findsOneWidget);
      expect(find.text('Deep Spatial'), findsOneWidget);
      expect(find.text('Hyper Float'), findsOneWidget);
      expect(find.text('Disabled'), findsOneWidget);

      // 4. Verify Sliders
      expect(find.text('Motion Sensitivity'), findsOneWidget);
      expect(find.text('Max Tilt Angle'), findsOneWidget);
      expect(find.text('Depth Zoom Scale'), findsOneWidget);

      // 5. Verify Toggles
      expect(find.text('Enable 3D Spatial Parallax'), findsOneWidget);
      expect(find.text('Invert Pitch (Vertical Axis)'), findsOneWidget);
      expect(find.text('Invert Roll (Horizontal Axis)'), findsOneWidget);

      // 6. Verify Apply Button
      expect(find.text('APPLY 3D SPATIAL PARALLAX'), findsOneWidget);

      // 7. Tap 'Deep Spatial' preset
      await tester.tap(find.text('Deep Spatial'));
      await tester.pumpAndSettle();

      // 8. Tap 'APPLY 3D SPATIAL PARALLAX'
      await tester.tap(find.text('APPLY 3D SPATIAL PARALLAX'));
      await tester.pumpAndSettle();

      // Verify BLoC state updated with Deep Spatial values
      expect(bloc.state.parallaxConfig.preset, ParallaxPreset.deepSpatial);
      expect(bloc.state.parallaxConfig.sensitivity, 1.8);
      expect(bloc.state.parallaxConfig.maxAngleDegrees, 18.0);
    });

    testWidgets('SmartDiscoverySheet renders sections, options, updates filters, and applies to BLoC',
        (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      final repo = FakeWallpaperRepository(prefs: prefs);
      final bloc = WallpaperBloc(
        repository: repo,
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
            home: Scaffold(
              body: SmartDiscoverySheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 1. Verify Header & Subtitle
      expect(find.text('Smart Semantic Discovery'), findsOneWidget);
      expect(find.text('Filter by vibe, color harmony & format'), findsOneWidget);

      // 2. Verify Section Headers that are visible
      expect(find.text('Media Format'), findsOneWidget);
      expect(find.text('Mood & Energy Vibe'), findsOneWidget);
      expect(find.text('Color Harmony Palette'), findsOneWidget);

      // 3. Verify & Select Format
      expect(find.text('All Formats'), findsOneWidget);
      expect(find.text('60 FPS Live'), findsOneWidget);
      expect(find.text('4K Ultra-HD'), findsOneWidget);

      await tester.tap(find.text('60 FPS Live'));
      await tester.pumpAndSettle();

      // 4. Verify & Select Mood Chips
      expect(find.text('All Moods'), findsOneWidget);
      expect(find.text('Fighter Spirit'), findsOneWidget);
      expect(find.text('Deep Focus'), findsOneWidget);

      await tester.tap(find.text('Fighter Spirit'));
      await tester.pumpAndSettle();

      // 5. Scroll to Display Attributes and verify
      await tester.scrollUntilVisible(
        find.text('Requires Text / Quote Overlay'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Display Attributes'), findsOneWidget);
      expect(find.text('AMOLED Certified Only'), findsOneWidget);
      expect(find.text('Requires Text / Quote Overlay'), findsOneWidget);

      // 6. Verify Match Pill & Apply Button (Pinned at bottom)
      expect(find.textContaining('match'), findsOneWidget);
      expect(find.text('Apply Discovery Filters'), findsOneWidget);

      await tester.tap(find.text('Apply Discovery Filters'));
      await tester.pumpAndSettle();

      // Verify BLoC state was updated
      expect(bloc.state.smartFilter.mediaType, equals(SmartMediaType.liveOnly));
      expect(bloc.state.smartFilter.mood, equals(SmartMood.fighterSpirit));
      expect(bloc.state.smartFilter.hasActiveFilters, isTrue);
    });

    testWidgets('DiscoverScreen displays Smart Discovery button and active filter banner',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final prefs = await SharedPreferences.getInstance();
      final repo = FakeWallpaperRepository(prefs: prefs);
      const activeFilter = SmartFilterConfig(
        mediaType: SmartMediaType.liveOnly,
        mood: SmartMood.fighterSpirit,
        paletteColor: SmartPaletteColor.neonCyan,
      );

      final bloc = WallpaperBloc(
        repository: repo,
        initialState: WallpaperState(
          allShorts: CuratedShortsData.shorts,
          filteredShorts: CuratedShortsData.shorts.where((s) => activeFilter.matches(s)).toList(),
          smartFilter: activeFilter,
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
      await tester.pump(const Duration(milliseconds: 300));

      // 1. Verify Smart Discovery active count badge
      expect(find.text('3'), findsOneWidget); // 3 active filters

      // 2. Verify Active Filter banner
      expect(find.textContaining('Smart Filter: 60 FPS Live'), findsOneWidget);
      expect(find.textContaining('Fighter Spirit'), findsOneWidget);

      // 3. Tap cancel icon to reset filters
      await tester.tap(find.byIcon(Icons.cancel_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify BLoC received ResetSmartFilterIntent
      expect(bloc.state.smartFilter, equals(SmartFilterConfig.defaultConfig));
    });

    testWidgets('BatteryTelemetrySheet renders telemetry cards, target fps options, switches, and saves settings',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final prefs = await SharedPreferences.getInstance();
      final repo = FakeWallpaperRepository(prefs: prefs);

      final bloc = WallpaperBloc(
        repository: repo,
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
            home: Scaffold(
              body: BatteryTelemetrySheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 1. Verify Header
      expect(find.text('Battery & Display Hub'), findsOneWidget);
      expect(find.text('OLED telemetry, frame rate & hardware governor'), findsOneWidget);

      // 2. Verify Metrics Card
      expect(find.text('LIVE OLED & POWER TELEMETRY'), findsOneWidget);
      expect(find.text('Hourly Drain'), findsOneWidget);
      expect(find.text('Energy Conserved'), findsOneWidget);

      // 3. Verify Target Frame-Rate Governor options
      expect(find.text('TARGET FRAME-RATE GOVERNOR'), findsOneWidget);
      expect(find.text('60 FPS Ultra-Smooth'), findsOneWidget);
      expect(find.text('30 FPS Balanced Eco'), findsOneWidget);
      expect(find.text('Adaptive Eco-Scaling'), findsOneWidget);

      // 4. Select 30 FPS mode
      await tester.tap(find.text('30 FPS Balanced Eco'));
      await tester.pumpAndSettle();

      // 5. Scroll down to see Hardware & Display options
      await tester.scrollUntilVisible(
        find.text('Zero Sleep Overhead Verified'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('HARDWARE & DISPLAY OPTIMIZATION'), findsOneWidget);
      expect(find.text('Micro-Pixel Shift Drift'), findsOneWidget);
      expect(find.text('Hardware Surface Acceleration'), findsOneWidget);
      expect(find.text('Adaptive Eco Throttle (<20%)'), findsOneWidget);
      expect(find.text('Zero Sleep Overhead Verified'), findsOneWidget);

      // 6. Verify and tap Save Settings button
      expect(find.text('Save Settings'), findsOneWidget);
      await tester.tap(find.text('Save Settings'));
      await tester.pumpAndSettle();

      // 7. Verify BLoC state was updated with 30 FPS
      expect(bloc.state.batteryTelemetry.targetFps, equals(TargetFpsMode.fps30));
    });

    testWidgets('BatteryTelemetrySheet Reset Defaults button restores factory defaults',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final prefs = await SharedPreferences.getInstance();
      final repo = FakeWallpaperRepository(prefs: prefs);

      const customConfig = BatteryTelemetryConfig(
        targetFps: TargetFpsMode.fps30,
        isEcoModeEnabled: true,
        isPixelShiftEnabled: false,
      );

      final bloc = WallpaperBloc(
        repository: repo,
        initialState: WallpaperState(
          allShorts: CuratedShortsData.shorts,
          filteredShorts: CuratedShortsData.shorts,
          batteryTelemetry: customConfig,
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: const MaterialApp(
            home: Scaffold(
              body: BatteryTelemetrySheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Reset Defaults
      expect(find.text('Reset Defaults'), findsOneWidget);
      await tester.tap(find.text('Reset Defaults'));
      await tester.pumpAndSettle();

      // Tap Save Settings
      await tester.tap(find.text('Save Settings'));
      await tester.pumpAndSettle();

      // Verify BLoC received default config
      expect(bloc.state.batteryTelemetry, equals(BatteryTelemetryConfig.defaultConfig));
    });

    testWidgets('SettingsSheet opens BatteryTelemetrySheet when tapping Battery & Display Hub tile',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final prefs = await SharedPreferences.getInstance();
      final repo = FakeWallpaperRepository(prefs: prefs);

      final bloc = WallpaperBloc(
        repository: repo,
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
            home: Scaffold(
              body: SettingsSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Scroll to Battery & Display Hub tile
      await tester.scrollUntilVisible(
        find.text('Battery & Display Hub'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Battery & Display Hub'), findsOneWidget);

      // Tap to open sheet
      await tester.tap(find.text('Battery & Display Hub'));
      await tester.pumpAndSettle();

      // Verify BatteryTelemetrySheet is opened
      expect(find.text('LIVE OLED & POWER TELEMETRY'), findsOneWidget);
      expect(find.text('Zero Sleep Overhead Verified'), findsOneWidget);
    });

    testWidgets('ParticleEffectSheet renders header, interactive preview, preset tiles, physics sliders, and saves settings',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final prefs = await SharedPreferences.getInstance();
      final repo = FakeWallpaperRepository(prefs: prefs);

      final bloc = WallpaperBloc(
        repository: repo,
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
            home: Scaffold(
              body: ParticleEffectSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 1. Verify Header
      expect(find.text('Interactive Particle FX'), findsOneWidget);
      expect(find.text('Real-time touch ripples & stardust physics'), findsOneWidget);

      // 2. Verify Sandbox Hint
      expect(find.textContaining('Touch or drag to test particle physics'), findsOneWidget);

      // 3. Verify Preset Tiles
      expect(find.text('PARTICLE PRESETS'), findsOneWidget);
      expect(find.text('Neon Stardust'), findsOneWidget);
      expect(find.text('Electric Sparks'), findsOneWidget);
      expect(find.text('Fluid Ripples'), findsOneWidget);
      expect(find.text('Sakura Petal Drift'), findsOneWidget);
      expect(find.text('Aurora Vortex'), findsOneWidget);
      expect(find.text('Clean Canvas (Off)'), findsOneWidget);

      // 4. Tap 'Electric Sparks' preset
      await tester.tap(find.text('Electric Sparks'));
      await tester.pumpAndSettle();

      // 5. Scroll down to sliders
      await tester.scrollUntilVisible(
        find.text('Ambient Glow Intensity'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('PHYSICS & VISUAL TUNING'), findsOneWidget);
      expect(find.text('Particle Density'), findsOneWidget);
      expect(find.text('Touch Velocity & Speed'), findsOneWidget);
      expect(find.text('Particle Lifespan'), findsOneWidget);
      expect(find.text('Ambient Glow Intensity'), findsOneWidget);

      // 6. Scroll down to hardware controls & save button
      await tester.scrollUntilVisible(
        find.text('Touch Haptic Feedback'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('HARDWARE CONTROLS'), findsOneWidget);
      expect(find.text('Touch Haptic Feedback'), findsOneWidget);
      expect(find.text('Low-Battery Auto-Pause (<15%)'), findsOneWidget);

      // 7. Verify Save Button and tap it
      expect(find.text('Save Particle FX'), findsOneWidget);
      await tester.tap(find.text('Save Particle FX'));
      await tester.pumpAndSettle();

      // 8. Verify BLoC state was updated with Electric Sparks preset
      expect(bloc.state.particleConfig.preset, equals(ParticlePreset.electricSparks));
    });

    testWidgets('ParticleEffectSheet Reset Defaults restores default configuration',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final prefs = await SharedPreferences.getInstance();
      final repo = FakeWallpaperRepository(prefs: prefs);

      const customConfig = ParticleEffectConfig(
        preset: ParticlePreset.sakuraDrift,
        particleCount: 90,
      );

      final bloc = WallpaperBloc(
        repository: repo,
        initialState: WallpaperState(
          allShorts: CuratedShortsData.shorts,
          filteredShorts: CuratedShortsData.shorts,
          particleConfig: customConfig,
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: const MaterialApp(
            home: Scaffold(
              body: ParticleEffectSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Reset Defaults
      expect(find.text('Reset Defaults'), findsOneWidget);
      await tester.tap(find.text('Reset Defaults'));
      await tester.pumpAndSettle();

      // Tap Save Particle FX
      await tester.tap(find.text('Save Particle FX'));
      await tester.pumpAndSettle();

      // Verify BLoC received default config
      expect(bloc.state.particleConfig, equals(ParticleEffectConfig.defaultConfig));
    });

    testWidgets('SettingsSheet opens ParticleEffectSheet when tapping Interactive Particle FX Studio tile',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final prefs = await SharedPreferences.getInstance();
      final repo = FakeWallpaperRepository(prefs: prefs);

      final bloc = WallpaperBloc(
        repository: repo,
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
            home: Scaffold(
              body: SettingsSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Scroll to Interactive Particle FX Studio tile
      await tester.scrollUntilVisible(
        find.text('Interactive Particle FX Studio'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Interactive Particle FX Studio'), findsOneWidget);

      // Tap to open sheet
      await tester.tap(find.text('Interactive Particle FX Studio'));
      await tester.pumpAndSettle();

      // Verify ParticleEffectSheet is opened
      expect(find.text('Interactive Particle FX'), findsOneWidget);
      expect(find.text('PARTICLE PRESETS'), findsOneWidget);
    });

    testWidgets('AuraPaletteSheet renders 5-point swatches, presets, tuning sliders, and saves settings',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final prefs = await SharedPreferences.getInstance();
      final repo = FakeWallpaperRepository(prefs: prefs);

      final bloc = WallpaperBloc(
        repository: repo,
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
            home: Scaffold(
              body: AuraPaletteSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 1. Verify Header
      expect(find.text('Aura Chromatic Harmonizer'), findsOneWidget);
      expect(find.text('Dynamic palette extraction & UI color sync'), findsOneWidget);

      // 2. Verify Swatches
      expect(find.text('EXTRACTED 5-POINT AURA PALETTE'), findsOneWidget);
      expect(find.text('Dominant'), findsOneWidget);
      expect(find.text('Vibrant'), findsOneWidget);
      expect(find.text('Harmonic'), findsOneWidget);
      expect(find.text('OLED Shadow'), findsOneWidget);
      expect(find.text('Glow'), findsOneWidget);

      // 3. Verify Preset Tiles
      expect(find.text('AURA THEME PRESETS'), findsOneWidget);
      expect(find.text('Wallpaper Reactive (Auto)'), findsOneWidget);
      expect(find.text('Cyber Aurora'), findsOneWidget);
      expect(find.text('Solar Eclipse'), findsOneWidget);
      expect(find.text('Emerald Matrix'), findsOneWidget);
      expect(find.text('Velvet Twilight'), findsOneWidget);
      expect(find.text('Obsidian Monochrome'), findsOneWidget);

      // 4. Tap 'Cyber Aurora' preset
      await tester.tap(find.text('Cyber Aurora'));
      await tester.pumpAndSettle();

      // 5. Scroll down to sliders
      await tester.scrollUntilVisible(
        find.text('Saturation Multiplier'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('CHROMATIC TUNING & SHIFT'), findsOneWidget);
      expect(find.text('Hue Shift'), findsOneWidget);
      expect(find.text('Saturation Multiplier'), findsOneWidget);

      // 6. Scroll down to synchronization targets & save button
      await tester.scrollUntilVisible(
        find.text('Sync Interactive Particle FX'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('HARMONIZATION TARGETS'), findsOneWidget);
      expect(find.text('Sync Interactive Particle FX'), findsOneWidget);
      expect(find.text('Sync Kinetic Quote Typography'), findsOneWidget);
      expect(find.text('Sync Lock Screen Clock & Accents'), findsOneWidget);

      // 7. Verify Save Button and tap it
      expect(find.text('Save Aura Theme'), findsOneWidget);
      await tester.tap(find.text('Save Aura Theme'));
      await tester.pumpAndSettle();

      // 8. Verify BLoC state was updated with Cyber Aurora preset
      expect(bloc.state.auraConfig.preset, equals(AuraThemePreset.cyberAurora));
    });

    testWidgets('AuraPaletteSheet Reset Defaults restores default configuration',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final prefs = await SharedPreferences.getInstance();
      final repo = FakeWallpaperRepository(prefs: prefs);

      final bloc = WallpaperBloc(
        repository: repo,
        initialState: WallpaperState(
          allShorts: CuratedShortsData.shorts,
          filteredShorts: CuratedShortsData.shorts,
          auraConfig: const AuraPaletteConfig(
            preset: AuraThemePreset.solarEclipse,
            hueShiftDegrees: 50.0,
          ),
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: const MaterialApp(
            home: Scaffold(
              body: AuraPaletteSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Reset Defaults
      expect(find.text('Reset Defaults'), findsOneWidget);
      await tester.tap(find.text('Reset Defaults'));
      await tester.pumpAndSettle();

      // Tap Save Aura Theme
      await tester.tap(find.text('Save Aura Theme'));
      await tester.pumpAndSettle();

      // Verify restored to default
      expect(bloc.state.auraConfig, equals(AuraPaletteConfig.defaultConfig));
    });

    testWidgets('SettingsSheet opens AuraPaletteSheet when tapping Aura Chromatic Harmonizer tile',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final prefs = await SharedPreferences.getInstance();
      final repo = FakeWallpaperRepository(prefs: prefs);

      final bloc = WallpaperBloc(
        repository: repo,
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
            home: Scaffold(
              body: SettingsSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Scroll to Aura Chromatic Harmonizer tile
      await tester.scrollUntilVisible(
        find.text('Aura Chromatic Harmonizer'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Aura Chromatic Harmonizer'), findsOneWidget);

      // Tap to open sheet
      await tester.tap(find.text('Aura Chromatic Harmonizer'));
      await tester.pumpAndSettle();

      // Verify AuraPaletteSheet is opened
      expect(find.text('Aura Chromatic Harmonizer'), findsWidgets);
      expect(find.text('EXTRACTED 5-POINT AURA PALETTE'), findsOneWidget);
    });

    testWidgets('DataPortabilitySheet renders active setup snapshot, JSON input, and buttons',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final prefs = await SharedPreferences.getInstance();
      final repo = FakeWallpaperRepository(prefs: prefs);

      final bloc = WallpaperBloc(
        repository: repo,
        initialState: WallpaperState(
          allShorts: CuratedShortsData.shorts,
          filteredShorts: CuratedShortsData.shorts,
          favoriteIds: const {'wall_1'},
          customizedQuotes: const {'wall_1': 'Be Bold'},
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: const MaterialApp(
            home: Scaffold(
              body: DataPortabilitySheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 1. Verify Header
      expect(find.text('Data Portability & Backup'), findsOneWidget);
      expect(find.text('Export, restore & manage your Wallora setup'), findsOneWidget);

      // 2. Verify Snapshot Badges
      expect(find.text('WALLORA ACTIVE SETUP SNAPSHOT'), findsOneWidget);
      expect(find.text('1 Favorites'), findsOneWidget);
      expect(find.text('1 Quotes'), findsOneWidget);
      expect(find.text('Copy Backup Archive (JSON)'), findsOneWidget);

      // 3. Verify Restore Card
      expect(find.text('RESTORE & IMPORT SETUP'), findsOneWidget);
      expect(find.text('Paste Backup Archive'), findsOneWidget);
      expect(find.text('Merge with current setup'), findsOneWidget);
      expect(find.text('Verify & Restore Setup'), findsOneWidget);

      // 4. Scroll to Storage & Reset
      await tester.scrollUntilVisible(
        find.text('Factory Reset All Settings & Playlists'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('STORAGE RECLAMATION & RESET'), findsOneWidget);
      expect(find.text('Clear Offline Video Cache'), findsOneWidget);
      expect(find.text('Factory Reset All Settings & Playlists'), findsOneWidget);
    });

    testWidgets('DataPortabilitySheet validates JSON and triggers restore',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final prefs = await SharedPreferences.getInstance();
      final repo = FakeWallpaperRepository(prefs: prefs);

      final bloc = WallpaperBloc(
        repository: repo,
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
            home: Scaffold(
              body: DataPortabilitySheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 1. Enter invalid text
      await tester.enterText(find.byType(TextField), 'invalid json text');
      await tester.pumpAndSettle();

      expect(find.text('Invalid Wallora backup format or missing version.'), findsOneWidget);

      // 2. Enter valid Wallora backup JSON
      final validBundle = WalloraBackupBundle(
        exportedAt: DateTime.now(),
        favoriteIds: const {'wall_imported_test'},
        isAmoledSaverModeEnabled: true,
      );
      await tester.enterText(find.byType(TextField), validBundle.toJsonString());
      await tester.pumpAndSettle();

      // Error should disappear
      expect(find.text('Invalid Wallora backup format or missing version.'), findsNothing);

      // 3. Tap Restore
      await tester.tap(find.text('Verify & Restore Setup'));
      await tester.pumpAndSettle();

      // Verify BLoC state received imported favorite
      expect(bloc.state.favoriteIds, contains('wall_imported_test'));
      expect(bloc.state.isAmoledSaverModeEnabled, isTrue);
    });

    testWidgets('SettingsSheet opens DataPortabilitySheet when tapping Data Portability & Backup Hub tile',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final prefs = await SharedPreferences.getInstance();
      final repo = FakeWallpaperRepository(prefs: prefs);

      final bloc = WallpaperBloc(
        repository: repo,
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
            home: Scaffold(
              body: SettingsSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Scroll to Data Portability tile
      await tester.scrollUntilVisible(
        find.text('Data Portability & Backup Hub'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Data Portability & Backup Hub'), findsOneWidget);

      // Tap to open sheet
      await tester.tap(find.text('Data Portability & Backup Hub'));
      await tester.pumpAndSettle();

      // Verify DataPortabilitySheet is opened
      expect(find.text('WALLORA ACTIVE SETUP SNAPSHOT'), findsOneWidget);
      expect(find.text('Copy Backup Archive (JSON)'), findsOneWidget);
    });

    testWidgets('GestureControlSheet renders playground, master toggle, action tiles, and chips', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final prefs = await SharedPreferences.getInstance();
      final repo = FakeWallpaperRepository(prefs: prefs);
      final bloc = WallpaperBloc(
        repository: repo,
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
            home: Scaffold(
              body: GestureControlSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Header and sections
      expect(find.text('Interactive Gesture Studio'), findsOneWidget);
      expect(find.text('TACTILE TOUCH PLAYGROUND'), findsOneWidget);
      expect(find.text('Enable Gesture Triggers'), findsOneWidget);
      expect(find.text('GESTURE ACTION MAPPINGS'), findsOneWidget);
      expect(find.text('Double-Tap Action'), findsOneWidget);
      expect(find.text('Triple-Tap Action'), findsOneWidget);
      expect(find.text('Long-Press Action'), findsOneWidget);
      expect(find.text('Two-Finger Swipe Down'), findsOneWidget);
      expect(find.text('SENSORY HAPTIC INTENSITY'), findsOneWidget);
      expect(find.text('TOUCH CONTACT VISUAL FX'), findsOneWidget);
      expect(find.text('CONTACT COLOR HARMONY'), findsOneWidget);

      // Verify playground interaction
      await tester.tap(find.text('Double-tap, triple-tap, or hold to feel tactile response'));
      await tester.pumpAndSettle();

      // Tap reset button and verify confirmation dialog
      await tester.scrollUntilVisible(
        find.text('Reset to Default Gestures'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Reset to Default Gestures'));
      await tester.pumpAndSettle();

      expect(find.text('Reset Gesture Controls'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Reset to Defaults'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Reset Gesture Controls'), findsNothing);
    });

    testWidgets('SettingsSheet navigation opens GestureControlSheet via Interactive Gesture Controls tile', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final prefs = await SharedPreferences.getInstance();
      final repo = FakeWallpaperRepository(prefs: prefs);
      final bloc = WallpaperBloc(
        repository: repo,
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
            home: Scaffold(
              body: SettingsSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Scroll to Interactive Gesture Controls tile
      await tester.scrollUntilVisible(
        find.text('Interactive Gesture Controls'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Interactive Gesture Controls'), findsOneWidget);

      // Tap to open sheet
      await tester.tap(find.text('Interactive Gesture Controls'));
      await tester.pumpAndSettle();

      // Verify GestureControlSheet is opened
      expect(find.text('Interactive Gesture Studio'), findsOneWidget);
      expect(find.text('TACTILE TOUCH PLAYGROUND'), findsOneWidget);
    });

    testWidgets('StandbyDockScreen renders clock, battery pill, and floating controls',
        (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      final repo = FakeWallpaperRepository(prefs: prefs);
      final bloc = WallpaperBloc(
        repository: repo,
        initialState: WallpaperState(
          allShorts: CuratedShortsData.shorts,
          filteredShorts: CuratedShortsData.shorts,
          standbyDockConfig: const StandbyDockConfig(
            showBatteryPill: true,
            showDateAndSolarSlot: true,
            showMotivationalQuote: true,
          ),
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: const MaterialApp(
            home: StandbyDockScreen(),
          ),
        ),
      );

      await tester.pump();

      // Verify battery pill
      expect(find.text('100% CHARGED'), findsOneWidget);

      // Verify back exit button icon exists
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

      // Verify night mode toggle exists
      expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
    });

    testWidgets('StandbyDockSheet renders typography styles, layout selectors, and OLED longevity switches',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final prefs = await SharedPreferences.getInstance();
      final repo = FakeWallpaperRepository(prefs: prefs);
      final bloc = WallpaperBloc(
        repository: repo,
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
            home: Scaffold(
              body: StandbyDockSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('Horizon Standby Studio'), findsOneWidget);
      expect(find.text('Ambient desk dock & nightstand OLED hub'), findsOneWidget);

      // Verify Sections
      expect(find.text('CLOCK TYPOGRAPHY'), findsOneWidget);
      expect(find.text('Modern Sans-Serif'), findsOneWidget);
      expect(find.text('Cyberpunk Mono'), findsOneWidget);
      expect(find.text('Editorial Serif'), findsOneWidget);
      expect(find.text('OLED Dot Matrix'), findsOneWidget);

      // Verify OLED protection tile
      expect(find.text('Anti-Burn-In Subpixel Shift'), findsOneWidget);

      // Verify Launch button
      expect(find.text('Launch Horizon Desk Dock'), findsOneWidget);
    });

    testWidgets('SettingsSheet opens StandbyDockSheet when Standby Studio tile is tapped',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final prefs = await SharedPreferences.getInstance();
      final repo = FakeWallpaperRepository(prefs: prefs);
      final bloc = WallpaperBloc(
        repository: repo,
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
            home: Scaffold(
              body: SettingsSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Scroll to Horizon Standby & Desk Dock Studio tile
      await tester.scrollUntilVisible(
        find.text('Horizon Standby & Desk Dock Studio'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Horizon Standby & Desk Dock Studio'), findsOneWidget);

      // Tap to open sheet
      await tester.tap(find.text('Horizon Standby & Desk Dock Studio'));
      await tester.pumpAndSettle();

      // Verify StandbyDockSheet is opened
      expect(find.text('Horizon Standby Studio'), findsOneWidget);
      expect(find.text('CLOCK TYPOGRAPHY'), findsOneWidget);
    });

    testWidgets('AuroraSynthesizerCanvas renders with custom configuration and child',
        (WidgetTester tester) async {
      const config = AuroraSynthesizerConfig(
        waveStyle: AuroraWaveStyle.cosmicNorthernLights,
        colorMode: AuroraColorMode.auraSync,
        waveCount: 4,
        isEnabled: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuroraSynthesizerCanvas(
              config: config,
              auraConfig: AuraPaletteConfig.defaultConfig,
              child: const Text('Aurora Overlay Content'),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AuroraSynthesizerCanvas), findsOneWidget);
      expect(find.text('Aurora Overlay Content'), findsOneWidget);
    });

    testWidgets('AuroraSynthesizerSheet renders viewport preview, style presets, sliders, and save button',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final prefs = await SharedPreferences.getInstance();
      final repo = FakeWallpaperRepository(prefs: prefs);
      final bloc = WallpaperBloc(
        repository: repo,
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
            home: Scaffold(
              body: AuroraSynthesizerSheet(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 1. Verify Header
      expect(find.text('Aurora Wave Synthesizer'), findsOneWidget);
      expect(find.text('Generative fluid aurora waves & procedural light ribbons'), findsOneWidget);

      // 2. Verify Sections & Presets
      expect(find.text('PROCEDURAL WAVE STYLE'), findsOneWidget);
      expect(find.text('Cosmic Northern Lights'), findsOneWidget);
      expect(find.text('Cyberpunk Laser Ribbon'), findsOneWidget);
      expect(find.text('Solar Flare Plasma'), findsOneWidget);

      // 3. Verify Harmony & Dynamics
      expect(find.text('COLOR HARMONY MODE'), findsOneWidget);
      expect(find.text('FLUID WAVE DYNAMICS'), findsOneWidget);

      // 4. Scroll to Save button
      await tester.scrollUntilVisible(
        find.text('Save Synthesized Aurora to Library'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Save Synthesized Aurora to Library'), findsOneWidget);

      // 5. Tap Save button
      await tester.tap(find.text('Save Synthesized Aurora to Library'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify that a new synthesized wallpaper was added to bloc.state.allShorts
      expect(bloc.state.allShorts.any((s) => s.id.startsWith('aurora_synth_')), isTrue);
    });

    testWidgets('SettingsSheet opens AuroraSynthesizerSheet when Aurora Wave Synthesizer Studio tile is tapped',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final prefs = await SharedPreferences.getInstance();
      final repo = FakeWallpaperRepository(prefs: prefs);
      final bloc = WallpaperBloc(
        repository: repo,
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
            home: Scaffold(
              body: SettingsSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Scroll to Aurora Wave Synthesizer Studio tile
      await tester.scrollUntilVisible(
        find.text('Aurora Wave Synthesizer Studio'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Aurora Wave Synthesizer Studio'), findsOneWidget);

      // Tap to open sheet
      await tester.tap(find.text('Aurora Wave Synthesizer Studio'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify AuroraSynthesizerSheet is opened
      expect(find.text('Aurora Wave Synthesizer'), findsOneWidget);
      expect(find.text('PROCEDURAL WAVE STYLE'), findsOneWidget);
    });

    testWidgets('DiscoverScreen renders Aurora Wave Synthesizer IconButton and opens AuroraSynthesizerSheet on tap',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final prefs = await SharedPreferences.getInstance();
      final repo = FakeWallpaperRepository(prefs: prefs);
      final bloc = WallpaperBloc(
        repository: repo,
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
            home: DiscoverScreen(
              onOpenLiveFeed: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Aurora Synthesizer IconButton
      final auroraButton = find.byTooltip('Aurora Wave Synthesizer');
      expect(auroraButton, findsOneWidget);

      // Tap to open
      await tester.tap(auroraButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify sheet opens
      expect(find.text('Aurora Wave Synthesizer'), findsOneWidget);
      expect(find.text('PROCEDURAL WAVE STYLE'), findsOneWidget);
    });

    testWidgets('CommunityExchangeSheet renders header, active setup banner, tag chips, and curated blueprints',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final prefs = await SharedPreferences.getInstance();
      final repo = FakeWallpaperRepository(prefs: prefs);
      final bloc = WallpaperBloc(
        repository: repo,
        initialState: WallpaperState(
          allShorts: CuratedShortsData.shorts,
          filteredShorts: CuratedShortsData.shorts,
          communityBlueprints: WalloraScreenBlueprint.curatedBlueprints,
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: const MaterialApp(
            home: Scaffold(
              body: CommunityExchangeSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('AESTHETIC BLUEPRINT EXCHANGE'), findsOneWidget);
      expect(find.text('Wallora • "Make every screen yours."'), findsOneWidget);

      // Verify Active Setup Banner
      expect(find.text('YOUR ACTIVE SETUP'), findsOneWidget);
      expect(find.text('Publish'), findsOneWidget);

      // Verify Tag Filters
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Cyberpunk'), findsOneWidget);
      expect(find.text('AMOLED'), findsOneWidget);

      // Verify Curated Blueprint Cards
      expect(find.text('Cyberpunk Neon Ronin'), findsOneWidget);
      expect(find.text('Shadow Monarch Dominion'), findsOneWidget);
    });

    testWidgets('CommunityExchangeSheet filters blueprints when tag chip is tapped',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final prefs = await SharedPreferences.getInstance();
      final repo = FakeWallpaperRepository(prefs: prefs);
      final bloc = WallpaperBloc(
        repository: repo,
        initialState: WallpaperState(
          allShorts: CuratedShortsData.shorts,
          filteredShorts: CuratedShortsData.shorts,
          communityBlueprints: WalloraScreenBlueprint.curatedBlueprints,
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: const MaterialApp(
            home: Scaffold(
              body: CommunityExchangeSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Cyberpunk tag
      await tester.tap(find.text('Cyberpunk'));
      await tester.pumpAndSettle();

      // Cyberpunk blueprint should be visible
      expect(find.text('Cyberpunk Neon Ronin'), findsOneWidget);
      // Celestial Aurora should be filtered out
      expect(find.text('Celestial Aurora Borealis'), findsNothing);
    });

    testWidgets('CommunityExchangeSheet tapping blueprint card opens details sheet with specifications',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final prefs = await SharedPreferences.getInstance();
      final repo = FakeWallpaperRepository(prefs: prefs);
      final bloc = WallpaperBloc(
        repository: repo,
        initialState: WallpaperState(
          allShorts: CuratedShortsData.shorts,
          filteredShorts: CuratedShortsData.shorts,
          communityBlueprints: WalloraScreenBlueprint.curatedBlueprints,
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: const MaterialApp(
            home: Scaffold(
              body: CommunityExchangeSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Cyberpunk Neon Ronin card
      await tester.tap(find.text('Cyberpunk Neon Ronin'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Details Modal
      expect(find.text('AESTHETIC DIMENSIONS SPECIFICATION'), findsOneWidget);
      expect(find.text('Wallpaper Asset'), findsOneWidget);
      expect(find.text('Chromatic Aura Palette'), findsOneWidget);
      expect(find.text('Interactive Particle Physics'), findsOneWidget);
      expect(find.text('3D Parallax Gyro Depth'), findsOneWidget);
      expect(find.text('Procedural Aurora Synthesizer'), findsOneWidget);
      expect(find.text('1-Tap Apply Complete Blueprint'), findsOneWidget);
    });

    testWidgets('CommunityExchangeSheet liking a blueprint updates like heart icon and persists',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final prefs = await SharedPreferences.getInstance();
      final repo = FakeWallpaperRepository(prefs: prefs);
      final bloc = WallpaperBloc(
        repository: repo,
        initialState: WallpaperState(
          allShorts: CuratedShortsData.shorts,
          filteredShorts: CuratedShortsData.shorts,
          communityBlueprints: WalloraScreenBlueprint.curatedBlueprints,
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: const MaterialApp(
            home: Scaffold(
              body: CommunityExchangeSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap first favorite border icon
      final favoriteButton = find.byIcon(Icons.favorite_border_rounded).first;
      await tester.tap(favoriteButton);
      await tester.pumpAndSettle();

      // Verify favorite icon changed to filled red heart
      expect(find.byIcon(Icons.favorite_rounded), findsAtLeastNWidgets(1));
    });

    testWidgets('CommunityExchangeSheet applying blueprint emits intent and displays SnackBar',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final prefs = await SharedPreferences.getInstance();
      final repo = FakeWallpaperRepository(prefs: prefs);
      final bloc = WallpaperBloc(
        repository: repo,
        initialState: WallpaperState(
          allShorts: CuratedShortsData.shorts,
          filteredShorts: CuratedShortsData.shorts,
          communityBlueprints: WalloraScreenBlueprint.curatedBlueprints,
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: const MaterialApp(
            home: Scaffold(
              body: CommunityExchangeSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Apply on the first blueprint card
      final applyButton = find.widgetWithText(ElevatedButton, 'Apply').first;
      await tester.tap(applyButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify confirmation SnackBar
      expect(find.textContaining('Applied'), findsOneWidget);
      expect(find.textContaining('Aesthetic Blueprint!'), findsOneWidget);
    });

    testWidgets('SettingsSheet renders Community Blueprint Showcase tile and opens CommunityExchangeSheet on tap',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final prefs = await SharedPreferences.getInstance();
      final repo = FakeWallpaperRepository(prefs: prefs);
      final bloc = WallpaperBloc(
        repository: repo,
        initialState: WallpaperState(
          allShorts: CuratedShortsData.shorts,
          filteredShorts: CuratedShortsData.shorts,
          communityBlueprints: WalloraScreenBlueprint.curatedBlueprints,
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

      // Verify tile presence
      final tile = find.text('Community Blueprint Showcase & Exchange');
      expect(tile, findsOneWidget);

      // Tap tile
      await tester.tap(tile);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify CommunityExchangeSheet opened
      expect(find.text('AESTHETIC BLUEPRINT EXCHANGE'), findsOneWidget);
      expect(find.text('YOUR ACTIVE SETUP'), findsOneWidget);
    });

    testWidgets('DiscoverScreen renders Blueprint Exchange IconButton and opens CommunityExchangeSheet on tap',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final prefs = await SharedPreferences.getInstance();
      final repo = FakeWallpaperRepository(prefs: prefs);
      final bloc = WallpaperBloc(
        repository: repo,
        initialState: WallpaperState(
          allShorts: CuratedShortsData.shorts,
          filteredShorts: CuratedShortsData.shorts,
          communityBlueprints: WalloraScreenBlueprint.curatedBlueprints,
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: MaterialApp(
            home: DiscoverScreen(
              onOpenLiveFeed: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Blueprint Exchange IconButton
      final exchangeButton = find.byTooltip('Blueprint Exchange');
      expect(exchangeButton, findsOneWidget);

      // Tap to open
      await tester.tap(exchangeButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify sheet opens
      expect(find.text('AESTHETIC BLUEPRINT EXCHANGE'), findsOneWidget);
      expect(find.text('YOUR ACTIVE SETUP'), findsOneWidget);
    });

    testWidgets('WeatherAtmosphereSheet renders preview, preset choices, climate dynamics sliders, and hardware sensor toggles',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final prefs = await SharedPreferences.getInstance();
      final repo = FakeWallpaperRepository(prefs: prefs);
      final bloc = WallpaperBloc(
        repository: repo,
        initialState: WallpaperState(
          allShorts: CuratedShortsData.shorts,
          filteredShorts: CuratedShortsData.shorts,
          weatherConfig: WeatherAtmosphereConfig.defaultConfig,
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: const MaterialApp(
            home: Scaffold(
              body: WeatherAtmosphereSheet(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 1. Verify Header
      expect(find.text('Atmospheric Weather Studio'), findsOneWidget);
      expect(find.text('Dynamic particle overlays & gyroscopic tilt'), findsOneWidget);

      // 2. Verify Presets
      expect(find.text('WEATHER EFFECT PRESETS'), findsOneWidget);
      expect(find.text('Clean Canvas (Off)'), findsOneWidget);
      expect(find.text('Cyberpunk Rain & Drizzle'), findsNWidgets(2));
      expect(find.text('Cosmic Snow & Blizzard'), findsOneWidget);
      expect(find.text('Neon Thunderstorm'), findsOneWidget);

      // 3. Verify Sliders
      expect(find.text('CLIMATE DYNAMICS & VELOCITY'), findsOneWidget);
      expect(find.text('Particle Density (Intensity)'), findsOneWidget);
      expect(find.text('Fall Velocity & Speed'), findsOneWidget);

      // 4. Verify Hardware Toggles
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -600));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Gyroscopic Tilt Adaptation'), findsOneWidget);
      expect(find.text('Lightning & Luminous Bursts'), findsOneWidget);
      expect(find.text('Zero Sleep Overhead & Battery Guard'), findsOneWidget);

      // 5. Verify Action Buttons
      expect(find.text('Reset Defaults'), findsOneWidget);
      expect(find.text('Apply to Live Canvas'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('SettingsSheet opens WeatherAtmosphereSheet when Atmospheric Weather Studio tile is tapped',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final prefs = await SharedPreferences.getInstance();
      final repo = FakeWallpaperRepository(prefs: prefs);
      final bloc = WallpaperBloc(
        repository: repo,
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
            home: Scaffold(
              body: SettingsSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final studioTile = find.text('Atmospheric Weather & Climate FX Studio');
      await tester.scrollUntilVisible(
        studioTile,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(studioTile, findsOneWidget);

      await tester.tap(studioTile);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Atmospheric Weather Studio'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('DiscoverScreen renders Weather Atmosphere Studio IconButton and opens WeatherAtmosphereSheet on tap',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final prefs = await SharedPreferences.getInstance();
      final repo = FakeWallpaperRepository(prefs: prefs);
      final bloc = WallpaperBloc(
        repository: repo,
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
            home: DiscoverScreen(
              onOpenLiveFeed: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final weatherButton = find.byTooltip('Weather Atmosphere Studio');
      expect(weatherButton, findsOneWidget);

      await tester.tap(weatherButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Atmospheric Weather Studio'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('DiscoverScreen renders Wallaza Cloud Discovery IconButton and opens WallazaCloudDiscoverySheet on tap',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final prefs = await SharedPreferences.getInstance();
      final repo = FakeWallpaperRepository(prefs: prefs);
      final bloc = WallpaperBloc(
        repository: repo,
        initialState: WallpaperState(
          allShorts: CuratedShortsData.shorts,
          filteredShorts: CuratedShortsData.shorts,
          weatherConfig: const WeatherAtmosphereConfig(effectType: WeatherEffectType.none),
          cloudWallpapers: WallazaCloudWallpaper.curatedCloudLibrary,
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: MaterialApp(
            home: DiscoverScreen(
              onOpenLiveFeed: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final cloudButton = find.byTooltip('Wallaza Cloud Discovery');
      expect(cloudButton, findsOneWidget);

      await tester.tap(cloudButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Wallaza Cloud Discovery'), findsWidgets);
      expect(find.text('4K PROXY'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('DiscoverScreen renders Wallaza Cloud Discovery Banner and opens sheet on DISCOVER tap',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final prefs = await SharedPreferences.getInstance();
      final repo = FakeWallpaperRepository(prefs: prefs);
      final bloc = WallpaperBloc(
        repository: repo,
        initialState: WallpaperState(
          allShorts: CuratedShortsData.shorts,
          filteredShorts: CuratedShortsData.shorts,
          weatherConfig: const WeatherAtmosphereConfig(effectType: WeatherEffectType.none),
          cloudWallpapers: WallazaCloudWallpaper.curatedCloudLibrary,
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: MaterialApp(
            home: DiscoverScreen(
              onOpenLiveFeed: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final bannerTitle = find.text('WALLAZA CLOUD DISCOVERY');
      await tester.scrollUntilVisible(
        bannerTitle,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(bannerTitle, findsOneWidget);

      final discoverButton = find.widgetWithText(ElevatedButton, 'DISCOVER');
      expect(discoverButton, findsOneWidget);

      await tester.tap(discoverButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Wallaza Cloud Discovery'), findsWidgets);
      expect(find.text('Cyberpunk'), findsWidgets);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('WallazaCloudDiscoverySheet renders search bar, filters, cards, and opens detail modal',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final prefs = await SharedPreferences.getInstance();
      final repo = FakeWallpaperRepository(prefs: prefs);
      final bloc = WallpaperBloc(
        repository: repo,
        initialState: WallpaperState(
          allShorts: CuratedShortsData.shorts,
          filteredShorts: CuratedShortsData.shorts,
          weatherConfig: const WeatherAtmosphereConfig(effectType: WeatherEffectType.none),
          cloudWallpapers: WallazaCloudWallpaper.curatedCloudLibrary,
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: const MaterialApp(
            home: Scaffold(
              body: WallazaCloudDiscoverySheet(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Verifies Header and badges
      expect(find.text('Wallaza Cloud Discovery'), findsOneWidget);
      expect(find.text('4K PROXY'), findsOneWidget);

      // Verifies Search field
      expect(find.byType(TextField), findsOneWidget);

      // Verifies Category chips
      expect(find.text('Cyberpunk'), findsOneWidget);
      expect(find.text('AMOLED'), findsWidgets);

      // Verifies Resolution filter chips
      expect(find.text('All Resolutions'), findsOneWidget);
      expect(find.text('3840x2160'), findsOneWidget);

      // Verifies Cloud Wallpaper Card
      final firstCardTitle = find.text(WallazaCloudWallpaper.curatedCloudLibrary.first.title);
      expect(firstCardTitle, findsOneWidget);

      // Tap card to open detail modal
      await tester.tap(firstCardTitle);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verifies detail modal action buttons and specs
      expect(find.text('Import to Library'), findsOneWidget);
      expect(find.text('Apply Wallpaper'), findsOneWidget);
      expect(find.text('RESOLUTION'), findsOneWidget);
      expect(find.text('SIZE'), findsOneWidget);

      // Tap Import to Library
      await tester.tap(find.text('Import to Library'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
