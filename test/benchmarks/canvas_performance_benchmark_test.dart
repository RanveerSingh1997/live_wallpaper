import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/models/audio_spectrum_metrics.dart';
import 'package:live_wallpaper/models/audio_visualizer_config.dart';
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

    testWidgets('AuroraSynthesizerCanvas renders 120 audio-reactive frames within 60 FPS budget',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const config = AuroraSynthesizerConfig(
        waveCount: 5,
        waveSpeed: 1.5,
        crestAmplitude: 1.5,
        frequency: 2.0,
        isEnabled: true,
      );

      const visualizerConfig = AudioVisualizerConfig(
        isEnabled: true,
        reactiveIntensity: 1.5,
      );

      const metrics = AudioSpectrumMetrics(
        bass: 0.85,
        mid: 0.65,
        treble: 0.45,
        overallAmplitude: 0.75,
        peakDetected: true,
        isSilent: false,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AuroraSynthesizerCanvas(
              config: config,
              auraConfig: AuraPaletteConfig.defaultConfig,
              audioVisualizerConfig: visualizerConfig,
              audioSpectrumMetrics: metrics,
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

    testWidgets('InteractiveParticleOverlay handles audio-reactive transient bursts within frame budget',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const particleConfig = ParticleEffectConfig(
        preset: ParticlePreset.electricSparks,
        particleCount: 50,
        speedMultiplier: 1.8,
        glowIntensity: 1.0,
      );

      const visualizerConfig = AudioVisualizerConfig(
        isEnabled: true,
        reactiveIntensity: 1.6,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InteractiveParticleOverlay(
              config: particleConfig,
              audioVisualizerConfig: visualizerConfig,
              audioSpectrumMetrics: AudioSpectrumMetrics.zero,
            ),
          ),
        ),
      );

      final stopwatch = Stopwatch()..start();
      const frameCount = 60;

      for (int i = 0; i < frameCount; i++) {
        final isPeak = i % 15 == 0;
        final metrics = AudioSpectrumMetrics(
          bass: isPeak ? 0.95 : 0.2,
          mid: 0.4,
          treble: 0.3,
          overallAmplitude: isPeak ? 0.9 : 0.25,
          peakDetected: isPeak,
          isSilent: false,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InteractiveParticleOverlay(
                config: particleConfig,
                audioVisualizerConfig: visualizerConfig,
                audioSpectrumMetrics: metrics,
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 16));
      }

      stopwatch.stop();
      final avgFrameTimeMicros = stopwatch.elapsedMicroseconds ~/ frameCount;

      expect(avgFrameTimeMicros, lessThan(frameBudgetMicros));
    });
  });
}
