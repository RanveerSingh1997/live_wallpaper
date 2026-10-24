import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/core.dart';
import '../models/aura_palette_config.dart';
import '../models/aurora_synthesizer_config.dart';

/// Interactive, zero-sleep-overhead procedural canvas that synthesizes real-time
/// multi-harmonic fluid aurora waves, cosmic ribbons, and celestial northern lights.
class AuroraSynthesizerCanvas extends StatefulWidget {
  final AuroraSynthesizerConfig config;
  final AuraPaletteConfig auraConfig;
  final Widget? child;
  final bool interactive;

  const AuroraSynthesizerCanvas({
    super.key,
    required this.config,
    required this.auraConfig,
    this.child,
    this.interactive = true,
  });

  @override
  State<AuroraSynthesizerCanvas> createState() =>
      _AuroraSynthesizerCanvasState();
}

class _AuroraSynthesizerCanvasState extends State<AuroraSynthesizerCanvas>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Offset? _touchPoint;
  double _touchIntensity = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
    if (widget.config.isEnabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant AuroraSynthesizerCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.config.isEnabled != oldWidget.config.isEnabled) {
      if (widget.config.isEnabled) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    if (!widget.config.isTouchReactive || !widget.interactive) return;
    setState(() {
      _touchPoint = Offset(
        details.localPosition.dx / constraints.maxWidth,
        details.localPosition.dy / constraints.maxHeight,
      );
      _touchIntensity = 1.0;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _touchIntensity = 0.0;
    });
  }

  List<Color> _resolvePalette() {
    switch (widget.config.colorMode) {
      case AuroraColorMode.auraSync:
        final resolved = widget.auraConfig.resolvePalette(null);
        return [
          resolved.dominant,
          resolved.vibrantNeon,
          resolved.harmonicSecondary,
          resolved.etherealGlow,
        ];
      case AuroraColorMode.cyanViolet:
        return const [
          AppColors.neonCyan,
          AppColors.auroraViolet,
          AppColors.deepPurple,
          AppColors.electricBlue,
        ];
      case AuroraColorMode.amberEmerald:
        return const [
          AppColors.sunsetAmber,
          AppColors.auroraEmerald,
          AppColors.solarGold,
          AppColors.cyberTeal,
        ];
      case AuroraColorMode.pureOledRed:
        return const [
          AppColors.nightCrimson,
          AppColors.sunsetAmber,
          AppColors.crimsonAccent,
          AppColors.favoriteRed,
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = _resolvePalette();

    return LayoutBuilder(
      builder: (context, constraints) {
        Widget content = AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _AuroraWavePainter(
                time: _controller.value * 2 * math.pi,
                config: widget.config,
                palette: palette,
                touchPoint: _touchPoint,
                touchIntensity: _touchIntensity,
              ),
              child: child,
            );
          },
          child: widget.child,
        );

        if (widget.interactive && widget.config.isTouchReactive) {
          content = GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanUpdate: (d) => _onPanUpdate(d, constraints),
            onPanEnd: _onPanEnd,
            child: content,
          );
        }

        return Semantics(
          label: 'Interactive Aurora Wave Synthesizer Visualizer',
          hint: widget.config.isEnabled
              ? 'Real-time procedural aurora waves active'
              : 'Aurora waves disabled',
          child: content,
        );
      },
    );
  }
}

class _AuroraWavePainter extends CustomPainter {
  final double time;
  final AuroraSynthesizerConfig config;
  final List<Color> palette;
  final Offset? touchPoint;
  final double touchIntensity;

  _AuroraWavePainter({
    required this.time,
    required this.config,
    required this.palette,
    required this.touchPoint,
    required this.touchIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = AppColors.obsidianBlack;
    canvas.drawRect(Offset.zero & size, bgPaint);

    if (!config.isEnabled || config.waveCount <= 0) return;

    final waveCount = config.waveCount.clamp(1, 6);

    for (int w = 0; w < waveCount; w++) {
      final speedFactor = config.waveSpeed * (0.8 + (w * 0.25));
      final waveTime = time * speedFactor + (w * 1.5);
      final waveColor = palette[w % palette.length];

      switch (config.waveStyle) {
        case AuroraWaveStyle.cosmicNorthernLights:
          _drawCurtainWave(
            canvas,
            size,
            w,
            waveCount,
            waveTime,
            waveColor,
          );
          break;

        case AuroraWaveStyle.cyberpunkRibbon:
          _drawCyberpunkRibbon(
            canvas,
            size,
            w,
            waveCount,
            waveTime,
            waveColor,
          );
          break;

        case AuroraWaveStyle.solarFlarePlasma:
          _drawSolarPlasma(
            canvas,
            size,
            w,
            waveCount,
            waveTime,
            waveColor,
          );
          break;

        case AuroraWaveStyle.bioluminescentDeepSea:
          _drawBioluminescentWave(
            canvas,
            size,
            w,
            waveCount,
            waveTime,
            waveColor,
          );
          break;

        case AuroraWaveStyle.monochromeOled:
          _drawMonochromeRidge(
            canvas,
            size,
            w,
            waveCount,
            waveTime,
          );
          break;
      }
    }
  }

  void _drawCurtainWave(
    Canvas canvas,
    Size size,
    int index,
    int total,
    double t,
    Color color,
  ) {
    final path = Path();
    final baseY = size.height * (0.35 + (index * 0.12));
    final amp = size.height * 0.12 * config.crestAmplitude;
    final freq = (config.frequency * 2 * math.pi) / size.width;

    path.moveTo(0, size.height);
    path.lineTo(0, baseY);

    const step = 8.0;
    for (double x = 0; x <= size.width + step; x += step) {
      double touchOffset = 0.0;
      if (touchPoint != null && touchIntensity > 0) {
        final tx = touchPoint!.dx * size.width;
        final ty = touchPoint!.dy * size.height;
        final dist = (x - tx).abs();
        if (dist < 120) {
          final factor = (1.0 - (dist / 120)) * touchIntensity;
          touchOffset = (ty - baseY) * factor * 0.4;
        }
      }

      final y = baseY +
          math.sin(x * freq + t) * amp +
          math.cos(x * freq * 0.5 - t * 0.6) * (amp * 0.5) +
          touchOffset;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.55 / (index + 1)),
          color.withValues(alpha: 0.15),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, config.blurSpread);

    canvas.drawPath(path, paint);
  }

