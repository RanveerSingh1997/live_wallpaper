import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:live_wallpaper/blocs/wallpaper_bloc.dart';
import 'package:live_wallpaper/blocs/wallpaper_state.dart';
import 'package:live_wallpaper/core/core.dart';
import 'package:live_wallpaper/data/curated_shorts_data.dart';
import 'package:live_wallpaper/models/motivational_short.dart';
import 'package:live_wallpaper/repositories/wallpaper_repository.dart';
import 'package:live_wallpaper/screens/categories_screen.dart';
import 'package:live_wallpaper/screens/main_navigation_shell.dart';
import 'package:live_wallpaper/widgets/fluid_pressable.dart';
import 'package:live_wallpaper/widgets/kinetic_quote_overlay.dart';
import 'package:live_wallpaper/widgets/shorts_action_rail.dart';

class MockWallpaperRepository extends WallpaperRepository {
  MockWallpaperRepository({required super.prefs});
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  final testShort = MotivationalShort(
    id: 'test_a11y_1',
    title: 'Hajime no Ippo: Creed',
    quote: 'Everyone who succeeds has worked hard.',
    author: 'Coach Kamogawa',
    videoAssetPath: 'assets/sample.mp4',
    category: 'Anime & Gaming',
    accentColor: AppColors.sunsetAmber,
    tags: 'anime, boxing, creed',
    trueBlackPercentage: 72,
    fileSizeBytes: 12000000,
  );

  group('Accessibility & Semantics Test Suite (Apple HIG & Google Play Guidelines)', () {
    testWidgets('FluidPressable renders accessible button semantics when label is provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FluidPressable(
              semanticsLabel: 'Tap to customize theme',
              onTap: () {},
              child: const Text('Customize'),
            ),
          ),
        ),
      );

      final semanticsFinder = find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.label == 'Tap to customize theme',
      );
      expect(semanticsFinder, findsOneWidget);

      final semantics = tester.widget<Semantics>(semanticsFinder);
      expect(semantics.properties.button, isTrue);
    });

    testWidgets('KineticQuoteOverlay exposes header semantics with quote and author',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KineticQuoteOverlay(
              short: testShort,
              effectiveQuote: testShort.quote,
              isCustomized: false,
            ),
          ),
        ),
      );

      final headerFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.header == true &&
            widget.properties.label?.contains('Coach Kamogawa') == true,
      );
      expect(headerFinder, findsOneWidget);
    });

    testWidgets('ShortsActionRail exposes accessible action buttons with stateful labels',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShortsActionRail(
              short: testShort,
              isFavorite: true,
              isMuted: false,
              isCurrentActive: false,
              isApplying: false,
              onApplyWallpaper: () {},
              onCustomizeQuote: () {},
              onToggleMute: () {},
              onToggleFavorite: () {},
              onShare: () {},
            ),
          ),
        ),
      );

      // Verify Apply Wallpaper semantic action
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.button == true &&
              widget.properties.label?.contains('Apply') == true,
        ),
        findsOneWidget,
      );

      // Verify Favorite semantic action
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.button == true &&
              widget.properties.label?.contains('favorites') == true,
        ),
        findsOneWidget,
      );

      // Verify Mute semantic action
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.button == true &&
              widget.properties.label?.contains('audio') == true,
        ),
        findsOneWidget,
      );
    });

    testWidgets('CategoriesScreen exposes selected tab semantics for genres and playlists',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repository = MockWallpaperRepository(prefs: prefs);
      final bloc = WallpaperBloc(
        repository: repository,
        initialState: WallpaperState(
          allShorts: CuratedShortsData.shorts,
          filteredShorts: CuratedShortsData.shorts,
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider<WallpaperBloc>.value(
          value: bloc,
          child: const MaterialApp(
            home: CategoriesScreen(),
          ),
        ),
      );
      await tester.pump();

      // Genres tab should be selected
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.button == true &&
              widget.properties.selected == true &&
              widget.properties.label?.contains('Genres tab') == true,
        ),
        findsOneWidget,
      );
    });

    testWidgets('MainNavigationShell exposes accessible tooltips on all bottom navigation items',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'has_seen_onboarding': true});
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
          child: const MaterialApp(
            home: MainNavigationShell(),
          ),
        ),
      );
      await tester.pump();

      final bottomNav = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNav.items[0].tooltip, equals('Discover Curated Wallpapers'));
      expect(bottomNav.items[1].tooltip, equals('Browse Wallpaper Categories & Playlists'));
      expect(bottomNav.items[2].tooltip?.contains('Favorite Wallpapers'), isTrue);
      expect(bottomNav.items[3].tooltip?.contains('Downloaded Wallpapers'), isTrue);
    });
  });
}
