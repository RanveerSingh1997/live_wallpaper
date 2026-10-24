import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/wallpaper_bloc.dart';
import '../blocs/wallpaper_intent.dart';
import '../blocs/wallpaper_state.dart';
import '../core/core.dart';
import '../models/gesture_control_config.dart';
import '../widgets/interactive_gesture_canvas.dart';

/// Modal bottom sheet allowing users to customize touch gestures, sensory haptics,
/// and contact ripple effects for Wallora live wallpapers.
class GestureControlSheet extends StatefulWidget {
  const GestureControlSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const GestureControlSheet(),
    );
  }

  @override
  State<GestureControlSheet> createState() => _GestureControlSheetState();
}

class _GestureControlSheetState extends State<GestureControlSheet> {
  late GestureControlConfig _config;
  String _lastDetectedEvent = 'Tap anywhere on the playground canvas below';

  @override
  void initState() {
    super.initState();
    final bloc = context.read<WallpaperBloc>();
    _config = bloc.state.gestureConfig;
  }

  void _safePop() {
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _updateConfig(GestureControlConfig newConfig) {
    setState(() {
      _config = newConfig;
    });
    context.read<WallpaperBloc>().add(UpdateGestureControlIntent(newConfig));
  }

  void _showActionPicker({
    required BuildContext context,
    required String title,
    required GestureAction currentAction,
    required void Function(GestureAction selected) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Material(
          color: AppColors.modalBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.70,
              ),
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
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: GestureAction.values.length,
                      separatorBuilder: (ctx, i) =>
                          const Divider(color: Colors.white10, height: 1),
                      itemBuilder: (ctx, index) {
                        final action = GestureAction.values[index];
                        final isSelected = action == currentAction;

                        return Material(
                          color: isSelected
                              ? AppColors.neonCyan.withAlpha(35)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: ListTile(
                            leading: Icon(
                              action.icon,
                              color: isSelected
                                  ? AppColors.neonCyan
                                  : Colors.white60,
                              size: 22,
                            ),
                            title: Text(
                              action.label,
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.neonCyan
                                    : Colors.white,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              action.description,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.neonCyan,
                                    size: 20,
                                  )
                                : null,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              onSelected(action);
                              if (sheetContext.mounted &&
                                  Navigator.of(sheetContext).canPop()) {
                                Navigator.of(sheetContext).pop();
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showResetConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.modalBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.restart_alt_rounded, color: AppColors.neonCyan),
            SizedBox(width: 12),
            Text(
              'Reset Gesture Controls',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: const Text(
          'Restore gesture trigger actions, haptic intensity, and touch contact ripples back to factory defaults?',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (dialogCtx.mounted && Navigator.of(dialogCtx).canPop()) {
                Navigator.of(dialogCtx).pop();
              }
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonCyan,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              context
                  .read<WallpaperBloc>()
                  .add(const ResetGestureControlIntent());
              setState(() {
                _config = GestureControlConfig.defaultConfig;
              });
              if (dialogCtx.mounted && Navigator.of(dialogCtx).canPop()) {
                Navigator.of(dialogCtx).pop();
              }
            },
            child: const Text(
              'Reset to Defaults',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WallpaperBloc, WallpaperState>(
      builder: (context, state) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.90,
          decoration: const BoxDecoration(
            color: AppColors.modalBackground,
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
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),

                // Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              AppColors.neonCyan.withAlpha((0.15 * 255).round()),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.touch_app_rounded,
                          color: AppColors.neonCyan,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Interactive Gesture Studio',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Touch triggers, sensory haptics & ripple FX',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: Colors.white70),
                        onPressed: _safePop,
                      ),
                    ],
                  ),
                ),

                const Divider(color: Colors.white10, height: 1),

                // Main Scrollable Studio Body
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // SECTION: Interactive Tactile Playground
                      _buildSectionHeader('TACTILE TOUCH PLAYGROUND'),
                      const SizedBox(height: 10),
                      _buildPlaygroundCard(state),

                      const SizedBox(height: 24),

                      // SECTION: Master Gestures Toggle
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.neonCyan
                                    .withAlpha((0.15 * 255).round()),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.gesture_rounded,
                                color: AppColors.neonCyan,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Enable Gesture Triggers',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Respond to double-taps, triple-taps & presses',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              value: _config.isGesturesEnabled,
                              activeThumbColor: AppColors.neonCyan,
                              activeTrackColor: AppColors.neonCyan
                                  .withAlpha((0.35 * 255).round()),
                              onChanged: (val) {
                                HapticFeedback.selectionClick();
                                _updateConfig(
                                    _config.copyWith(isGesturesEnabled: val));
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // SECTION: Gesture Trigger Mappings
                      _buildSectionHeader('GESTURE ACTION MAPPINGS'),
                      const SizedBox(height: 10),
                      _buildActionTile(
                        icon: Icons.touch_app_rounded,
                        title: 'Double-Tap Action',
                        action: _config.doubleTapAction,
                        onTap: () {
                          _showActionPicker(
                            context: context,
                            title: 'Double-Tap Action',
                            currentAction: _config.doubleTapAction,
                            onSelected: (selected) {
                              _updateConfig(
                                  _config.copyWith(doubleTapAction: selected));
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildActionTile(
                        icon: Icons.repeat_rounded,
                        title: 'Triple-Tap Action',
                        action: _config.tripleTapAction,
                        onTap: () {
                          _showActionPicker(
                            context: context,
                            title: 'Triple-Tap Action',
                            currentAction: _config.tripleTapAction,
                            onSelected: (selected) {
                              _updateConfig(
                                  _config.copyWith(tripleTapAction: selected));
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildActionTile(
                        icon: Icons.pan_tool_rounded,
                        title: 'Long-Press Action',
                        action: _config.longPressAction,
                        onTap: () {
                          _showActionPicker(
                            context: context,
                            title: 'Long-Press Action',
                            currentAction: _config.longPressAction,
                            onSelected: (selected) {
                              _updateConfig(
                                  _config.copyWith(longPressAction: selected));
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildActionTile(
                        icon: Icons.swipe_down_rounded,
                        title: 'Two-Finger Swipe Down',
                        action: _config.twoFingerSwipeDownAction,
                        onTap: () {
                          _showActionPicker(
                            context: context,
                            title: 'Two-Finger Swipe Down',
                            currentAction: _config.twoFingerSwipeDownAction,
                            onSelected: (selected) {
                              _updateConfig(_config.copyWith(
                                  twoFingerSwipeDownAction: selected));
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // SECTION: Tactile Haptic Intensity
                      _buildSectionHeader('SENSORY HAPTIC INTENSITY'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: HapticFeedbackProfile.values.map((profile) {
                          final isSelected = _config.hapticProfile == profile;
                          return ChoiceChip(
                            label: Text(profile.displayName),
                            selected: isSelected,
                            selectedColor: AppColors.neonCyan,
                            backgroundColor: AppColors.cardSurface,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontSize: 12,
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.neonCyan
                                  : Colors.white12,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                switch (profile) {
                                  case HapticFeedbackProfile.subtle:
                                    HapticFeedback.lightImpact();
                                    break;
                                  case HapticFeedbackProfile.medium:
                                    HapticFeedback.mediumImpact();
                                    break;
                                  case HapticFeedbackProfile.firm:
                                    HapticFeedback.heavyImpact();
                                    break;
                                  case HapticFeedbackProfile.selection:
                                    HapticFeedback.selectionClick();
                                    break;
                                  case HapticFeedbackProfile.off:
                                    break;
                                }
                                _updateConfig(
                                    _config.copyWith(hapticProfile: profile));
                              }
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      // SECTION: Touch Visual Effect
                      _buildSectionHeader('TOUCH CONTACT VISUAL FX'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: TouchVisualEffect.values.map((effect) {
                          final isSelected =
                              _config.touchVisualEffect == effect;
                          return ChoiceChip(
                            avatar: Icon(
                              effect.icon,
                              size: 16,
                              color: isSelected
                                  ? Colors.black
                                  : AppColors.neonCyan,
                            ),
                            label: Text(effect.displayName),
                            selected: isSelected,
                            selectedColor: AppColors.neonCyan,
                            backgroundColor: AppColors.cardSurface,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontSize: 12,
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.neonCyan
                                  : Colors.white12,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                HapticFeedback.selectionClick();
                                _updateConfig(_config.copyWith(
                                    touchVisualEffect: effect));
                              }
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      // SECTION: Ripple Color Harmony
                      _buildSectionHeader('CONTACT COLOR HARMONY'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: TouchColorMode.values.map((mode) {
                          final isSelected = _config.touchColorMode == mode;
                          final colorPreview = mode == TouchColorMode.auraSync
                              ? state.auraConfig.preset.primaryAccent
                              : mode.color;

                          return ChoiceChip(
                            avatar: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: colorPreview,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white70, width: 1),
                              ),
                            ),
                            label: Text(mode.displayName),
                            selected: isSelected,
                            selectedColor: AppColors.neonCyan,
                            backgroundColor: AppColors.cardSurface,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontSize: 12,
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.neonCyan
                                  : Colors.white12,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                HapticFeedback.selectionClick();
                                _updateConfig(
                                    _config.copyWith(touchColorMode: mode));
                              }
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 32),

                      // Reset Button
                      Center(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white60,
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.restart_alt_rounded, size: 18),
                          label: const Text(
                            'Reset to Default Gestures',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          onPressed: () =>
                              _showResetConfirmationDialog(context),
                        ),
                      ),
                      const SizedBox(height: 20),
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white54,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildPlaygroundCard(WallpaperState state) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.neonCyan.withAlpha((0.3 * 255).round()),
          width: 1.2,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.modalBackground,
            AppColors.darkBackground,
            state.auraConfig.preset.primaryAccent.withAlpha(20),
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background subtle grid lines
            Opacity(
              opacity: 0.12,
              child: CustomPaint(
                painter: _PlaygroundGridPainter(),
              ),
            ),

            // Live Interactive Gesture Canvas
            InteractiveGestureCanvas(
              config: _config,
              auraConfig: state.auraConfig,
              onDebugGesture: (event) {
                setState(() {
                  _lastDetectedEvent = event;
                });
              },
              onActionTriggered: (action) {
                setState(() {
                  _lastDetectedEvent = 'Triggered: ${action.label}';
                });
                context
                    .read<WallpaperBloc>()
                    .add(ExecuteGestureActionIntent(action));
              },
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha((0.65 * 255).round()),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.neonCyan
                              .withAlpha((0.4 * 255).round()),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.touch_app_rounded,
                            color: AppColors.neonCyan,
                            size: 15,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _lastDetectedEvent,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Double-tap, triple-tap, or hold to feel tactile response',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
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
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required GestureAction action,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.cardSurface,
      borderRadius: BorderRadius.circular(16),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white10),
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.neonCyan.withAlpha((0.15 * 255).round()),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.neonCyan, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        subtitle: Text(
          action.label,
          style: TextStyle(
            color: action.isEnabled ? AppColors.neonCyan : Colors.white38,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.white38,
          size: 14,
        ),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
      ),
    );
  }
}

class _PlaygroundGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 0.5;

    const step = 24.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
