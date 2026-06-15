import 'package:flutter/material.dart';
import '../models/video.dart';
import '../providers/video_provider.dart';
import '../utils/format.dart';

class VideoListSheet extends StatelessWidget {
  final VideoProvider provider;
  const VideoListSheet({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Text(
                  '视频列表',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                _SortChip(
                  label: _sortLabel(provider.sortMode),
                  ascending: provider.sortAscending,
                  onTap: () => _showSortSheet(context, provider),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.builder(
              itemCount: provider.videos.length,
              itemBuilder: (context, index) {
                final video = provider.videos[index];
                return _VideoTile(
                  video: video,
                  onDelete: video.id.startsWith('local_')
                      ? () => provider.removeVideo(video.id)
                      : null,
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
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '排序方式',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              for (final mode in VideoSortMode.values)
                ListTile(
                  title: Text(
                    _sortLabel(mode),
                    style: TextStyle(
                      color: provider.sortMode == mode ? const Color(0xFFFE2C55) : Colors.white,
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
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool ascending;
  final VoidCallback onTap;

  const _SortChip({required this.label, required this.ascending, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(width: 4),
            Icon(
              ascending ? Icons.arrow_upward : Icons.arrow_downward,
              color: Colors.white54,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoTile extends StatelessWidget {
  final VideoModel video;
  final VoidCallback? onDelete;

  const _VideoTile({required this.video, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.videocam, color: Colors.white54),
      title: Text(
        video.title,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        _buildSubtitle(),
        style: const TextStyle(color: Colors.white38, fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: onDelete != null
          ? IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
              onPressed: onDelete,
            )
          : null,
    );
  }

  String _buildSubtitle() {
    final parts = <String>[];
    if (video.author.isNotEmpty) parts.add(video.author);
    if (video.durationMs > 0) parts.add(formatDuration(video.duration));
    if (video.resolution.isNotEmpty) parts.add(video.resolution);
    if (video.fileSize > 0) parts.add(video.fileSizeFormatted);
    return parts.join(' · ');
  }
}
