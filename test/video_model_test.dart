import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tiktok/models/video.dart';

void main() {
  group('VideoModel', () {
    test('fromMap creates correct model', () {
      final map = {
        'id': '1',
        'title': '测试视频',
        'author': '@测试用户',
        'description': '测试描述',
        'url': 'https://example.com/video.mp4',
        'thumbnail': '',
        'likes': '100',
        'comments': '50',
        'shares': '20',
      };

      final video = VideoModel.fromMap(map);

      expect(video.id, '1');
      expect(video.title, '测试视频');
      expect(video.author, '@测试用户');
      expect(video.likes, '100');
      expect(video.isLiked, false);
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
      );

      final json = video.toJson();
      final restored = VideoModel.fromJson(json);

      expect(restored.id, video.id);
      expect(restored.title, video.title);
      expect(restored.isLiked, true);
    });

    test('fromJson handles missing fields', () {
      final video = VideoModel.fromJson({});
      expect(video.id, '');
      expect(video.title, '');
      expect(video.isLiked, false);
    });
  });
}
