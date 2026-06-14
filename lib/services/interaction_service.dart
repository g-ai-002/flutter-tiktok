import 'dart:convert';
import 'dart:io';
import '../models/comment.dart';
import '../services/log_service.dart';
import '../services/file_system_service.dart';

class InteractionService {
  static final InteractionService instance = InteractionService._();
  InteractionService._();

  // 评论
  final Map<String, List<CommentModel>> _comments = {};

  List<CommentModel> getComments(String videoId) {
    return _comments[videoId] ?? [];
  }

  void addComment(String videoId, String content) {
    final comment = CommentModel(
      id: 'cmt_${DateTime.now().millisecondsSinceEpoch}',
      videoId: videoId,
      author: '我',
      content: content,
      createdAt: DateTime.now(),
    );
    _comments.putIfAbsent(videoId, () => []).add(comment);
    _saveComments();
    LogService.info('添加评论: $videoId');
  }

  Future<void> _saveComments() async {
    try {
      final dir = await FileSystemService.instance.getUserRoot();
      final file = File('${dir.path}${Platform.pathSeparator}comments.json');
      final data = _comments.map((k, v) => MapEntry(k, v.map((c) => c.toJson()).toList()));
      await file.writeAsString(jsonEncode(data));
    } catch (e, st) {
      LogService.error('保存评论失败', e, st);
    }
  }

  Future<void> loadComments() async {
    try {
      final dir = await FileSystemService.instance.getUserRoot();
      final file = File('${dir.path}${Platform.pathSeparator}comments.json');
      if (!await file.exists()) return;
      final content = await file.readAsString();
      final data = (jsonDecode(content) as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, (v as List).map((j) => CommentModel.fromJson(j as Map<String, dynamic>)).toList()),
      );
      _comments.clear();
      _comments.addAll(data);
    } catch (e, st) {
      LogService.error('加载评论失败', e, st);
    }
  }

  // 收藏
  final Set<String> _favorites = {};

  bool isFavorite(String videoId) => _favorites.contains(videoId);

  void toggleFavorite(String videoId) {
    if (_favorites.contains(videoId)) {
      _favorites.remove(videoId);
    } else {
      _favorites.add(videoId);
    }
    _saveFavorites();
    LogService.info('${_favorites.contains(videoId) ? "收藏" : "取消收藏"}: $videoId');
  }

  Future<void> _saveFavorites() async {
    try {
      final dir = await FileSystemService.instance.getUserRoot();
      final file = File('${dir.path}${Platform.pathSeparator}favorites.json');
      await file.writeAsString(jsonEncode(_favorites.toList()));
    } catch (e, st) {
      LogService.error('保存收藏失败', e, st);
    }
  }

  Future<void> loadFavorites() async {
    try {
      final dir = await FileSystemService.instance.getUserRoot();
      final file = File('${dir.path}${Platform.pathSeparator}favorites.json');
      if (!await file.exists()) return;
      final content = await file.readAsString();
      final list = (jsonDecode(content) as List).cast<String>();
      _favorites.addAll(list);
    } catch (e, st) {
      LogService.error('加载收藏失败', e, st);
    }
  }

  // 历史记录
  final List<String> _history = [];
  static const int _maxHistory = 50;

  List<String> get history => List.unmodifiable(_history);

  void addToHistory(String videoId) {
    _history.remove(videoId);
    _history.insert(0, videoId);
    if (_history.length > _maxHistory) {
      _history.removeRange(_maxHistory, _history.length);
    }
    _saveHistory();
  }

  Future<void> _saveHistory() async {
    try {
      final dir = await FileSystemService.instance.getUserRoot();
      final file = File('${dir.path}${Platform.pathSeparator}history.json');
      await file.writeAsString(jsonEncode(_history));
    } catch (e, st) {
      LogService.error('保存历史记录失败', e, st);
    }
  }

  Future<void> loadHistory() async {
    try {
      final dir = await FileSystemService.instance.getUserRoot();
      final file = File('${dir.path}${Platform.pathSeparator}history.json');
      if (!await file.exists()) return;
      final content = await file.readAsString();
      final list = (jsonDecode(content) as List).cast<String>();
      _history.addAll(list);
    } catch (e, st) {
      LogService.error('加载历史记录失败', e, st);
    }
  }

  Future<void> init() async {
    await loadComments();
    await loadFavorites();
    await loadHistory();
  }
}
