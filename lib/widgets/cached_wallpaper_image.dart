import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'shimmer_loading.dart';

/// Ultra-high performance cached image component for Wallora.
/// Encapsulates LRU disk and memory caching via [CachedNetworkImage],
/// downsampling memory buffers ([memCacheWidth]) to eliminate RAM bloat and frame drop,
/// with obsidian shimmer preloading and graceful fallbacks for local assets/files.
class CachedWallpaperImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final int? maxWidthDiskCache;
  final int? maxHeightDiskCache;
  final ColorFilter? colorFilter;
  final Alignment alignment;
  final Duration fadeInDuration;

  const CachedWallpaperImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
    this.memCacheWidth,
    this.memCacheHeight,
    this.maxWidthDiskCache,
    this.maxHeightDiskCache,
    this.colorFilter,
    this.alignment = Alignment.center,
    this.fadeInDuration = const Duration(milliseconds: 220),
  });

  /// Factory preset for compact grid and carousel thumbnails (downsampled for zero frame-drop).
  factory CachedWallpaperImage.thumbnail({
    Key? key,
    required String imageUrl,
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    Widget? placeholder,
    Widget? errorWidget,
    ColorFilter? colorFilter,
  }) {
    return CachedWallpaperImage(
      key: key,
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      memCacheWidth: 600,
      maxWidthDiskCache: 1080,
      placeholder: placeholder,
      errorWidget: errorWidget,
      colorFilter: colorFilter,
    );
  }

  /// Factory preset for full-screen immersive view and lock screen preview sheet.
  factory CachedWallpaperImage.fullScreen({
    Key? key,
    required String imageUrl,
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    Widget? placeholder,
    Widget? errorWidget,
    ColorFilter? colorFilter,
  }) {
    return CachedWallpaperImage(
      key: key,
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      memCacheWidth: 1440,
      maxWidthDiskCache: 2160,
      placeholder: placeholder,
      errorWidget: errorWidget,
      colorFilter: colorFilter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cleanUrl = imageUrl.trim();
    if (cleanUrl.isEmpty) {
      return errorWidget ?? const SizedBox.shrink();
    }

    final isNetwork =
        cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://');

    if (isNetwork) {
      Widget image = CachedNetworkImage(
        imageUrl: cleanUrl,
        fit: fit,
        width: width,
        height: height,
        alignment: alignment,
        memCacheWidth: memCacheWidth,
        memCacheHeight: memCacheHeight,
        maxWidthDiskCache: maxWidthDiskCache,
        maxHeightDiskCache: maxHeightDiskCache,
        fadeInDuration: fadeInDuration,
        fadeOutDuration: const Duration(milliseconds: 150),
        placeholder: (context, url) {
          if (placeholder != null) return placeholder!;
          return const ShimmerLoading(
            child: ShimmerSkeletonBox(
              width: double.infinity,
              height: double.infinity,
              borderRadius: 0,
            ),
          );
        },
        errorWidget: (context, url, error) {
          return errorWidget ?? const SizedBox.shrink();
        },
      );

      if (colorFilter != null) {
        image = ColorFiltered(colorFilter: colorFilter!, child: image);
      }

      return image;
    }

    // Local asset fallback
    if (cleanUrl.startsWith('assets/')) {
      Widget image = Image.asset(
        cleanUrl,
        fit: fit,
        width: width,
        height: height,
        alignment: alignment,
        errorBuilder: (_, _, _) => errorWidget ?? const SizedBox.shrink(),
      );
      if (colorFilter != null) {
        image = ColorFiltered(colorFilter: colorFilter!, child: image);
      }
      return image;
    }

    // Local file fallback (mobile/desktop)
    if (!kIsWeb &&
        (cleanUrl.startsWith('/') || cleanUrl.startsWith('file://'))) {
      final path = cleanUrl.startsWith('file://')
          ? cleanUrl.replaceFirst('file://', '')
          : cleanUrl;
      Widget image = Image.file(
        File(path),
        fit: fit,
        width: width,
        height: height,
        alignment: alignment,
        errorBuilder: (_, _, _) => errorWidget ?? const SizedBox.shrink(),
      );
      if (colorFilter != null) {
        image = ColorFiltered(colorFilter: colorFilter!, child: image);
      }
      return image;
    }

    // Fallback for web file or other path
    return Image.network(
      cleanUrl,
      fit: fit,
      width: width,
      height: height,
      alignment: alignment,
      errorBuilder: (_, _, _) => errorWidget ?? const SizedBox.shrink(),
    );
  }
}
