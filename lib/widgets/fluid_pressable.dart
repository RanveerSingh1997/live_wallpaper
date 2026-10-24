import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Apple / Netflix-caliber tactile pressable widget with spring scale physics and micro-haptics.
class FluidPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scaleFactor;
  final Duration duration;
  final Curve curve;
  final bool enableHaptic;
  final HitTestBehavior behavior;
  final String? semanticsLabel;

  const FluidPressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleFactor = 0.96,
    this.duration = const Duration(milliseconds: 120),
    this.curve = Curves.easeOutCubic,
    this.enableHaptic = true,
    this.behavior = HitTestBehavior.opaque,
    this.semanticsLabel,
  });

  @override
  State<FluidPressable> createState() => _FluidPressableState();
}

class _FluidPressableState extends State<FluidPressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.enableHaptic) {
      HapticFeedback.lightImpact();
    }
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );

    if (widget.semanticsLabel != null) {
      content = Semantics(
        button: widget.onTap != null,
        label: widget.semanticsLabel,
        child: content,
      );
    }

    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: widget.onTap != null || widget.onLongPress != null ? _onTapDown : null,
      onTapUp: widget.onTap != null || widget.onLongPress != null ? _onTapUp : null,
      onTapCancel: widget.onTap != null || widget.onLongPress != null ? _onTapCancel : null,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: content,
    );
  }
}
