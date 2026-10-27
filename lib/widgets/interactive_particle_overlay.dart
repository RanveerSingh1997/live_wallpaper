import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/audio_spectrum_metrics.dart';
import '../models/audio_visualizer_config.dart';
import '../models/particle_effect_config.dart';

/// Interactive touch particle overlay that renders real-time kinetic particle FX.
/// Uses on-demand physics processing to ensure Zero Sleep Overhead and zero battery drain when idle.
class InteractiveParticleOverlay extends StatefulWidget {
  final ParticleEffectConfig config;
  final AudioSpectrumMetrics? audioSpectrumMetrics;
  final AudioVisualizerConfig? audioVisualizerConfig;
  final Widget? child;
  final bool enableTouchGestures;

  const InteractiveParticleOverlay({
    super.key,
    required this.config,
    this.audioSpectrumMetrics,
    this.audioVisualizerConfig,
    this.child,
    this.enableTouchGestures = true,
  });

  @override
  State<InteractiveParticleOverlay> createState() =>
      _InteractiveParticleOverlayState();
}

class _InteractiveParticleOverlayState extends State<InteractiveParticleOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();
  Size _lastSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_tick);
  }

  @override
  void didUpdateWidget(InteractiveParticleOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.config.preset != oldWidget.config.preset) {
      _particles.clear();
      if (!widget.config.isEnabled && _controller.isAnimating) {
        _controller.stop();
      } else if (widget.config.isEnabled && _lastSize != Size.zero) {
        _spawnTouchBurst(
          Offset(_lastSize.width / 2, _lastSize.height / 2),
          count: 5,
        );
      }
    }

    final audio = widget.audioSpectrumMetrics;
    final oldAudio = oldWidget.audioSpectrumMetrics;
    if (audio != null &&
        widget.config.isEnabled &&
        (widget.audioVisualizerConfig?.isEnabled ?? true) &&
        !audio.isSilent) {
      if (audio.peakDetected &&
          !(oldAudio?.peakDetected ?? false) &&
          _lastSize != Size.zero) {
        final intensity =
            widget.audioVisualizerConfig?.reactiveIntensity ?? 1.0;
        _spawnAudioReactiveBurst(
          Offset(_lastSize.width / 2, _lastSize.height / 2),
          intensity: intensity,
          bass: audio.bass,
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _tick() {
    if (!widget.config.isEnabled || _lastSize.isEmpty) {
      if (_controller.isAnimating) _controller.stop();
      return;
    }

    if (_particles.isEmpty) {
      if (_controller.isAnimating) _controller.stop();
      return;
    }

    final dt = 0.016 * widget.config.speedMultiplier;
    final maxLife = widget.config.lifespanSeconds;

    // Update existing particles
    for (int i = _particles.length - 1; i >= 0; i--) {
      final p = _particles[i];
      p.life += dt;

      if (p.life >= maxLife) {
        _particles.removeAt(i);
        continue;
      }

      p.x += p.vx * dt;
      p.y += p.vy * dt;

      // Presets behavioral physics
      switch (widget.config.preset) {
        case ParticlePreset.neonStardust:
          p.vy -= 14 * dt; // Gentle upward drift
          break;
        case ParticlePreset.electricSparks:
          p.vx *= 0.92; // High air friction damping
          p.vy *= 0.92;
          break;
        case ParticlePreset.fluidRipples:
          p.radius += 50 * dt; // Expanding ripple radius
          break;
        case ParticlePreset.sakuraDrift:
          p.vy += 18 * dt; // Gentle downward drift
          p.x += math.sin(p.life * 3.5) * 1.5; // Natural petal sway
          break;
        case ParticlePreset.auroraVortex:
          final angle = p.life * 4.0;
          p.x += math.cos(angle) * 22 * dt;
          p.y += math.sin(angle) * 22 * dt;
          break;
        case ParticlePreset.none:
          break;
      }

      // Fade out towards end of life
      final progress = p.life / maxLife;
      p.alpha = ((1.0 - progress) * widget.config.glowIntensity).clamp(0.0, 1.0);
    }

    if (_particles.isEmpty && _controller.isAnimating) {
      _controller.stop();
    }

    setState(() {});
  }

  void _onPointerDown(PointerDownEvent event) {
    if (!widget.config.isEnabled || !widget.enableTouchGestures) return;

    if (widget.config.isHapticsEnabled) {
      HapticFeedback.selectionClick();
    }
    _spawnTouchBurst(event.localPosition);
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!widget.config.isEnabled || !widget.enableTouchGestures) return;

    if (_random.nextDouble() < 0.4) {
      _spawnTouchBurst(event.localPosition, count: 2);
    }
  }

  void _spawnTouchBurst(Offset pos, {int count = 6}) {
    final preset = widget.config.preset;
    for (int i = 0; i < count; i++) {
      final angle = _random.nextDouble() * math.pi * 2;
      final speed = (_random.nextDouble() * 90 + 30) * widget.config.speedMultiplier;
      final vx = math.cos(angle) * speed;
      final vy = math.sin(angle) * speed;

      _particles.add(
        _Particle(
          x: pos.dx,
          y: pos.dy,
          vx: vx,
          vy: vy,
          radius: _random.nextDouble() * 4 + 3,
          alpha: widget.config.glowIntensity,
          maxLife: widget.config.lifespanSeconds * 0.8,
          life: 0,
          color: preset.accentColor,
        ),
      );
    }

    if (!_controller.isAnimating && widget.config.isEnabled) {
      _controller.repeat();
    }
  }

  void _spawnAudioReactiveBurst(
    Offset pos, {
    double intensity = 1.0,
    double bass = 0.5,
  }) {
    final preset = widget.config.preset;
    final count = ((_random.nextInt(6) + 6) * intensity).clamp(4, 18).toInt();
    for (int i = 0; i < count; i++) {
      final angle = _random.nextDouble() * math.pi * 2;
      final speed = (_random.nextDouble() * 120 + 40) *
          widget.config.speedMultiplier *
          (1.0 + bass);
      final vx = math.cos(angle) * speed;
      final vy = math.sin(angle) * speed;

      _particles.add(
        _Particle(
          x: pos.dx,
          y: pos.dy,
          vx: vx,
          vy: vy,
          radius: (_random.nextDouble() * 4 + 3) * (1.0 + bass * 0.5),
          alpha: (widget.config.glowIntensity * (1.0 + bass * 0.3)).clamp(0.2, 1.0),
          maxLife: widget.config.lifespanSeconds * 0.9,
          life: 0,
          color: preset.accentColor,
        ),
      );
    }

    if (!_controller.isAnimating && widget.config.isEnabled) {
      _controller.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = LayoutBuilder(
      builder: (context, constraints) {
        _lastSize = Size(constraints.maxWidth, constraints.maxHeight);

        return CustomPaint(
          size: _lastSize,
          painter: _ParticlePainter(
            particles: _particles,
            preset: widget.config.preset,
          ),
        );
      },
    );

    if (widget.enableTouchGestures && widget.config.isEnabled) {
      content = Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        child: content,
      );
    }

    final accessibleContent = Semantics(
      label: 'Interactive Particle Overlay',
      hint: widget.config.isEnabled
          ? '${widget.config.preset.displayName} particles active'
          : 'Particles disabled',
      child: content,
    );

    if (widget.child != null) {
      return Stack(
        fit: StackFit.passthrough,
        children: [
          widget.child!,
          Positioned.fill(child: accessibleContent),
        ],
      );
    }

    return accessibleContent;
  }
}

class _Particle {
  double x;
  double y;
  double vx;
  double vy;
  double radius;
  double alpha;
  final double maxLife;
  double life;
  final Color color;

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.alpha,
    required this.maxLife,
    required this.life,
    required this.color,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final ParticlePreset preset;

  _ParticlePainter({
    required this.particles,
    required this.preset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (preset == ParticlePreset.none || particles.isEmpty) return;

    final paint = Paint()..isAntiAlias = true;

    for (final p in particles) {
      final colorWithAlpha = p.color.withValues(alpha: p.alpha);

      switch (preset) {
        case ParticlePreset.neonStardust:
          // Glowing soft circle
          paint.style = PaintingStyle.fill;
          paint.color = colorWithAlpha;
          canvas.drawCircle(Offset(p.x, p.y), p.radius, paint);
          break;

        case ParticlePreset.electricSparks:
          // Sharp spark lines
          paint.style = PaintingStyle.stroke;
          paint.strokeWidth = 2.0;
          paint.color = colorWithAlpha;
          final sparkEnd = Offset(p.x - p.vx * 0.05, p.y - p.vy * 0.05);
          canvas.drawLine(Offset(p.x, p.y), sparkEnd, paint);
          break;

        case ParticlePreset.fluidRipples:
          // Concentric circular ripple rings
          paint.style = PaintingStyle.stroke;
          paint.strokeWidth = 1.8;
          paint.color = colorWithAlpha;
          canvas.drawCircle(Offset(p.x, p.y), p.radius, paint);
          break;

        case ParticlePreset.sakuraDrift:
          // Petal oval
          paint.style = PaintingStyle.fill;
          paint.color = colorWithAlpha;
          canvas.save();
          canvas.translate(p.x, p.y);
          canvas.rotate(p.life * 2);
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset.zero,
              width: p.radius * 2.5,
              height: p.radius * 1.2,
            ),
            paint,
          );
          canvas.restore();
          break;

        case ParticlePreset.auroraVortex:
          // Luminous aura glow circle
          paint.style = PaintingStyle.fill;
          paint.color = colorWithAlpha;
          canvas.drawCircle(Offset(p.x, p.y), p.radius * 1.5, paint);
          break;

        case ParticlePreset.none:
          break;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
