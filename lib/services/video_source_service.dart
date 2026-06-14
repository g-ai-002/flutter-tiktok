import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
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
        ));
      }
      LogService.info('导入了 ${videos.length} 个本地视频');
      return videos;
    } catch (e, st) {
      LogService.error('导入视频失败', e, st);
      return [];
    }
  }

  Future<List<VideoModel>> getSavedVideos() async {
    try {
      final dir = await FileSystemService.instance.getUserRoot();
      final metaFile = File('${dir.path}${Platform.pathSeparator}videos.json');
      if (!await metaFile.exists()) return [];
      final content = await metaFile.readAsString();
      final list = (jsonDecode(content) as List).cast<Map<String, dynamic>>();
      return list.map((j) => VideoModel.fromJson(j)).toList();
    } catch (e, st) {
      LogService.error('读取已保存视频失败', e, st);
      return [];
    }
  }

  Future<void> saveVideos(List<VideoModel> videos) async {
    try {
      final dir = await FileSystemService.instance.getUserRoot();
      final metaFile = File('${dir.path}${Platform.pathSeparator}videos.json');
      final list = videos.map((v) => v.toJson()).toList();
      await metaFile.writeAsString(jsonEncode(list));
    } catch (e, st) {
      LogService.error('保存视频列表失败', e, st);
    }
  }
}
