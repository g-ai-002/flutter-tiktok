import 'package:flutter/material.dart';
import '../models/video.dart';
import '../providers/video_provider.dart';
import '../services/category_service.dart';
import '../utils/format.dart';

class VideoListSheet extends StatefulWidget {
  final VideoProvider provider;
  const VideoListSheet({super.key, required this.provider});

  @override
  State<VideoListSheet> createState() => _VideoListSheetState();
}

class _VideoListSheetState extends State<VideoListSheet> {
  final Set<String> _selectedIds = {};
  bool _batchMode = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white70 : Colors.black54;
    final subTextColor = isDark ? Colors.white38 : Colors.black38;
    final iconColor = isDark ? Colors.white54 : Colors.black38;
    final chipBg = isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.06);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(
                  '视频列表',
                  style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                if (_batchMode) ...[
                  _ActionChip(
                    icon: Icons.close,
                    label: '取消',
                    onTap: () => setState(() {
                      _batchMode = false;
                      _selectedIds.clear();
                    }),
                    textColor: subColor,
                    chipBg: chipBg,
                  ),
                  const SizedBox(width: 8),
                  _ActionChip(
                    icon: Icons.folder,
                    label: '归类',
                    onTap: _selectedIds.isNotEmpty ? () => _showBatchCategorySheet(context) : null,
                    textColor: subColor,
                    chipBg: chipBg,
                  ),
                  const SizedBox(width: 8),
                  _ActionChip(
                    icon: Icons.delete,
                    label: '删除(${_selectedIds.length})',
                    onTap: _selectedIds.isNotEmpty ? () => _confirmBatchDelete(context) : null,
                    textColor: Colors.redAccent,
                    chipBg: chipBg,
                  ),
                ] else ...[
                  _ActionChip(
                    icon: Icons.checklist,
                    label: '批量',
                    onTap: () => setState(() => _batchMode = true),
                    textColor: subColor,
                    chipBg: chipBg,
                  ),
                  const SizedBox(width: 8),
                  _SortChip(
                    label: _sortLabel(widget.provider.sortMode),
                    ascending: widget.provider.sortAscending,
                    onTap: () => _showSortSheet(context, widget.provider),
                    textColor: subColor,
                    chipBg: chipBg,
                  ),
                ],
              ],
            ),
          ),
          Flexible(
            child: ListView.builder(
              itemCount: widget.provider.allVideos.length,
              itemBuilder: (context, index) {
                final video = widget.provider.allVideos[index];
                final isSelected = _selectedIds.contains(video.id);
                return _VideoTile(
                  video: video,
                  batchMode: _batchMode,
                  isSelected: isSelected,
                  onTap: _batchMode
                      ? () {
                          setState(() {
                            if (isSelected) {
                              _selectedIds.remove(video.id);
                            } else {
                              _selectedIds.add(video.id);
                            }
                          });
                        }
                      : null,
                  onEdit: video.id.startsWith('local_') && !_batchMode
                      ? () => _showEditDialog(context, video)
                      : null,
                  onDelete: video.id.startsWith('local_') && !_batchMode
                      ? () => widget.provider.removeVideo(video.id)
                      : null,
                  onCategory: video.id.startsWith('local_') && !_batchMode
                      ? () => _showCategoryPicker(context, video)
                      : null,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  iconColor: iconColor,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _sortLabel(VideoSortMode mode) {
    switch (mode) {
      case VideoSortMode.importTime:
        return '导入时间';
      case VideoSortMode.name:
        return '名称';
      case VideoSortMode.duration:
        return '时长';
      case VideoSortMode.fileSize:
        return '大小';
    }
  }

  void _showSortSheet(BuildContext context, VideoProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

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
                  '排序方式',
                  style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              for (final mode in VideoSortMode.values)
                ListTile(
                  title: Text(
                    _sortLabel(mode),
                    style: TextStyle(
                      color: provider.sortMode == mode ? const Color(0xFFFE2C55) : textColor,
                      fontWeight: provider.sortMode == mode ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  trailing: provider.sortMode == mode
                      ? Icon(
                          provider.sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                          color: const Color(0xFFFE2C55),
                          size: 18,
                        )
                      : null,
                  onTap: () {
                    provider.setSortMode(mode);
                    Navigator.pop(context);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, VideoModel video) {
    final titleCtrl = TextEditingController(text: video.title);
    final descCtrl = TextEditingController(text: video.description);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        title: Text('编辑视频信息', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: '标题',
                labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: '描述',
                labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('取消', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
          ),
          TextButton(
            onPressed: () {
              widget.provider.updateVideoInfo(
                video.id,
                title: titleCtrl.text.trim(),
                description: descCtrl.text.trim(),
              );
              Navigator.pop(ctx);
            },
            child: const Text('保存', style: TextStyle(color: Color(0xFFFE2C55))),
          ),
        ],
      ),
    );
  }

  void _showCategoryPicker(BuildContext context, VideoModel video) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white54 : Colors.black54;
    final categories = CategoryService.instance.categories;

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
                  '选择分类',
                  style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              ListTile(
                leading: Icon(Icons.folder_off, color: video.categoryId == null ? const Color(0xFFFE2C55) : subColor),
                title: Text(
                  '无分类',
                  style: TextStyle(
                    color: video.categoryId == null ? const Color(0xFFFE2C55) : textColor,
                    fontWeight: video.categoryId == null ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                onTap: () {
                  widget.provider.setVideoCategory(video.id, null);
                  Navigator.pop(context);
                },
              ),
              ...categories.map((cat) {
                final isSelected = video.categoryId == cat.id;
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
                    widget.provider.setVideoCategory(video.id, cat.id);
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showBatchCategorySheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white54 : Colors.black54;
    final categories = CategoryService.instance.categories;

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
                  '批量归类 (${_selectedIds.length}个)',
                  style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              ListTile(
                leading: Icon(Icons.folder_off, color: subColor),
                title: Text('无分类', style: TextStyle(color: textColor)),
                onTap: () {
                  widget.provider.batchSetCategory(_selectedIds.toList(), null);
                  setState(() {
                    _batchMode = false;
                    _selectedIds.clear();
                  });
                  Navigator.pop(context);
                },
              ),
              ...categories.map((cat) {
                return ListTile(
                  leading: Icon(Icons.folder, color: Color(cat.colorValue)),
                  title: Text(cat.name, style: TextStyle(color: textColor)),
                  onTap: () {
                    widget.provider.batchSetCategory(_selectedIds.toList(), cat.id);
                    setState(() {
                      _batchMode = false;
                      _selectedIds.clear();
                    });
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _confirmBatchDelete(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        title: Text('确认删除', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        content: Text(
          '确定要删除选中的 ${_selectedIds.length} 个视频吗？',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('取消', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
          ),
          TextButton(
            onPressed: () {
              widget.provider.batchDelete(_selectedIds.toList());
              setState(() {
                _batchMode = false;
                _selectedIds.clear();
              });
              Navigator.pop(ctx);
            },
            child: const Text('删除', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool ascending;
  final VoidCallback onTap;
  final Color textColor;
  final Color chipBg;

  const _SortChip({required this.label, required this.ascending, required this.onTap, required this.textColor, required this.chipBg});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: chipBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(color: textColor, fontSize: 12)),
            const SizedBox(width: 4),
            Icon(
              ascending ? Icons.arrow_upward : Icons.arrow_downward,
              color: textColor,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color textColor;
  final Color chipBg;

  const _ActionChip({required this.icon, required this.label, this.onTap, required this.textColor, required this.chipBg});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: chipBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: textColor, size: 14),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: textColor, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _VideoTile extends StatelessWidget {
  final VideoModel video;
  final bool batchMode;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onCategory;
  final Color textColor;
  final Color subTextColor;
  final Color iconColor;

  const _VideoTile({
    required this.video,
    required this.batchMode,
    required this.isSelected,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onCategory,
    required this.textColor,
    required this.subTextColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final catName = video.categoryId != null
        ? CategoryService.instance.categories.where((c) => c.id == video.categoryId).map((c) => c.name).firstOrNull
        : null;

    return ListTile(
      leading: batchMode
          ? Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? const Color(0xFFFE2C55) : iconColor,
            )
          : Icon(Icons.videocam, color: iconColor),
      title: Text(
        video.title,
        style: TextStyle(color: textColor, fontSize: 14),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        catName != null ? '$catName · ${buildVideoSubtitle(video, includeFileSize: true)}' : buildVideoSubtitle(video, includeFileSize: true),
        style: TextStyle(color: subTextColor, fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: batchMode
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onCategory != null)
                  IconButton(
                    icon: Icon(Icons.folder_outlined, color: iconColor, size: 18),
                    onPressed: onCategory,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                if (onEdit != null)
                  IconButton(
                    icon: Icon(Icons.edit_outlined, color: iconColor, size: 18),
                    onPressed: onEdit,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
              ],
            ),
      onTap: onTap,
    );
  }
}
