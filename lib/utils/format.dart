import '../models/video.dart';

String formatDuration(Duration d) {
  final hours = d.inHours;
  final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
  }
  return '$minutes:$seconds';
}

String buildVideoSubtitle(VideoModel v, {bool includeFileSize = false}) {
  final parts = <String>[];
  if (v.author.isNotEmpty) parts.add(v.author);
  if (v.durationMs > 0) parts.add(formatDuration(v.duration));
  if (v.resolution.isNotEmpty) parts.add(v.resolution);
  if (includeFileSize && v.fileSize > 0) parts.add(v.fileSizeFormatted);
  return parts.join(' · ');
}
