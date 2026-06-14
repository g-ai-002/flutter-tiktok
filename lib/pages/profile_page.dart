import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/video.dart';
import '../providers/video_provider.dart';
import '../services/interaction_service.dart';

class ProfilePage extends StatelessWidget {
  final void Function(int index)? onVideoSelected;

  const ProfilePage({super.key, this.onVideoSelected});

  @override
  Widget build(BuildContext context) {
    final interaction = InteractionService.instance;
    final provider = context.watch<VideoProvider>();

    final favorites = interaction.favorites
        .map((id) {
          try {
            return provider.videos.firstWhere((v) => v.id == id);
          } catch (_) {
            return null;
          }
        })
        .whereType<VideoModel>()
        .toList();

    final historyIds = interaction.history;
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

    final totalComments = interaction.totalComments;
    final totalLikes = provider.videos.where((v) => v.isLiked).length;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('个人主页', style: TextStyle(color: Colors.white, fontSize: 18)),
        centerTitle: true,
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
            const Center(
              child: Text('抖视频用户', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(label: '收藏', value: '${favorites.length}'),
                  _StatItem(label: '历史', value: '${historyVideos.length}'),
                  _StatItem(label: '点赞', value: '$totalLikes'),
                  _StatItem(label: '评论', value: '$totalComments'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionHeader(
              title: '我的收藏',
              count: favorites.length,
              onTap: () => _showListSheet(context, '我的收藏', favorites, provider),
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
              onTap: () => _showListSheet(context, '观看历史', historyVideos, provider),
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

  void _showListSheet(BuildContext context, String title, List<VideoModel> videos, VideoProvider provider) {
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
                            Navigator.pop(ctx);
                            _playVideo(context, v, provider);
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

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final VoidCallback onTap;

  const _SectionHeader({required this.title, required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Text('$count', style: const TextStyle(color: Colors.white38, fontSize: 13)),
          const Spacer(),
          GestureDetector(
            onTap: onTap,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('查看全部', style: TextStyle(color: Colors.white38, fontSize: 13)),
                Icon(Icons.chevron_right, color: Colors.white38, size: 18),
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
