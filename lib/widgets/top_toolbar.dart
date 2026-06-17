import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/video_provider.dart';
import '../services/category_service.dart';

class TopToolbar extends StatelessWidget {
  final VoidCallback onImport;
  final VoidCallback onManage;
  final VoidCallback onHistory;
  final VoidCallback onPlaylist;
  final VoidCallback onSleepTimer;

  const TopToolbar({
    super.key,
    required this.onImport,
    required this.onManage,
    required this.onHistory,
    required this.onPlaylist,
    required this.onSleepTimer,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final iconBgColor = isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.06);
    final iconColor = isDark ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _CategoryChip(
            textColor: textColor,
            iconBgColor: iconBgColor,
          ),
          const Spacer(),
          _ToolIcon(icon: Icons.bedtime_outlined, onTap: onSleepTimer, bgColor: iconBgColor, iconColor: iconColor),
          const SizedBox(width: 12),
          _ToolIcon(icon: Icons.playlist_play, onTap: onPlaylist, bgColor: iconBgColor, iconColor: iconColor),
          const SizedBox(width: 12),
          _ToolIcon(icon: Icons.history, onTap: onHistory, bgColor: iconBgColor, iconColor: iconColor),
          const SizedBox(width: 12),
          _ToolIcon(icon: Icons.file_upload_outlined, onTap: onImport, bgColor: iconBgColor, iconColor: iconColor),
          const SizedBox(width: 12),
          _ToolIcon(icon: Icons.list_alt, onTap: onManage, bgColor: iconBgColor, iconColor: iconColor),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final Color textColor;
  final Color iconBgColor;

  const _CategoryChip({required this.textColor, required this.iconBgColor});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VideoProvider>();
    final categories = CategoryService.instance.categories;
    final currentFilter = provider.categoryFilter;
    final label = currentFilter != null
        ? categories.where((c) => c.id == currentFilter).map((c) => c.name).firstOrNull ?? '分类'
        : '推荐';

    return GestureDetector(
      onTap: () => _showCategorySheet(context, provider, categories),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, color: textColor, size: 18),
          ],
        ),
      ),
    );
  }

  void _showCategorySheet(BuildContext context, VideoProvider provider, List categories) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white54 : Colors.black54;

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '视频分类',
                  style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              ListTile(
                leading: Icon(Icons.all_inclusive, color: provider.categoryFilter == null ? const Color(0xFFFE2C55) : subColor),
                title: Text(
                  '全部视频',
                  style: TextStyle(
                    color: provider.categoryFilter == null ? const Color(0xFFFE2C55) : textColor,
                    fontWeight: provider.categoryFilter == null ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                onTap: () {
                  provider.setCategoryFilter(null);
                  Navigator.pop(context);
                },
              ),
              ...categories.map((cat) {
                final isSelected = provider.categoryFilter == cat.id;
                return ListTile(
                  leading: Icon(
                    Icons.folder,
                    color: isSelected ? Color(cat.colorValue) : subColor,
                  ),
                  title: Text(
                    cat.name,
                    style: TextStyle(
                      color: isSelected ? Color(cat.colorValue) : textColor,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    provider.setCategoryFilter(cat.id);
                    Navigator.pop(context);
                  },
                );
              }),
              const Divider(),
              ListTile(
                leading: Icon(Icons.add, color: subColor),
                title: Text('新建分类', style: TextStyle(color: textColor)),
                onTap: () {
                  Navigator.pop(context);
                  _showCreateCategoryDialog(context);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showCreateCategoryDialog(BuildContext context) {
    final controller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        title: Text('新建分类', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: '输入分类名称',
            hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('取消', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                CategoryService.instance.addCategory(name);
                Navigator.pop(ctx);
              }
            },
            child: const Text('确定', style: TextStyle(color: Color(0xFFFE2C55))),
          ),
        ],
      ),
    );
  }
}

class _ToolIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color bgColor;
  final Color iconColor;

  const _ToolIcon({required this.icon, required this.onTap, required this.bgColor, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }
}
