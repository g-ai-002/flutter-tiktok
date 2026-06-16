import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/video_provider.dart';
import '../services/interaction_service.dart';
import '../services/video_preload_service.dart';
import '../utils/constants.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final videoProvider = context.watch<VideoProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white70 : Colors.black54;
    final subTextColor = isDark ? Colors.white38 : Colors.black38;
    final dividerColor = isDark ? Colors.white12 : Colors.black12;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('设置', style: TextStyle(color: textColor)),
        backgroundColor: bgColor,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: ListView(
        children: [
          _SectionHeader(title: '外观', textColor: subTextColor),
          SwitchListTile(
            secondary: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: subColor,
            ),
            title: Text('深色模式', style: TextStyle(color: textColor)),
            value: themeProvider.isDarkMode,
            activeColor: const Color(0xFFFE2C55),
            onChanged: (_) => themeProvider.toggleTheme(),
          ),
          Divider(color: dividerColor),
          _SectionHeader(title: '播放', textColor: subTextColor),
          SwitchListTile(
            secondary: Icon(
              videoProvider.autoPlay ? Icons.play_circle_fill : Icons.play_circle_outline,
              color: subColor,
            ),
            title: Text('自动连播', style: TextStyle(color: textColor)),
            subtitle: Text(
              '切换视频时自动开始播放',
              style: TextStyle(color: subTextColor, fontSize: 12),
            ),
            value: videoProvider.autoPlay,
            activeColor: const Color(0xFFFE2C55),
            onChanged: (v) => videoProvider.setAutoPlay(v),
          ),
          Divider(color: dividerColor),
          _SectionHeader(title: '数据管理', textColor: subTextColor),
          ListTile(
            leading: Icon(Icons.delete_outline, color: subColor),
            title: Text('清除观看历史', style: TextStyle(color: textColor)),
            onTap: () => _showConfirmDialog(context, '确定要清除所有观看历史吗？', () {
              InteractionService.instance.clearHistory();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('观看历史已清除'), backgroundColor: Color(0xFFFE2C55)),
                );
              }
            }),
          ),
          ListTile(
            leading: Icon(Icons.cached, color: subColor),
            title: Text('清除视频缓存', style: TextStyle(color: textColor)),
            onTap: () => _showConfirmDialog(context, '确定要清除视频预加载缓存吗？', () {
              VideoPreloadService.instance.clear();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('视频缓存已清除'), backgroundColor: Color(0xFFFE2C55)),
                );
              }
            }),
          ),
          Divider(color: dividerColor),
          _SectionHeader(title: '关于', textColor: subTextColor),
          ListTile(
            leading: Icon(Icons.info_outline, color: subColor),
            title: Text('应用名称', style: TextStyle(color: textColor)),
            trailing: Text(AppConstants.appName, style: TextStyle(color: subTextColor)),
          ),
          ListTile(
            leading: Icon(Icons.tag, color: subColor),
            title: Text('版本号', style: TextStyle(color: textColor)),
            trailing: Text('v${AppConstants.version}', style: TextStyle(color: subTextColor)),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(BuildContext context, String message, VoidCallback onConfirm) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        title: Text('确认', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        content: Text(message, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('取消', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: const Text('确定', style: TextStyle(color: Color(0xFFFE2C55))),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color textColor;
  const _SectionHeader({required this.title, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }
}
