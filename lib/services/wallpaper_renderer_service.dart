import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/motivational_short.dart';
import '../models/wallpaper_effect_config.dart';

class WallpaperRendererService {
  /// Renders a crisp 1080x1920 wallpaper with custom typography, ambient gradients, and effects.
  /// Saves the rendered PNG to cache and returns the local File.
  static Future<File> renderWallpaperToFile({
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
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()));

    // 1. Draw rich background gradient
    final gradientColors = wallpaper.gradientColors.isNotEmpty
        ? wallpaper.gradientColors
        : [
            wallpaper.accentColor.withValues(alpha: 0.35),
            const Color(0xFF141418),
            Colors.black,
          ];

    final bgPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(width / 2, 0),
        Offset(width / 2, height.toDouble()),
        gradientColors,
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()), bgPaint);

    // 2. Apply Custom Visual Effects (Tints & Filters)
    if (effectConfig != null && !effectConfig.isDefault) {
      if (effectConfig.colorFilterPreset == 'noir') {
        final noirPaint = Paint()
          ..colorFilter = const ColorFilter.mode(Colors.black, BlendMode.saturation);
        canvas.drawRect(Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()), noirPaint);
      } else if (effectConfig.colorFilterPreset == 'cyber_cyan') {
        final tintPaint = Paint()
          ..colorFilter = const ColorFilter.mode(Color(0xFF00E5FF), BlendMode.color);
        canvas.drawRect(Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()), tintPaint);
      } else if (effectConfig.colorFilterPreset == 'sunset_amber') {
        final tintPaint = Paint()
          ..colorFilter = const ColorFilter.mode(Color(0xFFFF5722), BlendMode.color);
        canvas.drawRect(Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()), tintPaint);
      } else if (effectConfig.colorFilterPreset == 'matrix_emerald') {
        final tintPaint = Paint()
          ..colorFilter = const ColorFilter.mode(Color(0xFF00E676), BlendMode.color);
        canvas.drawRect(Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()), tintPaint);
      } else if (effectConfig.colorFilterPreset == 'aurora_violet') {
        final tintPaint = Paint()
          ..colorFilter = const ColorFilter.mode(Color(0xFFD500F9), BlendMode.color);
        canvas.drawRect(Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()), tintPaint);
      }
    }

    // 3. Draw subtle dark ambient vignette top and bottom
    final double vignetteAlpha = (effectConfig != null && effectConfig.vignetteStrength > 0)
        ? (0.65 + effectConfig.vignetteStrength * 0.3).clamp(0.0, 0.98)
        : 0.65;

    final vignettePaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(width / 2, 0),
        Offset(width / 2, height.toDouble()),
        [
          Colors.black.withValues(alpha: vignetteAlpha),
          Colors.transparent,
          Colors.black.withValues(alpha: (vignetteAlpha + 0.15).clamp(0.0, 0.98)),
        ],
        [0.0, 0.45, 1.0],
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()), vignettePaint);

    // 3. Draw Category Pill Badge
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

    final badgeY = height * 0.28;
    canvas.drawParagraph(badgeParagraph, Offset(0, badgeY));

    // 4. Draw Motivational Quote (if present)
    if (effectiveQuote.isNotEmpty) {
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
          shadows: [
            const ui.Shadow(
              color: Colors.black87,
              blurRadius: 18,
              offset: Offset(0, 4),
            ),
          ],
        ))
        ..addText('"$effectiveQuote"');

      final quoteParagraph = quoteParagraphBuilder.build()
        ..layout(ui.ParagraphConstraints(width: width * 0.82));

      final quoteX = (width - (width * 0.82)) / 2;
      final quoteY = height * 0.40;
      canvas.drawParagraph(quoteParagraph, Offset(quoteX, quoteY));

      // 5. Draw Accent Divider & Author
      final dividerPaint = Paint()
        ..color = wallpaper.accentColor.withValues(alpha: 0.6)
        ..strokeWidth = 3;

      final dividerY = quoteY + quoteParagraph.height + 40;
      canvas.drawLine(
        Offset(width / 2 - 50, dividerY),
        Offset(width / 2 + 50, dividerY),
        dividerPaint,
      );

      final authorParagraphBuilder = ui.ParagraphBuilder(
        ui.ParagraphStyle(
          textAlign: TextAlign.center,
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
      )
        ..pushStyle(ui.TextStyle(
          color: Colors.white70,
          letterSpacing: 2.0,
        ))
        ..addText(wallpaper.author.toUpperCase());

      final authorParagraph = authorParagraphBuilder.build()
        ..layout(ui.ParagraphConstraints(width: width.toDouble()));

      canvas.drawParagraph(authorParagraph, Offset(0, dividerY + 24));
    }

    // 6. Finalize picture and render to PNG
    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw Exception('Failed to generate PNG byte data from canvas.');
    }

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/rendered_wallpaper_${wallpaper.id}.png');
    await file.writeAsBytes(byteData.buffer.asUint8List(), flush: true);

    return file;
  }
}
