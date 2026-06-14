import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tiktok/providers/video_provider.dart';
import 'package:flutter_tiktok/services/storage_service.dart';

void main() {
  group('VideoProvider', () {
    late VideoProvider provider;
    late StorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = await StorageService.instance;
      provider = VideoProvider(storage);
    });

    test('toggleLike toggles isLiked and updates count', () {
      final video = provider.videos.first;
      final initialLiked = video.isLiked;
      final initialLikes = int.parse(video.likes);

      provider.toggleLike(video.id);

      expect(video.isLiked, !initialLiked);
      if (video.isLiked) {
        expect(int.parse(video.likes), initialLikes + 1);
      } else {
        expect(int.parse(video.likes), initialLikes > 0 ? initialLikes - 1 : 0);
      }
    });

    test('toggleLike with invalid id does not throw', () {
      expect(() => provider.toggleLike('nonexistent'), returnsNormally);
    });

    test('setCurrentIndex within bounds', () {
      provider.setCurrentIndex(2);
      expect(provider.currentIndex, 2);
    });

    test('setCurrentIndex out of bounds is ignored', () {
      final originalIndex = provider.currentIndex;
      provider.setCurrentIndex(999);
      expect(provider.currentIndex, originalIndex);
    });

    test('currentVideo returns correct video', () {
      final video = provider.currentVideo;
      expect(video, isNotNull);
      expect(video!.id, provider.videos[provider.currentIndex].id);
    });
  });
}
