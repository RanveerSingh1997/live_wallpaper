import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/weather_atmosphere_config.dart';

/// Interactive canvas rendering real-time atmospheric weather and climate FX
/// (rain, snow, lightning flashes, sunbeams, mist, and meteor starfall).
class WeatherAtmosphereCanvas extends StatefulWidget {
  final WeatherAtmosphereConfig config;
  final Widget? child;

  const WeatherAtmosphereCanvas({
    super.key,
    required this.config,
    this.child,
  });

  @override
  State<WeatherAtmosphereCanvas> createState() =>
      _WeatherAtmosphereCanvasState();
}

class _WeatherAtmosphereCanvasState extends State<WeatherAtmosphereCanvas>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final math.Random _random = math.Random(42);
  late List<_AtmosphericParticle> _particles;
  double _lightningAlpha = 0.0;
  int _nextLightningFrame = 120;
  int _frameCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    _initParticles();

    if (widget.config.isEnabled) {
      _controller.repeat();
    }

    _controller.addListener(_updatePhysics);
  }

  @override
  void didUpdateWidget(WeatherAtmosphereCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.effectType != widget.config.effectType ||
        oldWidget.config.intensity != widget.config.intensity) {
      _initParticles();
    }

    if (widget.config.isEnabled) {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    } else {
      if (_controller.isAnimating) {
        _controller.stop();
      }
    }
  }

  void _initParticles() {
    final count = (60 * widget.config.intensity).clamp(15, 120).toInt();
    _particles = List.generate(count, (_) => _generateParticle());
  }

  _AtmosphericParticle _generateParticle() {
    return _AtmosphericParticle(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      size: _random.nextDouble() * 3.0 + 1.5,
      speed: _random.nextDouble() * 0.6 + 0.4,
      length: _random.nextDouble() * 18.0 + 8.0,
      alpha: _random.nextDouble() * 0.6 + 0.3,
      driftPhase: _random.nextDouble() * 2 * math.pi,
    );
  }

  void _updatePhysics() {
    if (!mounted || !widget.config.isEnabled) return;
    _frameCount++;

    // Thunderstorm lightning logic
    if (widget.config.effectType == WeatherEffectType.thunderstorm &&
        widget.config.isLightningEnabled) {
      if (_frameCount >= _nextLightningFrame) {
        _lightningAlpha = 0.65;
        _frameCount = 0;
        _nextLightningFrame = _random.nextInt(180) + 90;
      } else if (_lightningAlpha > 0.0) {
        _lightningAlpha = math.max(0.0, _lightningAlpha - 0.05);
      }
    } else {
      _lightningAlpha = 0.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.config.isEnabled) {
      return widget.child ?? const SizedBox.shrink();
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            foregroundPainter: _AtmospherePainter(
              config: widget.config,
              animationValue: _controller.value,
              particles: _particles,
              lightningAlpha: _lightningAlpha,
            ),
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

class _AtmosphericParticle {
  double x;
  double y;
  final double size;
  final double speed;
  final double length;
  final double alpha;
  final double driftPhase;

  _AtmosphericParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.length,
    required this.alpha,
    required this.driftPhase,
  });
}

class _AtmospherePainter extends CustomPainter {
  final WeatherAtmosphereConfig config;
  final double animationValue;
  final List<_AtmosphericParticle> particles;
  final double lightningAlpha;

  _AtmospherePainter({
    required this.config,
    required this.animationValue,
    required this.particles,
    required this.lightningAlpha,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    switch (config.effectType) {
      case WeatherEffectType.none:
        break;

      case WeatherEffectType.cyberRain:
        _paintRain(canvas, size, const Color(0xFF00E5FF));
        break;

      case WeatherEffectType.cosmicSnow:
        _paintSnow(canvas, size);
        break;

      case WeatherEffectType.thunderstorm:
        _paintRain(canvas, size, const Color(0xFF80D8FF));
        if (lightningAlpha > 0.0) {
          _paintLightningFlash(canvas, size);
        }
        break;

      case WeatherEffectType.solarSunbeams:
        _paintSunbeams(canvas, size);
        break;

      case WeatherEffectType.etherealMist:
        _paintMist(canvas, size);
        break;

      case WeatherEffectType.meteorShower:
        _paintMeteors(canvas, size);
        break;
    }
  }

  void _paintRain(Canvas canvas, Size size, Color baseColor) {
    final radians = (config.windAngleDegrees - 90.0) * math.pi / 180.0;
    final dx = math.cos(radians);
    final dy = math.sin(radians).abs();

    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final p in particles) {
      final curY = ((p.y + animationValue * p.speed * config.speedMultiplier * 2.5) % 1.0) *
          size.height;
      final curX = ((p.x + animationValue * dx * 0.5) % 1.0) * size.width;

      paint
        ..color = baseColor.withValues(alpha: p.alpha * config.intensity)
        ..strokeWidth = p.size * 0.8;

      canvas.drawLine(
        Offset(curX, curY),
        Offset(curX + dx * p.length, curY + dy * p.length),
        paint,
      );
    }
  }

