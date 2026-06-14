import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/video.dart';
import '../providers/video_provider.dart';
import '../services/interaction_service.dart';
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
    final provider = context.read<VideoProvider>();
    provider.setCurrentIndex(index);
    final video = provider.videos[index];
    InteractionService.instance.addToHistory(video.id);
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
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('暂无视频', style: TextStyle(color: Colors.white54, fontSize: 16)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => provider.importLocalVideos(),
                    icon: const Icon(Icons.add),
                    label: const Text('导入视频'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              PageView.builder(
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
                    onComment: () => _showCommentSheet(context, video),
                    onShare: () {},
                    onFavorite: () => InteractionService.instance.toggleFavorite(video.id),
                  );
                },
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 0,
                right: 0,
                child: _TopToolbar(
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
                              final currentComments = int.tryParse(video.comments) ?? 0;
                              video.comments = '${currentComments + 1}';
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
      builder: (ctx) => _VideoListSheet(provider: provider),
    );
  }

  void _showHistorySheet(BuildContext context, VideoProvider provider) {
    final historyIds = InteractionService.instance.history;
    final historyVideos = historyIds
        .map((id) {
          try {
            return provider.videos.firstWhere((v) => v.id == id);
          } catch (_) {
            return null;
          }
        })
        .whereType<VideoModel>()
        .toList();

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
                              _pageController.jumpToPage(idx);
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

class _TopToolbar extends StatelessWidget {
  final VoidCallback onImport;
  final VoidCallback onManage;
  final VoidCallback onHistory;

  const _TopToolbar({required this.onImport, required this.onManage, required this.onHistory});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Text(
            '推荐',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          _ToolIcon(icon: Icons.history, onTap: onHistory),
          const SizedBox(width: 12),
          _ToolIcon(icon: Icons.file_upload_outlined, onTap: onImport),
          const SizedBox(width: 12),
          _ToolIcon(icon: Icons.list_alt, onTap: onManage),
        ],
      ),
    );
  }
}

class _ToolIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ToolIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _VideoListSheet extends StatelessWidget {
  final VideoProvider provider;
  const _VideoListSheet({required this.provider});

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

class _VideoPage extends StatelessWidget {
  final VideoModel video;
  final bool isActive;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onFavorite;

  const _VideoPage({
    required this.video,
    required this.isActive,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        VideoPlayerWidget(videoUrl: video.url, isActive: isActive),
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
        Positioned(
          right: 12,
          bottom: 80,
          child: VideoActions(
            video: video,
            onLike: onLike,
            onComment: onComment,
            onShare: onShare,
            onFavorite: onFavorite,
          ),
        ),
      ],
    );
  }
}
