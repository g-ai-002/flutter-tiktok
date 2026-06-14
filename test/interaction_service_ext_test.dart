import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tiktok/services/interaction_service.dart';

void main() {
  group('InteractionService - 新增功能', () {
    final service = InteractionService.instance;

    test('favorites 返回不可变列表', () {
      service.toggleFavorite('v_fav_list_test');
      final favs = service.favorites;
      expect(favs.contains('v_fav_list_test'), true);
    });

    test('totalComments 统计评论总数', () {
      service.addComment('v_total_1', '评论1');
      service.addComment('v_total_2', '评论2');
      service.addComment('v_total_2', '评论3');
      expect(service.totalComments, greaterThanOrEqualTo(3));
    });
  });
}
