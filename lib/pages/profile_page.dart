import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/video.dart';
import '../providers/video_provider.dart';
import '../services/interaction_service.dart';
import '../services/playback_stats_service.dart';
import '../utils/format.dart';
import '../widgets/full_screen_video_list.dart';
import 'settings_page.dart';

class ProfilePage extends StatelessWidget {
  final void Function(int index)? onVideoSelected;

  const ProfilePage({super.key, this.onVideoSelected});

  @override
  Widget build(BuildContext context) {
    final interaction = InteractionService.instance;
    final provider = context.watch<VideoProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white54 : Colors.black54;
    final subTextColor = isDark ? Colors.white38 : Colors.black38;

    final favorites = provider.getVideosByIds(interaction.favorites);

    final historyVideos = provider.getVideosByIds(interaction.history);

    final totalComments = interaction.totalComments;
    final totalLikes = provider.videos.where((v) => v.isLiked).length;
    final stats = PlaybackStatsService.instance;
    final totalPlays = stats.totalPlayCount;
    final totalWatch = stats.totalWatchTime;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text('个人主页', style: TextStyle(color: textColor, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: subColor),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFFFE2C55),
                child: Icon(Icons.person, size: 48, color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text('抖视频用户', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(label: '收藏', value: '${favorites.length}', textColor: textColor, subColor: subColor),
                  _StatItem(label: '历史', value: '${historyVideos.length}', textColor: textColor, subColor: subColor),
                  _StatItem(label: '点赞', value: '$totalLikes', textColor: textColor, subColor: subColor),
                  _StatItem(label: '评论', value: '$totalComments', textColor: textColor, subColor: subColor),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(label: '播放次数', value: '$totalPlays', textColor: textColor, subColor: subColor),
                  _StatItem(label: '观看时长', value: formatDuration(totalWatch), textColor: textColor, subColor: subColor),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionHeader(
              title: '我的收藏',
              count: favorites.length,
              textColor: textColor,
              subTextColor: subTextColor,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenVideoList(
                    title: '我的收藏',
                    videos: favorites,
                    provider: provider,
                    onVideoSelected: onVideoSelected,
                  ),
                ),
              ),
            ),
            if (favorites.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: favorites.length.clamp(0, 10),
                  itemBuilder: (_, i) => _VideoThumbnail(
                    video: favorites[i],
                    onTap: () => _playVideo(context, favorites[i], provider),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            _SectionHeader(
              title: '观看历史',
              count: historyVideos.length,
              textColor: textColor,
              subTextColor: subTextColor,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenVideoList(
                    title: '观看历史',
                    videos: historyVideos,
                    provider: provider,
                    onVideoSelected: onVideoSelected,
                  ),
                ),
              ),
            ),
            if (historyVideos.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: historyVideos.length.clamp(0, 10),
                  itemBuilder: (_, i) => _VideoThumbnail(
                    video: historyVideos[i],
                    onTap: () => _playVideo(context, historyVideos[i], provider),
                  ),
                ),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _playVideo(BuildContext context, VideoModel video, VideoProvider provider) {
    final idx = provider.videos.indexWhere((v) => v.id == video.id);
    if (idx != -1) {
      onVideoSelected?.call(idx);
    }
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color textColor;
  final Color subColor;
  const _StatItem({required this.label, required this.value, required this.textColor, required this.subColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: subColor, fontSize: 12)),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color textColor;
  final Color subTextColor;
  final VoidCallback onTap;

  const _SectionHeader({required this.title, required this.count, required this.textColor, required this.subTextColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Text(title, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Text('$count', style: TextStyle(color: subTextColor, fontSize: 13)),
          const Spacer(),
          GestureDetector(
            onTap: onTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('查看全部', style: TextStyle(color: subTextColor, fontSize: 13)),
                Icon(Icons.chevron_right, color: subTextColor, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoThumbnail extends StatelessWidget {
  final VideoModel video;
  final VoidCallback onTap;

  const _VideoThumbnail({required this.video, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_circle_fill, color: Color(0xFFFE2C55), size: 28),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                video.title,
                style: const TextStyle(color: Colors.white70, fontSize: 10),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
