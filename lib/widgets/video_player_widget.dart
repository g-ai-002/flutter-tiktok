import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../services/log_service.dart';
import '../utils/format.dart';
import 'heart_animation.dart';

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
  late final Player _player;
  late final VideoController _videoController;
  bool _initialized = false;
  bool _hasError = false;
  bool _isPlaying = false;
  final ValueNotifier<Duration> _positionNotifier = ValueNotifier(Duration.zero);
  final ValueNotifier<Duration> _durationNotifier = ValueNotifier(Duration.zero);
  final List<HeartAnimation> _hearts = [];
  StreamSubscription? _playingSub;
  StreamSubscription? _completedSub;
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _errorSub;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _videoController = VideoController(_player);
    _initPlayer();
  }

  @override
  void didUpdateWidget(covariant VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoUrl != oldWidget.videoUrl) {
      _initPlayer();
    }
    if (widget.isActive != oldWidget.isActive) {
      _updatePlayState();
    }
  }

  void _initPlayer() {
    _hasError = false;
    _initialized = false;
    _isPlaying = false;
    _heartId = 0;
    _hearts.clear();

    _cancelSubscriptions();

    final uri = Uri.tryParse(widget.videoUrl);
    if (uri == null) {
      _hasError = true;
      return;
    }

    final isNetwork = uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    if (isNetwork) {
      _player.open(Media(widget.videoUrl));
    } else {
      final file = File(widget.videoUrl);
      if (!file.existsSync()) {
        _hasError = true;
        LogService.error('本地视频文件不存在: ${widget.videoUrl}');
        return;
      }
      _player.open(Media(widget.videoUrl));
    }

    _player.setPlaylistMode(PlaylistMode.loop);
    _playingSub = _player.stream.playing.listen((isPlaying) {
      if (mounted) setState(() => _isPlaying = isPlaying);
    });
    _completedSub = _player.stream.completed.listen((_) {
      if (mounted) setState(() => _initialized = true);
    });
    _positionSub = _player.stream.position.listen((pos) {
      _positionNotifier.value = pos;
    });
    _durationSub = _player.stream.duration.listen((dur) {
      _durationNotifier.value = dur;
    });
    _errorSub = _player.stream.error.listen((error) {
      LogService.error('视频播放错误: ${widget.videoUrl}', error);
      if (mounted) setState(() => _hasError = true);
    });

    _initialized = true;
    _updatePlayState();
  }

  void _cancelSubscriptions() {
    _playingSub?.cancel();
    _completedSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _errorSub?.cancel();
  }

  void _updatePlayState() {
    if (!_initialized) return;
    if (widget.isActive) {
      _player.play();
    } else {
      _player.pause();
    }
  }

  void _togglePlayPause() {
    if (!_initialized) return;
    if (_isPlaying) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  void _onDoubleTapDown(TapDownDetails details) {
    widget.onDoubleTap?.call();
    _addHeart(details.localPosition);
  }

  int _heartId = 0;

  void _addHeart(Offset position) {
    final id = _heartId++;
    setState(() {
      _hearts.add(HeartAnimation(
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
    _cancelSubscriptions();
    _positionNotifier.dispose();
    _durationNotifier.dispose();
    _player.dispose();
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

    if (!_initialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _togglePlayPause,
      onDoubleTapDown: _onDoubleTapDown,
      onDoubleTap: () {},
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: Video(
              controller: _videoController,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          ..._hearts.map((h) => h),
          if (!_isPlaying)
            const Center(
              child: Icon(Icons.play_arrow, color: Colors.white70, size: 64),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _ProgressBar(
              player: _player,
              positionNotifier: _positionNotifier,
              durationNotifier: _durationNotifier,
            ),
          ),
        ],
      ),
    );
  }

}

class _ProgressBar extends StatelessWidget {
  final Player player;
  final ValueNotifier<Duration> positionNotifier;
  final ValueNotifier<Duration> durationNotifier;

  const _ProgressBar({
    required this.player,
    required this.positionNotifier,
    required this.durationNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Duration>(
      valueListenable: positionNotifier,
      builder: (context, position, _) {
        return ValueListenableBuilder<Duration>(
          valueListenable: durationNotifier,
          builder: (context, duration, _) {
            final progress = duration.inMilliseconds > 0
                ? position.inMilliseconds / duration.inMilliseconds
                : 0.0;
            return GestureDetector(
              onHorizontalDragUpdate: (details) {
                final renderBox = context.findRenderObject() as RenderBox;
                final constraints = renderBox.constraints;
                final dx = details.localPosition.dx.clamp(0.0, constraints.maxWidth);
                final fraction = dx / constraints.maxWidth;
                final target = duration * fraction;
                player.seek(target);
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
                          formatDuration(position),
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                        Text(
                          formatDuration(duration),
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
