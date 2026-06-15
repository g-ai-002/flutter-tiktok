import 'dart:io';
import 'package:video_player/video_player.dart';
import 'log_service.dart';

class VideoPreloadService {
  static final VideoPreloadService instance = VideoPreloadService._();
  VideoPreloadService._();

  final Map<String, VideoPlayerController> _cache = {};
  static const int _maxCache = 4;

  void preload(String url) {
    if (_cache.containsKey(url)) return;
    if (_cache.length >= _maxCache) {
      _evictOne();
    }

    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final isNetwork = uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    VideoPlayerController controller;
    if (isNetwork) {
      controller = VideoPlayerController.networkUrl(uri);
    } else {
      final file = File(url);
      if (!file.existsSync()) return;
      controller = VideoPlayerController.file(file);
    }

    controller.initialize().then((_) {
      LogService.info('预加载完成: $url');
    }).catchError((e, st) {
      LogService.error('预加载失败: $url', e, st);
      controller.dispose();
      _cache.remove(url);
    });

    _cache[url] = controller;
  }

  VideoPlayerController? getController(String url) {
    return _cache[url];
  }

  void preloadAdjacent(List<String> urls, int currentIndex) {
    final prev = currentIndex > 0 ? urls[currentIndex - 1] : null;
    final next = currentIndex < urls.length - 1 ? urls[currentIndex + 1] : null;

    if (prev != null) preload(prev);
    if (next != null) preload(next);
  }

  void _evictOne() {
    if (_cache.isEmpty) return;
    final key = _cache.keys.first;
    _cache[key]?.dispose();
    _cache.remove(key);
  }

  void clear() {
    for (final c in _cache.values) {
      c.dispose();
    }
    _cache.clear();
  }
}
