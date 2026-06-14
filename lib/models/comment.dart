class CommentModel {
  final String id;
  final String videoId;
  final String author;
  final String content;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.videoId,
    required this.author,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'videoId': videoId,
        'author': author,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String? ?? '',
      videoId: json['videoId'] as String? ?? '',
      author: json['author'] as String? ?? '匿名用户',
      content: json['content'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
