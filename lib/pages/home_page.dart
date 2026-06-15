import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/video_provider.dart';
import '../services/interaction_service.dart';
import '../services/video_preload_service.dart';
import '../widgets/video_page.dart';
import '../widgets/top_toolbar.dart';
import '../widgets/video_list_sheet.dart';
import '../models/video.dart';

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
    VideoPreloadService.instance.preloadAdjacent(
      provider.videos.map((v) => v.url).toList(),
      index,
    );
  }

  Future<void> _refreshVideos() async {
    await context.read<VideoProvider>().refreshVideos();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.videos.isEmpty) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.video_library_outlined, color: Colors.white24, size: 64),
                    const SizedBox(height: 16),
                    const Text(
                      '还没有视频',
                      style: TextStyle(color: Colors.white54, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '点击下方按钮导入本地视频开始浏览',
                      style: TextStyle(color: Colors.white30, fontSize: 14),
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
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              RefreshIndicator(
                color: const Color(0xFFFE2C55),
                backgroundColor: const Color(0xFF1A1A1A),
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
                      onComment: () => _showCommentSheet(context, video),
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
                  onHistory: () => _showHistorySheet(context, provider),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCommentSheet(BuildContext context, VideoModel video) {
    final interaction = InteractionService.instance;
    final comments = interaction.getComments(video.id);
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      '评论',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Flexible(
                    child: comments.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(
                              child: Text('暂无评论', style: TextStyle(color: Colors.white38)),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: comments.length,
                            itemBuilder: (_, i) {
                              final c = comments[i];
                              return ListTile(
                                leading: const CircleAvatar(
                                  radius: 16,
                                  child: Icon(Icons.person, size: 18),
                                ),
                                title: Text(c.author, style: const TextStyle(color: Colors.white, fontSize: 13)),
                                subtitle: Text(c.content, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                              );
                            },
                          ),
                  ),
                  const Divider(color: Colors.white12),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: '说点什么...',
                              hintStyle: TextStyle(color: Colors.white38),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, color: Color(0xFFFE2C55)),
                          onPressed: () {
                            final text = controller.text.trim();
                            if (text.isNotEmpty) {
                              interaction.addComment(video.id, text);
                              context.read<VideoProvider>().incrementComments(video.id);
                              controller.clear();
                              setSheetState(() {});
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showVideoList(BuildContext context, VideoProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => VideoListSheet(provider: provider),
    );
  }

  void _showHistorySheet(BuildContext context, VideoProvider provider) {
    final historyVideos = provider.getVideosByIds(InteractionService.instance.history);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                '观看历史',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            Flexible(
              child: historyVideos.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text('暂无观看记录', style: TextStyle(color: Colors.white38)),
                      ),
                    )
                  : ListView.builder(
                      itemCount: historyVideos.length,
                      itemBuilder: (_, i) {
                        final v = historyVideos[i];
                        return ListTile(
                          leading: const Icon(Icons.play_circle_outline, color: Colors.white54),
                          title: Text(
                            v.title,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            v.author,
                            style: const TextStyle(color: Colors.white38, fontSize: 12),
                          ),
                          onTap: () {
                            final idx = provider.videos.indexWhere((pv) => pv.id == v.id);
                            if (idx != -1) {
                              widget.pageController.jumpToPage(idx);
                            }
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
