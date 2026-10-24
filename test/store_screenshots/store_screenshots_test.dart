import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:live_wallpaper/blocs/wallpaper_bloc.dart';
import 'package:live_wallpaper/blocs/wallpaper_state.dart';
import 'package:live_wallpaper/core/core.dart';
import 'package:live_wallpaper/data/curated_shorts_data.dart';
import 'package:live_wallpaper/models/motivational_short.dart';
import 'package:live_wallpaper/models/wallpaper_collection.dart';
import 'package:live_wallpaper/models/wallpaper_effect_config.dart';
import 'package:live_wallpaper/repositories/wallpaper_repository.dart';
import 'package:live_wallpaper/screens/categories_screen.dart';
import 'package:live_wallpaper/screens/main_navigation_shell.dart';
import 'package:live_wallpaper/screens/standby_dock_screen.dart';
import 'package:live_wallpaper/widgets/aurora_synthesizer_canvas.dart';
import 'package:live_wallpaper/widgets/kinetic_quote_overlay.dart';
import 'package:live_wallpaper/widgets/shorts_action_rail.dart';
import 'package:live_wallpaper/models/aurora_synthesizer_config.dart';
import 'package:live_wallpaper/models/aura_palette_config.dart';

class MockWallpaperRepository extends WallpaperRepository {
  MockWallpaperRepository({required super.prefs});

  @override
  Future<int> getTotalDownloadSizeBytes() async => 42000000;

  @override
  Future<bool> isWallpaperActiveOnDevice() async => true;

  @override
  Future<Map<String, dynamic>> applyAsLiveWallpaper({
    required MotivationalShort short,
    bool isMuted = true,
  }) async => {'status': 'success'};

  @override
  Future<Map<String, dynamic>> applyStaticWallpaper({
    required MotivationalShort short,
    String targetScreen = 'both',
    String? customQuote,
    WallpaperEffectConfig? effectConfig,
  }) async => {'status': 'success'};
}