  void _drawCyberpunkRibbon(
    Canvas canvas,
    Size size,
    int index,
    int total,
    double t,
    Color color,
  ) {
    final path = Path();
    final baseY = size.height * (0.45 + (index * 0.10));
    final amp = size.height * 0.10 * config.crestAmplitude;
    final freq = (config.frequency * 3 * math.pi) / size.width;

    const step = 6.0;
    bool first = true;
    for (double x = 0; x <= size.width + step; x += step) {
      final y = baseY +
          math.sin(x * freq + t) * amp +
          math.sin(x * freq * 2.2 + t * 1.4) * (amp * 0.35);

      if (first) {
        path.moveTo(x, y);
        first = false;
      } else {
        path.lineTo(x, y);
      }
    }

    // Glow line
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, config.blurSpread * 0.6);
    canvas.drawPath(path, glowPaint);

    // Sharp laser core
    final corePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(path, corePaint);
  }

  void _drawSolarPlasma(
    Canvas canvas,
    Size size,
    int index,
    int total,
    double t,
    Color color,
  ) {
    final path = Path();
    final baseY = size.height * (0.50 + (index * 0.08));
    final amp = size.height * 0.15 * config.crestAmplitude;
    final freq = (config.frequency * 1.8 * math.pi) / size.width;

    path.moveTo(0, size.height);
    path.lineTo(0, baseY);

    const step = 10.0;
    for (double x = 0; x <= size.width + step; x += step) {
      final y = baseY +
          math.cos(x * freq + t) * amp +
          math.sin(x * freq * 0.8 - t * 0.5) * (amp * 0.6);
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.close();

    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment(0.0, -0.2 + (index * 0.2)),
        radius: 1.1,
        colors: [
          color.withValues(alpha: 0.45),
          AppColors.sunsetAmber.withValues(alpha: 0.20),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, config.blurSpread);

    canvas.drawPath(path, paint);
  }

  void _drawBioluminescentWave(
    Canvas canvas,
    Size size,
    int index,
    int total,
    double t,
    Color color,
  ) {
    final path = Path();
    final baseY = size.height * (0.40 + (index * 0.12));
    final amp = size.height * 0.08 * config.crestAmplitude;
    final freq = (config.frequency * 2.2 * math.pi) / size.width;

    path.moveTo(0, size.height);
    path.lineTo(0, baseY);

    const step = 10.0;
    for (double x = 0; x <= size.width + step; x += step) {
      final y = baseY + math.sin(x * freq + t) * amp;
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.close();

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.40),
          AppColors.neonCyan.withValues(alpha: 0.10),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, config.blurSpread * 0.8);

    canvas.drawPath(path, paint);
  }

  void _drawMonochromeRidge(
    Canvas canvas,
    Size size,
    int index,
    int total,
    double t,
  ) {
    final path = Path();
    final baseY = size.height * (0.45 + (index * 0.10));
    final amp = size.height * 0.09 * config.crestAmplitude;
    final freq = (config.frequency * 2.5 * math.pi) / size.width;

    const step = 8.0;
    bool first = true;
    for (double x = 0; x <= size.width + step; x += step) {
      final y = baseY +
          math.sin(x * freq + t) * amp +
          math.cos(x * freq * 1.5 - t * 0.8) * (amp * 0.4);

      if (first) {
        path.moveTo(x, y);
        first = false;
      } else {
        path.lineTo(x, y);
      }
    }

    final alpha = (0.6 - (index * 0.1)).clamp(0.15, 0.8);
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = (2.5 - (index * 0.3)).clamp(1.0, 3.0)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, config.blurSpread * 0.3);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _AuroraWavePainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.config != config ||
        oldDelegate.palette != palette ||
        oldDelegate.touchPoint != touchPoint ||
        oldDelegate.touchIntensity != touchIntensity;
  }
}
