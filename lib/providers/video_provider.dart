import 'package:flutter/foundation.dart';
import '../models/video.dart';
import '../utils/constants.dart';
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

  Future<void> _loadVideos() async {
    _isLoading = true;
    notifyListeners();

    try {
      final likedIds = _storage.likedVideos.toSet();
      final saved = await VideoSourceService.instance.getSavedVideos();
      if (saved.isNotEmpty) {
        _videos = saved;
      } else {
        _videos = AppConstants.sampleVideos.map((map) {
          final video = VideoModel.fromJson(map);
          video.isLiked = likedIds.contains(video.id);
          return video;
        }).toList();
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
    final video = _videos.firstWhere((v) => v.id == videoId);
    video.isLiked = !video.isLiked;

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

  Future<void> resetToSampleVideos() async {
    final likedIds = _storage.likedVideos.toSet();
    _videos = AppConstants.sampleVideos.map((map) {
      final video = VideoModel.fromJson(map);
      video.isLiked = likedIds.contains(video.id);
      return video;
    }).toList();
    _currentIndex = 0;
    await VideoSourceService.instance.saveVideos(_videos);
    notifyListeners();
    LogService.info('已重置为示例视频');
  }
}
