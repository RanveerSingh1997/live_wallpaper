import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class WallpaperCollection extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final String badge;
  final IconData icon;
  final List<String> wallpaperIds;
  final List<Color> gradientColors;
  final bool isUserCreated;

  /// Compile-time constant icons supported for collections to ensure tree-shaking
  /// compatibility on Flutter Web, iOS, and Android.
  static const List<IconData> supportedIcons = [
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
    Icons.wallpaper_rounded,
    Icons.star_rounded,
    Icons.movie_rounded,
    Icons.music_note_rounded,
    Icons.fitness_center_rounded,
    Icons.lightbulb_rounded,
    Icons.flag_rounded,
    Icons.bolt_rounded,
    Icons.wb_sunny_rounded,
    Icons.nights_stay_rounded,
    Icons.play_arrow_rounded,
    Icons.queue_music_rounded,
    Icons.explore_rounded,
    Icons.photo_library_rounded,
    Icons.diamond_rounded,
    Icons.flare_rounded,
    Icons.blur_on_rounded,
  ];

  static IconData iconFromCodePoint(int? codePoint) {
    if (codePoint == null) return Icons.collections_bookmark_rounded;
    for (final icon in supportedIcons) {
      if (icon.codePoint == codePoint) {
        return icon;
      }
    }
    return Icons.collections_bookmark_rounded;
  }

  const WallpaperCollection({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.icon,
    required this.wallpaperIds,
    required this.gradientColors,
    this.isUserCreated = false,
  });

  WallpaperCollection copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? badge,
    IconData? icon,
    List<String>? wallpaperIds,
    List<Color>? gradientColors,
    bool? isUserCreated,
  }) {
    return WallpaperCollection(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      badge: badge ?? this.badge,
      icon: icon ?? this.icon,
      wallpaperIds: wallpaperIds ?? this.wallpaperIds,
      gradientColors: gradientColors ?? this.gradientColors,
      isUserCreated: isUserCreated ?? this.isUserCreated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'badge': badge,
      'iconCodePoint': icon.codePoint,
      'wallpaperIds': wallpaperIds,
      'gradientColors': gradientColors.map((c) => c.toARGB32()).toList(),
      'isUserCreated': isUserCreated,
    };
  }

  factory WallpaperCollection.fromJson(Map<String, dynamic> json) {
    final codePoint = json['iconCodePoint'] as int?;
    return WallpaperCollection(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? 'Custom Playlist',
      badge: json['badge'] as String? ?? 'PLAYLIST',
      icon: iconFromCodePoint(codePoint),
      wallpaperIds: (json['wallpaperIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      gradientColors: (json['gradientColors'] as List<dynamic>?)
              ?.map((c) => Color(c as int))
              .toList() ??
          const [Color(0xFF1B0B2E), Color(0xFF7C4DFF), Color(0xFF0D061A)],
      isUserCreated: json['isUserCreated'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        subtitle,
        badge,
        icon.codePoint,
        wallpaperIds,
        gradientColors,
        isUserCreated,
      ];
}
