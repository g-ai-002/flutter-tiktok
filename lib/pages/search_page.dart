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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.white38 : Colors.black38;
    final appBarBg = isDark ? Colors.black : Colors.white;

    return Consumer<VideoProvider>(
      builder: (context, provider, _) {
        return GestureDetector(
          onTap: () => _focusNode.unfocus(),
          child: Scaffold(
            backgroundColor: bgColor,
            appBar: AppBar(
              backgroundColor: appBarBg,
              elevation: 0,
              title: Container(
                height: 36,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: TextStyle(color: textColor, fontSize: 14),
                  cursorColor: const Color(0xFFFE2C55),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: '搜索视频标题或作者',
                    hintStyle: TextStyle(color: hintColor, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: isDark ? Colors.white54 : Colors.black38, size: 20),
                    suffixIcon: _controller.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _controller.clear();
                              _search('', provider.videos);
                            },
                            child: Icon(Icons.close, color: isDark ? Colors.white54 : Colors.black38, size: 18),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    isCollapsed: true,
                  ),
                  onChanged: (v) {
                    _search(v, provider.videos);
                    setState(() {});
                  },
                ),
              ),
            ),
            body: _buildBody(provider, isDark),
          ),
        );
      },
    );
  }

  Widget _buildBody(VideoProvider provider, bool isDark) {
    final textColor = isDark ? Colors.white38 : Colors.black38;
    if (!_hasSearched) {
      return Center(
        child: Text('输入关键词搜索视频', style: TextStyle(color: textColor, fontSize: 14)),
      );
    }
    if (_results.isEmpty) {
      return Center(
        child: Text('未找到相关视频', style: TextStyle(color: textColor, fontSize: 14)),
      );
    }
    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final video = _results[index];
        return ListTile(
          leading: Icon(Icons.play_circle_outline, color: isDark ? Colors.white54 : Colors.black38),
          title: Text(
            video.title,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            buildVideoSubtitle(video),
            style: TextStyle(color: textColor, fontSize: 12),
          ),
          trailing: Text(
            '${video.likes} 赞',
            style: TextStyle(color: textColor, fontSize: 12),
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
}
