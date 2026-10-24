import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/core.dart';
import '../models/motivational_short.dart';
import 'fluid_pressable.dart';

class ShortsActionRail extends StatelessWidget {
  final MotivationalShort short;
  final bool isFavorite;
  final bool isMuted;
  final bool isCurrentActive;
  final bool isApplying;
  final VoidCallback onApplyWallpaper;
  final VoidCallback onCustomizeQuote;
  final VoidCallback onToggleMute;
  final VoidCallback onToggleFavorite;
  final VoidCallback? onShare;

  const ShortsActionRail({
    super.key,
    required this.short,
    required this.isFavorite,
    required this.isMuted,
    required this.isCurrentActive,
    required this.isApplying,
    required this.onApplyWallpaper,
    required this.onCustomizeQuote,
    required this.onToggleMute,
    required this.onToggleFavorite,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 14, bottom: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Apply Live Wallpaper CTA
          _buildApplyButton(context),

          const SizedBox(height: 18),

          // Customize Quote Button
          _buildActionButton(
            icon: Icons.edit_note_rounded,
            label: 'Customize',
            accentColor: Colors.white,
            onTap: onCustomizeQuote,
          ),

          const SizedBox(height: 16),

          // Mute / Unmute Toggle
          _buildActionButton(
            icon: isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
            label: isMuted ? 'Muted' : 'Sound',
            accentColor: isMuted ? Colors.white70 : short.accentColor,
            onTap: onToggleMute,
          ),

          const SizedBox(height: 16),

          // Favorite Button
          _buildActionButton(
            icon: isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            label: isFavorite ? 'Saved' : 'Like',
            accentColor: isFavorite ? AppColors.favoriteRed : Colors.white,
            onTap: onToggleFavorite,
          ),

          const SizedBox(height: 16),

          // Info Button
          _buildActionButton(
            icon: Icons.info_outline_rounded,
            label: 'Info',
            accentColor: Colors.white70,
            onTap: () => _showShortInfo(context),
          ),

          if (onShare != null) ...[
            const SizedBox(height: 16),
            _buildActionButton(
              icon: Icons.ios_share_rounded,
              label: 'Share',
              accentColor: AppColors.electricBlue,
              onTap: onShare!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildApplyButton(BuildContext context) {
    return FluidPressable(
      onTap: isApplying
          ? null
          : () {
              HapticFeedback.mediumImpact();
              onApplyWallpaper();
            },
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isCurrentActive
                    ? [AppColors.auroraEmerald, AppColors.electricBlue]
                    : [short.accentColor, short.accentColor.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isCurrentActive ? AppColors.auroraEmerald : short.accentColor)
                      .withValues(alpha: 0.5),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: isApplying
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(
                      isCurrentActive ? Icons.check_circle_rounded : Icons.wallpaper_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isCurrentActive ? 'ACTIVE' : 'APPLY',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
              color: isCurrentActive ? AppColors.auroraEmerald : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return FluidPressable(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.45),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: accentColor,
              size: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black,
                  offset: Offset(0, 1),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showShortInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_rounded, color: short.accentColor),
                  const SizedBox(width: 8),
                  Text(
                    short.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow('Category', short.category),
              _buildInfoRow('Aspect Ratio', '9:16 Vertical Fullscreen'),
              _buildInfoRow('Loop Format', 'Seamless 60fps MP4 Loop'),
              _buildInfoRow('Screens Supported', 'Lock Screen & Home Screen'),
              _buildInfoRow('Platforms', 'Android & iPad / iOS'),
              _buildInfoRow('iPad Wallpaper', 'Photos > Share > Use as Wallpaper'),
              _buildInfoRow('Battery Optimization', 'Hardware-accelerated decode'),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
