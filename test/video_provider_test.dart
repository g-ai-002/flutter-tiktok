import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tiktok/providers/video_provider.dart';
import 'package:flutter_tiktok/services/storage_service.dart';
import 'package:flutter_tiktok/models/video.dart';

void main() {
  group('VideoProvider', () {
    late VideoProvider provider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.instance;
      provider = VideoProvider(storage);
    });

    test('toggleLike with invalid id does not throw', () {
      expect(() => provider.toggleLike('nonexistent'), returnsNormally);
    });

    test('setCurrentIndex out of bounds is ignored', () {
      final originalIndex = provider.currentIndex;
      provider.setCurrentIndex(999);
      expect(provider.currentIndex, originalIndex);
    });

    test('initial state is loading', () {
      expect(provider.isLoading, true);
    });

    test('initial videos is empty', () {
      expect(provider.videos, isEmpty);
    });

    test('currentVideo is null when videos empty', () {
      expect(provider.currentVideo, isNull);
    });

    test('getVideosByIds returns empty for unknown ids', () {
      expect(provider.getVideosByIds(['unknown']), isEmpty);
    });

    test('incrementComments does not throw for invalid id', () {
      expect(() => provider.incrementComments('nonexistent'), returnsNormally);
    });

    test('getVideosByIds returns matching videos', () {
      final v1 = VideoModel(
        id: 'a', title: 'A', author: 'a', description: '', url: '', thumbnail: '',
        likes: '0', comments: '0', shares: '0',
      );
      final v2 = VideoModel(
        id: 'b', title: 'B', author: 'b', description: '', url: '', thumbnail: '',
        likes: '0', comments: '0', shares: '0',
      );
      provider.videos.addAll([v1, v2]);

      final result = provider.getVideosByIds(['a', 'c']);
      expect(result.length, 1);
      expect(result.first.id, 'a');
    });

    test('getVideosByIds with empty ids returns empty', () {
      expect(provider.getVideosByIds([]), isEmpty);
    });

    test('refreshVideos does not throw', () async {
      await provider.refreshVideos();
      expect(provider.isLoading, false);
    });

    test('initial sort mode is importTime', () {
      expect(provider.sortMode, VideoSortMode.importTime);
      expect(provider.sortAscending, false);
    });

    test('setSortMode toggles ascending on same mode', () {
      expect(provider.sortAscending, false);
      provider.setSortMode(VideoSortMode.importTime);
      expect(provider.sortAscending, true);
      provider.setSortMode(VideoSortMode.importTime);
      expect(provider.sortAscending, false);
    });

    test('setSortMode switches mode and resets ascending', () {
      provider.setSortMode(VideoSortMode.importTime);
      expect(provider.sortAscending, true);
      provider.setSortMode(VideoSortMode.name);
      expect(provider.sortMode, VideoSortMode.name);
      expect(provider.sortAscending, false);
    });

    test('sort by name works', () {
      final v1 = VideoModel(
        id: '1', title: 'C', author: '', description: '', url: '', thumbnail: '',
        likes: '0', comments: '0', shares: '0',
      );
      final v2 = VideoModel(
        id: '2', title: 'A', author: '', description: '', url: '', thumbnail: '',
        likes: '0', comments: '0', shares: '0',
      );
      final v3 = VideoModel(
        id: '3', title: 'B', author: '', description: '', url: '', thumbnail: '',
        likes: '0', comments: '0', shares: '0',
      );
      provider.videos.addAll([v1, v2, v3]);

      provider.setSortMode(VideoSortMode.name);
      expect(provider.videos[0].title, 'C');
      expect(provider.videos[1].title, 'B');
      expect(provider.videos[2].title, 'A');

      provider.setSortMode(VideoSortMode.name);
      expect(provider.videos[0].title, 'A');
      expect(provider.videos[1].title, 'B');
      expect(provider.videos[2].title, 'C');
    });

    test('sort by duration works', () {
      final v1 = VideoModel(
        id: '1', title: '', author: '', description: '', url: '', thumbnail: '',
        likes: '0', comments: '0', shares: '0', durationMs: 10000,
      );
      final v2 = VideoModel(
        id: '2', title: '', author: '', description: '', url: '', thumbnail: '',
        likes: '0', comments: '0', shares: '0', durationMs: 5000,
      );
      provider.videos.addAll([v1, v2]);

      provider.setSortMode(VideoSortMode.duration);
      expect(provider.videos[0].durationMs, 10000);
      expect(provider.videos[1].durationMs, 5000);
    });

    test('sort by fileSize works', () {
      final v1 = VideoModel(
        id: '1', title: '', author: '', description: '', url: '', thumbnail: '',
        likes: '0', comments: '0', shares: '0', fileSize: 1000,
      );
      final v2 = VideoModel(
        id: '2', title: '', author: '', description: '', url: '', thumbnail: '',
        likes: '0', comments: '0', shares: '0', fileSize: 2000,
      );
      provider.videos.addAll([v1, v2]);

      provider.setSortMode(VideoSortMode.fileSize);
      expect(provider.videos[0].fileSize, 2000);
      expect(provider.videos[1].fileSize, 1000);
    });
  });
}
