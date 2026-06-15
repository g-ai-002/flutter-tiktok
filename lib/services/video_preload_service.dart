import 'dart:io';
import 'package:media_kit/media_kit.dart';
import 'log_service.dart';

class VideoPreloadService {
  static final VideoPreloadService instance = VideoPreloadService._();
  VideoPreloadService._();

  final Map<String, Player> _cache = {};
  static const int _maxCache = 4;

  void preload(String url) {
    if (_cache.containsKey(url)) return;
    if (_cache.length >= _maxCache) {
      _evictOne();
    }

    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final isNetwork = uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    if (!isNetwork) {
      final file = File(url);
      if (!file.existsSync()) return;
    }

    final player = Player();
    player.open(Media(url));
    player.stream.completed.listen((_) {
      LogService.info('预加载完成: $url');
    });
    player.stream.error.listen((e) {
      LogService.error('预加载失败: $url', e);
      player.dispose();
      _cache.remove(url);
    });

    _cache[url] = player;
  }

  Player? getPlayer(String url) {
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
    for (final p in _cache.values) {
      p.dispose();
    }
    _cache.clear();
  }
}
