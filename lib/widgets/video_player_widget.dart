import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../services/log_service.dart';
import '../utils/format.dart';
import 'speed_sheet.dart';

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
  bool _isMuted = false;
  double _speed = 1.0;
  final List<_HeartAnimation> _hearts = [];
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
    _playingSub = _player.stream.playing.listen((_) {
      if (mounted) setState(() {});
    });
    _completedSub = _player.stream.completed.listen((_) {
      if (mounted) setState(() => _initialized = true);
    });
    _positionSub = _player.stream.position.listen((_) {
      if (mounted) setState(() {});
    });
    _durationSub = _player.stream.duration.listen((_) {
      if (mounted) setState(() {});
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

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _player.setVolume(_isMuted ? 0 : 100);
    });
  }

  void _setSpeed(double speed) {
    setState(() => _speed = speed);
    _player.setRate(speed);
  }

  void _togglePlayPause() {
    if (!_initialized) return;
    setState(() {
      if (_player.state.playing) {
        _player.pause();
      } else {
        _player.play();
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
    _cancelSubscriptions();
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

    final position = _player.state.position;
    final duration = _player.state.duration;
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
          Video(
            controller: _videoController,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
          ),
          ..._hearts.map((h) => h),
          if (!_player.state.playing)
            const Center(
              child: Icon(Icons.play_arrow, color: Colors.white70, size: 64),
            ),
          Positioned(
            right: 12,
            top: MediaQuery.of(context).size.height * 0.40,
            child: GestureDetector(
              onTap: () => SpeedSheet.show(context, _speed, _setSpeed),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _speed == 1.0 ? '倍速' : '${_speed}x',
                  style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ),
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
                if (!_initialized) return;
                final renderBox = context.findRenderObject() as RenderBox;
                final constraints = renderBox.constraints;
                final dx = details.localPosition.dx.clamp(0.0, constraints.maxWidth);
                final fraction = dx / constraints.maxWidth;
                final target = _player.state.duration * fraction;
                _player.seek(target);
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
            ),
          ),
        ],
      ),
    );
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
