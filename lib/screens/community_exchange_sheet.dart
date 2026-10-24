import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/wallpaper_bloc.dart';
import '../blocs/wallpaper_intent.dart';
import '../blocs/wallpaper_state.dart';
import '../core/core.dart';
import '../models/wallora_screen_blueprint.dart';

/// Modal bottom sheet for exploring, liking, inspecting, and 1-tap applying
/// complete community-crafted Wallora Screen Blueprints ("Aesthetic Profiles"),
/// and packaging/publishing user setups to the global exchange.
class CommunityExchangeSheet extends StatefulWidget {
  const CommunityExchangeSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const CommunityExchangeSheet(),
    );
  }

  @override
  State<CommunityExchangeSheet> createState() => _CommunityExchangeSheetState();
}

class _CommunityExchangeSheetState extends State<CommunityExchangeSheet> {
  final TextEditingController _searchController = TextEditingController();

  static const List<String> _tagFilters = [
    'All',
    'Cyberpunk',
    'AMOLED',
    'Anime',
    'Motivation',
    'Nature',
    'Staff Pick',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _safePop() {
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _applyBlueprint(WalloraScreenBlueprint blueprint) {
    HapticFeedback.heavyImpact();
    context.read<WallpaperBloc>().add(ApplyScreenBlueprintIntent(blueprint));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.auroraEmerald),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '✨ Applied "${blueprint.title}" Aesthetic Blueprint!',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.cardSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showPublishDialog(BuildContext context, WallpaperState state) {
    final current = state.currentShort;
    final titleController = TextEditingController(
      text: current != null ? '${current.title} Setup' : 'My Screen Blueprint',
    );
    final creatorController = TextEditingController(text: 'Wallora Creator');
    final descController = TextEditingController(
      text: 'A curated aesthetic setup crafted with Wallora.',
    );
    final Set<String> selectedTags = {
      if (current != null) current.category,
      'Community',
    };

    final availableTags = [
      'Cyberpunk',
      'AMOLED',
      'Anime',
      'Motivation',
      'Nature',
      'Minimalist',
      'Gaming',
      'Neon',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(dialogContext).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                decoration: const BoxDecoration(
                  color: AppColors.modalBackground,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border(
                    top: BorderSide(color: AppColors.neonCyan, width: 1.5),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.neonCyan, AppColors.auroraViolet],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.cloud_upload_rounded,
                                color: Colors.black, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PUBLISH BLUEPRINT',
                                  style: TextStyle(
                                    color: AppColors.neonCyan,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                Text(
                                  'Share Your Setup with Wallora Community',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // Blueprint Title
                      const Text(
                        'BLUEPRINT TITLE',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: titleController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'e.g. Cyberpunk Neon Ronin',
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: AppColors.cardSurface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Creator Name
                      const Text(
                        'CREATOR HANDLE / NAME',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: creatorController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'e.g. NeonArtist',
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: AppColors.cardSurface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Description
                      const Text(
                        'DESCRIPTION',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: descController,
                        maxLines: 2,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Describe your visual theme and mood...',
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: AppColors.cardSurface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Tag selection chips
                      const Text(
                        'AESTHETIC TAGS',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: availableTags.map((tag) {
                          final isSelected = selectedTags.contains(tag);
                          return FilterChip(
                            label: Text(tag),
                            selected: isSelected,
                            onSelected: (val) {
                              setDialogState(() {
                                if (val) {
                                  selectedTags.add(tag);
                                } else {
                                  selectedTags.remove(tag);
                                }
                              });
                            },
                            backgroundColor: AppColors.cardSurface,
                            selectedColor:
                                AppColors.neonCyan.withValues(alpha: 0.25),
                            checkmarkColor: AppColors.neonCyan,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? AppColors.neonCyan
                                  : Colors.white70,
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.neonCyan
                                    : Colors.white12,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 22),
                      // Publish Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            final title = titleController.text.trim();
                            final creator = creatorController.text.trim();
                            final desc = descController.text.trim();

                            context.read<WallpaperBloc>().add(
                                  PublishCurrentSetupIntent(
                                    title: title.isEmpty
                                        ? 'My Wallora Setup'
                                        : title,
                                    creatorName: creator.isEmpty
                                        ? 'Wallora Creator'
                                        : creator,
                                    description: desc.isEmpty
                                        ? 'Curated Wallora screen aesthetic.'
                                        : desc,
                                    tags: selectedTags.toList(),
                                  ),
                                );
                            HapticFeedback.mediumImpact();
                            if (dialogContext.mounted &&
                                Navigator.of(dialogContext).canPop()) {
                              Navigator.of(dialogContext).pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.neonCyan,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.rocket_launch_rounded, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Publish to Community Showcase',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showBlueprintDetails(
      BuildContext context, WalloraScreenBlueprint blueprint) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          decoration: const BoxDecoration(
            color: AppColors.modalBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: AppColors.auroraViolet, width: 1.5),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: blueprint.creatorAvatarColor,
                      child: Text(
                        blueprint.creatorName.isNotEmpty
                            ? blueprint.creatorName[0].toUpperCase()
                            : 'W',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            blueprint.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Curated by ${blueprint.creatorName}',
                            style: const TextStyle(
                              color: AppColors.neonCyan,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (blueprint.isStaffPick)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.solarGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.solarGold, width: 0.8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded,
                                color: AppColors.solarGold, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'STAFF PICK',
                              style: TextStyle(
                                color: AppColors.solarGold,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  blueprint.description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                // Dimensions Breakdown Cards
                const Text(
                  'AESTHETIC DIMENSIONS SPECIFICATION',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 10),
                _buildDimensionTile(
                  icon: Icons.image_rounded,
                  accentColor: AppColors.neonCyan,
                  title: 'Wallpaper Asset',
                  subtitle:
                      '${blueprint.wallpaper.title} (${blueprint.wallpaper.isLive ? "Live Wallpaper" : "Ultra-HD Static"})',
                ),
                _buildDimensionTile(
                  icon: Icons.format_quote_rounded,
                  accentColor: AppColors.solarGold,
                  title: 'Custom Kinetic Quote',
                  subtitle: blueprint.customQuote.isNotEmpty
                      ? '"${blueprint.customQuote}"'
                      : 'Default typography',
                ),
                _buildDimensionTile(
                  icon: Icons.blur_on_rounded,
                  accentColor: AppColors.auroraViolet,
                  title: 'Chromatic Aura Palette',
                  subtitle:
                      '${blueprint.auraConfig.preset.displayName} • ${blueprint.auraConfig.isDynamicThemingEnabled ? "Dynamic" : "Static"}',
                ),
                _buildDimensionTile(
                  icon: Icons.grain_rounded,
                  accentColor: AppColors.sunsetAmber,
                  title: 'Interactive Particle Physics',
                  subtitle:
                      '${blueprint.particleConfig.preset.displayName} • ${blueprint.particleConfig.particleCount} particles',
                ),
                _buildDimensionTile(
                  icon: Icons.layers_rounded,
                  accentColor: AppColors.auroraEmerald,
                  title: '3D Parallax Gyro Depth',
                  subtitle:
                      '${blueprint.parallaxConfig.sensitivity.toStringAsFixed(1)}x Sensitivity • ${blueprint.parallaxConfig.preset.label}',
                ),
                _buildDimensionTile(
                  icon: Icons.waves_rounded,
                  accentColor: AppColors.neonCyan,
                  title: 'Procedural Aurora Synthesizer',
                  subtitle:
                      '${blueprint.auroraConfig.waveStyle.displayName} • ${blueprint.auroraConfig.colorMode.displayName}',
                ),
                const SizedBox(height: 20),
                // 1-Tap Apply Action Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      _applyBlueprint(blueprint);
                      if (ctx.mounted && Navigator.of(ctx).canPop()) {
                        Navigator.of(ctx).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonCyan,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          '1-Tap Apply Complete Blueprint',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDimensionTile({
    required IconData icon,
    required Color accentColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: accentColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocBuilder<WallpaperBloc, WallpaperState>(
      builder: (context, state) {
        final blueprints = state.filteredBlueprints;
        final currentTag = state.communityTagFilter;

        return Container(
          height: screenHeight * 0.90,
          decoration: BoxDecoration(
            color: AppColors.darkBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonCyan.withValues(alpha: 0.4),
                blurRadius: 30,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Drag Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 12, 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.neonCyan, AppColors.auroraViolet],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neonCyan.withValues(alpha: 0.35),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.hub_rounded,
                          color: Colors.black, size: 22),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AESTHETIC BLUEPRINT EXCHANGE',
                            style: TextStyle(
                              color: AppColors.neonCyan,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Wallora • "Make every screen yours."',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.white70, size: 22),
                      onPressed: _safePop,
                    ),
                  ],
                ),
              ),

              // Publish Active Setup Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.cardSurface, AppColors.cardHighlight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.neonCyan.withValues(alpha: 0.3),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.neonCyan.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.palette_rounded,
                            color: AppColors.neonCyan, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'YOUR ACTIVE SETUP',
                              style: TextStyle(
                                color: AppColors.neonCyan,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              state.currentShort != null
                                  ? state.currentShort!.title
                                  : 'Active Screen Aesthetic',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showPublishDialog(context, state),
                        icon: const Icon(Icons.share_rounded, size: 14),
                        label: const Text(
                          'Publish',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.neonCyan,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Tag Filter Bar
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _tagFilters.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final tag = _tagFilters[index];
                    final isSelected = (currentTag == tag) ||
                        (tag == 'All' &&
                            (currentTag.isEmpty || currentTag == 'All'));

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        context
                            .read<WallpaperBloc>()
                            .add(FilterCommunityBlueprintsIntent(tag));
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.neonCyan
                              : AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.neonCyan
                                : Colors.white12,
                            width: 0.8,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white70,
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w900
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Blueprints Grid
              Expanded(
                child: blueprints.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.layers_clear_rounded,
                                color: Colors.white24, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              'No blueprints found for "$currentTag"',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                context.read<WallpaperBloc>().add(
                                    const FilterCommunityBlueprintsIntent(
                                        'All'));
                              },
                              child: const Text('Show All Blueprints',
                                  style: TextStyle(color: AppColors.neonCyan)),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.58,
                        ),
                        itemCount: blueprints.length,
                        itemBuilder: (context, index) {
                          final bp = blueprints[index];
                          final isLiked =
                              state.likedBlueprintIds.contains(bp.id);

                          return _buildBlueprintCard(
                            context: context,
                            blueprint: bp,
                            isLiked: isLiked,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBlueprintCard({
    required BuildContext context,
    required WalloraScreenBlueprint blueprint,
    required bool isLiked,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _showBlueprintDetails(context, blueprint);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: blueprint.wallpaper.gradientColors.isNotEmpty
                ? blueprint.wallpaper.gradientColors
                : [
                    blueprint.wallpaper.accentColor.withValues(alpha: 0.35),
                    Colors.black,
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: blueprint.isStaffPick
                ? AppColors.solarGold.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.12),
            width: blueprint.isStaffPick ? 1.2 : 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: (blueprint.auraConfig.customPrimaryColor ??
                      blueprint.auraConfig.preset.primaryAccent)
                  .withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Dark Gradient Vignette for Text Readability
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.4),
                    Colors.black.withValues(alpha: 0.95),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // Top Badges
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (blueprint.isStaffPick)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: AppColors.solarGold, width: 0.6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded,
                              color: AppColors.solarGold, size: 10),
                          SizedBox(width: 2),
                          Text(
                            'STAFF',
                            style: TextStyle(
                              color: AppColors.solarGold,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white24, width: 0.5),
                    ),
                    child: Text(
                      blueprint.wallpaper.isLive ? 'LIVE' : 'STATIC',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Center: Quote snippet
            if (blueprint.customQuote.isNotEmpty)
              Positioned(
                top: 40,
                left: 10,
                right: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '"${blueprint.customQuote}"',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 9,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

            // Bottom Content Information
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    blueprint.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 6,
                        backgroundColor: blueprint.creatorAvatarColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          blueprint.creatorName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Actions Row: Likes + Apply Button
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          context.read<WallpaperBloc>().add(
                                ToggleBlueprintLikeIntent(blueprint.id),
                              );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isLiked
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: isLiked
                                    ? AppColors.favoriteRed
                                    : Colors.white60,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${blueprint.likesCount}',
                                style: TextStyle(
                                  color: isLiked
                                      ? AppColors.favoriteRed
                                      : Colors.white70,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _applyBlueprint(blueprint),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.neonCyan,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Apply',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
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
      ),
    );
  }
}
