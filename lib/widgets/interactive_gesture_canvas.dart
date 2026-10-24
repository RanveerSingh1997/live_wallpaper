import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/core.dart';
import '../models/aura_palette_config.dart';
import '../models/gesture_control_config.dart';

/// Interactive touch contact ripple or particle burst instance.
class _TouchContactRipple {
  final Offset position;
  final DateTime startTime;
  final Color color;
  final TouchVisualEffect effect;
  final List<_SparkParticle> sparks;

  _TouchContactRipple({
    required this.position,
    required this.startTime,
    required this.color,
    required this.effect,
    required this.sparks,
  });
}

class _SparkParticle {
  final double angle;
  final double speed;
  final double radius;

  _SparkParticle({
    required this.angle,
    required this.speed,
    required this.radius,
  });
}

/// A zero-sleep-overhead interactive canvas that paints real-time touch ripples,
/// stardust sparks, or celestial aurora shockwaves at user contact points, while executing
/// tactile haptic feedback profiles.
class InteractiveGestureCanvas extends StatefulWidget {
  final GestureControlConfig config;
  final AuraPaletteConfig auraConfig;
  final Widget? child;
  final void Function(GestureAction action)? onActionTriggered;
  final void Function(String debugEvent)? onDebugGesture;
  final bool absorbPointers;

  const InteractiveGestureCanvas({
    super.key,
    required this.config,
    required this.auraConfig,
    this.child,
    this.onActionTriggered,
    this.onDebugGesture,
    this.absorbPointers = false,
  });

  @override
  State<InteractiveGestureCanvas> createState() =>
      _InteractiveGestureCanvasState();
}

class _InteractiveGestureCanvasState extends State<InteractiveGestureCanvas>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final List<_TouchContactRipple> _ripples = [];
  final math.Random _random = math.Random();

  DateTime? _lastTapTime;
  int _consecutiveTapCount = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_tick);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _tick() {
    if (_ripples.isEmpty) {
      if (_animController.isAnimating) _animController.stop();
      return;
    }

    final now = DateTime.now();
    final duration = widget.config.rippleDurationMs;

    _ripples.removeWhere(
      (r) => now.difference(r.startTime).inMilliseconds >= duration,
    );

    if (_ripples.isEmpty && _animController.isAnimating) {
      _animController.stop();
    }
    setState(() {});
  }

  Color _resolveTouchColor() {
    switch (widget.config.touchColorMode) {
      case TouchColorMode.auraSync:
        return widget.auraConfig.preset.primaryAccent;
      case TouchColorMode.electricCyan:
        return AppColors.neonCyan;
      case TouchColorMode.auroraViolet:
        return AppColors.auroraViolet;
      case TouchColorMode.solarAmber:
        return AppColors.sunsetAmber;
      case TouchColorMode.emeraldNeon:
        return AppColors.auroraEmerald;
      case TouchColorMode.pureWhite:
        return Colors.white;
    }
  }

  void _triggerHaptic() {
    if (!widget.config.isGesturesEnabled) return;
    switch (widget.config.hapticProfile) {
      case HapticFeedbackProfile.subtle:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackProfile.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackProfile.firm:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackProfile.selection:
        HapticFeedback.selectionClick();
        break;
      case HapticFeedbackProfile.off:
        break;
    }
  }

  void _spawnVisualEffect(Offset position) {
    if (!widget.config.isGesturesEnabled ||
        widget.config.touchVisualEffect == TouchVisualEffect.none) {
      return;
    }

    final List<_SparkParticle> sparks = [];
    if (widget.config.touchVisualEffect == TouchVisualEffect.particleBurst) {
      for (int i = 0; i < 14; i++) {
        final angle = _random.nextDouble() * 2 * math.pi;
        final speed = 40.0 + _random.nextDouble() * 80.0;
        final radius = 2.0 + _random.nextDouble() * 3.5;
        sparks.add(_SparkParticle(angle: angle, speed: speed, radius: radius));
      }
    }

    _ripples.add(_TouchContactRipple(
      position: position,
      startTime: DateTime.now(),
      color: _resolveTouchColor(),
      effect: widget.config.touchVisualEffect,
      sparks: sparks,
    ));

    if (!_animController.isAnimating) {
      _animController.repeat();
    }
  }

  void _handleTapDown(TapDownDetails details) {
    _triggerHaptic();
    _spawnVisualEffect(details.localPosition);

    final now = DateTime.now();
    if (_lastTapTime == null ||
        now.difference(_lastTapTime!).inMilliseconds > 350) {
      _consecutiveTapCount = 1;
    } else {
      _consecutiveTapCount++;
    }
    _lastTapTime = now;

    if (_consecutiveTapCount == 2) {
      widget.onDebugGesture?.call('Double-Tap Detected');
      if (widget.config.isGesturesEnabled &&
          widget.config.doubleTapAction.isEnabled) {
        widget.onActionTriggered?.call(widget.config.doubleTapAction);
      }
    } else if (_consecutiveTapCount == 3) {
      widget.onDebugGesture?.call('Triple-Tap Detected');
      if (widget.config.isGesturesEnabled &&
          widget.config.tripleTapAction.isEnabled) {
        widget.onActionTriggered?.call(widget.config.tripleTapAction);
      }
      _consecutiveTapCount = 0;
    }
  }

  void _handleLongPress() {
    _triggerHaptic();
    widget.onDebugGesture?.call('Long-Press Detected');
    if (widget.config.isGesturesEnabled &&
        widget.config.longPressAction.isEnabled) {
      widget.onActionTriggered?.call(widget.config.longPressAction);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gestureLayer = GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: _handleTapDown,
      onLongPress: _handleLongPress,
      child: CustomPaint(
        painter: _TouchRipplePainter(
          ripples: _ripples,
          durationMs: widget.config.rippleDurationMs,
        ),
        child: widget.child ?? const SizedBox.expand(),
      ),
    );

    return gestureLayer;
  }
}

