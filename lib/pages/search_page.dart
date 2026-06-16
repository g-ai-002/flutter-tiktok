import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/video.dart';
import '../providers/video_provider.dart';
import '../utils/format.dart';

class SearchPage extends StatefulWidget {
  final void Function(int index)? onVideoSelected;

  const SearchPage({super.key, this.onVideoSelected});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<VideoModel> _results = [];
  bool _hasSearched = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _search(String query, List<VideoModel> videos) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (query.trim().isEmpty) {
        setState(() {
          _results = [];
          _hasSearched = false;
        });
        return;
      }
      final q = query.trim().toLowerCase();
      setState(() {
        _results = videos.where((v) {
          return v.title.toLowerCase().contains(q) || v.author.toLowerCase().contains(q);
        }).toList();
        _hasSearched = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoProvider>(
      builder: (context, provider, _) {
        return GestureDetector(
          onTap: () => _focusNode.unfocus(),
          child: Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              elevation: 0,
              title: Container(
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  cursorColor: const Color(0xFFFE2C55),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: '搜索视频标题或作者',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: Colors.white54, size: 20),
                    suffixIcon: _controller.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _controller.clear();
                              _search('', provider.videos);
                            },
                            child: const Icon(Icons.close, color: Colors.white54, size: 18),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (v) {
                    _search(v, provider.videos);
                    setState(() {});
                  },
                ),
              ),
            ),
            body: _buildBody(provider),
          ),
        );
      },
    );
  }

  Widget _buildBody(VideoProvider provider) {
    if (!_hasSearched) {
      return const Center(
        child: Text('输入关键词搜索视频', style: TextStyle(color: Colors.white38, fontSize: 14)),
      );
    }
    if (_results.isEmpty) {
      return const Center(
        child: Text('未找到相关视频', style: TextStyle(color: Colors.white38, fontSize: 14)),
      );
    }
    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final video = _results[index];
        return ListTile(
          leading: const Icon(Icons.play_circle_outline, color: Colors.white54),
          title: Text(
            video.title,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            _buildSubtitle(video),
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
          trailing: Text(
            '${video.likes} 赞',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
          onTap: () {
            final idx = provider.videos.indexWhere((v) => v.id == video.id);
            if (idx != -1) {
              widget.onVideoSelected?.call(idx);
            }
          },
        );
      },
    );
  }

  String _buildSubtitle(VideoModel v) {
    final parts = <String>[];
    if (v.author.isNotEmpty) parts.add(v.author);
    if (v.durationMs > 0) parts.add(formatDuration(v.duration));
    if (v.resolution.isNotEmpty) parts.add(v.resolution);
    return parts.join(' · ');
  }
}
