import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Represents a vertical live wallpaper short designed for continuous looping.
/// Can be a motivational quote short or a pure visual aesthetic/nature/car wallpaper.
class MotivationalShort extends Equatable {
  final String id;
  final String title;
  final String quote;
  final String author;
  final String category;
  final String videoAssetPath;
  final Color accentColor;
  final List<String> alternativeQuotes;
  final String tags;
  final bool hasTextByDefault;
  final String mood;

  const MotivationalShort({
    required this.id,
    required this.title,
    required this.quote,
    required this.author,
    required this.category,
    required this.videoAssetPath,
    required this.accentColor,
    this.alternativeQuotes = const [],
    required this.tags,
    this.hasTextByDefault = true,
    this.mood = 'Inspiring',
  });

  MotivationalShort copyWith({
    String? id,
    String? title,
    String? quote,
    String? author,
    String? category,
    String? videoAssetPath,
    Color? accentColor,
    List<String>? alternativeQuotes,
    String? tags,
    bool? hasTextByDefault,
    String? mood,
  }) {
    return MotivationalShort(
      id: id ?? this.id,
      title: title ?? this.title,
      quote: quote ?? this.quote,
      author: author ?? this.author,
      category: category ?? this.category,
      videoAssetPath: videoAssetPath ?? this.videoAssetPath,
      accentColor: accentColor ?? this.accentColor,
      alternativeQuotes: alternativeQuotes ?? this.alternativeQuotes,
      tags: tags ?? this.tags,
      hasTextByDefault: hasTextByDefault ?? this.hasTextByDefault,
      mood: mood ?? this.mood,
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
        accentColor,
        alternativeQuotes,
        tags,
        hasTextByDefault,
        mood,
      ];
}

/// Type alias for broader live wallpaper taxonomy
typedef LiveWallpaperItem = MotivationalShort;
