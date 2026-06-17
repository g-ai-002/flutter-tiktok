class PlaylistModel {
  final String id;
  String name;
  final List<String> videoIds;
  final String createdAt;

  PlaylistModel({
    required this.id,
    required this.name,
    List<String>? videoIds,
    String? createdAt,
  })  : videoIds = videoIds ?? [],
        createdAt = createdAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'videoIds': videoIds,
        'createdAt': createdAt,
      };

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      videoIds: (json['videoIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: json['createdAt'] as String?,
    );
  }
}
