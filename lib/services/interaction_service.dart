import 'dart:async';
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
  Timer? _saveTimer;
  bool _dirty = false;

  void _markDirty() {
    _dirty = true;
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), () {
      if (_dirty) _flushAll();
    });
  }

  Future<void> _flushAll() async {
    _dirty = false;
    await Future.wait([
      _saveJson('comments.json', _comments.map((k, v) => MapEntry(k, v.map((c) => c.toJson()).toList()))),
      _saveJson('favorites.json', _favorites.toList()),
      _saveJson('history.json', _history),
    ]);
  }

  // 评论
  List<CommentModel> getComments(String videoId) => _comments[videoId] ?? [];
  int get totalComments => _comments.values.fold(0, (sum, list) => sum + list.length);

  void addComment(String videoId, String content) {
    final comment = CommentModel(
      id: 'cmt_${DateTime.now().millisecondsSinceEpoch}',
      videoId: videoId,
      author: '我',
      content: content,
      createdAt: DateTime.now(),
    );
    _comments.putIfAbsent(videoId, () => []).add(comment);
    _markDirty();
    LogService.info('添加评论: $videoId');
  }

  // 收藏
  List<String> get favorites => List.unmodifiable(_favorites);
  bool isFavorite(String videoId) => _favorites.contains(videoId);

  void toggleFavorite(String videoId) {
    if (_favorites.contains(videoId)) {
      _favorites.remove(videoId);
    } else {
      _favorites.add(videoId);
    }
    _markDirty();
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
    _markDirty();
  }

  void clearHistory() {
    _history.clear();
    _markDirty();
    LogService.info('清除观看历史');
  }

  void reset() {
    _comments.clear();
    _favorites.clear();
    _history.clear();
    _saveTimer?.cancel();
    _dirty = false;
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
