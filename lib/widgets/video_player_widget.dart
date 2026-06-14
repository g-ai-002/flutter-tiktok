import 'dart:io';
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
  bool _hasError = false;

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
