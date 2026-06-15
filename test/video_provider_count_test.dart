import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tiktok/providers/video_provider.dart';
import 'package:flutter_tiktok/services/storage_service.dart';
import 'package:flutter_tiktok/models/video.dart';

void main() {
  group('VideoProvider 中文数字解析', () {
    late VideoProvider provider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.instance;
      provider = VideoProvider(storage);
    });

    test('toggleLike 正确解析 "1.2万" 格式', () {
      final video = VideoModel(
        id: 'test_wan', title: '测试', author: 'a', description: '', url: '', thumbnail: '',
        likes: '1.2万', comments: '0', shares: '0',
      );
      provider.videos.add(video);

      provider.toggleLike('test_wan');
      expect(video.likes, '12001');
      expect(video.isLiked, true);

      provider.toggleLike('test_wan');
      expect(video.likes, '1.2万');
      expect(video.isLiked, false);
    });

    test('toggleLike 正确解析普通数字格式', () {
      final video = VideoModel(
        id: 'test_num', title: '测试', author: 'a', description: '', url: '', thumbnail: '',
        likes: '356', comments: '0', shares: '0',
      );
      provider.videos.add(video);

      provider.toggleLike('test_num');
      expect(video.likes, '357');
      expect(video.isLiked, true);

      provider.toggleLike('test_num');
      expect(video.likes, '356');
      expect(video.isLiked, false);
    });

    test('incrementComments 正确解析 "1.2万" 格式', () {
      final video = VideoModel(
        id: 'test_cmt', title: '测试', author: 'a', description: '', url: '', thumbnail: '',
        likes: '0', comments: '1.2万', shares: '0',
      );
      provider.videos.add(video);

      provider.incrementComments('test_cmt');
      expect(video.comments, '12001');
    });

    test('toggleLike 处理 9999 → 1.0万 边界', () {
      final video = VideoModel(
        id: 'test_boundary', title: '测试', author: 'a', description: '', url: '', thumbnail: '',
        likes: '9999', comments: '0', shares: '0',
      );
      provider.videos.add(video);

      provider.toggleLike('test_boundary');
      expect(video.likes, '1.0万');
    });
  });
}
