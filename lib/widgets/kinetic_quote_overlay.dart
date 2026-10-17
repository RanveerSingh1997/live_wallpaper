import 'package:flutter/material.dart';
import '../models/motivational_short.dart';

class KineticQuoteOverlay extends StatelessWidget {
  final MotivationalShort short;
  final String effectiveQuote;
  final bool isCustomized;

  const KineticQuoteOverlay({
    super.key,
    required this.short,
    required this.effectiveQuote,
    this.isCustomized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.2),
            Colors.black.withValues(alpha: 0.85),
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category & Custom Tag Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: short.accentColor.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: short.accentColor.withValues(alpha: 0.8),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      size: 14,
                      color: short.accentColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      short.category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: short.accentColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (isCustomized) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'CUSTOM QUOTE',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),

          // Main Motivational Quote with Kinetic Outline & Shadow
          Text(
            '"$effectiveQuote"',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1.25,
              letterSpacing: -0.2,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.9),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
                Shadow(
                  color: short.accentColor.withValues(alpha: 0.4),
                  offset: const Offset(0, 0),
                  blurRadius: 16,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Author / Origin Line
          Row(
            children: [
              Container(
                width: 16,
                height: 2,
                color: short.accentColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  short.author,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                    color: Colors.white.withValues(alpha: 0.85),
                    shadows: const [
                      Shadow(
                        color: Colors.black,
                        offset: Offset(0, 1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
