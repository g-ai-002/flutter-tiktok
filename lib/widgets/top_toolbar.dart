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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final iconBgColor = isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.06);
    final iconColor = isDark ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            '推荐',
            style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          _ToolIcon(icon: Icons.history, onTap: onHistory, bgColor: iconBgColor, iconColor: iconColor),
          const SizedBox(width: 12),
          _ToolIcon(icon: Icons.file_upload_outlined, onTap: onImport, bgColor: iconBgColor, iconColor: iconColor),
          const SizedBox(width: 12),
          _ToolIcon(icon: Icons.list_alt, onTap: onManage, bgColor: iconBgColor, iconColor: iconColor),
        ],
      ),
    );
  }
}

class _ToolIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color bgColor;
  final Color iconColor;

  const _ToolIcon({required this.icon, required this.onTap, required this.bgColor, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }
}
