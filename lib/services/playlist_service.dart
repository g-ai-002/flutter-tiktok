import 'dart:convert';
import '../models/playlist.dart';
import '../services/log_service.dart';
import '../services/file_system_service.dart';

class PlaylistService {
  static final PlaylistService instance = PlaylistService._();
  PlaylistService._();

  final List<PlaylistModel> _playlists = [];

  List<PlaylistModel> get playlists => List.unmodifiable(_playlists);

  PlaylistModel? getPlaylist(String id) {
    try {
      return _playlists.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  void addPlaylist(String name) {
    final playlist = PlaylistModel(
      id: 'pl_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
    );
    _playlists.add(playlist);
    _save();
    LogService.info('创建播放列表: $name');
  }

  void renamePlaylist(String playlistId, String newName) {
    final playlist = getPlaylist(playlistId);
    if (playlist == null) return;
    playlist.name = newName;
    _save();
    LogService.info('重命名播放列表: $playlistId -> $newName');
  }

  void deletePlaylist(String playlistId) {
    _playlists.removeWhere((p) => p.id == playlistId);
    _save();
    LogService.info('删除播放列表: $playlistId');
  }

  void addVideo(String playlistId, String videoId) {
    final playlist = getPlaylist(playlistId);
    if (playlist == null) return;
    if (!playlist.videoIds.contains(videoId)) {
      playlist.videoIds.add(videoId);
      _save();
    }
  }

  void removeVideo(String playlistId, String videoId) {
    final playlist = getPlaylist(playlistId);
    if (playlist == null) return;
    playlist.videoIds.remove(videoId);
    _save();
  }

  bool isInPlaylist(String playlistId, String videoId) {
    final playlist = getPlaylist(playlistId);
    return playlist?.videoIds.contains(videoId) ?? false;
  }

  Future<void> _save() async {
    try {
      final file = await FileSystemService.instance.getUserFile('playlists.json');
      final data = _playlists.map((p) => p.toJson()).toList();
      await file.writeAsString(jsonEncode(data));
    } catch (e, st) {
      LogService.error('保存播放列表数据失败', e, st);
    }
  }

  Future<void> init() async {
    try {
      final file = await FileSystemService.instance.getUserFile('playlists.json');
      if (!await file.exists()) return;
      final content = await file.readAsString();
      final list = (jsonDecode(content) as List)
          .map((j) => PlaylistModel.fromJson(j as Map<String, dynamic>))
          .toList();
      _playlists.addAll(list);
    } catch (e, st) {
      LogService.error('加载播放列表数据失败', e, st);
    }
  }
}
