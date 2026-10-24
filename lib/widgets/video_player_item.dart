import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerItem extends StatefulWidget {
  final String videoAssetPath;
  final bool isActive;
  final bool isMuted;
  final VoidCallback onDoubleTapLike;

  const VideoPlayerItem({
    super.key,
    required this.videoAssetPath,
    required this.isActive,
    required this.isMuted,
    required this.onDoubleTapLike,
  });

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showHeartAnimation = false;
  late AnimationController _heartAnimController;

  @override
  void initState() {
    super.initState();
    _heartAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      final VideoPlayerController controller;
      final path = widget.videoAssetPath;
      if (path.startsWith('http://') || path.startsWith('https://')) {
        controller = VideoPlayerController.networkUrl(Uri.parse(path));
      } else if (path.startsWith('/') || path.startsWith('file://')) {
        final cleanPath =
            path.startsWith('file://') ? path.replaceFirst('file://', '') : path;
        controller = VideoPlayerController.file(File(cleanPath));
      } else {
        controller = VideoPlayerController.asset(path);
      }

      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(widget.isMuted ? 0.0 : 1.0);

      if (mounted) {
        setState(() {
          _controller = controller;
          _isInitialized = true;
          _hasError = false;
        });

        if (widget.isActive) {
          _controller?.play();
        }
      } else {
        await controller.dispose();
      }
    } catch (e) {
      debugPrint('Error initializing video player: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void didUpdateWidget(VideoPlayerItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_controller != null && _isInitialized) {
      // Play/Pause based on whether this page is currently active in the feed
      if (widget.isActive != oldWidget.isActive) {
        if (widget.isActive) {
          _controller?.play();
        } else {
          _controller?.pause();
        }
      }

      // Audio mute/unmute
      if (widget.isMuted != oldWidget.isMuted) {
        _controller?.setVolume(widget.isMuted ? 0.0 : 1.0);
      }
    }
  }

  void _handleDoubleTap() {
    HapticFeedback.mediumImpact();
    widget.onDoubleTapLike();
    setState(() {
      _showHeartAnimation = true;
    });
    _heartAnimController.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() {
          _showHeartAnimation = false;
        });
      }
    });
  }

  void _handleSingleTap() {
    if (_controller == null || !_isInitialized) return;
    HapticFeedback.selectionClick();
    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _heartAnimController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleSingleTap,
      onDoubleTap: _handleDoubleTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Video Fill
          if (_isInitialized && _controller != null)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: _controller!.value.size.width > 0
                      ? _controller!.value.size.width
                      : 1080,
                  height: _controller!.value.size.height > 0
                      ? _controller!.value.size.height
                      : 1920,
                  child: VideoPlayer(_controller!),
                ),
              ),
            )
          else if (_hasError)
            Container(
              color: const Color(0xFF141416),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.play_disabled_rounded,
                      color: Colors.white38,
                      size: 40,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Video loop could not be loaded',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _hasError = false;
                          _isInitialized = false;
                        });
                        _initializePlayer();
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white12,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white38),
                ),
              ),
            ),

          // Play/Pause indicator overlay when paused manually
          if (_isInitialized && _controller != null && !_controller!.value.isPlaying && widget.isActive)
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.5),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 44,
                ),
              ),
            ),

          // Bursting Heart Animation on Double Tap
          if (_showHeartAnimation)
            Center(
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.6, end: 1.4).animate(
                  CurvedAnimation(
                    parent: _heartAnimController,
                    curve: Curves.elasticOut,
                  ),
                ),
                child: FadeTransition(
                  opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
                    CurvedAnimation(
                      parent: _heartAnimController,
                      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
                    ),
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: Color(0xFFFF1744),
                    size: 96,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        offset: Offset(0, 4),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
