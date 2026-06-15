class VideoModel {
  final String id;
  final String title;
  final String author;
  final String description;
  final String url;
  final String thumbnail;
  String likes;
  String comments;
  final String shares;
  bool isLiked;
  final int durationMs;
  final String resolution;
  final int fileSize;
  final String importTime;

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
    this.durationMs = 0,
    this.resolution = '',
    this.fileSize = 0,
    String? importTime,
  }) : importTime = importTime ?? DateTime.now().toIso8601String();

  Duration get duration => Duration(milliseconds: durationMs);

  String get fileSizeFormatted {
    if (fileSize <= 0) return '';
    if (fileSize < 1024) return '${fileSize}B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    if (fileSize < 1024 * 1024 * 1024) return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
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
        'durationMs': durationMs,
        'resolution': resolution,
        'fileSize': fileSize,
        'importTime': importTime,
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
      durationMs: json['durationMs'] as int? ?? 0,
      resolution: json['resolution'] as String? ?? '',
      fileSize: json['fileSize'] as int? ?? 0,
      importTime: json['importTime'] as String?,
    );
  }
}
