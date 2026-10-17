import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/data/curated_shorts_data.dart';
import 'package:live_wallpaper/widgets/kinetic_quote_overlay.dart';
import 'package:live_wallpaper/widgets/shorts_action_rail.dart';

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
  });
}
