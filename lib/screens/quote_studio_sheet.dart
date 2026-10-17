import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/wallpaper_bloc.dart';
import '../blocs/wallpaper_intent.dart';
import '../data/curated_shorts_data.dart';
import '../models/motivational_short.dart';

enum TypographyStyle {
  modernSans('Modern Sans', 'sans-serif', FontWeight.w800, 1.2),
  editorialSerif('Editorial Serif', 'serif', FontWeight.w700, 0.4),
  cyberMono('Cyber Mono', 'monospace', FontWeight.w700, 1.4),
  impactBold('Impact Bold', 'sans-serif', FontWeight.w900, -0.2),
  minimalZen('Minimal Zen', 'sans-serif', FontWeight.w300, 2.4);

  final String label;
  final String fontFamily;
  final FontWeight fontWeight;
  final double letterSpacing;

  const TypographyStyle(
    this.label,
    this.fontFamily,
    this.fontWeight,
    this.letterSpacing,
  );
}

class StudioGlowPalette {
  final String name;
  final Color primaryColor;
  final Color glowColor;

  const StudioGlowPalette({
    required this.name,
    required this.primaryColor,
    required this.glowColor,
  });
}

/// Kinetic Quote Typography Studio for Wallora.
///
/// Allows users to:
/// - Write or randomize motivational quotes & mantras
/// - Select from 5 distinct typographic aesthetics (Modern Sans, Editorial Serif, Cyber Mono, Impact Bold, Minimal Zen)
/// - Choose text alignment & radiant aurora neon glow palettes
/// - Live 4K preview on an interactive simulated smartphone canvas
/// - Switch background wallpaper from the catalog
/// - Save and directly apply to lockscreen / homescreen
class QuoteStudioSheet extends StatefulWidget {
  final MotivationalShort? short;
  final String? currentQuote;

  const QuoteStudioSheet({
    super.key,
    this.short,
    this.currentQuote,
  });

  static Future<void> show(
    BuildContext context, {
    MotivationalShort? short,
    String? currentQuote,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QuoteStudioSheet(
        short: short,
        currentQuote: currentQuote,
      ),
    );
  }

  @override
  State<QuoteStudioSheet> createState() => _QuoteStudioSheetState();
}

class _QuoteStudioSheetState extends State<QuoteStudioSheet> {
  late TextEditingController _quoteController;
  late TextEditingController _authorController;
  late MotivationalShort _selectedShort;

  TypographyStyle _selectedStyle = TypographyStyle.modernSans;
  TextAlign _selectedAlignment = TextAlign.center;
  int _selectedPaletteIndex = 0;

  static const List<StudioGlowPalette> _glowPalettes = [
    StudioGlowPalette(
      name: 'Aurora Neon',
      primaryColor: Color(0xFF00E5FF),
      glowColor: Color(0xFF7C4DFF),
    ),
    StudioGlowPalette(
      name: 'Solar Flare',
      primaryColor: Color(0xFFFF5722),
      glowColor: Color(0xFFFFD600),
    ),
    StudioGlowPalette(
      name: 'Pure Gold',
      primaryColor: Color(0xFFFFD700),
      glowColor: Color(0xFFFFA000),
    ),
    StudioGlowPalette(
      name: 'Cyber Emerald',
      primaryColor: Color(0xFF00E676),
      glowColor: Color(0xFF1DE9B6),
    ),
    StudioGlowPalette(
      name: 'Arctic Ice',
      primaryColor: Colors.white,
      glowColor: Color(0xFF80D8FF),
    ),
  ];

