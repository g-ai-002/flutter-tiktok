import 'package:flutter/material.dart';
import '../models/video.dart';
import '../providers/video_provider.dart';

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
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
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
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          Flexible(
            child: videos.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('暂无内容', style: TextStyle(color: Colors.white38))),
                  )
                : ListView.builder(
                    itemCount: videos.length,
                    itemBuilder: (_, i) {
                      final v = videos[i];
                      return ListTile(
                        leading: const Icon(Icons.play_circle_outline, color: Colors.white54),
                        title: Text(
                          v.title,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(v.author, style: const TextStyle(color: Colors.white38, fontSize: 12)),
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
