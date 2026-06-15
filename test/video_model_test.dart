import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tiktok/models/video.dart';

void main() {
  group('VideoModel', () {
    test('fromJson creates correct model', () {
      final json = <String, dynamic>{
        'id': '1',
        'title': '测试视频',
        'author': '@测试用户',
        'description': '测试描述',
        'url': 'https://example.com/video.mp4',
        'thumbnail': '',
        'likes': '100',
        'comments': '50',
        'shares': '20',
        'durationMs': 120000,
        'resolution': '1920x1080',
        'fileSize': 1048576,
        'importTime': '2025-01-01T00:00:00.000',
      };

      final video = VideoModel.fromJson(json);

      expect(video.id, '1');
      expect(video.title, '测试视频');
      expect(video.author, '@测试用户');
      expect(video.likes, '100');
      expect(video.isLiked, false);
      expect(video.durationMs, 120000);
      expect(video.resolution, '1920x1080');
      expect(video.fileSize, 1048576);
      expect(video.importTime, '2025-01-01T00:00:00.000');
    });

    test('toJson and fromJson roundtrip', () {
      final video = VideoModel(
        id: '1',
        title: '测试',
        author: '@test',
        description: 'desc',
        url: 'https://example.com/v.mp4',
        thumbnail: '',
        likes: '100',
        comments: '50',
        shares: '20',
        isLiked: true,
        durationMs: 60000,
        resolution: '1280x720',
        fileSize: 524288,
        importTime: '2025-06-01T12:00:00.000',
      );

      final json = video.toJson();
      final restored = VideoModel.fromJson(json);

      expect(restored.id, video.id);
      expect(restored.title, video.title);
      expect(restored.isLiked, true);
      expect(restored.durationMs, 60000);
      expect(restored.resolution, '1280x720');
      expect(restored.fileSize, 524288);
      expect(restored.importTime, '2025-06-01T12:00:00.000');
    });

    test('fromJson handles missing fields', () {
      final video = VideoModel.fromJson({});
      expect(video.id, '');
      expect(video.title, '');
      expect(video.isLiked, false);
      expect(video.durationMs, 0);
      expect(video.resolution, '');
      expect(video.fileSize, 0);
    });

    test('duration getter returns correct Duration', () {
      final video = VideoModel(
        id: '1', title: '', author: '', description: '', url: '', thumbnail: '',
        likes: '0', comments: '0', shares: '0', durationMs: 125000,
      );
      expect(video.duration, const Duration(milliseconds: 125000));
    });

    test('fileSizeFormatted formats correctly', () {
      VideoModel makeVideo(int size) => VideoModel(
        id: '1', title: '', author: '', description: '', url: '', thumbnail: '',
        likes: '0', comments: '0', shares: '0', fileSize: size,
      );

      expect(makeVideo(0).fileSizeFormatted, '');
      expect(makeVideo(500).fileSizeFormatted, '500B');
      expect(makeVideo(1536).fileSizeFormatted, '1.5KB');
      expect(makeVideo(1048576).fileSizeFormatted, '1.0MB');
      expect(makeVideo(1572864).fileSizeFormatted, '1.5MB');
    });

    test('importTime defaults to current time', () {
      final video = VideoModel(
        id: '1', title: '', author: '', description: '', url: '', thumbnail: '',
        likes: '0', comments: '0', shares: '0',
      );
      expect(video.importTime, isNotEmpty);
    });
  });
}
