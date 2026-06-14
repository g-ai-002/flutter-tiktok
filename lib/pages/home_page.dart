import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/video.dart';
import '../providers/video_provider.dart';
import '../widgets/video_player_widget.dart';
import '../widgets/video_actions.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    context.read<VideoProvider>().setCurrentIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.videos.isEmpty) {
          return const Scaffold(
            body: Center(
              child: Text('暂无视频', style: TextStyle(color: Colors.white54, fontSize: 16)),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.black,
          body: PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: provider.videos.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              final video = provider.videos[index];
              final isActive = index == provider.currentIndex;
              return _VideoPage(
                video: video,
                isActive: isActive,
                onLike: () => provider.toggleLike(video.id),
                onComment: () {},
                onShare: () {},
              );
            },
          ),
        );
      },
    );
  }
}

class _VideoPage extends StatelessWidget {
  final VideoModel video;
  final bool isActive;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const _VideoPage({
    required this.video,
    required this.isActive,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        VideoPlayerWidget(videoUrl: video.url, isActive: isActive),
        // 底部信息区
        Positioned(
          left: 16,
          right: 80,
          bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                video.author,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                video.description,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.music_note, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      video.title,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // 右侧操作按钮
        Positioned(
          right: 12,
          bottom: 80,
          child: VideoActions(
            video: video,
            onLike: onLike,
            onComment: onComment,
            onShare: onShare,
          ),
        ),
      ],
    );
  }
}
