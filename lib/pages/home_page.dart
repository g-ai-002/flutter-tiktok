import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/video_provider.dart';
import '../services/interaction_service.dart';
import '../services/video_preload_service.dart';
import '../services/category_service.dart';
import '../services/playlist_service.dart';
import '../services/sleep_timer_service.dart';
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
  String? _lastCategoryFilter;

  void _onPageChanged(int index) {
    final provider = context.read<VideoProvider>();
    provider.setCurrentIndex(index);
    final videos = provider.videos;
    if (index < videos.length) {
      final video = videos[index];
      InteractionService.instance.addToHistory(video.id);
      final urls = videos.map((v) => v.url).toList();
      VideoPreloadService.instance.preloadAdjacent(urls, index);
    }
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
        if (provider.categoryFilter != _lastCategoryFilter) {
          _lastCategoryFilter = provider.categoryFilter;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (widget.pageController.hasClients) {
              widget.pageController.jumpToPage(0);
            }
          });
        }

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
                      autoPlay: provider.autoPlay,
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
                  onPlaylist: () => _showPlaylistSheet(context, provider),
                  onSleepTimer: () => _showSleepTimerSheet(context),
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

  void _showPlaylistSheet(BuildContext context, VideoProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white54 : Colors.black54;

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final playlists = PlaylistService.instance.playlists;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '播放列表',
                  style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              if (playlists.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text('暂无播放列表', style: TextStyle(color: subColor)),
                )
              else
                ...playlists.map((pl) {
                  final videoCount = pl.videoIds.length;
                  return ListTile(
                    leading: const Icon(Icons.playlist_play, color: Color(0xFFFE2C55)),
                    title: Text(pl.name, style: TextStyle(color: textColor)),
                    subtitle: Text('$videoCount 个视频', style: TextStyle(color: subColor, fontSize: 12)),
                    trailing: PopupMenuButton<String>(
                      icon: Icon(Icons.more_horiz, color: subColor),
                      onSelected: (action) {
                        Navigator.pop(ctx);
                        if (action == 'rename') {
                          _showRenamePlaylistDialog(context, pl.id, pl.name);
                        } else if (action == 'delete') {
                          PlaylistService.instance.deletePlaylist(pl.id);
                          _showPlaylistSheet(context, provider);
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(value: 'rename', child: Text('重命名', style: TextStyle(color: textColor))),
                        PopupMenuItem(value: 'delete', child: Text('删除', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      final playlistVideos = provider.getVideosByIds(pl.videoIds);
                      VideoItemListSheet.show(
                        context,
                        title: pl.name,
                        videos: playlistVideos,
                        provider: provider,
                        onVideoSelected: (idx) => widget.pageController.jumpToPage(idx),
                      );
                    },
                  );
                }),
              const Divider(),
              ListTile(
                leading: Icon(Icons.add, color: subColor),
                title: Text('新建播放列表', style: TextStyle(color: textColor)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showCreatePlaylistDialog(context);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final controller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        title: Text('新建播放列表', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: '输入播放列表名称',
            hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('取消', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                PlaylistService.instance.addPlaylist(name);
                Navigator.pop(ctx);
              }
            },
            child: const Text('确定', style: TextStyle(color: Color(0xFFFE2C55))),
          ),
        ],
      ),
    );
  }

  void _showRenamePlaylistDialog(BuildContext context, String playlistId, String currentName) {
    final controller = TextEditingController(text: currentName);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        title: Text('重命名播放列表', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: '输入新名称',
            hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('取消', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                PlaylistService.instance.renamePlaylist(playlistId, name);
                Navigator.pop(ctx);
              }
            },
            child: const Text('确定', style: TextStyle(color: Color(0xFFFE2C55))),
          ),
        ],
      ),
    );
  }

  void _showSleepTimerSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white54 : Colors.black54;

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final timer = SleepTimerService.instance;
            final isActive = timer.isActive;
            final remaining = timer.remaining;

            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '定时关闭',
                      style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (isActive)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFE2C55).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.timer, color: Color(0xFFFE2C55), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '剩余 ${remaining.inMinutes} 分 ${remaining.inSeconds % 60} 秒',
                              style: const TextStyle(color: Color(0xFFFE2C55), fontSize: 14),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                timer.cancel();
                                setSheetState(() {});
                              },
                              child: const Text('取消', style: TextStyle(color: Color(0xFFFE2C55))),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ...[15, 30, 60].map((minutes) {
                    return ListTile(
                      leading: Icon(Icons.timer_outlined, color: subColor),
                      title: Text('$minutes 分钟后', style: TextStyle(color: textColor)),
                      onTap: () {
                        timer.start(minutes);
                        Navigator.pop(ctx);
                      },
                    );
                  }),
                  ListTile(
                    leading: Icon(Icons.edit, color: subColor),
                    title: Text('自定义', style: TextStyle(color: textColor)),
                    onTap: () {
                      Navigator.pop(ctx);
                      _showCustomSleepTimerDialog(context);
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCustomSleepTimerDialog(BuildContext context) {
    final controller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        title: Text('自定义定时', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: '输入分钟数',
            hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
            suffixText: '分钟',
            suffixStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('取消', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
          ),
          TextButton(
            onPressed: () {
              final minutes = int.tryParse(controller.text.trim());
              if (minutes != null && minutes > 0) {
                SleepTimerService.instance.start(minutes);
                Navigator.pop(ctx);
              }
            },
            child: const Text('确定', style: TextStyle(color: Color(0xFFFE2C55))),
          ),
        ],
      ),
    );
  }
}
