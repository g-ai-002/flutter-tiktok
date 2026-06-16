import 'dart:convert';
import '../models/category.dart';
import '../services/log_service.dart';
import '../services/file_system_service.dart';

class CategoryService {
  static final CategoryService instance = CategoryService._();
  CategoryService._();

  final List<CategoryModel> _categories = [];
  final Map<String, String> _videoCategory = {};

  List<CategoryModel> get categories => List.unmodifiable(_categories);
  String? getCategoryId(String videoId) => _videoCategory[videoId];

  List<String> getVideoIds(String categoryId) =>
      _videoCategory.entries.where((e) => e.value == categoryId).map((e) => e.key).toList();

  void addCategory(String name, {int colorValue = 0xFFFE2C55}) {
    final cat = CategoryModel(
      id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      colorValue: colorValue,
    );
    _categories.add(cat);
    _save();
    LogService.info('创建分类: $name');
  }

  void renameCategory(String categoryId, String newName) {
    final idx = _categories.indexWhere((c) => c.id == categoryId);
    if (idx == -1) return;
    _categories[idx].name = newName;
    _save();
    LogService.info('重命名分类: $categoryId -> $newName');
  }

  void deleteCategory(String categoryId) {
    _categories.removeWhere((c) => c.id == categoryId);
    _videoCategory.removeWhere((_, catId) => catId == categoryId);
    _save();
    LogService.info('删除分类: $categoryId');
  }

  void setVideoCategory(String videoId, String? categoryId) {
    if (categoryId == null) {
      _videoCategory.remove(videoId);
    } else {
      _videoCategory[videoId] = categoryId;
    }
    _save();
  }

  void batchSetCategory(List<String> videoIds, String? categoryId) {
    for (final id in videoIds) {
      if (categoryId == null) {
        _videoCategory.remove(id);
      } else {
        _videoCategory[id] = categoryId;
      }
    }
    _save();
  }

  Future<void> _save() async {
    try {
      final file = await FileSystemService.instance.getUserFile('categories.json');
      final data = {
        'categories': _categories.map((c) => c.toJson()).toList(),
        'videoCategory': _videoCategory,
      };
      await file.writeAsString(jsonEncode(data));
    } catch (e, st) {
      LogService.error('保存分类数据失败', e, st);
    }
  }

  Future<void> init() async {
    try {
      final file = await FileSystemService.instance.getUserFile('categories.json');
      if (!await file.exists()) return;
      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      final cats = (data['categories'] as List?)
          ?.map((j) => CategoryModel.fromJson(j as Map<String, dynamic>))
          .toList() ?? [];
      _categories.addAll(cats);
      final vc = data['videoCategory'] as Map<String, dynamic>?;
      if (vc != null) {
        _videoCategory.addAll(vc.map((k, v) => MapEntry(k, v as String)));
      }
    } catch (e, st) {
      LogService.error('加载分类数据失败', e, st);
    }
  }
}
