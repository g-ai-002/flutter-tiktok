import 'package:flutter/material.dart';

class TopToolbar extends StatelessWidget {
  final VoidCallback onImport;
  final VoidCallback onManage;
  final VoidCallback onHistory;

  const TopToolbar({
    super.key,
    required this.onImport,
    required this.onManage,
    required this.onHistory,
  });

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
