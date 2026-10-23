import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'motivational_short.dart';

/// Representation of a cloud-streamed wallpaper entity from the Wallaza API.
class WallazaCloudWallpaper extends Equatable {
  final String id;
  final String title;
  final String description;
  final String url;
  final String thumbnailUrl;
  final String category;
  final List<String> tags;
  final String resolution;
  final int fileSizeBytes;
  final int downloads;
  final int favorites;
  final String? authorName;
  final String? authorUsername;
  final String? authorAvatarUrl;
  final DateTime? createdAt;

  const WallazaCloudWallpaper({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.thumbnailUrl,
    required this.category,
    this.tags = const [],
    this.resolution = '3840x2160',
    this.fileSizeBytes = 3500000,
    this.downloads = 0,
    this.favorites = 0,
    this.authorName,
    this.authorUsername,
    this.authorAvatarUrl,
    this.createdAt,
  });

  WallazaCloudWallpaper copyWith({
    String? id,
    String? title,
    String? description,
    String? url,
    String? thumbnailUrl,
    String? category,
    List<String>? tags,
    String? resolution,
    int? fileSizeBytes,
    int? downloads,
    int? favorites,
    String? authorName,
    String? authorUsername,
    String? authorAvatarUrl,
    DateTime? createdAt,
  }) {
    return WallazaCloudWallpaper(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      resolution: resolution ?? this.resolution,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      downloads: downloads ?? this.downloads,
      favorites: favorites ?? this.favorites,
      authorName: authorName ?? this.authorName,
      authorUsername: authorUsername ?? this.authorUsername,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Formatted human-readable file size (e.g. "3.5 MB")
  String get fileSizeFormatted {
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Whether this cloud wallpaper meets 4K UHD resolution criteria
  bool get is4K =>
      resolution.contains('3840') ||
      resolution.contains('4K') ||
      resolution.contains('4096');

  /// Whether this cloud wallpaper is tagged or categorized as AMOLED True-Black
  bool get isAmoled =>
      category.toLowerCase().contains('amoled') ||
      tags.any((t) => t.toLowerCase().contains('amoled'));

  /// Serializes this entity into a JSON map matching the Wallaza API specification
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'url': url,
      'thumbnail_url': thumbnailUrl,
      'category': category,
      'tags': tags,
      'resolution': resolution,
      'file_size': fileSizeBytes,
      'downloads': downloads,
      'favorites': favorites,
      'author': {
        'name': authorName,
        'username': authorUsername,
        'avatar_url': authorAvatarUrl,
      },
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Deserializes a JSON map from Wallaza REST responses
  factory WallazaCloudWallpaper.fromJson(Map<String, dynamic> json) {
    final authorMap = json['author'] as Map<String, dynamic>?;
    DateTime? parsedDate;
    if (json['created_at'] != null) {
      try {
        parsedDate = DateTime.parse(json['created_at'] as String);
      } catch (_) {}
    }

    final rawTags = json['tags'];
    List<String> tagsList = [];
    if (rawTags is List) {
      tagsList = rawTags.map((t) => t.toString()).toList();
    }

    return WallazaCloudWallpaper(
      id: json['id'] as String? ?? 'wallaza_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] as String? ?? 'Cloud Wallpaper',
      description: json['description'] as String? ?? '',
      url: json['url'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String? ?? (json['url'] as String? ?? ''),
      category: json['category'] as String? ?? 'General',
      tags: tagsList,
      resolution: json['resolution'] as String? ?? '3840x2160',
      fileSizeBytes: (json['file_size'] as num?)?.toInt() ?? 3500000,
      downloads: (json['downloads'] as num?)?.toInt() ?? 0,
      favorites: (json['favorites'] as num?)?.toInt() ?? 0,
      authorName: authorMap?['name'] as String?,
      authorUsername: authorMap?['username'] as String?,
      authorAvatarUrl: authorMap?['avatar_url'] as String?,
      createdAt: parsedDate,
    );
  }

  /// Converts this cloud wallpaper into a Wallora [MotivationalShort] format,
  /// unlocking full compatibility with wallpaper setting, spatial parallax,
  /// kinetic particles, lock screen studio, and dynamic aura harmonizer.
  MotivationalShort toMotivationalShort() {
    Color accent;
    switch (category.toLowerCase()) {
      case 'cyberpunk':
        accent = const Color(0xFF00E5FF); // Neon Cyan
        break;
      case 'nature':
        accent = const Color(0xFF00E676); // Neon Emerald
        break;
      case 'space':
      case 'galaxy':
        accent = const Color(0xFFD500F9); // Neon Violet
        break;
      case 'amoled':
      case 'minimalist':
        accent = const Color(0xFFFFFFFF); // Pure White
        break;
      case 'anime':
        accent = const Color(0xFFFF4081); // Vibrant Rose
        break;
      case 'abstract':
      default:
        accent = const Color(0xFFFF5722); // Vibrant Amber
        break;
    }

    return MotivationalShort(
      id: id.startsWith('cloud_') ? id : 'cloud_$id',
      title: title,
      quote: title,
      author: authorName ?? 'Wallaza Cloud Artist',
      category: category,
      videoAssetPath: '',
      imageUrl: url,
      accentColor: accent,
      tags: tags.join(', '),
      hasTextByDefault: false,
      mood: 'Cloud Discover',
      isLive: false,
      resolution: '$resolution (Ultra HD)',
      fileSizeBytes: fileSizeBytes,
      durationSeconds: 0,
      trueBlackPercentage: isAmoled ? 85 : 15,
      gradientColors: [
        accent.withAlpha(200),
        const Color(0xFF000000),
      ],
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        url,
        thumbnailUrl,
        category,
        tags,
        resolution,
        fileSizeBytes,
        downloads,
        favorites,
        authorName,
        authorUsername,
        authorAvatarUrl,
        createdAt,
      ];

  /// High-definition curated fallback cloud wallpapers to guarantee zero-latency
  /// discovery even during server boot or offline states.
  static const List<WallazaCloudWallpaper> curatedCloudLibrary = [
    WallazaCloudWallpaper(
      id: 'wlz_cyber_01',
      title: 'Neo-Tokyo Cyber Nexus',
      description: 'Ultra-dense neon highrises reflecting through holographic rain and aurora lasers',
      url: 'https://images.unsplash.com/photo-1542751371-adc38448a05e?q=80&w=3840&auto=format&fit=crop',
      thumbnailUrl: 'https://images.unsplash.com/photo-1542751371-adc38448a05e?q=80&w=800&auto=format&fit=crop',
      category: 'Cyberpunk',
      tags: ['cyberpunk', 'neon', 'city', 'night', '4k', 'futuristic'],
      resolution: '3840x2160',
      fileSizeBytes: 4210000,
      downloads: 48200,
      favorites: 12400,
      authorName: 'Kenji Takahashi',
      authorUsername: 'kenjit',
    ),
    WallazaCloudWallpaper(
      id: 'wlz_space_02',
      title: 'Cosmic Orion Stellar Nursery',
      description: 'Deep-space telescopic capture of ionizing interstellar dust clouds and baby stars',
      url: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?q=80&w=3840&auto=format&fit=crop',
      thumbnailUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?q=80&w=800&auto=format&fit=crop',
      category: 'Space',
      tags: ['space', 'nebula', 'orion', 'galaxy', 'stars', '4k'],
      resolution: '3840x2160',
      fileSizeBytes: 5120000,
      downloads: 62100,
      favorites: 19800,
      authorName: 'Aria Sterling',
      authorUsername: 'ariacosmos',
    ),
    WallazaCloudWallpaper(
      id: 'wlz_nature_03',
      title: 'Misty Alpine Emerald Ridge',
      description: 'Morning mountain mist cascading down sharp granite pinnacles into pine valleys',
      url: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=3840&auto=format&fit=crop',
      thumbnailUrl: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=800&auto=format&fit=crop',
      category: 'Nature',
      tags: ['nature', 'mountains', 'fog', 'forest', 'serene', 'landscape'],
      resolution: '3840x2160',
      fileSizeBytes: 3890000,
      downloads: 35100,
      favorites: 8900,
      authorName: 'Lukas Meyer',
      authorUsername: 'lukasm',
    ),
    WallazaCloudWallpaper(
      id: 'wlz_amoled_04',
      title: 'Obsidian Singularity & Event Horizon',
      description: 'Zero-nit pure true black field orbiting an iridescent neon accretion ring',
      url: 'https://images.unsplash.com/photo-1550684848-fac1c5b4e853?q=80&w=3840&auto=format&fit=crop',
      thumbnailUrl: 'https://images.unsplash.com/photo-1550684848-fac1c5b4e853?q=80&w=800&auto=format&fit=crop',
      category: 'AMOLED',
      tags: ['amoled', 'black', 'minimalist', 'dark', 'oled', 'clean'],
      resolution: '3840x2160',
      fileSizeBytes: 2150000,
      downloads: 89400,
      favorites: 31200,
      authorName: 'Eleni Thorne',
      authorUsername: 'eleni_dark',
    ),
    WallazaCloudWallpaper(
      id: 'wlz_abstract_05',
      title: 'Fluid Neon Aurora Chromatics',
      description: 'High-viscosity multi-chromatic fluid ribbons flowing through zero-gravity',
      url: 'https://images.unsplash.com/photo-1541701494587-cb58502866ab?q=80&w=3840&auto=format&fit=crop',
      thumbnailUrl: 'https://images.unsplash.com/photo-1541701494587-cb58502866ab?q=80&w=800&auto=format&fit=crop',
      category: 'Abstract',
      tags: ['abstract', 'fluid', 'neon', 'colors', 'vibrant', '4k'],
      resolution: '3840x2160',
      fileSizeBytes: 4450000,
      downloads: 41200,
      favorites: 14700,
      authorName: 'Vance Calloway',
      authorUsername: 'vancefluid',
    ),
    WallazaCloudWallpaper(
      id: 'wlz_anime_06',
      title: 'Cherry Blossom Sunset Shrine',
      description: 'Ethereal Japanese torii gate engulfed in glowing evening twilight and sakura petals',
      url: 'https://images.unsplash.com/photo-1528164344705-475426879c0d?q=80&w=3840&auto=format&fit=crop',
      thumbnailUrl: 'https://images.unsplash.com/photo-1528164344705-475426879c0d?q=80&w=800&auto=format&fit=crop',
      category: 'Anime',
      tags: ['anime', 'japan', 'sakura', 'shrine', 'sunset', 'aesthetic'],
      resolution: '3840x2160',
      fileSizeBytes: 3980000,
      downloads: 57300,
      favorites: 22100,
      authorName: 'Sakura K.',
      authorUsername: 'sakurak',
    ),
  ];
}
