import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../services/log_service.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final bool isActive;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    required this.isActive,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  String? _lastUrl;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didUpdateWidget(covariant VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoUrl != _lastUrl) {
      _disposeController();
      _initController();
    }
    if (widget.isActive != oldWidget.isActive) {
      _updatePlayState();
    }
  }

  void _initController() {
    _lastUrl = widget.videoUrl;
    final uri = Uri.tryParse(widget.videoUrl);
    if (uri == null) return;

    _controller = VideoPlayerController.networkUrl(uri)
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _initialized = true);
          _updatePlayState();
        }
      }).catchError((e, st) {
        LogService.error('视频初始化失败: ${widget.videoUrl}', e, st);
      });

    _controller!.setLooping(true);
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
    _controller?.dispose();
    _controller = null;
    _initialized = false;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized || _controller == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return GestureDetector(
      onTap: () {
        if (_controller!.value.isPlaying) {
          _controller!.pause();
        } else {
          _controller!.play();
        }
        setState(() {});
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          VideoPlayer(_controller!),
          if (!_controller!.value.isPlaying)
            const Center(
              child: Icon(Icons.play_arrow, color: Colors.white70, size: 64),
            ),
        ],
      ),
    );
  }
}
