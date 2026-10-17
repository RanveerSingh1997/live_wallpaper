import 'package:flutter/material.dart';

class WallpaperCollection {
  final String id;
  final String title;
  final String subtitle;
  final String badge;
  final IconData icon;
  final List<String> wallpaperIds;
  final List<Color> gradientColors;

  const WallpaperCollection({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.icon,
    required this.wallpaperIds,
    required this.gradientColors,
  });
}
