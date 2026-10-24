import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Netflix & Google-caliber obsidian shimmer loading effect for media preloaders.
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.isLoading = true,
    this.baseColor = const Color(0xFF16161F),
    this.highlightColor = const Color(0xFF28283A),
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value.clamp(0.0, 1.0),
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Prebuilt placeholder skeleton components matching Wallora's card geometry.
class ShimmerSkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerSkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.white10),
      ),
    );
  }
}

/// Netflix-style discover skeleton layout when loading wallpapers.
class ShimmerDiscoverSkeleton extends StatelessWidget {
  const ShimmerDiscoverSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Search bar skeleton
          const ShimmerSkeletonBox(width: double.infinity, height: 48, borderRadius: 24),
          const SizedBox(height: 18),
          // Hero banner skeleton
          const ShimmerSkeletonBox(width: double.infinity, height: 200, borderRadius: 22),
          const SizedBox(height: 24),
          // Category chips skeleton row
          Row(
            children: List.generate(
              4,
              (index) => const Padding(
                padding: EdgeInsets.only(right: 8),
                child: ShimmerSkeletonBox(width: 80, height: 36, borderRadius: 18),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Trending row skeleton
          Row(
            children: List.generate(
              3,
              (index) => const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: ShimmerSkeletonBox(width: 120, height: 180, borderRadius: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