Widget _buildLiveWallpaperShowcase(MotivationalShort short) {
  return Scaffold(
    backgroundColor: Colors.black,
    body: Stack(
      fit: StackFit.expand,
      children: [
        // Fluid Aurora Background Canvas
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, -0.2),
              radius: 1.2,
              colors: [
                Color(0xFF1E0E38),
                Color(0xFF0F0B1E),
                Colors.black,
              ],
            ),
          ),
          child: const AuroraSynthesizerCanvas(
            config: AuroraSynthesizerConfig(
              waveCount: 4,
              waveSpeed: 0.8,
              crestAmplitude: 1.1,
              frequency: 1.3,
              isEnabled: true,
            ),
            auraConfig: AuraPaletteConfig.defaultConfig,
          ),
        ),

        // Motivational Quote Typography Overlay
        KineticQuoteOverlay(
          short: short,
          effectiveQuote: short.quote,
          isCustomized: false,
        ),

        // Vertical Quick Action Rail
        Positioned(
          right: 12,
          bottom: 80,
          child: ShortsActionRail(
            short: short,
            isFavorite: true,
            isMuted: false,
            isCurrentActive: true,
            isApplying: false,
            onApplyWallpaper: () {},
            onCustomizeQuote: () {},
            onToggleMute: () {},
            onToggleFavorite: () {},
          ),
        ),

        // Top Header
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  onPressed: () {},
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.5)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: AppColors.neonCyan, size: 14),
                      SizedBox(width: 6),
                      Text(
                        '4K ULTRA HD',
                        style: TextStyle(
                          color: AppColors.neonCyan,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('Automated Store Screenshots Suite (Google Play & Apple App Store)', () {
    testWidgets('Capture 01: Discover & Curated Editorial Hub', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      SharedPreferences.setMockInitialValues({
        'has_seen_onboarding': true,
        'favorites': ['neon_cyberpunk', 'aurora_borealis'],
        'downloaded': ['neon_cyberpunk'],
      });
      final prefs = await SharedPreferences.getInstance();
      final repository = MockWallpaperRepository(prefs: prefs);

      final bloc = WallpaperBloc(
        repository: repository,
        initialState: WallpaperState(
          hasSeenOnboarding: true,
          allShorts: CuratedShortsData.shorts,
          filteredShorts: CuratedShortsData.shorts,
          favoriteIds: const {'neon_cyberpunk', 'aurora_borealis'},
          downloadedIds: const {'neon_cyberpunk'},
          activeWallpaperId: CuratedShortsData.shorts.first.id,
          isLiveWallpaperActiveOnDevice: true,
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider<WallpaperBloc>.value(
          value: bloc,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            home: const MainNavigationShell(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(MainNavigationShell), findsOneWidget);

      await expectLater(
        find.byType(MainNavigationShell),
        matchesGoldenFile('../../store_metadata/screenshots/phone/01_discover_hub.png'),
      );
    });

    testWidgets('Capture 02: Cinematic Vertical Live Video Feed', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final flagshipShort = CuratedShortsData.shorts.first;

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          home: _buildLiveWallpaperShowcase(flagshipShort),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(KineticQuoteOverlay), findsOneWidget);

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('../../store_metadata/screenshots/phone/02_live_feed.png'),
      );
    });

    testWidgets('Capture 03: Categories & Editorial Playlists', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      SharedPreferences.setMockInitialValues({
        'has_seen_onboarding': true,
        'favorites': ['neon_cyberpunk', 'aurora_borealis'],
        'downloaded': ['neon_cyberpunk'],
      });
      final prefs = await SharedPreferences.getInstance();
      final repository = MockWallpaperRepository(prefs: prefs);

      final testCollections = [
        const WallpaperCollection(
          id: 'cyber_collection',
          title: 'Cyberpunk & Synthwave',
          subtitle: 'Vibrant neon corridors and futuristic cityscapes.',
          wallpaperIds: ['neon_cyberpunk', 'cyber_samurai'],
          gradientColors: [AppColors.deepPurple, AppColors.neonCyan],
          icon: Icons.electric_bolt_rounded,
          badge: 'TRENDING',
          isUserCreated: false,
        ),
      ];

      final bloc = WallpaperBloc(
        repository: repository,
        initialState: WallpaperState(
          hasSeenOnboarding: true,
          allShorts: CuratedShortsData.shorts,
          filteredShorts: CuratedShortsData.shorts,
          favoriteIds: const {'neon_cyberpunk', 'aurora_borealis'},
          downloadedIds: const {'neon_cyberpunk'},
          customCollections: testCollections,
          activeWallpaperId: CuratedShortsData.shorts.first.id,
          isLiveWallpaperActiveOnDevice: true,
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider<WallpaperBloc>.value(
          value: bloc,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            home: const CategoriesScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CategoriesScreen), findsOneWidget);

      await expectLater(
        find.byType(CategoriesScreen),
        matchesGoldenFile('../../store_metadata/screenshots/phone/03_categories.png'),
      );
    });

    testWidgets('Capture 04: Standby Desk Dock & Bedside Clock', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      SharedPreferences.setMockInitialValues({
        'has_seen_onboarding': true,
      });
      final prefs = await SharedPreferences.getInstance();
      final repository = MockWallpaperRepository(prefs: prefs);

      final bloc = WallpaperBloc(
        repository: repository,
        initialState: WallpaperState(
          hasSeenOnboarding: true,
          allShorts: CuratedShortsData.shorts,
          filteredShorts: CuratedShortsData.shorts,
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider<WallpaperBloc>.value(
          value: bloc,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            home: StandbyDockScreen(
              fixedTime: DateTime(2026, 10, 24, 9, 41, 00),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(StandbyDockScreen), findsOneWidget);

      await expectLater(
        find.byType(StandbyDockScreen),
        matchesGoldenFile('../../store_metadata/screenshots/phone/04_standby_dock.png'),
      );
    });
  });
}
