import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../core/core.dart';
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
  final bool isVideo;
  final String? videoStreamUrl;
  final int durationSeconds;

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
    this.isVideo = false,
    this.videoStreamUrl,
    this.durationSeconds = 15,
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
    bool? isVideo,
    String? videoStreamUrl,
    int? durationSeconds,
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
      isVideo: isVideo ?? this.isVideo,
      videoStreamUrl: videoStreamUrl ?? this.videoStreamUrl,
      durationSeconds: durationSeconds ?? this.durationSeconds,
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

  /// Formatted initials for the author's avatar badge
  String get authorInitials {
    final name = authorName?.trim();
    if (name == null || name.isEmpty) return 'W';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

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
      'video_url': videoStreamUrl,
      'is_video': isVideo,
      'duration': durationSeconds,
    };
  }

  /// Deserializes a JSON map from Wallaza REST responses or Pixabay API
  factory WallazaCloudWallpaper.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('largeImageURL') ||
        json.containsKey('webformatURL') ||
        json.containsKey('videos') ||
        json.containsKey('previewURL')) {
      return WallazaCloudWallpaper.fromPixabayJson(json);
    }

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

    final String? videoUrl = json['video_url'] as String?;
    final bool isVideoParsed = (json['is_video'] as bool?) ??
        (videoUrl != null && videoUrl.isNotEmpty) ||
        (json['category'] as String? ?? '').toLowerCase() == 'live' ||
        tagsList.any((t) => t.toLowerCase() == 'live' || t.toLowerCase() == 'video');

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
      isVideo: isVideoParsed,
      videoStreamUrl: videoUrl,
      durationSeconds: (json['duration'] as num?)?.toInt() ?? 15,
    );
  }

  /// Parses a raw hit from the Pixabay API (photos, vectors, illustrations, videos).
  /// Conforms to https://pixabay.com/api/docs/#api_support
  factory WallazaCloudWallpaper.fromPixabayJson(Map<String, dynamic> json) {
    final int id = json['id'] is int
        ? json['id'] as int
        : int.tryParse(json['id'].toString()) ?? 0;
    final String tags = json['tags'] as String? ?? 'wallpaper';
    final List<String> tagList = tags
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    final String firstTag = tagList.isNotEmpty ? tagList.first : 'Wallpaper';
    final String title = firstTag.isNotEmpty
        ? '${firstTag[0].toUpperCase()}${firstTag.substring(1)} Wallpaper'
        : 'Pixabay Wallpaper';

    final bool isVideo = json.containsKey('videos') ||
        json['type'] == 'film' ||
        json['type'] == 'animation';

    String url = '';
    String thumbnailUrl = '';
    String? videoUrl;
    String resolution = '3840x2160';
    int fileSizeBytes = 3500000;
    int duration = 0;

    if (isVideo) {
      final videos = json['videos'] as Map<String, dynamic>?;
      final large = videos?['large'] as Map<String, dynamic>?;
      final medium = videos?['medium'] as Map<String, dynamic>?;
      final small = videos?['small'] as Map<String, dynamic>?;

      videoUrl = large?['url'] as String? ??
          medium?['url'] as String? ??
          small?['url'] as String?;
      thumbnailUrl = large?['thumbnail'] as String? ??
          medium?['thumbnail'] as String? ??
          (json['userImageURL'] as String? ?? '');
      url = thumbnailUrl;
      final int width = (large?['width'] as num?)?.toInt() ?? 1920;
      final int height = (large?['height'] as num?)?.toInt() ?? 1080;
      resolution = '${width}x$height';
      fileSizeBytes = (large?['size'] as num?)?.toInt() ?? 8000000;
      duration = (json['duration'] as num?)?.toInt() ?? 15;
    } else {
      url = json['largeImageURL'] as String? ??
          json['fullHDURL'] as String? ??
          json['imageURL'] as String? ??
          json['webformatURL'] as String? ??
          '';
      thumbnailUrl = json['webformatURL'] as String? ??
          json['previewURL'] as String? ??
          url;
      final int width = (json['imageWidth'] as num?)?.toInt() ?? 3840;
      final int height = (json['imageHeight'] as num?)?.toInt() ?? 2160;
      resolution = '${width}x$height';
      fileSizeBytes = (json['imageSize'] as num?)?.toInt() ?? 3500000;
    }

    String category = 'Abstract';
    for (final tag in tagList) {
      final t = tag.toLowerCase();
      if (t == 'nature' ||
          t == 'landscape' ||
          t == 'mountain' ||
          t == 'forest' ||
          t == 'ocean') {
        category = 'Nature';
        break;
      } else if (t == 'space' ||
          t == 'galaxy' ||
          t == 'stars' ||
          t == 'sky' ||
          t == 'astronomy') {
        category = 'Space';
        break;
      } else if (t == 'cyberpunk' ||
          t == 'neon' ||
          t == 'city' ||
          t == 'urban' ||
          t == 'technology') {
        category = 'Cyberpunk';
        break;
      } else if (t == 'amoled' ||
          t == 'dark' ||
          t == 'black' ||
          t == 'minimalist') {
        category = 'AMOLED';
        break;
      } else if (t == 'anime' || t == 'illustration' || t == 'art') {
        category = 'Anime';
        break;
      }
    }
    if (isVideo && category == 'Abstract') {
      category = 'Live';
    }

    return WallazaCloudWallpaper(
      id: 'pixabay_$id',
      title: title,
      description:
          'Pixabay ${json['type'] ?? (isVideo ? 'video' : 'photo')} by ${json['user'] ?? 'Creator'}',
      url: url,
      thumbnailUrl: thumbnailUrl,
      category: category,
      tags: tagList,
      resolution: resolution,
      fileSizeBytes: fileSizeBytes,
      downloads: (json['downloads'] as num?)?.toInt() ?? 0,
      favorites: (json['likes'] as num?)?.toInt() ?? 0,
      authorName: json['user'] as String? ?? 'Pixabay Artist',
      authorUsername: json['user'] as String?,
      authorAvatarUrl: json['userImageURL'] as String?,
      createdAt: DateTime.now(),
      isVideo: isVideo,
      videoStreamUrl: videoUrl,
      durationSeconds: duration,
    );
  }

  /// Converts this cloud wallpaper into a Wallora [MotivationalShort] format,
  /// unlocking full compatibility with wallpaper setting, spatial parallax,
  /// kinetic particles, lock screen studio, and dynamic aura harmonizer.
  MotivationalShort toMotivationalShort() {
    Color accent;
    switch (category.toLowerCase()) {
      case 'live':
      case 'cyberpunk':
        accent = AppColors.neonCyan;
        break;
      case 'nature':
        accent = AppColors.auroraEmerald;
        break;
      case 'space':
      case 'galaxy':
        accent = AppColors.auroraViolet;
        break;
      case 'amoled':
      case 'minimalist':
        accent = AppColors.textPrimary;
        break;
      case 'anime':
        accent = AppColors.plasmaPink;
        break;
      case 'abstract':
      default:
        accent = AppColors.sunsetAmber;
        break;
    }

    return MotivationalShort(
      id: id.startsWith('cloud_') ? id : 'cloud_$id',
      title: title,
      quote: title,
      author: authorName ?? 'Wallaza Cloud Artist',
      category: category,
      videoAssetPath: isVideo ? (videoStreamUrl ?? url) : '',
      imageUrl: isVideo ? thumbnailUrl : url,
      accentColor: accent,
      tags: tags.join(', '),
      hasTextByDefault: false,
      mood: isVideo ? 'Live Motion 60FPS' : 'Cloud Discover',
      isLive: isVideo,
      resolution: '$resolution (Ultra HD)',
      fileSizeBytes: fileSizeBytes,
      durationSeconds: isVideo ? durationSeconds : 0,
      trueBlackPercentage: isAmoled ? 85 : 15,
      gradientColors: [
        accent.withAlpha(200),
        AppColors.obsidianBlack,
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
        isVideo,
        videoStreamUrl,
        durationSeconds,
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
    WallazaCloudWallpaper(
      id: 'wlz_live_cyber_07',
      title: 'Neo-Tokyo Holographic Neon Rain',
      description: 'Continuous 4K 60fps holographic raindrops falling across neon skyscraper billboards',
      url: 'https://images.unsplash.com/photo-1542751371-adc38448a05e?q=80&w=3840&auto=format&fit=crop',
      thumbnailUrl: 'https://images.unsplash.com/photo-1542751371-adc38448a05e?q=80&w=800&auto=format&fit=crop',
      videoStreamUrl: 'https://assets.mixkit.co/videos/preview/mixkit-futuristic-city-with-flying-traffic-at-night-41546-large.mp4',
      category: 'Live',
      tags: ['live', 'motion', 'video', 'cyberpunk', 'neon', 'rain', '4k', 'loop'],
      resolution: '3840x2160',
      fileSizeBytes: 8900000,
      downloads: 54100,
      favorites: 22300,
      isVideo: true,
      durationSeconds: 15,
      authorName: 'Kenji Takahashi',
      authorUsername: 'kenjit',
    ),
    WallazaCloudWallpaper(
      id: 'wlz_live_cosmic_08',
      title: 'Hyperdrive Stellar Singularity',
      description: 'Mesmerizing looping warp drive through glowing cosmic nebula clouds',
      url: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?q=80&w=3840&auto=format&fit=crop',
      thumbnailUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?q=80&w=800&auto=format&fit=crop',
      videoStreamUrl: 'https://assets.mixkit.co/videos/preview/mixkit-flying-through-a-starfield-in-space-41544-large.mp4',
      category: 'Live',
      tags: ['live', 'motion', 'video', 'space', 'nebula', 'cosmic', 'hyperspace', '4k'],
      resolution: '3840x2160',
      fileSizeBytes: 9800000,
      downloads: 68900,
      favorites: 28400,
      isVideo: true,
      durationSeconds: 15,
      authorName: 'Aria Sterling',
      authorUsername: 'ariacosmos',
    ),
    WallazaCloudWallpaper(
      id: 'wlz_live_aurora_09',
      title: 'Aurora Borealis Liquid Ribbon Waves',
      description: 'Fluid emerald and violet aurora ribbons shimmering across polar night skies',
      url: 'https://images.unsplash.com/photo-1541701494587-cb58502866ab?q=80&w=3840&auto=format&fit=crop',
      thumbnailUrl: 'https://images.unsplash.com/photo-1541701494587-cb58502866ab?q=80&w=800&auto=format&fit=crop',
      videoStreamUrl: 'https://assets.mixkit.co/videos/preview/mixkit-ink-swirling-in-water-in-slow-motion-41551-large.mp4',
      category: 'Live',
      tags: ['live', 'motion', 'video', 'aurora', 'nature', 'fluid', 'emerald', '4k'],
      resolution: '3840x2160',
      fileSizeBytes: 7600000,
      downloads: 49800,
      favorites: 18700,
      isVideo: true,
      durationSeconds: 12,
      authorName: 'Vance Calloway',
      authorUsername: 'vancefluid',
    ),
  ];
}
