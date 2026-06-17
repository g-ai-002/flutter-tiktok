import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/video.dart';
import '../services/interaction_service.dart';

class VideoActions extends StatelessWidget {
  final VideoModel video;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onFavorite;

  const VideoActions({
    super.key,
    required this.video,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: InteractionService.instance.changeNotifier,
      builder: (context, _, _) {
        final isFav = InteractionService.instance.isFavorite(video.id);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ActionButton(
              icon: video.isLiked ? Icons.favorite : Icons.favorite_border,
              iconColor: video.isLiked ? const Color(0xFFFE2C55) : Colors.white,
              label: video.likes,
              onTap: onLike,
            ),
            const SizedBox(height: 20),
            _ActionButton(
              icon: Icons.comment,
              label: video.comments,
              onTap: onComment,
            ),
            const SizedBox(height: 20),
            _ActionButton(
              icon: isFav ? Icons.star : Icons.star_border,
              iconColor: isFav ? const Color(0xFFFFD700) : Colors.white,
              label: '收藏',
              onTap: onFavorite,
            ),
            const SizedBox(height: 20),
            _ActionButton(
              icon: Icons.share,
              label: video.shares,
              onTap: () {
                Share.share('${video.title} - ${video.description}');
              },
            ),
            const SizedBox(height: 20),
            const _CircleAvatar(),
          ],
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor ?? Colors.white, size: 32),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _CircleAvatar extends StatelessWidget {
  const _CircleAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        gradient: const LinearGradient(
          colors: [Color(0xFFFE2C55), Color(0xFF25F4EE)],
        ),
      ),
      child: const Icon(Icons.person, color: Colors.white, size: 24),
    );
  }
}
