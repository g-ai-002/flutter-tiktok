import 'dart:convert';
import '../models/comment.dart';
import '../services/log_service.dart';
import '../services/file_system_service.dart';

class InteractionService {
  static final InteractionService instance = InteractionService._();
  InteractionService._();

  final Map<String, List<CommentModel>> _comments = {};
  final Set<String> _favorites = {};
  final List<String> _history = [];
  static const int _maxHistory = 50;

  // 评论
  List<CommentModel> getComments(String videoId) => _comments[videoId] ?? [];

  void addComment(String videoId, String content) {
    final comment = CommentModel(
      id: 'cmt_${DateTime.now().millisecondsSinceEpoch}',
      videoId: videoId,
      author: '我',
      content: content,
      createdAt: DateTime.now(),
    );
    _comments.putIfAbsent(videoId, () => []).add(comment);
    _saveJson('comments.json', _comments.map((k, v) => MapEntry(k, v.map((c) => c.toJson()).toList())));
    LogService.info('添加评论: $videoId');
  }

  // 收藏
  bool isFavorite(String videoId) => _favorites.contains(videoId);

  void toggleFavorite(String videoId) {
    if (_favorites.contains(videoId)) {
      _favorites.remove(videoId);
    } else {
      _favorites.add(videoId);
    }
    _saveJson('favorites.json', _favorites.toList());
    LogService.info('${_favorites.contains(videoId) ? "收藏" : "取消收藏"}: $videoId');
  }

  // 历史记录
  List<String> get history => List.unmodifiable(_history);

  void addToHistory(String videoId) {
    _history.remove(videoId);
    _history.insert(0, videoId);
    if (_history.length > _maxHistory) {
      _history.removeRange(_maxHistory, _history.length);
    }
    _saveJson('history.json', _history);
  }

  // 持久化
  Future<void> _saveJson(String filename, dynamic data) async {
    try {
      final file = await FileSystemService.instance.getUserFile(filename);
      await file.writeAsString(jsonEncode(data));
    } catch (e, st) {
      LogService.error('保存 $filename 失败', e, st);
    }
  }

  Future<dynamic> _loadJson(String filename) async {
    try {
      final file = await FileSystemService.instance.getUserFile(filename);
      if (!await file.exists()) return null;
      return jsonDecode(await file.readAsString());
    } catch (e, st) {
      LogService.error('加载 $filename 失败', e, st);
      return null;
    }
  }

  Future<void> init() async {
    final commentsData = await _loadJson('comments.json');
    if (commentsData is Map<String, dynamic>) {
      _comments.addAll(commentsData.map(
        (k, v) => MapEntry(k, (v as List).map((j) => CommentModel.fromJson(j as Map<String, dynamic>)).toList()),
      ));
    }

    final favoritesData = await _loadJson('favorites.json');
    if (favoritesData is List) {
      _favorites.addAll(favoritesData.cast<String>());
    }

    final historyData = await _loadJson('history.json');
    if (historyData is List) {
      _history.addAll(historyData.cast<String>());
    }
  }
}
