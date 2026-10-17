import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/wallpaper_bloc.dart';
import '../blocs/wallpaper_intent.dart';
import '../models/motivational_short.dart';

class QuoteStudioSheet extends StatefulWidget {
  final MotivationalShort short;
  final String currentQuote;

  const QuoteStudioSheet({
    super.key,
    required this.short,
    required this.currentQuote,
  });

  @override
  State<QuoteStudioSheet> createState() => _QuoteStudioSheetState();
}

class _QuoteStudioSheetState extends State<QuoteStudioSheet> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.currentQuote);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _saveQuote() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      context.read<WallpaperBloc>().add(
            UpdateCustomQuoteIntent(
              shortId: widget.short.id,
              newQuote: text,
            ),
          );
      Navigator.of(context).pop();
    }
  }

  void _resetQuote() {
    context.read<WallpaperBloc>().add(
          ResetCustomQuoteIntent(widget.short.id),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF18181B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customize Motivation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.short.accentColor,
                      ),
                    ),
                    Text(
                      widget.short.title,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: _resetQuote,
                  child: const Text(
                    'Reset',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Editable Quote Input
            TextField(
              controller: _textController,
              maxLines: 3,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.3,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF27272A),
                hintText: 'Enter your custom motivational quote...',
                hintStyle: const TextStyle(color: Colors.white38),
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: widget.short.accentColor,
                    width: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Alternative Pre-built Quotes
            if (widget.short.alternativeQuotes.isNotEmpty) ...[
              const Text(
                'QUICK PRESETS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 8),
              ...widget.short.alternativeQuotes.map((alt) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _textController.text = alt;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF222226),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _textController.text == alt
                              ? widget.short.accentColor
                              : Colors.white12,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.format_quote_rounded,
                            size: 16,
                            color: widget.short.accentColor,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              alt,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],

            const SizedBox(height: 16),

            // Save CTA Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveQuote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.short.accentColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Apply Quote to Short',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
