import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/models/aura_palette_config.dart';
import 'package:live_wallpaper/models/aurora_synthesizer_config.dart';
import 'package:live_wallpaper/models/gesture_control_config.dart';
import 'package:live_wallpaper/models/particle_effect_config.dart';
import 'package:live_wallpaper/models/weather_atmosphere_config.dart';
import 'package:live_wallpaper/widgets/aurora_synthesizer_canvas.dart';
import 'package:live_wallpaper/widgets/interactive_gesture_canvas.dart';
import 'package:live_wallpaper/widgets/interactive_particle_overlay.dart';
import 'package:live_wallpaper/widgets/weather_atmosphere_canvas.dart';

void main() {
  group('Wallora Canvas Rendering Performance Benchmarks', () {
    const frameBudgetMicros = 16666; // 16.66ms for 60 FPS budget

    testWidgets('AuroraSynthesizerCanvas renders 120 animation frames within 60 FPS budget',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const config = AuroraSynthesizerConfig(
        waveCount: 4,
        waveSpeed: 1.0,
        crestAmplitude: 1.2,
        frequency: 1.5,
        isEnabled: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AuroraSynthesizerCanvas(
              config: config,
              auraConfig: AuraPaletteConfig.defaultConfig,
            ),
          ),
        ),
      );

      final stopwatch = Stopwatch()..start();
      const frameCount = 120; // 2 seconds of 60 FPS frames

      for (int i = 0; i < frameCount; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      stopwatch.stop();
      final avgFrameTimeMicros = stopwatch.elapsedMicroseconds ~/ frameCount;

      // Ensure average frame calculation takes less than the budget
      expect(avgFrameTimeMicros, lessThan(frameBudgetMicros));
    });

    testWidgets('InteractiveParticleOverlay sustains 100 particles within frame budget',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const particleConfig = ParticleEffectConfig(
        preset: ParticlePreset.neonStardust,
        particleCount: 100,
        speedMultiplier: 1.5,
        glowIntensity: 0.9,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InteractiveParticleOverlay(
              config: particleConfig,
            ),
          ),
        ),
      );

      final stopwatch = Stopwatch()..start();
      const frameCount = 120;

      for (int i = 0; i < frameCount; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      stopwatch.stop();
      final avgFrameTimeMicros = stopwatch.elapsedMicroseconds ~/ frameCount;

      expect(avgFrameTimeMicros, lessThan(frameBudgetMicros));
    });

    testWidgets('WeatherAtmosphereCanvas renders precipitation storm within frame budget',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const weatherConfig = WeatherAtmosphereConfig(
        effectType: WeatherEffectType.cyberRain,
        intensity: 1.0,
        speedMultiplier: 2.0,
        windAngleDegrees: 75.0,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeatherAtmosphereCanvas(
              config: weatherConfig,
            ),
          ),
        ),
      );

      final stopwatch = Stopwatch()..start();
      const frameCount = 120;

      for (int i = 0; i < frameCount; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      stopwatch.stop();
      final avgFrameTimeMicros = stopwatch.elapsedMicroseconds ~/ frameCount;

      expect(avgFrameTimeMicros, lessThan(frameBudgetMicros));
    });

    testWidgets('InteractiveGestureCanvas processes continuous ripples without frame drops',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const gestureConfig = GestureControlConfig(
        isGesturesEnabled: true,
        touchVisualEffect: TouchVisualEffect.neonRipple,
        rippleDurationMs: 450,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InteractiveGestureCanvas(
              config: gestureConfig,
              auraConfig: AuraPaletteConfig.defaultConfig,
            ),
          ),
        ),
      );

      final gestureFinder = find.byType(InteractiveGestureCanvas);
      expect(gestureFinder, findsOneWidget);

      final stopwatch = Stopwatch()..start();
      const frameCount = 60;

      for (int i = 0; i < frameCount; i++) {
        if (i % 10 == 0) {
          await tester.tap(gestureFinder);
        }
        await tester.pump(const Duration(milliseconds: 16));
      }

      stopwatch.stop();
      final avgFrameTimeMicros = stopwatch.elapsedMicroseconds ~/ frameCount;

      expect(avgFrameTimeMicros, lessThan(frameBudgetMicros));
    });
  });
}
