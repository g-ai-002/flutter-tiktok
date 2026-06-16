import 'package:flutter/foundation.dart';
import '../models/video.dart';
import '../services/storage_service.dart';
import '../services/log_service.dart';
import '../services/video_source_service.dart';
import '../services/category_service.dart';

enum VideoSortMode { importTime, name, duration, fileSize }

class VideoProvider extends ChangeNotifier {
  final StorageService _storage;
  List<VideoModel> _videos = [];
  int _currentIndex = 0;
  bool _isLoading = false;
  VideoSortMode _sortMode = VideoSortMode.importTime;
  bool _sortAscending = false;
  bool _autoPlay = true;
  String? _categoryFilter;

  VideoProvider(this._storage) {
    _loadVideos();
  }

  List<VideoModel> get videos => _categoryFilter != null
      ? _videos.where((v) => v.categoryId == _categoryFilter).toList()
      : _videos;
  List<VideoModel> get allVideos => _videos;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  VideoSortMode get sortMode => _sortMode;
  bool get sortAscending => _sortAscending;
  bool get autoPlay => _autoPlay;
  String? get categoryFilter => _categoryFilter;
  VideoModel? get currentVideo =>
      videos.isNotEmpty && _currentIndex < videos.length ? videos[_currentIndex] : null;

  List<VideoModel> getVideosByIds(List<String> ids) {
    final idSet = ids.toSet();
    return _videos.where((v) => idSet.contains(v.id)).toList();
  }

  void setSortMode(VideoSortMode mode) {
    if (_sortMode == mode) {
      _sortAscending = !_sortAscending;
    } else {
      _sortMode = mode;
      _sortAscending = false;
    }
    _sortVideos();
    notifyListeners();
  }

  void _sortVideos() {
    int cmp(VideoModel a, VideoModel b) {
      switch (_sortMode) {
        case VideoSortMode.name:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case VideoSortMode.duration:
          return a.durationMs.compareTo(b.durationMs);
        case VideoSortMode.fileSize:
          return a.fileSize.compareTo(b.fileSize);
        case VideoSortMode.importTime:
          return a.importTime.compareTo(b.importTime);
      }
    }

    _videos.sort((a, b) => _sortAscending ? cmp(a, b) : cmp(b, a));
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
        v.categoryId = CategoryService.instance.getCategoryId(v.id);
      }
      _sortVideos();
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
    _sortVideos();
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

  void setAutoPlay(bool value) {
    _autoPlay = value;
    notifyListeners();
  }

  void setCategoryFilter(String? categoryId) {
    _categoryFilter = categoryId;
    _currentIndex = 0;
    notifyListeners();
  }

  void updateVideoInfo(String videoId, {String? title, String? description}) {
    final index = _videos.indexWhere((v) => v.id == videoId);
    if (index == -1) return;
    final video = _videos[index];
    final updated = VideoModel(
      id: video.id,
      title: title ?? video.title,
      author: video.author,
      description: description ?? video.description,
      url: video.url,
      thumbnail: video.thumbnail,
      likes: video.likes,
      comments: video.comments,
      shares: video.shares,
      isLiked: video.isLiked,
      durationMs: video.durationMs,
      resolution: video.resolution,
      fileSize: video.fileSize,
      importTime: video.importTime,
      categoryId: video.categoryId,
    );
    _videos[index] = updated;
    VideoSourceService.instance.saveVideos(_videos);
    notifyListeners();
    LogService.info('更新视频信息: $videoId');
  }

  void setVideoCategory(String videoId, String? categoryId) {
    CategoryService.instance.setVideoCategory(videoId, categoryId);
    final index = _videos.indexWhere((v) => v.id == videoId);
    if (index != -1) {
      _videos[index].categoryId = categoryId;
      notifyListeners();
    }
  }

  Future<void> batchDelete(List<String> videoIds) async {
    _videos.removeWhere((v) => videoIds.contains(v.id));
    if (_currentIndex >= _videos.length) {
      _currentIndex = _videos.isNotEmpty ? _videos.length - 1 : 0;
    }
    await VideoSourceService.instance.saveVideos(_videos);
    notifyListeners();
    LogService.info('批量删除 ${videoIds.length} 个视频');
  }

  void batchSetCategory(List<String> videoIds, String? categoryId) {
    CategoryService.instance.batchSetCategory(videoIds, categoryId);
    for (final v in _videos) {
      if (videoIds.contains(v.id)) {
        v.categoryId = categoryId;
      }
    }
    notifyListeners();
  }

  Future<void> refreshVideos() async {
    await _loadVideos();
  }
}
