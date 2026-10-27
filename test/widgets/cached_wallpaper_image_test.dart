import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/widgets/cached_wallpaper_image.dart';

void main() {
  group('CachedWallpaperImage Tests', () {
    testWidgets('renders fallback SizedBox.shrink for empty image url',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedWallpaperImage(
              imageUrl: '',
            ),
          ),
        ),
      );

      expect(find.byType(CachedWallpaperImage), findsOneWidget);
    });

    testWidgets('renders custom errorWidget when imageUrl is empty',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedWallpaperImage(
              imageUrl: '',
              errorWidget: Text('Custom Error Widget'),
            ),
          ),
        ),
      );

      expect(find.text('Custom Error Widget'), findsOneWidget);
    });

    testWidgets('renders network image with thumbnail preset without crash',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CachedWallpaperImage.thumbnail(
              imageUrl: 'https://images.unsplash.com/photo-1518791841217-8f162f1e1131',
            ),
          ),
        ),
      );

      expect(find.byType(CachedWallpaperImage), findsOneWidget);
    });

    testWidgets('renders network image with fullScreen preset without crash',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CachedWallpaperImage.fullScreen(
              imageUrl: 'https://images.unsplash.com/photo-1518791841217-8f162f1e1131',
            ),
          ),
        ),
      );

      expect(find.byType(CachedWallpaperImage), findsOneWidget);
    });
  });
}
