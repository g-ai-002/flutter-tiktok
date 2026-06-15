import 'package:flutter/foundation.dart';
import '../models/video.dart';
import '../services/storage_service.dart';
import '../services/log_service.dart';
import '../services/video_source_service.dart';

class VideoProvider extends ChangeNotifier {
  final StorageService _storage;
  List<VideoModel> _videos = [];
  int _currentIndex = 0;
  bool _isLoading = false;

  VideoProvider(this._storage) {
    _loadVideos();
  }

  List<VideoModel> get videos => _videos;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  VideoModel? get currentVideo =>
      _videos.isNotEmpty && _currentIndex < _videos.length ? _videos[_currentIndex] : null;

  List<VideoModel> getVideosByIds(List<String> ids) {
    final idSet = ids.toSet();
    return _videos.where((v) => idSet.contains(v.id)).toList();
  }

  Future<void> _loadVideos() async {
    _isLoading = true;
    notifyListeners();

    try {
      final likedIds = _storage.likedVideos.toSet();
      final saved = await VideoSourceService.instance.getSavedVideos();
      _videos = saved;
      for (final v in _videos) {
        v.isLiked = likedIds.contains(v.id);
      }
      LogService.info('加载了 ${_videos.length} 个视频');
    } catch (e, st) {
      LogService.error('加载视频失败', e, st);
    }

    _isLoading = false;
    notifyListeners();
  }

  void setCurrentIndex(int index) {
    if (index >= 0 && index < _videos.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void toggleLike(String videoId) {
    final index = _videos.indexWhere((v) => v.id == videoId);
    if (index == -1) return;
    final video = _videos[index];
    video.isLiked = !video.isLiked;

    final currentLikes = _parseCount(video.likes);
    video.likes = _formatCount(video.isLiked ? currentLikes + 1 : (currentLikes > 0 ? currentLikes - 1 : 0));

    final likedIds = _videos.where((v) => v.isLiked).map((v) => v.id).toList();
    _storage.setLikedVideos(likedIds);

    notifyListeners();
    LogService.info('${video.isLiked ? "点赞" : "取消点赞"} 视频: $videoId');
  }

  Future<void> importLocalVideos() async {
    final imported = await VideoSourceService.instance.importVideos();
    if (imported.isEmpty) return;

    _videos.addAll(imported);
    await VideoSourceService.instance.saveVideos(_videos);
    notifyListeners();
    LogService.info('视频列表已更新，共 ${_videos.length} 个视频');
  }

  Future<void> removeVideo(String videoId) async {
    _videos.removeWhere((v) => v.id == videoId);
    if (_currentIndex >= _videos.length) {
      _currentIndex = _videos.isNotEmpty ? _videos.length - 1 : 0;
    }
    await VideoSourceService.instance.saveVideos(_videos);
    notifyListeners();
    LogService.info('已移除视频: $videoId');
  }

  void incrementComments(String videoId) {
    final index = _videos.indexWhere((v) => v.id == videoId);
    if (index == -1) return;
    final video = _videos[index];
    final current = _parseCount(video.comments);
    video.comments = _formatCount(current + 1);
    notifyListeners();
  }

  int _parseCount(String text) {
    final cleaned = text.trim();
    if (cleaned.endsWith('万')) {
      final num = double.tryParse(cleaned.replaceAll('万', ''));
      if (num != null) return (num * 10000).round();
    }
    return int.tryParse(cleaned) ?? 0;
  }

  String _formatCount(int count) {
    if (count >= 10000) {
      final wan = count / 10000;
      if (wan == wan.roundToDouble()) {
        return '${wan.round()}万';
      }
      return '${wan.toStringAsFixed(1)}万';
    }
    return '$count';
  }

  Future<void> refreshVideos() async {
    await _loadVideos();
  }
}