class _TouchRipplePainter extends CustomPainter {
  final List<_TouchContactRipple> ripples;
  final int durationMs;

  _TouchRipplePainter({
    required this.ripples,
    required this.durationMs,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (ripples.isEmpty) return;

    final now = DateTime.now();

    for (final ripple in ripples) {
      final elapsed = now.difference(ripple.startTime).inMilliseconds;
      final progress = (elapsed / durationMs).clamp(0.0, 1.0);
      final alpha = ((1.0 - progress) * 255).round().clamp(0, 255);

      switch (ripple.effect) {
        case TouchVisualEffect.neonRipple:
          final currentRadius = 10.0 + (progress * 75.0);
          final strokeWidth = math.max(1.0, (1.0 - progress) * 4.0);

          final paint = Paint()
            ..color = ripple.color.withAlpha(alpha)
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth;

          canvas.drawCircle(ripple.position, currentRadius, paint);

          // Subtle inner glow halo
          final haloPaint = Paint()
            ..color = ripple.color.withAlpha((alpha * 0.35).round())
            ..style = PaintingStyle.fill;
          canvas.drawCircle(ripple.position, currentRadius * 0.45, haloPaint);
          break;

        case TouchVisualEffect.particleBurst:
          for (final spark in ripple.sparks) {
            final distance = spark.speed * progress;
            final dx = ripple.position.dx + math.cos(spark.angle) * distance;
            final dy = ripple.position.dy + math.sin(spark.angle) * distance;

            final sparkPaint = Paint()
              ..color = ripple.color.withAlpha(alpha)
              ..style = PaintingStyle.fill;

            canvas.drawCircle(
              Offset(dx, dy),
              spark.radius * (1.0 - (progress * 0.5)),
              sparkPaint,
            );
          }
          break;

        case TouchVisualEffect.auroraWave:
          final waveRadius = 15.0 + (progress * 90.0);
          final wavePaint = Paint()
            ..shader = RadialGradient(
              colors: [
                ripple.color.withAlpha((alpha * 0.6).round()),
                ripple.color.withAlpha((alpha * 0.15).round()),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(
              Rect.fromCircle(center: ripple.position, radius: waveRadius),
            );

          canvas.drawCircle(ripple.position, waveRadius, wavePaint);
          break;

        case TouchVisualEffect.none:
          break;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TouchRipplePainter oldDelegate) => true;
}
