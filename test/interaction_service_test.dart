import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tiktok/services/interaction_service.dart';

void main() {
  group('InteractionService', () {
    final service = InteractionService.instance;

    tearDown(() {
      service.reset();
    });

    test('addComment and getComments', () {
      service.addComment('v_test_1', '好视频');
      service.addComment('v_test_1', '不错');

      final comments = service.getComments('v_test_1');
      expect(comments.length, greaterThanOrEqualTo(2));
    });

    test('getComments returns empty for unknown video', () {
      expect(service.getComments('unknown_video_id'), isEmpty);
    });

    test('toggleFavorite toggles state', () {
      expect(service.isFavorite('v_fav_test'), false);
      service.toggleFavorite('v_fav_test');
      expect(service.isFavorite('v_fav_test'), true);
      service.toggleFavorite('v_fav_test');
      expect(service.isFavorite('v_fav_test'), false);
    });

    test('addToHistory maintains order', () {
      service.addToHistory('v_h1');
      service.addToHistory('v_h2');
      service.addToHistory('v_h1');

      final history = service.history;
      expect(history[0], 'v_h1');
      expect(history[1], 'v_h2');
    });
  });
}
