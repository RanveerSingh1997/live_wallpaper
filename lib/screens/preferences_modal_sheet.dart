import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/wallpaper_bloc.dart';
import '../blocs/wallpaper_intent.dart';
import '../core/core.dart';
import '../data/curated_shorts_data.dart';

class PreferencesModalSheet extends StatefulWidget {
  final Set<String> initialPreferences;
  final bool initialTextOverlayEnabled;

  const PreferencesModalSheet({
    super.key,
    required this.initialPreferences,
    required this.initialTextOverlayEnabled,
  });

  @override
  State<PreferencesModalSheet> createState() => _PreferencesModalSheetState();
}

class _PreferencesModalSheetState extends State<PreferencesModalSheet> {
  late Set<String> _selectedPreferences;
  late bool _textOverlayEnabled;

  @override
  void initState() {
    super.initState();
    _selectedPreferences = Set<String>.from(widget.initialPreferences);
    _textOverlayEnabled = widget.initialTextOverlayEnabled;
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Anime & Gaming':
        return Icons.sports_mma_rounded;
      case 'Nature & Scenery':
        return Icons.landscape_rounded;
      case 'Cyberpunk & Tech':
        return Icons.memory_rounded;
      case 'Cars & Speed':
        return Icons.speed_rounded;
      case 'Minimal & AMOLED':
        return Icons.dark_mode_rounded;
      case 'Motivation & Mindset':
        return Icons.psychology_rounded;
      case 'Fitness & Grind':
        return Icons.fitness_center_rounded;
      default:
        return Icons.auto_awesome_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Anime & Gaming':
        return AppColors.sunsetAmber;
      case 'Nature & Scenery':
        return AppColors.auroraEmerald;
      case 'Cyberpunk & Tech':
        return AppColors.auroraViolet;
      case 'Cars & Speed':
        return AppColors.favoriteRed;
      case 'Minimal & AMOLED':
        return AppColors.deepPurple;
      case 'Motivation & Mindset':
        return AppColors.neonCyan;
      case 'Fitness & Grind':
        return AppColors.solarGold;
      default:
        return Colors.white;
    }
  }

  void _savePreferences() {
    final bloc = context.read<WallpaperBloc>();

    // Update Category Preferences
    bloc.add(UpdateUserPreferencesIntent(_selectedPreferences));

    // Update Text Overlay if changed
    if (_textOverlayEnabled != widget.initialTextOverlayEnabled) {
      bloc.add(ToggleTextOverlayVisibilityIntent());
    }

    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.solarGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: AppColors.solarGold,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Wallpaper Preferences',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Personalize your live wallpaper feed',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white54),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Genre Selection Header & Quick toggles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'YOUR FAVORITE GENRES',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPreferences =
                            Set<String>.from(CuratedShortsData.availablePreferences);
                      });
                    },
                    child: const Text(
                      'All',
                      style: TextStyle(
                        color: Color(0xFFFFD600),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPreferences.clear();
                      });
                    },
                    child: const Text(
                      'Clear',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Multi-Select Category Wrap
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: CuratedShortsData.availablePreferences.map((category) {
              final isSelected = _selectedPreferences.contains(category);
              final catColor = _getCategoryColor(category);

              return FilterChip(
                showCheckmark: false,
                avatar: Icon(
                  _getCategoryIcon(category),
                  size: 16,
                  color: isSelected ? Colors.black : catColor,
                ),
                label: Text(
                  category,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.black : Colors.white,
                  ),
                ),
                selected: isSelected,
                selectedColor: catColor,
                backgroundColor: AppColors.sheetBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? catColor : Colors.white12,
                    width: 1.2,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedPreferences.add(category);
                    } else {
                      _selectedPreferences.remove(category);
                    }
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 24),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 16),

          // Text Overlay Switch Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.modalBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _textOverlayEnabled ? Icons.subtitles_rounded : Icons.subtitles_off_rounded,
                    color: _textOverlayEnabled ? AppColors.auroraEmerald : Colors.white38,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Show Text / Quote Overlay',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _textOverlayEnabled
                            ? 'Motivational typography overlay visible'
                            : 'Pure video loop mode (text hidden)',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _textOverlayEnabled,
                  activeTrackColor: AppColors.auroraEmerald,
                  activeThumbColor: Colors.white,
                  onChanged: (val) {
                    setState(() {
                      _textOverlayEnabled = val;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _savePreferences,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.solarGold,
                foregroundColor: Colors.black,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Save Preferences',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
