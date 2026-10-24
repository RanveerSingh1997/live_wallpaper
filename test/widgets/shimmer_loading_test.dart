import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/widgets/shimmer_loading.dart';

void main() {
  group('ShimmerLoading Widget Tests', () {
    testWidgets('renders child wrapped in ShaderMask when isLoading is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerLoading(
              isLoading: true,
              child: Text('Loading Content'),
            ),
          ),
        ),
      );

      expect(find.byType(ShaderMask), findsOneWidget);
      expect(find.text('Loading Content'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 200));
    });

    testWidgets('renders child directly without ShaderMask when isLoading is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerLoading(
              isLoading: false,
              child: Text('Loaded Content'),
            ),
          ),
        ),
      );

      expect(find.byType(ShaderMask), findsNothing);
      expect(find.text('Loaded Content'), findsOneWidget);
    });

    testWidgets('ShimmerSkeletonBox applies custom dimensions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerSkeletonBox(
              width: 140,
              height: 220,
              borderRadius: 20,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.borderRadius, BorderRadius.circular(20));
      final size = tester.getSize(find.byType(ShimmerSkeletonBox));
      expect(size.width, 140);
      expect(size.height, 220);
    });

    testWidgets('ShimmerDiscoverSkeleton builds complete skeleton structure', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerDiscoverSkeleton(),
          ),
        ),
      );

      expect(find.byType(ShimmerDiscoverSkeleton), findsOneWidget);
      expect(find.byType(ShimmerSkeletonBox), findsWidgets);

      await tester.pump(const Duration(milliseconds: 200));
    });
  });
}
