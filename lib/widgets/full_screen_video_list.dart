import 'package:flutter/material.dart';
import '../models/video.dart';
import '../providers/video_provider.dart';
import '../utils/format.dart';

class FullScreenVideoList extends StatelessWidget {
  final String title;
  final List<VideoModel> videos;
  final VideoProvider provider;
  final void Function(int index)? onVideoSelected;

  const FullScreenVideoList({
    super.key,
    required this.title,
    required this.videos,
    required this.provider,
    this.onVideoSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white38 : Colors.black38;
    final iconColor = isDark ? Colors.white54 : Colors.black38;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(title, style: TextStyle(color: textColor)),
        backgroundColor: bgColor,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: videos.isEmpty
          ? Center(child: Text('暂无内容', style: TextStyle(color: subColor)))
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
    );
  }
}
