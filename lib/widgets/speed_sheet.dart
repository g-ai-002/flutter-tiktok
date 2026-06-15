import 'package:flutter/material.dart';

class SpeedSheet extends StatelessWidget {
  final double currentSpeed;
  final void Function(double) onSpeedChanged;

  static const List<double> speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  const SpeedSheet({
    super.key,
    required this.currentSpeed,
    required this.onSpeedChanged,
  });

  static void show(BuildContext context, double currentSpeed, void Function(double) onSpeedChanged) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SpeedSheet(currentSpeed: currentSpeed, onSpeedChanged: onSpeedChanged),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '播放速度',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          ...speeds.map((s) => ListTile(
            title: Text(
              s == 1.0 ? '${s.toStringAsFixed(0)}x (正常)' : '${s}x',
              style: TextStyle(
                color: currentSpeed == s ? const Color(0xFFFE2C55) : Colors.white,
                fontWeight: currentSpeed == s ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            trailing: currentSpeed == s ? const Icon(Icons.check, color: Color(0xFFFE2C55)) : null,
            onTap: () {
              onSpeedChanged(s);
              Navigator.pop(context);
            },
          )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
