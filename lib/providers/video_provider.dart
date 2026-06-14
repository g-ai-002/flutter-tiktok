import 'package:flutter/foundation.dart';
import '../models/video.dart';
import '../utils/constants.dart';
import '../services/storage_service.dart';
import '../services/log_service.dart';

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

  void _loadVideos() {
    _isLoading = true;
    notifyListeners();

    try {
      final likedIds = _storage.likedVideos.toSet();
      _videos = AppConstants.sampleVideos.map((map) {
        final video = VideoModel.fromMap(map);
        video.isLiked = likedIds.contains(video.id);
        return video;
      }).toList();
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

  void nextVideo() {
    if (_currentIndex < _videos.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void previousVideo() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }
}