  static const List<Map<String, String>> _inspirationalQuotes = [
    {
      'quote': 'A man who gives up before stepping into the ring has already lost.',
      'author': 'Coach Kamogawa',
      'mood': 'Discipline & Grit',
    },
    {
      'quote': 'It is not about being the best today; it is about being better than yesterday.',
      'author': 'Makunouchi Ippo',
      'mood': 'Discipline & Grit',
    },
    {
      'quote': 'You have power over your mind, not outside events. Realize this, and find strength.',
      'author': 'Marcus Aurelius',
      'mood': 'Stoic Citadel',
    },
    {
      'quote': 'The obstacle in the path becomes the path. Never forget, within every obstacle is an opportunity.',
      'author': 'Ryan Holiday',
      'mood': 'Stoic Citadel',
    },
    {
      'quote': 'Speed is a feeling, perfection is an obsession.',
      'author': 'Enzo Ferrari',
      'mood': 'Nocturnal Speed',
    },
    {
      'quote': 'In the infinity of the void, craft your own constellation.',
      'author': 'Stephen Hawking',
      'mood': 'Deep Space',
    },
    {
      'quote': 'The mountains are calling and I must go.',
      'author': 'John Muir',
      'mood': 'Zen & Solitude',
    },
    {
      'quote': 'Silence isn’t empty, it’s full of answers.',
      'author': 'Miyamoto Musashi',
      'mood': 'Iron Focus',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedShort = widget.short ?? CuratedShortsData.shorts.first;
    final initialQuote = widget.currentQuote ?? _selectedShort.quote;
    _quoteController = TextEditingController(text: initialQuote);
    _authorController = TextEditingController(text: _selectedShort.author);
  }

  @override
  void dispose() {
    _quoteController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  void _randomizeQuote() {
    HapticFeedback.mediumImpact();
    final random = Random();
    final item = _inspirationalQuotes[random.nextInt(_inspirationalQuotes.length)];
    setState(() {
      _quoteController.text = item['quote']!;
      _authorController.text = item['author']!;
    });
  }

  void _saveQuote() {
    final text = _quoteController.text.trim();
    if (text.isNotEmpty) {
      HapticFeedback.lightImpact();
      context.read<WallpaperBloc>().add(
            UpdateCustomQuoteIntent(
              shortId: _selectedShort.id,
              newQuote: text,
            ),
          );
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kinetic typography saved for ${_selectedShort.title}'),
          backgroundColor: const Color(0xFF1E1E22),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _applyAndSave() {
    final text = _quoteController.text.trim();
    if (text.isNotEmpty) {
      HapticFeedback.heavyImpact();
      context.read<WallpaperBloc>().add(
            UpdateCustomQuoteIntent(
              shortId: _selectedShort.id,
              newQuote: text,
            ),
          );
      Navigator.of(context).pop();

      if (_selectedShort.isLive) {
        context.read<WallpaperBloc>().add(
              ApplyLiveWallpaperIntent(
                short: _selectedShort,
                isMuted: true,
              ),
            );
      } else {
        context.read<WallpaperBloc>().add(
              ApplyStaticWallpaperIntent(
                short: _selectedShort,
                targetScreen: 'both',
                customQuote: text,
              ),
            );
      }
    }
  }

  void _resetQuote() {
    HapticFeedback.selectionClick();
    context.read<WallpaperBloc>().add(
          ResetCustomQuoteIntent(_selectedShort.id),
        );
    setState(() {
      _quoteController.text = _selectedShort.quote;
      _authorController.text = _selectedShort.author;
    });
  }

  @override
  Widget build(BuildContext context) {
    final activePalette = _glowPalettes[_selectedPaletteIndex];
    final allWallpapers = CuratedShortsData.shorts;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF101014),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Drag Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 14, bottom: 8),
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Studio Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: activePalette.primaryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: activePalette.primaryColor, width: 0.8),
                          ),
                          child: Icon(
                            Icons.format_quote_rounded,
                            size: 18,
                            color: activePalette.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'QUOTE STUDIO',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              _selectedShort.title,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: _resetQuote,
                          icon: const Icon(Icons.refresh_rounded, size: 14, color: Colors.white54),
                          label: const Text(
                            'Reset',
                            style: TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white70),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white10, height: 1),

              // Scrollable Studio Controls & Live Preview
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  children: [
                    // Section 1: Live Interactive Phone Canvas Mockup
                    _buildPhoneCanvasPreview(activePalette),

                    const SizedBox(height: 20),

                    // Section 2: Canvas Background Selector
                    const Text(
                      'CANVAS WALLPAPER',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 52,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: allWallpapers.length,
                        separatorBuilder: (ctx, i) => const SizedBox(width: 8),
                        itemBuilder: (ctx, i) {
                          final item = allWallpapers[i];
                          final isSelected = item.id == _selectedShort.id;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _selectedShort = item;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 80,
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  colors: item.gradientColors.isNotEmpty
                                      ? item.gradientColors
                                      : [item.accentColor.withValues(alpha: 0.3), Colors.black],
                                ),
                                border: Border.all(
                                  color: isSelected ? activePalette.primaryColor : Colors.white12,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  item.mood,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Section 3: Editable Quote & Randomizer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'CUSTOM MANTHRA / CREED',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: Colors.white54,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _randomizeQuote,
                          icon: const Icon(Icons.casino_rounded, size: 14, color: Color(0xFFFF5722)),
                          label: const Text(
                            'Surprise Me',
                            style: TextStyle(
                              color: Color(0xFFFF5722),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _quoteController,
                      maxLines: 3,
                      onChanged: (val) => setState(() {}),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.35,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF1A1A1E),
                        hintText: 'Enter your custom motivational mantra...',
                        hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                        contentPadding: const EdgeInsets.all(14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: activePalette.primaryColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Author Field
                    TextField(
                      controller: _authorController,
                      onChanged: (val) => setState(() {}),
                      style: const TextStyle(fontSize: 13, color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF1A1A1E),
                        prefixIcon: const Icon(Icons.person_outline_rounded, size: 16, color: Colors.white38),
                        hintText: 'Author attribution or signature...',
                        hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Section 4: Typography Aesthetics
                    const Text(
                      'TYPOGRAPHIC AESTHETIC',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: TypographyStyle.values.map((style) {
                        final isSelected = _selectedStyle == style;
                        return ChoiceChip(
                          label: Text(style.label),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _selectedStyle = style;
                              });
                            }
                          },
                          selectedColor: activePalette.primaryColor.withValues(alpha: 0.2),
                          backgroundColor: const Color(0xFF1E1E22),
                          labelStyle: TextStyle(
                            color: isSelected ? activePalette.primaryColor : Colors.white70,
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                          ),
                          side: BorderSide(
                            color: isSelected ? activePalette.primaryColor : Colors.white12,
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 18),

                    // Section 5: Text Alignment & Glow Palette
                    Row(
                      children: [
                        // Alignment Controls
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ALIGNMENT',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                  color: Colors.white54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1A1E),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: Row(
                                  children: [
                                    _buildAlignButton(TextAlign.left, Icons.format_align_left_rounded),
                                    _buildAlignButton(TextAlign.center, Icons.format_align_center_rounded),
                                    _buildAlignButton(TextAlign.right, Icons.format_align_right_rounded),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Glow Color Palette
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'AURA GLOW',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                  color: Colors.white54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 38,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _glowPalettes.length,
                                  separatorBuilder: (ctx, i) => const SizedBox(width: 8),
                                  itemBuilder: (ctx, i) {
                                    final p = _glowPalettes[i];
                                    final isSelected = _selectedPaletteIndex == i;
                                    return GestureDetector(
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        setState(() {
                                          _selectedPaletteIndex = i;
                                        });
                                      },
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: [p.primaryColor, p.glowColor],
                                          ),
                                          border: Border.all(
                                            color: isSelected ? Colors.white : Colors.transparent,
                                            width: isSelected ? 2.5 : 0,
                                          ),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: p.primaryColor.withValues(alpha: 0.5),
                                                    blurRadius: 8,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Section 6: Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              onPressed: _saveQuote,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: activePalette.primaryColor, width: 1.2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                'SAVE TYPOGRAPHY',
                                style: TextStyle(
                                  color: activePalette.primaryColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _applyAndSave,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: activePalette.primaryColor,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 4,
                              ),
                              icon: const Icon(Icons.wallpaper_rounded, size: 16),
                              label: const Text(
                                'APPLY TO SCREEN',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
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
        );
      },
    );
  }

  Widget _buildAlignButton(TextAlign align, IconData icon) {
    final isSelected = _selectedAlignment == align;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _selectedAlignment = align;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white12 : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isSelected ? Colors.white : Colors.white38,
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneCanvasPreview(StudioGlowPalette palette) {
    final quoteText = _quoteController.text.trim().isNotEmpty
        ? _quoteController.text.trim()
        : 'Inspiration takes action.';
    final authorText = _authorController.text.trim().isNotEmpty
        ? _authorController.text.trim()
        : _selectedShort.author;

    return Center(
      child: Container(
        width: 240,
        height: 230,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: _selectedShort.gradientColors.isNotEmpty
                ? _selectedShort.gradientColors
                : [_selectedShort.accentColor.withValues(alpha: 0.4), Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(color: Colors.white24, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: palette.primaryColor.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Dark vignette overlay
              Container(
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

              // Mock phone status header (Lockscreen clock)
              const Positioned(
                top: 10,
                left: 12,
                right: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '09:41',
                      style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Icon(Icons.wifi, size: 10, color: Colors.white70),
                        SizedBox(width: 4),
                        Icon(Icons.battery_full_rounded, size: 12, color: Colors.white70),
                      ],
                    ),
                  ],
                ),
              ),

              // Central Rendered Kinetic Typography
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: palette.primaryColor, width: 0.6),
                        ),
                        child: Text(
                          _selectedShort.category.toUpperCase(),
                          style: TextStyle(
                            color: palette.primaryColor,
                            fontSize: 7,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),

                      // Quote Body
                      Text(
                        '"$quoteText"',
                        textAlign: _selectedAlignment,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: _selectedStyle.fontFamily,
                          fontWeight: _selectedStyle.fontWeight,
                          letterSpacing: _selectedStyle.letterSpacing,
                          fontSize: 12,
                          height: 1.3,
                          color: Colors.white,
                          fontStyle: _selectedStyle == TypographyStyle.editorialSerif
                              ? FontStyle.italic
                              : FontStyle.normal,
                          shadows: [
                            Shadow(
                              color: palette.glowColor,
                              blurRadius: 12,
                            ),
                            Shadow(
                              color: palette.primaryColor,
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Author Attribution
                      Text(
                        '— $authorText',
                        textAlign: _selectedAlignment,
                        style: TextStyle(
                          color: palette.primaryColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Live Indicator Pill in Corner
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white24, width: 0.6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _selectedShort.isLive ? Icons.videocam_rounded : Icons.image_rounded,
                        size: 9,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        _selectedShort.isLive ? 'LIVE' : '4K',
                        style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold),
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
