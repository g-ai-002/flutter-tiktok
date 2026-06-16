import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tiktok/services/interaction_service.dart';

void main() {
  group('InteractionService - 新增功能', () {
    final service = InteractionService.instance;

    tearDown(() {
      service.reset();
    });

    test('clearHistory 清除所有历史记录', () {
      service.addToHistory('v_h1');
      service.addToHistory('v_h2');
      expect(service.history.isNotEmpty, true);

      service.clearHistory();
      expect(service.history, isEmpty);
    });

    test('clearHistory 后 addToHistory 仍正常工作', () {
      service.clearHistory();
      service.addToHistory('v_new');
      expect(service.history.length, 1);
      expect(service.history[0], 'v_new');
    });
  });
}
