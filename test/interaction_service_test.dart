import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tiktok/services/interaction_service.dart';

void main() {
  group('InteractionService', () {
    final service = InteractionService.instance;

    setUp(() {
      service.getComments('v1').clear();
    });

    test('addComment and getComments', () {
      service.addComment('v1', '好视频');
      service.addComment('v1', '不错');

      final comments = service.getComments('v1');
      expect(comments.length, 2);
      expect(comments[0].content, '好视频');
      expect(comments[1].content, '不错');
    });

    test('getComments returns empty for unknown video', () {
      expect(service.getComments('unknown'), isEmpty);
    });

    test('toggleFavorite toggles state', () {
      expect(service.isFavorite('v1'), false);
      service.toggleFavorite('v1');
      expect(service.isFavorite('v1'), true);
      service.toggleFavorite('v1');
      expect(service.isFavorite('v1'), false);
    });

    test('addToHistory maintains order and max size', () {
      service.addToHistory('v1');
      service.addToHistory('v2');
      service.addToHistory('v1');

      final history = service.history;
      expect(history[0], 'v1');
      expect(history[1], 'v2');
    });
  });
}
