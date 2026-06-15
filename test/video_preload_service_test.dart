import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tiktok/services/video_preload_service.dart';

void main() {
  group('VideoPreloadService', () {
    final service = VideoPreloadService.instance;

    test('preload with invalid url does not throw', () {
      expect(() => service.preload('not_a_valid_url_!@#'), returnsNormally);
    });

    test('preload with non-existent local file does not throw', () {
      expect(() => service.preload('/nonexistent/path/video.mp4'), returnsNormally);
    });

    test('getController returns null for unknown url', () {
      expect(service.getController('unknown_url'), isNull);
    });

    test('preloadAdjacent with empty list does not throw', () {
      expect(() => service.preloadAdjacent([], 0), returnsNormally);
    });

    test('preloadAdjacent with single item does not throw', () {
      expect(() => service.preloadAdjacent(['url1'], 0), returnsNormally);
    });

    test('clear does not throw', () {
      expect(() => service.clear(), returnsNormally);
    });
  });
}
