import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/widgets/fluid_pressable.dart';

void main() {
  group('FluidPressable Widget Tests', () {
    testWidgets('renders child widget correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FluidPressable(
              onTap: () {},
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      expect(find.text('Tap Me'), findsOneWidget);
    });

    testWidgets('triggers onTap callback when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FluidPressable(
              onTap: () => tapped = true,
              child: const Text('Tap Action'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Action'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('triggers onLongPress callback when held', (tester) async {
      bool longPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FluidPressable(
              onLongPress: () => longPressed = true,
              child: const Text('Long Press Action'),
            ),
          ),
        ),
      );

      await tester.longPress(find.text('Long Press Action'));
      await tester.pumpAndSettle();

      expect(longPressed, isTrue);
    });

    testWidgets('animates scale transform on tap down and tap up', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: FluidPressable(
                onTap: () {},
                scaleFactor: 0.9,
                child: Container(
                  key: const Key('target_box'),
                  width: 100,
                  height: 100,
                  color: Colors.blue,
                  child: const Text('Target'),
                ),
              ),
            ),
          ),
        ),
      );

      final scaleFinder = find.descendant(
        of: find.byType(FluidPressable),
        matching: find.byType(ScaleTransition),
      );
      ScaleTransition scaleTransition = tester.widget(scaleFinder);
      expect(scaleTransition.scale.value, 1.0);

      // Gesture tap down
      final gesture = await tester.startGesture(tester.getCenter(find.byKey(const Key('target_box'))));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      scaleTransition = tester.widget(scaleFinder);
      expect(scaleTransition.scale.value, lessThan(1.0));

      // Gesture tap up
      await gesture.up();
      await tester.pumpAndSettle();

      scaleTransition = tester.widget(scaleFinder);
      expect(scaleTransition.scale.value, 1.0);
    });
  });
}
