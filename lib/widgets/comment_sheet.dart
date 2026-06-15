import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/video.dart';
import '../providers/video_provider.dart';
import '../services/interaction_service.dart';

class CommentSheet extends StatefulWidget {
  final VideoModel video;

  const CommentSheet({super.key, required this.video});

  static void show(BuildContext context, VideoModel video) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => CommentSheet(video: video),
    );
  }

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final interaction = InteractionService.instance;
    final comments = interaction.getComments(widget.video.id);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                      controller: _controller,
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
                      final text = _controller.text.trim();
                      if (text.isNotEmpty) {
                        interaction.addComment(widget.video.id, text);
                        context.read<VideoProvider>().incrementComments(widget.video.id);
                        _controller.clear();
                        setState(() {});
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
  }
}
