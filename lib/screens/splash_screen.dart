import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/core.dart';
import 'main_navigation_shell.dart';

/// Premium animated splash screen for Wallora.
///
/// Features:
/// - Breathing aurora gradient vortex glow behind the central brand icon
/// - Smooth spring scale & opacity entrance for the Wallora 3D icon
/// - Staggered typography entrance ("WALLORA" -> "Make every screen yours.")
/// - Minimalist neon progress indicator
/// - Seamless fade navigation transition to [MainNavigationShell]
class SplashScreen extends StatefulWidget {
  final Duration duration;
  final Widget? nextScreen;
  final VoidCallback? onAnimationComplete;

  const SplashScreen({
    super.key,
    this.duration = AppConstants.splashDelay,
    this.nextScreen,
    this.onAnimationComplete,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _iconFadeAnimation;
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _taglineFadeAnimation;
  late Animation<double> _auraPulseAnimation;

  Timer? _navigationTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _iconScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _iconFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _auraPulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.85, curve: Curves.easeInOut),
      ),
    );

    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.8, curve: Curves.easeOut),
      ),
    );

    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _taglineFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Schedule transition to the main navigation shell
    if (widget.duration > Duration.zero) {
      _navigationTimer = Timer(widget.duration, _navigateToNext);
    }
  }

  void _navigateToNext() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    widget.onAnimationComplete?.call();

    final destination = widget.nextScreen ?? const MainNavigationShell();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _navigateToNext();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF09090C),
        body: Stack(
          children: [
            // Ambient Aurora Radial Glow
            AnimatedBuilder(
              animation: _auraPulseAnimation,
              builder: (context, child) {
                return Center(
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF7C4DFF).withValues(
                            alpha: 0.22 * _auraPulseAnimation.value,
                          ),
                          const Color(0xFFFF5722).withValues(
                            alpha: 0.14 * _auraPulseAnimation.value,
                          ),
                          const Color(0xFF00E5FF).withValues(
                            alpha: 0.08 * _auraPulseAnimation.value,
                          ),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.45, 0.75, 1.0],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Subtle Background Grid Texture / Gradient
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.6),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Central Branding Content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon with dynamic scale & aura frame
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _iconFadeAnimation.value,
                        child: Transform.scale(
                          scale: _iconScaleAnimation.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.18),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF5722).withValues(alpha: 0.35),
                                  blurRadius: 36,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 10),
                                ),
                                BoxShadow(
                                  color: const Color(0xFF7C4DFF).withValues(alpha: 0.25),
                                  blurRadius: 24,
                                  spreadRadius: -2,
                                  offset: const Offset(0, -6),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(27),
                              child: Image.asset(
                                'assets/icon/wallora_app_icon.png',
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) {
                                  // Fallback high-fidelity icon container if image loading encounters error
                                  return Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Color(0xFF2A0D00), Color(0xFFFF5722), Color(0xFF7C4DFF)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.auto_awesome_rounded,
                                        size: 54,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // Brand Name: WALLORA
                  AnimatedBuilder(
                    animation: _titleFadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _titleFadeAnimation.value,
                        child: SlideTransition(
                          position: _titleSlideAnimation,
                          child: Text(
                            AppStrings.appName.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 8.0,
                              shadows: [
                                Shadow(
                                  color: AppColors.sunsetAmber,
                                  blurRadius: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  // Tagline: Make every screen yours.
                  AnimatedBuilder(
                    animation: _taglineFadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _taglineFadeAnimation.value,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 14,
                              height: 1.5,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.transparent, AppColors.sunsetAmber],
                                ),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              AppStrings.appTagline,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 14,
                              height: 1.5,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFF5722), Colors.transparent],
                                ),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Bottom Minimalist Micro-Loading Bar
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedBuilder(
                  animation: _taglineFadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _taglineFadeAnimation.value,
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: Colors.white10,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: const LinearProgressIndicator(
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFFF5722),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'PREPARING CANVASES',
                            style: TextStyle(
                              color: Colors.white24,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
