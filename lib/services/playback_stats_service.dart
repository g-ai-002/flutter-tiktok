import 'dart:convert';
import '../services/log_service.dart';
import '../services/file_system_service.dart';

class PlaybackStats {
  int playCount;
  int totalWatchMs;
  String? lastPlayedAt;

  PlaybackStats({
    this.playCount = 0,
    this.totalWatchMs = 0,
    this.lastPlayedAt,
  });

  Duration get totalWatchDuration => Duration(milliseconds: totalWatchMs);

  Map<String, dynamic> toJson() => {
        'playCount': playCount,
        'totalWatchMs': totalWatchMs,
        'lastPlayedAt': lastPlayedAt,
      };

  factory PlaybackStats.fromJson(Map<String, dynamic> json) {
    return PlaybackStats(
      playCount: json['playCount'] as int? ?? 0,
      totalWatchMs: json['totalWatchMs'] as int? ?? 0,
      lastPlayedAt: json['lastPlayedAt'] as String?,
    );
  }
}

class PlaybackStatsService {
  static final PlaybackStatsService instance = PlaybackStatsService._();
  PlaybackStatsService._();

  final Map<String, PlaybackStats> _stats = {};

  PlaybackStats getStats(String videoId) {
    return _stats.putIfAbsent(videoId, () => PlaybackStats());
  }

  void recordPlay(String videoId) {
    final stats = getStats(videoId);
    stats.playCount++;
    stats.lastPlayedAt = DateTime.now().toIso8601String();
    _save();
  }

  void recordWatchTime(String videoId, int ms) {
    if (ms <= 0) return;
    final stats = getStats(videoId);
    stats.totalWatchMs += ms;
    _save();
  }

  int get totalPlayCount {
    int count = 0;
    for (final s in _stats.values) {
      count += s.playCount;
    }
    return count;
  }

  Duration get totalWatchTime {
    int ms = 0;
    for (final s in _stats.values) {
      ms += s.totalWatchMs;
    }
    return Duration(milliseconds: ms);
  }

  Future<void> _save() async {
    try {
      final file = await FileSystemService.instance.getUserFile('playback_stats.json');
      final data = _stats.map((k, v) => MapEntry(k, v.toJson()));
      await file.writeAsString(jsonEncode(data));
    } catch (e, st) {
      LogService.error('保存播放统计失败', e, st);
    }
  }

  Future<void> init() async {
    try {
      final file = await FileSystemService.instance.getUserFile('playback_stats.json');
      if (!await file.exists()) return;
      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      for (final entry in data.entries) {
        _stats[entry.key] = PlaybackStats.fromJson(entry.value as Map<String, dynamic>);
      }
    } catch (e, st) {
      LogService.error('加载播放统计失败', e, st);
    }
  }
}
