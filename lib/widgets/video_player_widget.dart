import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../services/log_service.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final bool isActive;
  final VoidCallback? onDoubleTap;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    required this.isActive,
    this.onDoubleTap,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _hasError = false;
  bool _isMuted = false;
  final List<_HeartAnimation> _hearts = [];

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didUpdateWidget(covariant VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoUrl != oldWidget.videoUrl) {
      _disposeController();
      _initController();
    }
    if (widget.isActive != oldWidget.isActive) {
      _updatePlayState();
    }
  }

  void _initController() {
    _hasError = false;
    final uri = Uri.tryParse(widget.videoUrl);
    if (uri == null) {
      _hasError = true;
      return;
    }

    final isNetwork = uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    if (isNetwork) {
      _controller = VideoPlayerController.networkUrl(uri);
    } else {
      final file = File(widget.videoUrl);
      if (!file.existsSync()) {
        _hasError = true;
        LogService.error('本地视频文件不存在: ${widget.videoUrl}');
        return;
      }
      _controller = VideoPlayerController.file(file);
    }

    _controller!
        .initialize()
        .then((_) {
          if (mounted) {
            setState(() => _initialized = true);
            _updatePlayState();
          }
        })
        .catchError((e, st) {
          LogService.error('视频初始化失败: ${widget.videoUrl}', e, st);
          if (mounted) setState(() => _hasError = true);
        });

    _controller!.setLooping(true);
    _controller!.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  void _updatePlayState() {
    if (_controller == null || !_initialized) return;
    if (widget.isActive) {
      _controller!.play();
    } else {
      _controller!.pause();
    }
  }

  void _disposeController() {
    _controller?.removeListener(_onControllerUpdate);
    _controller?.dispose();
    _controller = null;
    _initialized = false;
  }

  void _toggleMute() {
    if (_controller == null) return;
    setState(() {
      _isMuted = !_isMuted;
      _controller!.setVolume(_isMuted ? 0 : 1);
    });
  }

  void _togglePlayPause() {
    if (_controller == null || !_initialized) return;
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    });
  }

  void _onDoubleTapDown(TapDownDetails details) {
    widget.onDoubleTap?.call();
    _addHeart(details.localPosition);
  }

  int _heartId = 0;

  void _addHeart(Offset position) {
    final id = _heartId++;
    setState(() {
      _hearts.add(_HeartAnimation(
        key: ValueKey(id),
        position: position,
        onDone: () {
          setState(() => _hearts.removeWhere((h) => h.key == ValueKey(id)));
        },
      ));
    });
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.white54, size: 48),
            SizedBox(height: 12),
            Text('视频加载失败', style: TextStyle(color: Colors.white54, fontSize: 14)),
          ],
        ),
      );
    }

    if (!_initialized || _controller == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    final position = _controller!.value.position;
    final duration = _controller!.value.duration;
    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return GestureDetector(
      onTap: _togglePlayPause,
      onDoubleTapDown: _onDoubleTapDown,
      onDoubleTap: () {},
      child: Stack(
        fit: StackFit.expand,
        children: [
          VideoPlayer(_controller!),
          ..._hearts.map((h) => h),
          if (!_controller!.value.isPlaying)
            const Center(
              child: Icon(Icons.play_arrow, color: Colors.white70, size: 64),
            ),
          Positioned(
            right: 12,
            top: MediaQuery.of(context).size.height * 0.45,
            child: GestureDetector(
              onTap: _toggleMute,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white70,
                  size: 24,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                if (_controller == null || !_initialized) return;
                final renderBox = context.findRenderObject() as RenderBox;
                final constraints = renderBox.constraints;
                final dx = details.localPosition.dx.clamp(0.0, constraints.maxWidth);
                final fraction = dx / constraints.maxWidth;
                final position = _controller!.value.duration * fraction;
                _controller!.seekTo(position);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFE2C55)),
                    minHeight: 3,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(position),
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                        Text(
                          _formatDuration(duration),
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _HeartAnimation extends StatefulWidget {
  final Offset position;
  final VoidCallback onDone;

  const _HeartAnimation({super.key, required this.position, required this.onDone});

  @override
  State<_HeartAnimation> createState() => _HeartAnimationState();
}

class _HeartAnimationState extends State<_HeartAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scale = Tween<double>(begin: 0.3, end: 1.5).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.3, 1.0, curve: Curves.easeOut)),
    );
    _slide = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -80)).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _animController.forward().then((_) => widget.onDone());
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Positioned(
          left: widget.position.dx - 30,
          top: widget.position.dy - 30,
          child: Transform.translate(
            offset: _slide.value,
            child: Opacity(
              opacity: _opacity.value,
              child: Transform.scale(
                scale: _scale.value,
                child: const Icon(Icons.favorite, color: Color(0xFFFE2C55), size: 60),
              ),
            ),
          ),
        );
      },
    );
  }
}
