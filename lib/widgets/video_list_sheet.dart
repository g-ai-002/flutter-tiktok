import 'package:flutter/material.dart';
import '../providers/video_provider.dart';

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
                TextButton(
                  onPressed: () {
                    provider.resetToSampleVideos();
                    Navigator.pop(context);
                  },
                  child: const Text('恢复默认', style: TextStyle(color: Colors.white54)),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.builder(
              itemCount: provider.videos.length,
              itemBuilder: (context, index) {
                final video = provider.videos[index];
                return ListTile(
                  leading: const Icon(Icons.videocam, color: Colors.white54),
                  title: Text(
                    video.title,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    video.author,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  trailing: video.id.startsWith('local_')
                      ? IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                          onPressed: () => provider.removeVideo(video.id),
                        )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
