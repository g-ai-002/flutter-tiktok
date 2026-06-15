import 'package:flutter/material.dart';
import '../services/interaction_service.dart';
import '../services/video_preload_service.dart';
import '../utils/constants.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('设置', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          const _SectionHeader(title: '数据管理'),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.white70),
            title: const Text('清除观看历史', style: TextStyle(color: Colors.white)),
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
            leading: const Icon(Icons.cached, color: Colors.white70),
            title: const Text('清除视频缓存', style: TextStyle(color: Colors.white)),
            onTap: () => _showConfirmDialog(context, '确定要清除视频预加载缓存吗？', () {
              VideoPreloadService.instance.clear();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('视频缓存已清除'), backgroundColor: Color(0xFFFE2C55)),
                );
              }
            }),
          ),
          const Divider(color: Colors.white12),
          const _SectionHeader(title: '关于'),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.white70),
            title: const Text('应用名称', style: TextStyle(color: Colors.white)),
            trailing: const Text(AppConstants.appName, style: TextStyle(color: Colors.white38)),
          ),
          ListTile(
            leading: const Icon(Icons.tag, color: Colors.white70),
            title: const Text('版本号', style: TextStyle(color: Colors.white)),
            trailing: Text('v${AppConstants.version}', style: const TextStyle(color: Colors.white38)),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(BuildContext context, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('确认', style: TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消', style: TextStyle(color: Colors.white54)),
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
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white38, fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }
}
