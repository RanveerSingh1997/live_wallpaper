import 'package:flutter/material.dart';
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
      final controller = VideoPlayerController.asset(widget.videoAssetPath);
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(widget.isMuted ? 0.0 : 1.0);

      if (mounted) {
        setState(() {
          _controller = controller;
          _isInitialized = true;
        });

        if (widget.isActive) {
          _controller?.play();
        }
      } else {
        await controller.dispose();
      }
    } catch (e) {
      debugPrint('Error initializing video player: $e');
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
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: VideoPlayer(_controller!),
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
