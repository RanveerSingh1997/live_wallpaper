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
    final codePoint = json['iconCodePoint'] as int? ??
        Icons.collections_bookmark_rounded.codePoint;
    return WallpaperCollection(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? 'Custom Playlist',
      badge: json['badge'] as String? ?? 'PLAYLIST',
      // ignore: non_const_argument_for_const_parameter
      icon: IconData(codePoint, fontFamily: 'MaterialIcons'),
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
