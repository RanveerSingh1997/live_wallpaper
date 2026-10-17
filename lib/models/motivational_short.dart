import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Represents a wallpaper asset (either a dynamic looping Live Wallpaper or an Ultra-HD Static Wallpaper).
/// Can feature kinetic motivational typography or pure unobstructed visual aesthetics.
class MotivationalShort extends Equatable {
  final String id;
  final String title;
  final String quote;
  final String author;
  final String category;
  final String videoAssetPath;
  final String? imageUrl;
  final Color accentColor;
  final List<String> alternativeQuotes;
  final String tags;
  final bool hasTextByDefault;
  final String mood;
  final bool isLive;
  final String resolution;
  final int fileSizeBytes;
  final int durationSeconds;
  final List<Color> gradientColors;

  const MotivationalShort({
    required this.id,
    required this.title,
    required this.quote,
    required this.author,
    required this.category,
    required this.videoAssetPath,
    this.imageUrl,
    required this.accentColor,
    this.alternativeQuotes = const [],
    required this.tags,
    this.hasTextByDefault = true,
    this.mood = 'Inspiring',
    this.isLive = true,
    this.resolution = '1080x1920 (FHD)',
    this.fileSizeBytes = 2848208,
    this.durationSeconds = 15,
    this.gradientColors = const [],
  });

  MotivationalShort copyWith({
    String? id,
    String? title,
    String? quote,
    String? author,
    String? category,
    String? videoAssetPath,
    String? imageUrl,
    Color? accentColor,
    List<String>? alternativeQuotes,
    String? tags,
    bool? hasTextByDefault,
    String? mood,
    bool? isLive,
    String? resolution,
    int? fileSizeBytes,
    int? durationSeconds,
    List<Color>? gradientColors,
  }) {
    return MotivationalShort(
      id: id ?? this.id,
      title: title ?? this.title,
      quote: quote ?? this.quote,
      author: author ?? this.author,
      category: category ?? this.category,
      videoAssetPath: videoAssetPath ?? this.videoAssetPath,
      imageUrl: imageUrl ?? this.imageUrl,
      accentColor: accentColor ?? this.accentColor,
      alternativeQuotes: alternativeQuotes ?? this.alternativeQuotes,
      tags: tags ?? this.tags,
      hasTextByDefault: hasTextByDefault ?? this.hasTextByDefault,
      mood: mood ?? this.mood,
      isLive: isLive ?? this.isLive,
      resolution: resolution ?? this.resolution,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      gradientColors: gradientColors ?? this.gradientColors,
    );
  }

  /// Human-readable file size string (e.g. "2.7 MB")
  String get fileSizeFormatted {
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  List<Object?> get props => [
        id,
        title,
        quote,
        author,
        category,
        videoAssetPath,
        imageUrl,
        accentColor,
        alternativeQuotes,
        tags,
        hasTextByDefault,
        mood,
        isLive,
        resolution,
        fileSizeBytes,
        durationSeconds,
        gradientColors,
      ];
}

/// Type alias for broader wallpaper taxonomy
typedef LiveWallpaperItem = MotivationalShort;
typedef WallpaperItem = MotivationalShort;
