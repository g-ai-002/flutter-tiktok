import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tiktok/providers/video_provider.dart';
import 'package:flutter_tiktok/services/storage_service.dart';

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
  });

  testWidgets('VideoProvider loads sample videos', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.instance;
    final provider = VideoProvider(storage);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(provider.videos.length, 5);
    expect(provider.currentVideo, isNotNull);
  });

  testWidgets('toggleLike toggles isLiked and updates count', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.instance;
    final provider = VideoProvider(storage);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

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

  testWidgets('setCurrentIndex within bounds', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.instance;
    final provider = VideoProvider(storage);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    provider.setCurrentIndex(2);
    expect(provider.currentIndex, 2);
  });
}
