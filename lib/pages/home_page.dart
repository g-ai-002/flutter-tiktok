import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/video_provider.dart';
import '../services/interaction_service.dart';
import '../services/video_preload_service.dart';
import '../widgets/video_page.dart';
import '../widgets/top_toolbar.dart';
import '../widgets/video_list_sheet.dart';
import '../widgets/comment_sheet.dart';
import '../widgets/video_item_list_sheet.dart';

class HomePage extends StatefulWidget {
  final PageController pageController;

  const HomePage({super.key, required this.pageController});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _onPageChanged(int index) {
    final provider = context.read<VideoProvider>();
    provider.setCurrentIndex(index);
    final video = provider.videos[index];
    InteractionService.instance.addToHistory(video.id);
    final urls = provider.videos.map((v) => v.url).toList();
    VideoPreloadService.instance.preloadAdjacent(urls, index);
  }

  Future<void> _refreshVideos() async {
    await context.read<VideoProvider>().refreshVideos();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : Colors.white;
    final emptyIconColor = isDark ? Colors.white24 : Colors.black12;
    final emptyTextColor = isDark ? Colors.white54 : Colors.black54;
    final emptySubColor = isDark ? Colors.white30 : Colors.black26;

    return Consumer<VideoProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return Scaffold(
            backgroundColor: bgColor,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.videos.isEmpty) {
          return Scaffold(
            backgroundColor: bgColor,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.video_library_outlined, color: emptyIconColor, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      '还没有视频',
                      style: TextStyle(color: emptyTextColor, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '点击下方按钮导入本地视频开始浏览',
                      style: TextStyle(color: emptySubColor, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => provider.importLocalVideos(),
                      icon: const Icon(Icons.add),
                      label: const Text('导入视频'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFE2C55),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: bgColor,
          body: Stack(
            children: [
              RefreshIndicator(
                color: const Color(0xFFFE2C55),
                backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                onRefresh: _refreshVideos,
                child: PageView.builder(
                  controller: widget.pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: provider.videos.length,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, index) {
                    final video = provider.videos[index];
                    final isActive = index == provider.currentIndex;
                    return VideoPage(
                      video: video,
                      isActive: isActive,
                      onLike: () => provider.toggleLike(video.id),
                      onComment: () => CommentSheet.show(context, video),
                      onShare: () {},
                      onFavorite: () => InteractionService.instance.toggleFavorite(video.id),
                    );
                  },
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 0,
                right: 0,
                child: TopToolbar(
                  onImport: () => provider.importLocalVideos(),
                  onManage: () => _showVideoList(context, provider),
                  onHistory: () {
                    final historyVideos = provider.getVideosByIds(InteractionService.instance.history);
                    VideoItemListSheet.show(
                      context,
                      title: '观看历史',
                      videos: historyVideos,
                      provider: provider,
                      onVideoSelected: (idx) => widget.pageController.jumpToPage(idx),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showVideoList(BuildContext context, VideoProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => VideoListSheet(provider: provider),
    );
  }
}
