class VideoModel {
  final String id;
  final String title;
  final String author;
  final String description;
  final String url;
  final String thumbnail;
  final String likes;
  final String comments;
  final String shares;
  bool isLiked;

  VideoModel({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.url,
    required this.thumbnail,
    required this.likes,
    required this.comments,
    required this.shares,
    this.isLiked = false,
  });

  factory VideoModel.fromMap(Map<String, String> map) {
    return VideoModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      description: map['description'] ?? '',
      url: map['url'] ?? '',
      thumbnail: map['thumbnail'] ?? '',
      likes: map['likes'] ?? '0',
      comments: map['comments'] ?? '0',
      shares: map['shares'] ?? '0',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'description': description,
        'url': url,
        'thumbnail': thumbnail,
        'likes': likes,
        'comments': comments,
        'shares': shares,
        'isLiked': isLiked,
      };

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      author: json['author'] as String? ?? '',
      description: json['description'] as String? ?? '',
      url: json['url'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
      likes: json['likes'] as String? ?? '0',
      comments: json['comments'] as String? ?? '0',
      shares: json['shares'] as String? ?? '0',
      isLiked: json['isLiked'] as bool? ?? false,
    );
  }
}
