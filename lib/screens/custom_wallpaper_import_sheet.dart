import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/wallpaper_bloc.dart';
import '../blocs/wallpaper_intent.dart';
import '../data/curated_shorts_data.dart';
import '../models/motivational_short.dart';

/// Creator Custom Wallpaper Importer Sheet.
///
/// Enables users to:
/// - Import custom live video (MP4) or static (PNG/JPG) wallpapers
/// - Define custom titles, creator tags, and category classifications
/// - Select radiant accent neon colors
/// - Attach kinetic motivational quotes and mantras
/// - Preview the wallpaper inside a simulated 4K smartphone canvas
/// - Save to personal Wallora library and apply directly to Lockscreen/Homescreen
class CustomWallpaperImportSheet extends StatefulWidget {
  const CustomWallpaperImportSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const CustomWallpaperImportSheet(),
    );
  }

  @override
  State<CustomWallpaperImportSheet> createState() =>
      _CustomWallpaperImportSheetState();
}

class _CustomWallpaperImportSheetState
    extends State<CustomWallpaperImportSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _pathController;
  late TextEditingController _quoteController;

  bool _isLive = true;
  bool _hasTextOverlay = true;
  String _selectedCategory = 'Nature & Scenery';
  String _selectedResolution = '4K Ultra HD (2160x3840)';

  static const List<Color> _accentColors = [
    Color(0xFF00E5FF), // Aurora Cyan
    Color(0xFFFF5722), // Apex Amber
    Color(0xFF00E676), // Matrix Green
    Color(0xFFD500F9), // Neon Violet
    Color(0xFFFFD600), // Cyber Gold
    Color(0xFF2979FF), // Electric Blue
  ];
  int _selectedColorIndex = 0;

  static const List<Map<String, dynamic>> _presetSources = [
    {
      'label': 'Apex Live Video',
      'path': 'assets/videos/ippo_motivation.mp4',
      'isLive': true,
      'title': 'Apex Velocity',
      'author': 'Wallora Studio',
      'category': 'Cars & Speed',
      'quote': 'Speed without limits. Precision without compromise.',
    },
    {
      'label': 'Celestial Aurora',
      'path': 'assets/videos/iron_mind.mp4',
      'isLive': true,
      'title': 'Celestial Aurora Borealis',
      'author': 'Nordic Skies',
      'category': 'Nature & Scenery',
      'quote': 'Silence in the northern light. Tranquility within.',
    },
    {
      'label': 'Neon Cyber City',
      'path': 'assets/videos/tokyo_drift.mp4',
      'isLive': true,
      'title': 'Cyber City Skyline',
      'author': 'Neo Tokyo',
      'category': 'Cyberpunk & Tech',
      'quote': 'Built in obsidian, illuminated in electric violet.',
    },
    {
      'label': 'Glass Canvas 4K',
      'path': 'assets/icon/wallora_app_icon.png',
      'isLive': false,
      'title': 'Wallora Obsidian Canvas',
      'author': 'Wallora Design',
      'category': 'Minimal & AMOLED',
      'quote': 'Make every screen yours.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: 'My Custom Aurora');
    _authorController = TextEditingController(text: 'Creator Studio');
    _pathController =
        TextEditingController(text: 'assets/videos/iron_mind.mp4');
    _quoteController =
        TextEditingController(text: 'Make every screen yours.');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _pathController.dispose();
    _quoteController.dispose();
    super.dispose();
  }

  void _applyPreset(Map<String, dynamic> preset) {
    setState(() {
      _pathController.text = preset['path'] as String;
      _isLive = preset['isLive'] as bool;
      _titleController.text = preset['title'] as String;
      _authorController.text = preset['author'] as String;
      _selectedCategory = preset['category'] as String;
      _quoteController.text = preset['quote'] as String;
    });
  }

  MotivationalShort _buildShort() {
    final title = _titleController.text.trim().isEmpty
        ? 'Custom Wallpaper'
        : _titleController.text.trim();
    final author = _authorController.text.trim().isEmpty
        ? 'Creator Studio'
        : _authorController.text.trim();
    final path = _pathController.text.trim().isEmpty
        ? (_isLive
            ? 'assets/videos/ippo_motivation.mp4'
            : 'assets/icon/wallora_app_icon.png')
        : _pathController.text.trim();
    final quote = _quoteController.text.trim().isEmpty
        ? 'Make every screen yours.'
        : _quoteController.text.trim();
    final accent = _accentColors[_selectedColorIndex];

    final id =
        'custom_${DateTime.now().millisecondsSinceEpoch}_${title.toLowerCase().replaceAll(RegExp(r'\s+'), '_')}';

    return MotivationalShort(
      id: id,
      title: title,
      quote: quote,
      author: author,
      category: _selectedCategory,
      videoAssetPath: path,
      imageUrl: _isLive ? null : path,
      accentColor: accent,
      mood: 'Custom Creator',
      hasTextByDefault: _hasTextOverlay,
      isLive: _isLive,
      resolution: _selectedResolution,
      fileSizeBytes: _isLive ? 3500000 : 1800000,
      durationSeconds: _isLive ? 15 : 0,
      gradientColors: [
        const Color(0xFF05050A),
        accent.withValues(alpha: 0.6),
        const Color(0xFF000000),
      ],
      tags:
          'custom creator imported ${_selectedCategory.toLowerCase()} ${title.toLowerCase()}',
    );
  }

  void _submit({bool andApply = false}) {
    if (!_formKey.currentState!.validate()) return;

    final short = _buildShort();
    final bloc = context.read<WallpaperBloc>();

    bloc.add(ImportCustomWallpaperIntent(short));
    if (andApply) {
      if (short.isLive) {
        bloc.add(ApplyLiveWallpaperIntent(short: short));
      } else {
        bloc.add(ApplyStaticWallpaperIntent(
          short: short,
          targetScreen: 'both',
          customQuote: _hasTextOverlay ? short.quote : null,
        ));
      }
    }

    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentAccent = _accentColors[_selectedColorIndex];

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Color(0xFF141418),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [currentAccent, const Color(0xFFD500F9)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add_photo_alternate_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CREATOR STUDIO',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Import your own 4K live video or artwork',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.6),
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
          ),
          const Divider(color: Colors.white10, height: 1),

          // Scrollable Body
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // 4K Phone Simulator Canvas Preview
                  _buildPhoneCanvasPreview(currentAccent),

                  const SizedBox(height: 24),

                  // Media Type Toggle: Live Video vs 4K Static Image
                  const Text(
                    'WALLPAPER FORMAT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFormatSelectorButton(
                          title: 'Live Video (MP4)',
                          subtitle: '60 FPS Motion Loop',
                          icon: Icons.videocam_rounded,
                          isSelected: _isLive,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _isLive = true);
                          },
                          accent: currentAccent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFormatSelectorButton(
                          title: 'Static 4K Image',
                          subtitle: 'Lossless Hi-Res',
                          icon: Icons.image_rounded,
                          isSelected: !_isLive,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _isLive = false);
                          },
                          accent: currentAccent,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Quick Presets
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'QUICK SAMPLE PRESETS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: Colors.white54,
                        ),
                      ),
                      Text(
                        'Instant Auto-fill',
                        style: TextStyle(
                          fontSize: 11,
                          color: currentAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _presetSources.map((preset) {
                        final isSelected =
                            _pathController.text == preset['path'];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            avatar: Icon(
                              preset['isLive'] as bool
                                  ? Icons.play_arrow_rounded
                                  : Icons.photo_rounded,
                              size: 16,
                              color: isSelected ? Colors.black : Colors.white70,
                            ),
                            label: Text(
                              preset['label'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color:
                                    isSelected ? Colors.black : Colors.white70,
                              ),
                            ),
                            backgroundColor: isSelected
                                ? currentAccent
                                : const Color(0xFF1E1E24),
                            side: BorderSide(
                              color: isSelected
                                  ? currentAccent
                                  : Colors.white12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              _applyPreset(preset);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Source File / Asset Path Input
                  const Text(
                    'FILE PATH OR ASSET URI',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _pathController,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontFamily: 'monospace',
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1A1A20),
                      hintText: '/storage/emulated/0/DCIM/my_video.mp4 or asset path',
                      hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
                      prefixIcon: const Icon(Icons.link_rounded,
                          color: Colors.white38, size: 20),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear_rounded,
                            color: Colors.white38, size: 18),
                        onPressed: () => _pathController.clear(),
                      ),
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
                        borderSide: BorderSide(color: currentAccent),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please provide a valid file path or asset URI';
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: 22),

                  // Title & Author Inputs
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'WALLPAPER TITLE',
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
                                filled: true,
                                fillColor: const Color(0xFF1A1A20),
                                hintText: 'e.g. Midnight Apex',
                                hintStyle: const TextStyle(color: Colors.white24),
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
                                  borderSide: BorderSide(color: currentAccent),
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Title required';
                                }
                                return null;
                              },
                              onChanged: (_) => setState(() {}),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CREATOR / ARTIST',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                                color: Colors.white54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _authorController,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFF1A1A20),
                                hintText: 'e.g. Studio Vertex',
                                hintStyle: const TextStyle(color: Colors.white24),
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
                                  borderSide: BorderSide(color: currentAccent),
                                ),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Category & Resolution Selectors
                  Row(
                    children: [
                      // Category
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CATEGORY',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                                color: Colors.white54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A20),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedCategory,
                                  isExpanded: true,
                                  dropdownColor: const Color(0xFF22222A),
                                  icon: const Icon(Icons.arrow_drop_down_rounded,
                                      color: Colors.white54),
                                  items: CuratedShortsData.availablePreferences
                                      .map((cat) => DropdownMenuItem(
                                            value: cat,
                                            child: Text(
                                              cat,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _selectedCategory = val);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Resolution
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TARGET RESOLUTION',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                                color: Colors.white54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A20),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedResolution,
                                  isExpanded: true,
                                  dropdownColor: const Color(0xFF22222A),
                                  icon: const Icon(Icons.arrow_drop_down_rounded,
                                      color: Colors.white54),
                                  items: const [
                                    DropdownMenuItem(
                                      value: '4K Ultra HD (2160x3840)',
                                      child: Text(
                                        '4K Ultra HD',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 13),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: '1080x1920 (FHD 60fps)',
                                      child: Text(
                                        '1080p FHD 60fps',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 13),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: '1440x2560 (2K QHD)',
                                      child: Text(
                                        '2K QHD',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 13),
                                      ),
                                    ),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _selectedResolution = val);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Accent Glow Palette
                  const Text(
                    'AURORA ACCENT PALETTE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(_accentColors.length, (idx) {
                      final c = _accentColors[idx];
                      final isSelected = idx == _selectedColorIndex;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedColorIndex = idx);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: c.withValues(alpha: 0.6),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : [],
                          ),
                          child: isSelected
                              ? const Icon(Icons.check_rounded,
                                  color: Colors.black, size: 20)
                              : null,
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 24),

                  // Kinetic Typography Mantra (Optional)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'KINETIC QUOTE / MANTRA',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: Colors.white54,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            _hasTextOverlay ? 'Overlay On' : 'No Text',
                            style: TextStyle(
                              fontSize: 11,
                              color: _hasTextOverlay
                                  ? currentAccent
                                  : Colors.white38,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Switch.adaptive(
                            value: _hasTextOverlay,
                            activeThumbColor: currentAccent,
                            activeTrackColor: currentAccent.withValues(alpha: 0.3),
                            onChanged: (v) {
                              HapticFeedback.selectionClick();
                              setState(() => _hasTextOverlay = v);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (_hasTextOverlay) ...[
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _quoteController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      maxLines: 2,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF1A1A20),
                        hintText: 'Enter your personal mantra or motivational quote',
                        hintStyle: const TextStyle(color: Colors.white24),
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
                          borderSide: BorderSide(color: currentAccent),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            decoration: const BoxDecoration(
              color: Color(0xFF0D0D10),
              border: Border(top: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _submit(andApply: false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.library_add_rounded, size: 18),
                    label: const Text(
                      'IMPORT TO LIBRARY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _submit(andApply: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 4,
                      shadowColor: currentAccent.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.wallpaper_rounded, size: 18),
                    label: const Text(
                      'IMPORT & APPLY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatSelectorButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color accent,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? accent.withValues(alpha: 0.15) : const Color(0xFF1A1A20),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? accent : Colors.white12,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? accent : Colors.white54,
              size: 24,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isSelected ? accent : Colors.white38,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneCanvasPreview(Color accent) {
    final title = _titleController.text.trim().isEmpty
        ? 'Wallora Canvas'
        : _titleController.text.trim();
    final author = _authorController.text.trim().isEmpty
        ? 'Creator Studio'
        : _authorController.text.trim();
    final quote = _quoteController.text.trim().isEmpty
        ? 'Make every screen yours.'
        : _quoteController.text.trim();

    return Center(
      child: Container(
        width: 240,
        height: 380,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(36),
          border: Border.all(color: Colors.white24, width: 3),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.35),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(33),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Dynamic Background Aurora Wash
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF05050A),
                      accent.withValues(alpha: 0.45),
                      const Color(0xFF000000),
                    ],
                  ),
                ),
              ),

              // Subtle Radial Glow
              Positioned(
                top: 40,
                right: -20,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: 0.25),
                  ),
                ),
              ),

              // Phone Notch / Speaker
              Positioned(
                top: 8,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 60,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              // Top Status Bar (Clock & Icons)
              Positioned(
                top: 24,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '09:41',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: const [
                        Icon(Icons.wifi_rounded, color: Colors.white, size: 10),
                        SizedBox(width: 4),
                        Icon(Icons.battery_full_rounded, color: Colors.white, size: 10),
                      ],
                    ),
                  ],
                ),
              ),

              // Media Type & Category Badges
              Positioned(
                top: 46,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: accent.withValues(alpha: 0.6)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isLive
                                ? Icons.motion_photos_on_rounded
                                : Icons.photo_size_select_actual_rounded,
                            color: accent,
                            size: 10,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isLive ? 'LIVE 60FPS' : '4K STATIC',
                            style: TextStyle(
                              color: accent,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _selectedCategory.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Center Kinetic Quote (if overlay enabled)
              if (_hasTextOverlay)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '"$quote"',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                            shadows: [
                              Shadow(
                                color: accent,
                                blurRadius: 10,
                              ),
                              const Shadow(
                                color: Colors.black,
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Bottom Title & Creator Info
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.verified_rounded, color: accent, size: 10),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'by $author',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
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
  }
}
