import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/core/core.dart';
import 'package:live_wallpaper/models/motivational_short.dart';
import 'package:live_wallpaper/widgets/kinetic_quote_overlay.dart';
import 'package:live_wallpaper/widgets/shorts_action_rail.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  final testShort = MotivationalShort(
    id: 'test_golden_1',
    title: 'Cyberpunk Neon Ronin',
    quote: 'The blade that cuts through neon darkness never rusts.',
    author: 'Neo Tokyo',
    videoAssetPath: 'assets/sample.mp4',
    category: 'Cyberpunk & Tech',
    accentColor: AppColors.neonCyan,
    tags: 'cyberpunk, neon, ronin',
    trueBlackPercentage: 68,
    fileSizeBytes: 12500000,
  );

  Widget wrapInFrame(Widget child) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: Center(
          child: SizedBox(
            width: 380,
            height: 700,
            child: RepaintBoundary(
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  group('UI Widget Golden Snapshot Tests', () {
    testWidgets('KineticQuoteOverlay renders typography and badges',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapInFrame(
          KineticQuoteOverlay(
            short: testShort,
            effectiveQuote: testShort.quote,
            isCustomized: true,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(KineticQuoteOverlay),
        matchesGoldenFile('goldens/kinetic_quote_overlay.png'),
      );
    });

    testWidgets('ShortsActionRail renders interactive button stack',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapInFrame(
          ShortsActionRail(
            short: testShort,
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
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(ShortsActionRail),
        matchesGoldenFile('goldens/shorts_action_rail.png'),
      );
    });
  });
}
