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
  });
}
