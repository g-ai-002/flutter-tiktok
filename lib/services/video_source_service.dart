import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path/path.dart' as p;
import '../models/video.dart';
import '../services/log_service.dart';
import '../services/file_system_service.dart';

class VideoSourceService {
  static final VideoSourceService instance = VideoSourceService._();
  VideoSourceService._();

  Future<List<VideoModel>> importVideos() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: true,
      );
      if (result == null || result.files.isEmpty) return [];

      final videos = <VideoModel>[];
      for (final file in result.files) {
        if (file.path == null) continue;
        final name = p.basenameWithoutExtension(file.name);
        final metadata = await _extractMetadata(file.path!);
        videos.add(VideoModel(
          id: 'local_${DateTime.now().millisecondsSinceEpoch}_${videos.length}',
          title: name,
          author: '本地视频',
          description: file.name,
          url: file.path!,
          thumbnail: '',
          likes: '0',
          comments: '0',
          shares: '0',
          durationMs: metadata['durationMs'] as int? ?? 0,
          resolution: metadata['resolution'] as String? ?? '',
          fileSize: metadata['fileSize'] as int? ?? 0,
        ));
      }
      LogService.info('导入了 ${videos.length} 个本地视频');
      return videos;
    } catch (e, st) {
      LogService.error('导入视频失败', e, st);
      return [];
    }
  }

  Future<Map<String, dynamic>> _extractMetadata(String filePath) async {
    final result = <String, dynamic>{};
    try {
      final file = File(filePath);
      if (await file.exists()) {
        result['fileSize'] = await file.length();
      }
    } catch (_) {}

    try {
      final player = Player();
      final completer = Completer<void>();
      Timer? timeout;

      player.stream.duration.listen((duration) {
        result['durationMs'] = duration.inMilliseconds;
      });

      player.stream.videoParams.listen((params) {
        if (params != null && params.width > 0 && params.height > 0) {
          result['resolution'] = '${params.width}x${params.height}';
        }
        if (!completer.isCompleted) {
          timeout?.cancel();
          completer.complete();
        }
      });

      player.stream.error.listen((_) {
        if (!completer.isCompleted) {
          timeout?.cancel();
          completer.complete();
        }
      });

      player.open(Media(filePath));

      timeout = Timer(const Duration(seconds: 3), () {
        if (!completer.isCompleted) completer.complete();
      });

      await completer.future;
      player.dispose();
    } catch (e) {
      LogService.error('提取视频元数据失败: $filePath', e);
    }

    return result;
  }

  Future<List<VideoModel>> getSavedVideos() async {
    try {
      final file = await FileSystemService.instance.getUserFile('videos.json');
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      final list = (jsonDecode(content) as List).cast<Map<String, dynamic>>();
      return list.map((j) => VideoModel.fromJson(j)).toList();
    } catch (e, st) {
      LogService.error('读取已保存视频失败', e, st);
      return [];
    }
  }

  Future<void> saveVideos(List<VideoModel> videos) async {
    try {
      final file = await FileSystemService.instance.getUserFile('videos.json');
      final list = videos.map((v) => v.toJson()).toList();
      await file.writeAsString(jsonEncode(list));
    } catch (e, st) {
      LogService.error('保存视频列表失败', e, st);
    }
  }
}
