import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/wallpaper_bloc.dart';
import '../blocs/wallpaper_intent.dart';
import '../blocs/wallpaper_state.dart';
import '../core/core.dart';
import '../data/curated_shorts_data.dart';

class OnboardingSheet extends StatefulWidget {
  const OnboardingSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const OnboardingSheet(),
    );
  }

  @override
  State<OnboardingSheet> createState() => _OnboardingSheetState();
}

class _OnboardingSheetState extends State<OnboardingSheet> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final Set<String> _selectedPreferences = {};

  @override
  void initState() {
    super.initState();
    final currentPrefs = context.read<WallpaperBloc>().state.userPreferences;
    if (currentPrefs.isNotEmpty) {
      _selectedPreferences.addAll(currentPrefs);
    } else {
      _selectedPreferences.addAll(['Anime & Gaming', 'Nature & Scenery', 'Motivation & Mindset']);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    HapticFeedback.lightImpact();
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    HapticFeedback.mediumImpact();
    context.read<WallpaperBloc>().add(
          CompleteOnboardingIntent(
            _selectedPreferences.isEmpty
                ? {'Anime & Gaming', 'Nature & Scenery', 'Motivation & Mindset'}
                : _selectedPreferences,
          ),
        );
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WallpaperBloc, WallpaperState>(
      builder: (context, state) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.88,
          decoration: const BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 30,
                offset: Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top drag indicator
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 14, bottom: 8),
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Page Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  children: [
                    _buildWelcomePage(),
                    _buildPreferencesPage(),
                    _buildTrustGuaranteePage(),
                  ],
                ),
              ),

              // Bottom Control Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.white10, width: 0.8)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Page Indicator Dots
                    Row(
                      children: List.generate(3, (index) {
                        final isSelected = index == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.only(right: 6),
                          height: 6,
                          width: isSelected ? 22 : 6,
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [AppColors.sunsetAmber, AppColors.auroraViolet],
                                  )
                                : null,
                            color: isSelected ? null : Colors.white24,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),

                    // Navigation CTA
                    Row(
                      children: [
                        if (_currentPage > 0)
                          TextButton(
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: const Text(
                              'Back',
                              style: TextStyle(
                                color: Colors.white54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.sunsetAmber,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 4,
                          ),
                          child: Text(
                            _currentPage == 2 ? 'Explore Wallora' : 'Continue',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 10),
          // Gradient Brand Emblem
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.sunsetAmber, AppColors.auroraViolet, AppColors.neonCyan],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: AppColors.sunsetAmber.withValues(alpha: 0.35),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 42,
            ),
          ),
          const SizedBox(height: 22),

          const Text(
            'WALLORA',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Make every screen yours.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.sunsetAmber,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Discover cinematic live wallpapers, 4K AMOLED static backgrounds, and custom motivational typography designed for your home and lock screen.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 28),

          // Feature Pillars
          _buildPillarTile(
            icon: Icons.play_circle_fill_rounded,
            iconColor: AppColors.sunsetAmber,
            title: 'Cinematic Live Wallpapers',
            subtitle: 'Ultra-smooth 60fps vertical shorts with zero battery drain on sleep.',
          ),
          const SizedBox(height: 12),
          _buildPillarTile(
            icon: Icons.wallpaper_rounded,
            iconColor: AppColors.neonCyan,
            title: '4K AMOLED Backgrounds',
            subtitle: 'Ultra-deep obsidian blacks and high-contrast visuals for OLED displays.',
          ),
          const SizedBox(height: 12),
          _buildPillarTile(
            icon: Icons.format_quote_rounded,
            iconColor: AppColors.auroraViolet,
            title: 'Kinetic Quote Studio',
            subtitle: 'Personalize quotes, typography, and daily affirmations on any wallpaper.',
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesPage() {
    final categories = CuratedShortsData.availablePreferences;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What is your aesthetic?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Choose the styles you love most. Wallora tailors your "For You" discovery feed instantly.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white60,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Category Chips
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: categories.map((cat) {
              final isSelected = _selectedPreferences.contains(cat);
              return FilterChip(
                label: Text(cat),
                selected: isSelected,
                onSelected: (selected) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    if (selected) {
                      _selectedPreferences.add(cat);
                    } else {
                      if (_selectedPreferences.length > 1) {
                        _selectedPreferences.remove(cat);
                      }
                    }
                  });
                },
                backgroundColor: AppColors.cardSurface,
                selectedColor: AppColors.sunsetAmber.withValues(alpha: 0.25),
                checkmarkColor: AppColors.sunsetAmber,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  fontSize: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isSelected ? AppColors.sunsetAmber : Colors.white12,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                const Icon(Icons.tune_rounded, color: AppColors.neonCyan, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${_selectedPreferences.length} aesthetics selected. You can refine this anytime from the filter menu.',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustGuaranteePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Engineered for Trust',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'We believe personalization should never compromise your battery or privacy.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white60,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 22),

          _buildTrustCard(
            icon: Icons.battery_charging_full_rounded,
            color: AppColors.auroraEmerald,
            title: 'Zero Battery Sleep Drain',
            description:
                'The Android live engine actively pauses video decoders whenever your screen turns off or another app is open.',
          ),
          const SizedBox(height: 12),
          _buildTrustCard(
            icon: Icons.lock_outline_rounded,
            color: AppColors.neonCyan,
            title: '100% Private & Local',
            description:
                'No tracking, no invasive telemetry. Your favorites, offline downloads, and custom quotes remain strictly on your device.',
          ),
          const SizedBox(height: 12),
          _buildTrustCard(
            icon: Icons.speed_rounded,
            color: AppColors.sunsetAmber,
            title: 'Native Hardware Engine',
            description:
                'Hardware-accelerated media decoders deliver crisp 60fps playback without device stutter or memory pressure.',
          ),
        ],
      ),
    );
  }

  Widget _buildPillarTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.modalBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustCard({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.modalBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
