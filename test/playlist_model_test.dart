import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tiktok/models/playlist.dart';

void main() {
  group('PlaylistModel', () {
    test('fromJson creates correct model', () {
      final json = <String, dynamic>{
        'id': 'pl_1',
        'name': '我的收藏',
        'videoIds': ['v1', 'v2'],
        'createdAt': '2025-01-01T00:00:00.000',
      };

      final pl = PlaylistModel.fromJson(json);

      expect(pl.id, 'pl_1');
      expect(pl.name, '我的收藏');
      expect(pl.videoIds, ['v1', 'v2']);
      expect(pl.createdAt, '2025-01-01T00:00:00.000');
    });

    test('toJson and fromJson roundtrip', () {
      final pl = PlaylistModel(
        id: 'pl_1',
        name: '测试列表',
        videoIds: ['a', 'b', 'c'],
        createdAt: '2025-06-01T12:00:00.000',
      );

      final json = pl.toJson();
      final restored = PlaylistModel.fromJson(json);

      expect(restored.id, pl.id);
      expect(restored.name, pl.name);
      expect(restored.videoIds, pl.videoIds);
      expect(restored.createdAt, pl.createdAt);
    });

    test('fromJson handles missing fields', () {
      final pl = PlaylistModel.fromJson({});
      expect(pl.id, '');
      expect(pl.name, '');
      expect(pl.videoIds, isEmpty);
    });

    test('videoIds defaults to empty list', () {
      final pl = PlaylistModel(id: 'pl_1', name: '测试');
      expect(pl.videoIds, isEmpty);
    });

    test('createdAt defaults to current time', () {
      final pl = PlaylistModel(id: 'pl_1', name: '测试');
      expect(pl.createdAt, isNotEmpty);
    });

    test('name is mutable', () {
      final pl = PlaylistModel(id: 'pl_1', name: '旧名称');
      pl.name = '新名称';
      expect(pl.name, '新名称');
    });
  });
}
