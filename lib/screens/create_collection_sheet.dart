import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/wallpaper_bloc.dart';
import '../blocs/wallpaper_intent.dart';
import '../blocs/wallpaper_state.dart';
import '../core/core.dart';
import '../models/wallpaper_collection.dart';

class CreateCollectionSheet extends StatefulWidget {
  final String? initialWallpaperId;

  const CreateCollectionSheet({
    super.key,
    this.initialWallpaperId,
  });

  static Future<WallpaperCollection?> show(
    BuildContext context, {
    String? initialWallpaperId,
  }) {
    return showModalBottomSheet<WallpaperCollection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CreateCollectionSheet(
        initialWallpaperId: initialWallpaperId,
      ),
    );
  }

  @override
  State<CreateCollectionSheet> createState() => _CreateCollectionSheetState();
}

class _CreateCollectionSheetState extends State<CreateCollectionSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;

  static const List<IconData> _iconChoices = [
    Icons.collections_bookmark_rounded,
    Icons.electric_bolt_rounded,
    Icons.local_fire_department_rounded,
    Icons.auto_awesome_rounded,
    Icons.dark_mode_rounded,
    Icons.favorite_rounded,
    Icons.palette_rounded,
    Icons.speed_rounded,
    Icons.landscape_rounded,
    Icons.sports_mma_rounded,
  ];

  static const List<List<Color>> _gradientChoices = [
    [AppColors.neonCyan, AppColors.auroraViolet],
    [AppColors.deepPurple, AppColors.auroraViolet, AppColors.obsidianBlack],
    [AppColors.sunsetAmber, AppColors.favoriteRed],
    [AppColors.auroraEmerald, AppColors.electricBlue],
    [AppColors.solarGold, AppColors.sunsetAmber],
    [AppColors.electricBlue, AppColors.neonCyan],
  ];

  static const List<String> _badgeChoices = [
    'PLAYLIST',
    'CURATED',
    'FAVORITES',
    'VIBE',
    'FOCUS',
  ];

  late IconData _selectedIcon;
  late List<Color> _selectedGradient;
  late String _selectedBadge;
  final Set<String> _selectedWallpaperIds = {};

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _subtitleController = TextEditingController(text: 'Personal Curation');
    _selectedIcon = _iconChoices.first;
    _selectedGradient = _gradientChoices.first;
    _selectedBadge = _badgeChoices.first;

    if (widget.initialWallpaperId != null) {
      _selectedWallpaperIds.add(widget.initialWallpaperId!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final subtitle = _subtitleController.text.trim().isEmpty
        ? 'Personal Curation'
        : _subtitleController.text.trim();

    final newCollection = WallpaperCollection(
      id: 'custom_col_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      subtitle: subtitle,
      badge: _selectedBadge,
      icon: _selectedIcon,
      wallpaperIds: _selectedWallpaperIds.toList(),
      gradientColors: _selectedGradient,
      isUserCreated: true,
    );

    context.read<WallpaperBloc>().add(
          CreateCustomCollectionIntent(newCollection),
        );

    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Created playlist "$title"'),
        backgroundColor: AppColors.neonCyan,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop(newCollection);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WallpaperBloc, WallpaperState>(
      builder: (context, state) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.darkBackground,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Form(
                key: _formKey,
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 36),
                  children: [
                    // Drag Handle
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
                    const SizedBox(height: 14),

                    // Sheet Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.playlist_add_rounded,
                                color: AppColors.neonCyan, size: 24),
                            SizedBox(width: 10),
                            Text(
                              'NEW PLAYLIST',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: Colors.white70),
                          onPressed: () {
                            if (mounted && Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Live Playlist Card Preview
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _titleController,
                      builder: (context, value, _) {
                        final previewTitle =
                            value.text.trim().isEmpty ? 'My Playlist' : value.text.trim();
                        final count = _selectedWallpaperIds.length;

                        return Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: _selectedGradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(color: Colors.white24),
                            boxShadow: [
                              BoxShadow(
                                color: _selectedGradient.first.withValues(alpha: 0.3),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.white24, width: 0.8),
                                    ),
                                    child: Text(
                                      _selectedBadge,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  Icon(_selectedIcon, color: Colors.white, size: 22),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                previewTitle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$count ${count == 1 ? 'Canvas' : 'Canvases'} Curated',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 22),

                    // Title Input
                    const Text(
                      'PLAYLIST NAME',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'e.g. Cyberpunk Vibes, Night Grind',
                        hintStyle: const TextStyle(color: Colors.white24),
                        filled: true,
                        fillColor: AppColors.cardSurface,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Colors.white12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Colors.white12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.neonCyan, width: 1.5),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a playlist name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // Subtitle / Description Input
                    const Text(
                      'DESCRIPTION / SUBTITLE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _subtitleController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'e.g. Neon nights for AMOLED lock screen',
                        hintStyle: const TextStyle(color: Colors.white24),
                        filled: true,
                        fillColor: AppColors.cardSurface,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Colors.white12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Colors.white12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.neonCyan, width: 1.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Icon Selector
                    const Text(
                      'PLAYLIST ICON',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 52,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _iconChoices.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final icon = _iconChoices[index];
                          final isSelected = _selectedIcon == icon;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedIcon = icon);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.neonCyan.withValues(alpha: 0.2)
                                    : AppColors.cardSurface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.neonCyan
                                      : Colors.white12,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Icon(
                                icon,
                                color: isSelected
                                    ? AppColors.neonCyan
                                    : Colors.white70,
                                size: 24,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Gradient Theme Selector
                    const Text(
                      'AURORA COLOR PALETTE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 52,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _gradientChoices.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final gradient = _gradientChoices[index];
                          final isSelected = _selectedGradient == gradient;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedGradient = gradient);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: gradient,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? Colors.white : Colors.white24,
                                  width: isSelected ? 2.5 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: gradient.first.withValues(alpha: 0.5),
                                          blurRadius: 10,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check_rounded,
                                      color: Colors.white, size: 22)
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Badge Selector
                    const Text(
                      'BADGE LABEL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _badgeChoices.map((badge) {
                        final isSelected = _selectedBadge == badge;
                        return ChoiceChip(
                          label: Text(badge),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedBadge = badge);
                            }
                          },
                          selectedColor:
                              AppColors.neonCyan.withValues(alpha: 0.2),
                          backgroundColor: AppColors.cardSurface,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppColors.neonCyan
                                : Colors.white70,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            fontSize: 11,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.neonCyan
                                : Colors.white12,
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Initial Wallpaper Selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'INCLUDE WALLPAPERS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: Colors.white54,
                          ),
                        ),
                        Text(
                          '${_selectedWallpaperIds.length} SELECTED',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.neonCyan,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.allShorts.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final short = state.allShorts[index];
                          final isIncluded =
                              _selectedWallpaperIds.contains(short.id);

                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                if (isIncluded) {
                                  _selectedWallpaperIds.remove(short.id);
                                } else {
                                  _selectedWallpaperIds.add(short.id);
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  colors: short.gradientColors.isNotEmpty
                                      ? short.gradientColors
                                      : [AppColors.cardSurface, Colors.black],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                border: Border.all(
                                  color: isIncluded
                                      ? AppColors.neonCyan
                                      : Colors.white12,
                                  width: isIncluded ? 2 : 1,
                                ),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Text(
                                      short.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isIncluded)
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: AppColors.neonCyan,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check_rounded,
                                          color: Colors.black,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Primary CTA: Create Playlist Button
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.neonCyan,
                          foregroundColor: Colors.black,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.add_rounded, size: 22),
                        label: const Text(
                          'CREATE PLAYLIST',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
