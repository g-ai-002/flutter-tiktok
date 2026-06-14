import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tiktok/models/comment.dart';

void main() {
  group('CommentModel', () {
    test('fromJson creates correct model', () {
      final json = <String, dynamic>{
        'id': 'cmt_1',
        'videoId': 'v1',
        'author': '测试用户',
        'content': '好视频',
        'createdAt': '2025-06-15T10:00:00.000',
      };

      final comment = CommentModel.fromJson(json);

      expect(comment.id, 'cmt_1');
      expect(comment.videoId, 'v1');
      expect(comment.author, '测试用户');
      expect(comment.content, '好视频');
      expect(comment.createdAt, DateTime(2025, 6, 15, 10, 0, 0));
    });

    test('toJson and fromJson roundtrip', () {
      final comment = CommentModel(
        id: 'cmt_1',
        videoId: 'v1',
        author: '我',
        content: '不错',
        createdAt: DateTime(2025, 6, 15),
      );

      final json = comment.toJson();
      final restored = CommentModel.fromJson(json);

      expect(restored.id, comment.id);
      expect(restored.videoId, comment.videoId);
      expect(restored.author, comment.author);
      expect(restored.content, comment.content);
    });

    test('fromJson handles missing fields', () {
      final comment = CommentModel.fromJson({});
      expect(comment.id, '');
      expect(comment.videoId, '');
      expect(comment.author, '匿名用户');
      expect(comment.content, '');
    });
  });
}
