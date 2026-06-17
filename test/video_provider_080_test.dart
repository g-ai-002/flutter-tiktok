import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tiktok/providers/video_provider.dart';
import 'package:flutter_tiktok/services/storage_service.dart';
import 'package:flutter_tiktok/models/video.dart';

void main() {
  group('VideoProvider 0.8.0 新功能', () {
    late VideoProvider provider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.instance;
      provider = VideoProvider(storage);
      await Future.delayed(const Duration(milliseconds: 100));
    });

    test('autoPlay 默认为 true', () {
      expect(provider.autoPlay, true);
    });

    test('setAutoPlay 切换自动连播', () {
      provider.setAutoPlay(false);
      expect(provider.autoPlay, false);
      provider.setAutoPlay(true);
      expect(provider.autoPlay, true);
    });

    test('categoryFilter 默认为 null', () {
      expect(provider.categoryFilter, isNull);
    });

    test('setCategoryFilter 设置分类筛选', () {
      provider.setCategoryFilter('cat_1');
      expect(provider.categoryFilter, 'cat_1');
      expect(provider.currentIndex, 0);
    });

    test('setCategoryFilter 重置 currentIndex', () {
      final v = VideoModel(
        id: '1', title: 'A', author: '', description: '', url: '', thumbnail: '',
        likes: '0', comments: '0', shares: '0',
      );
      provider.videos.add(v);
      provider.setCurrentIndex(0);
      provider.setCategoryFilter('cat_1');
      expect(provider.currentIndex, 0);
    });

    test('videos 按分类筛选', () {
      final v1 = VideoModel(
        id: '1', title: 'A', author: '', description: '', url: '', thumbnail: '',
        likes: '0', comments: '0', shares: '0', categoryId: 'cat_1',
      );
      final v2 = VideoModel(
        id: '2', title: 'B', author: '', description: '', url: '', thumbnail: '',
        likes: '0', comments: '0', shares: '0', categoryId: 'cat_2',
      );
      final v3 = VideoModel(
        id: '3', title: 'C', author: '', description: '', url: '', thumbnail: '',
        likes: '0', comments: '0', shares: '0',
      );
      provider.videos.addAll([v1, v2, v3]);

      provider.setCategoryFilter('cat_1');
      expect(provider.videos.length, 1);
      expect(provider.videos.first.id, '1');

      provider.setCategoryFilter(null);
      expect(provider.videos.length, 3);
    });

    test('updateVideoInfo 更新标题和描述', () {
      final v = VideoModel(
        id: '1', title: '旧标题', author: '', description: '旧描述', url: '', thumbnail: '',
        likes: '0', comments: '0', shares: '0',
      );
      provider.videos.add(v);

      provider.updateVideoInfo('1', title: '新标题', description: '新描述');
      expect(provider.videos.first.title, '新标题');
      expect(provider.videos.first.description, '新描述');
    });

    test('updateVideoInfo 只更新标题', () {
      final v = VideoModel(
        id: '1', title: '旧标题', author: '', description: '旧描述', url: '', thumbnail: '',
        likes: '0', comments: '0', shares: '0',
      );
      provider.videos.add(v);

      provider.updateVideoInfo('1', title: '新标题');
      expect(provider.videos.first.title, '新标题');
      expect(provider.videos.first.description, '旧描述');
    });

    test('updateVideoInfo 无效 id 不抛异常', () {
      expect(() => provider.updateVideoInfo('nonexistent', title: 'x'), returnsNormally);
    });

    test('batchDelete 批量删除', () async {
      final v1 = VideoModel(
        id: '1', title: 'A', author: '', description: '', url: '', thumbnail: '',
        likes: '0', comments: '0', shares: '0',
      );
      final v2 = VideoModel(
        id: '2', title: 'B', author: '', description: '', url: '', thumbnail: '',
        likes: '0', comments: '0', shares: '0',
      );
      final v3 = VideoModel(
        id: '3', title: 'C', author: '', description: '', url: '', thumbnail: '',
        likes: '0', comments: '0', shares: '0',
      );
      provider.videos.addAll([v1, v2, v3]);

      await provider.batchDelete(['1', '3']);
      expect(provider.videos.length, 1);
      expect(provider.videos.first.id, '2');
    });

    test('batchDelete 空列表不抛异常', () async {
      await provider.batchDelete([]);
      expect(provider.videos, isEmpty);
    });

    test('batchSetCategory 批量归类', () {
      final v1 = VideoModel(
        id: '1', title: 'A', author: '', description: '', url: '', thumbnail: '',
        likes: '0', comments: '0', shares: '0',
      );
      final v2 = VideoModel(
        id: '2', title: 'B', author: '', description: '', url: '', thumbnail: '',
        likes: '0', comments: '0', shares: '0',
      );
      provider.videos.addAll([v1, v2]);

      provider.batchSetCategory(['1', '2'], 'cat_1');
      expect(provider.videos[0].categoryId, 'cat_1');
      expect(provider.videos[1].categoryId, 'cat_1');
    });

    test('batchSetCategory 取消归类', () {
      final v = VideoModel(
        id: '1', title: 'A', author: '', description: '', url: '', thumbnail: '',
        likes: '0', comments: '0', shares: '0', categoryId: 'cat_1',
      );
      provider.videos.add(v);

      provider.batchSetCategory(['1'], null);
      expect(provider.videos.first.categoryId, isNull);
    });

    test('VideoModel categoryId 序列化', () {
      final v = VideoModel(
        id: '1', title: 'A', author: '', description: '', url: '', thumbnail: '',
        likes: '0', comments: '0', shares: '0', categoryId: 'cat_1',
      );
      final json = v.toJson();
      expect(json['categoryId'], 'cat_1');

      final restored = VideoModel.fromJson(json);
      expect(restored.categoryId, 'cat_1');
    });

    test('VideoModel categoryId 默认为 null', () {
      final v = VideoModel(
        id: '1', title: '', author: '', description: '', url: '', thumbnail: '',
        likes: '0', comments: '0', shares: '0',
      );
      expect(v.categoryId, isNull);
    });
  });
}
