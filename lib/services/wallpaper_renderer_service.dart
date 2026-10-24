import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../core/core.dart';
import '../models/motivational_short.dart';
import '../models/wallpaper_effect_config.dart';

/// Abstract service contract for rendering high-resolution wallpaper canvases to local images.
/// Follows Dependency Inversion Principle (DIP).
abstract class WallpaperRendererService {
  factory WallpaperRendererService() = WallpaperRendererServiceImpl;

  Future<File> renderWallpaper({
    required MotivationalShort wallpaper,
    String? quoteOverride,
    WallpaperEffectConfig? effectConfig,
    int width = 1080,
    int height = 1920,
  });

  /// Static helper method preserved for backward compatibility.
  static Future<File> renderWallpaperToFile({
    required MotivationalShort wallpaper,
    String? quoteOverride,
    WallpaperEffectConfig? effectConfig,
    int width = 1080,
    int height = 1920,
  }) {
    return WallpaperRendererServiceImpl().renderWallpaper(
      wallpaper: wallpaper,
      quoteOverride: quoteOverride,
      effectConfig: effectConfig,
      width: width,
      height: height,
    );
  }
}

/// Concrete implementation of [WallpaperRendererService].
class WallpaperRendererServiceImpl implements WallpaperRendererService {
  @override
  Future<File> renderWallpaper({
    required MotivationalShort wallpaper,
    String? quoteOverride,
    WallpaperEffectConfig? effectConfig,
    int width = 1080,
    int height = 1920,
  }) async {
    final effectiveQuote = quoteOverride?.trim().isNotEmpty == true
        ? quoteOverride!.trim()
        : wallpaper.quote;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
        recorder, Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()));

    // 1. Draw rich background gradient
    final gradientColors = wallpaper.gradientColors.isNotEmpty
        ? wallpaper.gradientColors
        : [
            wallpaper.accentColor.withValues(alpha: 0.35),
            AppColors.darkSurface,
            Colors.black,
          ];

    final bgPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(width / 2, 0),
        Offset(width / 2, height.toDouble()),
        gradientColors,
      );
    canvas.drawRect(
        Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()), bgPaint);

    // 2. Apply Custom Visual Effects (Tints & Filters)
    if (effectConfig != null && !effectConfig.isDefault) {
      if (effectConfig.colorFilterPreset == 'noir') {
        final noirPaint = Paint()
          ..colorFilter =
              const ColorFilter.mode(Colors.black, BlendMode.saturation);
        canvas.drawRect(
            Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
            noirPaint);
      } else if (effectConfig.colorFilterPreset == 'cyber_cyan') {
        final tintPaint = Paint()
          ..colorFilter =
              const ColorFilter.mode(AppColors.neonCyan, BlendMode.color);
        canvas.drawRect(
            Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
            tintPaint);
      } else if (effectConfig.colorFilterPreset == 'sunset_amber') {
        final tintPaint = Paint()
          ..colorFilter =
              const ColorFilter.mode(AppColors.sunsetAmber, BlendMode.color);
        canvas.drawRect(
            Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
            tintPaint);
      } else if (effectConfig.colorFilterPreset == 'matrix_emerald') {
        final tintPaint = Paint()
          ..colorFilter =
              const ColorFilter.mode(AppColors.auroraEmerald, BlendMode.color);
        canvas.drawRect(
            Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
            tintPaint);
      } else if (effectConfig.colorFilterPreset == 'aurora_violet') {
        final tintPaint = Paint()
          ..colorFilter =
              const ColorFilter.mode(AppColors.auroraViolet, BlendMode.color);
        canvas.drawRect(
            Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
            tintPaint);
      }
    }

    // 3. Draw subtle dark ambient vignette top and bottom
    final double vignetteAlpha =
        (effectConfig != null && effectConfig.vignetteStrength > 0)
            ? (0.65 + effectConfig.vignetteStrength * 0.3).clamp(0.0, 0.98)
            : 0.65;

    final vignettePaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(width / 2, 0),
        Offset(width / 2, height.toDouble()),
        [
          Colors.black.withValues(alpha: vignetteAlpha),
          Colors.transparent,
          Colors.black
              .withValues(alpha: (vignetteAlpha + 0.15).clamp(0.0, 0.98)),
        ],
        [0.0, 0.45, 1.0],
      );
    canvas.drawRect(
        Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
        vignettePaint);

    // 4. Draw Category Pill Badge
    final categoryText = wallpaper.category.toUpperCase();
    final badgeParagraphBuilder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textAlign: TextAlign.center,
        fontSize: 24,
        fontWeight: FontWeight.w800,
      ),
    )
      ..pushStyle(ui.TextStyle(
        color: wallpaper.accentColor,
        letterSpacing: 3.5,
      ))
      ..addText(categoryText);

    final badgeParagraph = badgeParagraphBuilder.build()
      ..layout(ui.ParagraphConstraints(width: width.toDouble()));
    canvas.drawParagraph(badgeParagraph, const Offset(0, 360));

    // 5. Draw Central Quote Typography
    final quoteParagraphBuilder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textAlign: TextAlign.center,
        fontSize: 54,
        fontWeight: FontWeight.w900,
        height: 1.3,
      ),
    )
      ..pushStyle(ui.TextStyle(
        color: Colors.white,
        letterSpacing: 1.2,
        shadows: [
          Shadow(
            color: Colors.black87,
            offset: Offset(0, 6),
            blurRadius: 18,
          ),
        ],
      ))
      ..addText('"$effectiveQuote"');

    final quoteParagraph = quoteParagraphBuilder.build()
      ..layout(ui.ParagraphConstraints(width: width - 180));
    final double quoteTop = (height - quoteParagraph.height) / 2 - 40;
    canvas.drawParagraph(quoteParagraph, Offset(90, quoteTop));

    // 6. Draw Author Pill & Attribution
    final authorParagraphBuilder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textAlign: TextAlign.center,
        fontSize: 32,
        fontWeight: FontWeight.w600,
      ),
    )
      ..pushStyle(ui.TextStyle(
        color: Colors.white70,
        letterSpacing: 2.0,
      ))
      ..addText('— ${wallpaper.author}');

    final authorParagraph = authorParagraphBuilder.build()
      ..layout(ui.ParagraphConstraints(width: width.toDouble()));
    canvas.drawParagraph(
        authorParagraph, Offset(0, quoteTop + quoteParagraph.height + 40));

    // 7. Render Picture to Image -> PNG bytes
    final picture = recorder.endRecording();
    final ui.Image image = await picture.toImage(width, height);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw Exception('Failed to generate PNG byte data from canvas.');
    }

    final Uint8List pngBytes = byteData.buffer.asUint8List();

    // 8. Cache to file
    final tempDir = await getTemporaryDirectory();
    final file = File(
        '${tempDir.path}/rendered_${wallpaper.id}_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(pngBytes, flush: true);

    return file;
  }
}
