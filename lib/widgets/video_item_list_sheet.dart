import 'package:flutter/material.dart';
import '../models/video.dart';
import '../providers/video_provider.dart';
import '../utils/format.dart';

class VideoItemListSheet extends StatelessWidget {
  final String title;
  final List<VideoModel> videos;
  final VideoProvider provider;
  final void Function(int index)? onVideoSelected;

  const VideoItemListSheet({
    super.key,
    required this.title,
    required this.videos,
    required this.provider,
    this.onVideoSelected,
  });

  static void show(
    BuildContext context, {
    required String title,
    required List<VideoModel> videos,
    required VideoProvider provider,
    void Function(int index)? onVideoSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => VideoItemListSheet(
        title: title,
        videos: videos,
        provider: provider,
        onVideoSelected: onVideoSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white38 : Colors.black38;
    final iconColor = isDark ? Colors.white54 : Colors.black38;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          Flexible(
            child: videos.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(child: Text('暂无内容', style: TextStyle(color: subColor))),
                  )
                : ListView.builder(
                    itemCount: videos.length,
                    itemBuilder: (_, i) {
                      final v = videos[i];
                      return ListTile(
                        leading: Icon(Icons.play_circle_outline, color: iconColor),
                        title: Text(
                          v.title,
                          style: TextStyle(color: textColor, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          buildVideoSubtitle(v),
                          style: TextStyle(color: subColor, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          final idx = provider.videos.indexWhere((pv) => pv.id == v.id);
                          if (idx != -1) {
                            onVideoSelected?.call(idx);
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