  void _paintSnow(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      final progress = (p.y + animationValue * p.speed * config.speedMultiplier * 0.8) % 1.0;
      final curY = progress * size.height;
      final drift = math.sin(progress * 4 * math.pi + p.driftPhase) * 16.0;
      final curX = ((p.x * size.width) + drift) % size.width;

      paint.color = Colors.white.withValues(alpha: p.alpha * config.intensity);
      canvas.drawCircle(Offset(curX, curY), p.size, paint);
    }
  }

  void _paintLightningFlash(Canvas canvas, Size size) {
    final flashPaint = Paint()
      ..color = const Color(0xFFD500F9).withValues(alpha: lightningAlpha * 0.35);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), flashPaint);

    final whiteFlash = Paint()
      ..color = Colors.white.withValues(alpha: lightningAlpha * 0.25);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), whiteFlash);
  }

  void _paintSunbeams(Canvas canvas, Size size) {
    final beamCount = 4;
    final baseAngle = config.windAngleDegrees * math.pi / 180.0;

    for (int i = 0; i < beamCount; i++) {
      final offset = (animationValue + i * 0.25) % 1.0;
      final startX = size.width * (0.1 + i * 0.25 + math.sin(offset * 2 * math.pi) * 0.05);

      final path = Path()
        ..moveTo(startX, 0)
        ..lineTo(startX + 80, 0)
        ..lineTo(startX + math.cos(baseAngle) * size.height + 140, size.height)
        ..lineTo(startX + math.cos(baseAngle) * size.height - 40, size.height)
        ..close();

      final paint = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFFFFD600).withValues(alpha: 0.25 * config.intensity),
            const Color(0xFFFF9100).withValues(alpha: 0.12 * config.intensity),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawPath(path, paint);
    }
  }

  void _paintMist(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final layers = 3;

    for (int i = 0; i < layers; i++) {
      final layerProgress = (animationValue * (0.2 + i * 0.1) + i * 0.33) % 1.0;
      final path = Path();
      final baseHeight = size.height * (0.65 + i * 0.1);

      path.moveTo(0, size.height);
      path.lineTo(0, baseHeight);

      for (double x = 0; x <= size.width; x += 30) {
        final y = baseHeight +
            math.sin((x / size.width * 2 * math.pi) + (layerProgress * 2 * math.pi)) * 20.0;
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.close();

      paint.shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF00E676).withValues(alpha: 0.12 * config.intensity),
          const Color(0xFF00E5FF).withValues(alpha: 0.18 * config.intensity),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, baseHeight - 40, size.width, size.height - baseHeight + 40));

      canvas.drawPath(path, paint);
    }
  }

  void _paintMeteors(Canvas canvas, Size size) {
    final meteorCount = (3 * config.intensity).ceil();
    final paint = Paint()..strokeCap = StrokeCap.round;

    for (int i = 0; i < meteorCount; i++) {
      final progress = (animationValue * config.speedMultiplier * 2.0 + (i * 0.33)) % 1.0;
      if (progress < 0.6) {
        final startX = size.width * (0.2 + i * 0.35);
        final curX = startX + progress * size.width * 0.6;
        final curY = progress * size.height * 0.7;

        paint
          ..shader = LinearGradient(
            colors: [
              Colors.transparent,
              const Color(0xFFFF5722).withValues(alpha: 0.8),
              Colors.white,
            ],
          ).createShader(Rect.fromPoints(
            Offset(curX - 45, curY - 35),
            Offset(curX, curY),
          ))
          ..strokeWidth = 2.5;

        canvas.drawLine(
          Offset(curX - 45, curY - 35),
          Offset(curX, curY),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AtmospherePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.config != config ||
        oldDelegate.lightningAlpha != lightningAlpha;
  }
}
