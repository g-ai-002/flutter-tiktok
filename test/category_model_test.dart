import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tiktok/models/category.dart';

void main() {
  group('CategoryModel', () {
    test('fromJson creates correct model', () {
      final json = <String, dynamic>{
        'id': 'cat_1',
        'name': '搞笑',
        'colorValue': 0xFF25F4EE,
        'createdAt': '2025-01-01T00:00:00.000',
      };

      final cat = CategoryModel.fromJson(json);

      expect(cat.id, 'cat_1');
      expect(cat.name, '搞笑');
      expect(cat.colorValue, 0xFF25F4EE);
      expect(cat.createdAt, '2025-01-01T00:00:00.000');
    });

    test('toJson and fromJson roundtrip', () {
      final cat = CategoryModel(
        id: 'cat_1',
        name: '音乐',
        colorValue: 0xFFFE2C55,
        createdAt: '2025-06-01T12:00:00.000',
      );

      final json = cat.toJson();
      final restored = CategoryModel.fromJson(json);

      expect(restored.id, cat.id);
      expect(restored.name, cat.name);
      expect(restored.colorValue, cat.colorValue);
      expect(restored.createdAt, cat.createdAt);
    });

    test('fromJson handles missing fields', () {
      final cat = CategoryModel.fromJson({});
      expect(cat.id, '');
      expect(cat.name, '');
      expect(cat.colorValue, 0xFFFE2C55);
    });

    test('createdAt defaults to current time', () {
      final cat = CategoryModel(id: 'cat_1', name: '测试');
      expect(cat.createdAt, isNotEmpty);
    });

    test('name is mutable', () {
      final cat = CategoryModel(id: 'cat_1', name: '旧名称');
      cat.name = '新名称';
      expect(cat.name, '新名称');
    });
  });
}
