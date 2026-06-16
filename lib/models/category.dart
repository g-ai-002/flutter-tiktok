class CategoryModel {
  final String id;
  String name;
  final int colorValue;
  final String createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    this.colorValue = 0xFFFE2C55,
    String? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'colorValue': colorValue,
        'createdAt': createdAt,
      };

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      colorValue: json['colorValue'] as int? ?? 0xFFFE2C55,
      createdAt: json['createdAt'] as String?,
    );
  }
}
