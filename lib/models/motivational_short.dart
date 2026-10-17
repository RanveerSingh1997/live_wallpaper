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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'quote': quote,
      'author': author,
      'category': category,
      'videoAssetPath': videoAssetPath,
      'imageUrl': imageUrl,
      'accentColor': accentColor.toARGB32(),
      'alternativeQuotes': alternativeQuotes,
      'tags': tags,
      'hasTextByDefault': hasTextByDefault,
      'mood': mood,
      'isLive': isLive,
      'resolution': resolution,
      'fileSizeBytes': fileSizeBytes,
      'durationSeconds': durationSeconds,
      'gradientColors': gradientColors.map((c) => c.toARGB32()).toList(),
    };
  }

  factory MotivationalShort.fromJson(Map<String, dynamic> json) {
    return MotivationalShort(
      id: json['id'] as String,
      title: json['title'] as String,
      quote: json['quote'] as String,
      author: json['author'] as String,
      category: json['category'] as String,
      videoAssetPath: json['videoAssetPath'] as String,
      imageUrl: json['imageUrl'] as String?,
      accentColor: Color(json['accentColor'] as int),
      alternativeQuotes: (json['alternativeQuotes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      tags: json['tags'] as String? ?? '',
      hasTextByDefault: json['hasTextByDefault'] as bool? ?? true,
      mood: json['mood'] as String? ?? 'Custom Creator',
      isLive: json['isLive'] as bool? ?? true,
      resolution: json['resolution'] as String? ?? '1080x1920 (FHD)',
      fileSizeBytes: json['fileSizeBytes'] as int? ?? 2500000,
      durationSeconds: json['durationSeconds'] as int? ?? 15,
      gradientColors: (json['gradientColors'] as List<dynamic>?)
              ?.map((c) => Color(c as int))
              .toList() ??
          const [],
    );
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
