import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/wallpaper_bloc.dart';
import '../blocs/wallpaper_intent.dart';
import '../blocs/wallpaper_state.dart';
import '../models/aura_palette_config.dart';
import '../models/motivational_short.dart';

/// Modal bottom sheet allowing users to extract, fine-tune, and harmonize
/// Wallora's 5-point chromatic Aura palette with active wallpapers.
class AuraPaletteSheet extends StatefulWidget {
  const AuraPaletteSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AuraPaletteSheet(),
    );
  }

  @override
  State<AuraPaletteSheet> createState() => _AuraPaletteSheetState();
}

class _AuraPaletteSheetState extends State<AuraPaletteSheet> {
  late AuraPaletteConfig _config;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<WallpaperBloc>();
    _config = bloc.state.auraConfig;
  }

  void _safePop() {
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  String _formatColorHex(Color color) {
    final a = (color.a * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase();
    final r = (color.r * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase();
    final g = (color.g * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase();
    final b = (color.b * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase();
    if (a == 'FF') {
      return '#$r$g$b';
    }
    return '#$a$r$g$b';
  }

  void _copyToClipboard(String hex, String label) {
    Clipboard.setData(ClipboardData(text: hex));
    HapticFeedback.selectionClick();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied $label ($hex) to clipboard!'),
        backgroundColor: const Color(0xFF1E1E28),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WallpaperBloc, WallpaperState>(
      builder: (context, state) {
        final currentWallpaper = state.currentShort;
        final resolvedPalette = _config.resolvePalette(currentWallpaper);

        return Container(
          height: MediaQuery.of(context).size.height * 0.90,
          decoration: const BoxDecoration(
            color: Color(0xFF0F0F14),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 28,
                spreadRadius: 8,
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                // Modal Drag Handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),

                // Header Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00E5FF), Color(0xFFD500F9)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.palette_rounded,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Aura Chromatic Harmonizer',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Dynamic palette extraction & UI color sync',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.65),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: _safePop,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(color: Colors.white10, height: 1),

                // Scrollable Content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    children: [
                      // 1. Live Chromatic Swatch Studio
                      _buildPaletteStudioCard(resolvedPalette, currentWallpaper),
                      const SizedBox(height: 22),

                      // 2. Preset Themes
                      const Text(
                        'AURA THEME PRESETS',
                        style: TextStyle(
                          color: Color(0xFF00E5FF),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...AuraThemePreset.values.map((preset) => _buildPresetTile(preset)),

                      const SizedBox(height: 22),

                      // 3. Fine-Tuning Chromatic Controls
                      const Text(
                        'CHROMATIC TUNING & SHIFT',
                        style: TextStyle(
                          color: Color(0xFF00E5FF),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),

                      _buildSliderTile(
                        label: 'Hue Shift',
                        valueDisplay: _config.hueShiftDegrees == 0.0
                            ? '0° (Natural)'
                            : '${_config.hueShiftDegrees > 0 ? '+' : ''}${_config.hueShiftDegrees.round()}°',
                        value: _config.hueShiftDegrees,
                        min: -180.0,
                        max: 180.0,
                        divisions: 36,
                        onChanged: (val) {
                          setState(() {
                            _config = _config.copyWith(hueShiftDegrees: val);
                          });
                        },
                      ),
                      const SizedBox(height: 12),

                      _buildSliderTile(
                        label: 'Saturation Multiplier',
                        valueDisplay: '${_config.saturationMultiplier.toStringAsFixed(1)}x',
                        value: _config.saturationMultiplier,
                        min: 0.5,
                        max: 1.5,
                        divisions: 20,
                        onChanged: (val) {
                          setState(() {
                            _config = _config.copyWith(saturationMultiplier: val);
                          });
                        },
                      ),

                      const SizedBox(height: 22),

                      // 4. Target Synchronization Toggles
                      const Text(
                        'HARMONIZATION TARGETS',
                        style: TextStyle(
                          color: Color(0xFF00E5FF),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),

                      _buildSwitchTile(
                        icon: Icons.auto_awesome_rounded,
                        title: 'Sync Interactive Particle FX',
                        subtitle: 'Tints touch ripples and stardust to match extracted Aura',
                        value: _config.syncParticles,
                        onChanged: (val) {
                          setState(() {
                            _config = _config.copyWith(syncParticles: val);
                          });
                        },
                      ),
                      const SizedBox(height: 8),

                      _buildSwitchTile(
                        icon: Icons.format_quote_rounded,
                        title: 'Sync Kinetic Quote Typography',
                        subtitle: 'Applies active Aura gradient accents to quote banners',
                        value: _config.syncKineticQuotes,
                        onChanged: (val) {
                          setState(() {
                            _config = _config.copyWith(syncKineticQuotes: val);
                          });
                        },
                      ),
                      const SizedBox(height: 8),

                      _buildSwitchTile(
                        icon: Icons.lock_clock_rounded,
                        title: 'Sync Lock Screen Clock & Accents',
                        subtitle: 'Tints lock screen typography with vibrant luminescence',
                        value: _config.syncLockScreen,
                        onChanged: (val) {
                          setState(() {
                            _config = _config.copyWith(syncLockScreen: val);
                          });
                        },
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // Bottom Action Dock
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF14141B),
                    border: Border(
                      top: BorderSide(color: Colors.white10),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Reset to Default button
                      TextButton.icon(
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Reset Defaults'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white70,
                        ),
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          setState(() {
                            _config = AuraPaletteConfig.defaultConfig;
                          });
                        },
                      ),
                      const Spacer(),

                      // Apply button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E5FF),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        onPressed: () {
                          HapticFeedback.heavyImpact();
                          context
                              .read<WallpaperBloc>()
                              .add(UpdateAuraPaletteIntent(_config));
                          _safePop();
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_rounded, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Save Aura Theme',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaletteStudioCard(
    AuraResolvedPalette palette,
    MotivationalShort? wallpaper,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16161F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: palette.vibrantNeon.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: palette.vibrantNeon.withValues(alpha: 0.12),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.color_lens_rounded,
                size: 16,
                color: palette.vibrantNeon,
              ),
              const SizedBox(width: 8),
              const Flexible(
                child: Text(
                  'EXTRACTED 5-POINT AURA PALETTE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: palette.vibrantNeon.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _config.preset.name.toUpperCase(),
                  style: TextStyle(
                    color: palette.vibrantNeon,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Swatches Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSwatchItem(
                label: 'Dominant',
                color: palette.dominant,
              ),
              _buildSwatchItem(
                label: 'Vibrant',
                color: palette.vibrantNeon,
              ),
              _buildSwatchItem(
                label: 'Harmonic',
                color: palette.harmonicSecondary,
              ),
              _buildSwatchItem(
                label: 'OLED Shadow',
                color: palette.deepOledTone,
              ),
              _buildSwatchItem(
                label: 'Glow',
                color: palette.etherealGlow,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Copy hint
          Center(
            child: Text(
              'Tap any swatch to copy HEX code to clipboard',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwatchItem({
    required String label,
    required Color color,
  }) {
    final hex = _formatColorHex(color);
    return InkWell(
      onTap: () => _copyToClipboard(hex, label),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white24,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              hex,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 9,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetTile(AuraThemePreset preset) {
    final isSelected = _config.preset == preset;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected ? const Color(0xFF1E1E2A) : const Color(0xFF15151D),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _config = _config.copyWith(preset: preset);
            });
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF00E5FF)
                    : Colors.white.withValues(alpha: 0.08),
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                // Icon Badge
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF00E5FF).withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    preset.icon,
                    color: isSelected ? const Color(0xFF00E5FF) : Colors.white70,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Title & Description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              preset.displayName,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Dual color preview indicator
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [preset.primaryAccent, preset.secondaryAccent],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        preset.description,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Checkmark
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF00E5FF),
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliderTile({
    required String label,
    required String valueDisplay,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF15151D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                valueDisplay,
                style: const TextStyle(
                  color: Color(0xFF00E5FF),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF00E5FF),
              inactiveTrackColor: Colors.white12,
              thumbColor: const Color(0xFF00E5FF),
              overlayColor: const Color(0xFF00E5FF).withValues(alpha: 0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              trackHeight: 3,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Material(
      color: const Color(0xFF15151D),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white70, size: 20),
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
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              activeThumbColor: const Color(0xFF00E5FF),
              activeTrackColor: const Color(0xFF00E5FF).withValues(alpha: 0.35),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
