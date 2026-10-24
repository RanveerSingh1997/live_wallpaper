import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/core/core.dart';
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
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  Widget wrapInFrame(Widget child) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: Center(
          child: SizedBox(
            width: 360,
            height: 640,
            child: RepaintBoundary(
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  group('Canvas Golden Snapshot Tests', () {
    testWidgets('AuroraSynthesizerCanvas renders procedural aurora wave',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapInFrame(
          const AuroraSynthesizerCanvas(
            config: AuroraSynthesizerConfig(
              waveCount: 4,
              waveSpeed: 1.0,
              crestAmplitude: 1.2,
              frequency: 1.5,
              isEnabled: true,
            ),
            auraConfig: AuraPaletteConfig.defaultConfig,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      await expectLater(
        find.byType(AuroraSynthesizerCanvas),
        matchesGoldenFile('goldens/aurora_synthesizer_canvas.png'),
      );
    });

    testWidgets('InteractiveParticleOverlay renders cosmic stardust particles',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapInFrame(
          const InteractiveParticleOverlay(
            config: ParticleEffectConfig(
              preset: ParticlePreset.neonStardust,
              particleCount: 50,
              speedMultiplier: 1.2,
              glowIntensity: 0.8,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      await expectLater(
        find.byType(InteractiveParticleOverlay),
        matchesGoldenFile('goldens/particle_overlay_cosmic_dust.png'),
      );
    });

    testWidgets('WeatherAtmosphereCanvas renders rainy climate atmosphere',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapInFrame(
          const WeatherAtmosphereCanvas(
            config: WeatherAtmosphereConfig(
              effectType: WeatherEffectType.cyberRain,
              intensity: 0.8,
              speedMultiplier: 1.5,
              windAngleDegrees: 70.0,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      await expectLater(
        find.byType(WeatherAtmosphereCanvas),
        matchesGoldenFile('goldens/weather_atmosphere_rain.png'),
      );
    });

    testWidgets('InteractiveGestureCanvas renders touch playground',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapInFrame(
          const InteractiveGestureCanvas(
            config: GestureControlConfig(
              isGesturesEnabled: true,
              touchVisualEffect: TouchVisualEffect.neonRipple,
            ),
            auraConfig: AuraPaletteConfig.defaultConfig,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      await expectLater(
        find.byType(InteractiveGestureCanvas),
        matchesGoldenFile('goldens/gesture_canvas_shockwave.png'),
      );
    });
  });
}
