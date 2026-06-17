import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tiktok/services/playback_stats_service.dart';

void main() {
  group('PlaybackStats', () {
    test('default values are zero', () {
      final stats = PlaybackStats();
      expect(stats.playCount, 0);
      expect(stats.totalWatchMs, 0);
      expect(stats.lastPlayedAt, isNull);
    });

    test('toJson and fromJson roundtrip', () {
      final stats = PlaybackStats(
        playCount: 5,
        totalWatchMs: 120000,
        lastPlayedAt: '2025-06-01T12:00:00.000',
      );

      final json = stats.toJson();
      final restored = PlaybackStats.fromJson(json);

      expect(restored.playCount, 5);
      expect(restored.totalWatchMs, 120000);
      expect(restored.lastPlayedAt, '2025-06-01T12:00:00.000');
    });

    test('fromJson handles missing fields', () {
      final stats = PlaybackStats.fromJson({});
      expect(stats.playCount, 0);
      expect(stats.totalWatchMs, 0);
      expect(stats.lastPlayedAt, isNull);
    });

    test('totalWatchDuration returns correct Duration', () {
      final stats = PlaybackStats(totalWatchMs: 65000);
      expect(stats.totalWatchDuration, Duration(seconds: 65));
    });
  });

  group('PlaybackStatsService', () {
    test('getStats returns default stats for unknown video', () {
      final stats = PlaybackStatsService.instance.getStats('unknown');
      expect(stats.playCount, 0);
      expect(stats.totalWatchMs, 0);
    });

    test('recordPlay increments playCount', () {
      final service = PlaybackStatsService.instance;
      service.recordPlay('v1');
      expect(service.getStats('v1').playCount, 1);
      service.recordPlay('v1');
      expect(service.getStats('v1').playCount, 2);
    });

    test('recordPlay sets lastPlayedAt', () {
      final service = PlaybackStatsService.instance;
      service.recordPlay('v2');
      expect(service.getStats('v2').lastPlayedAt, isNotNull);
    });

    test('recordWatchTime accumulates watch time', () {
      final service = PlaybackStatsService.instance;
      service.recordWatchTime('v3', 5000);
      expect(service.getStats('v3').totalWatchMs, 5000);
      service.recordWatchTime('v3', 3000);
      expect(service.getStats('v3').totalWatchMs, 8000);
    });

    test('recordWatchTime ignores zero or negative', () {
      final service = PlaybackStatsService.instance;
      service.recordWatchTime('v4', 0);
      expect(service.getStats('v4').totalWatchMs, 0);
      service.recordWatchTime('v4', -100);
      expect(service.getStats('v4').totalWatchMs, 0);
    });

    test('totalPlayCount sums all videos', () {
      final service = PlaybackStatsService.instance;
      service.recordPlay('a');
      service.recordPlay('a');
      service.recordPlay('b');
      expect(service.totalPlayCount, 3);
    });

    test('totalWatchTime sums all videos', () {
      final service = PlaybackStatsService.instance;
      service.recordWatchTime('x', 10000);
      service.recordWatchTime('y', 20000);
      expect(service.totalWatchTime, Duration(milliseconds: 30000));
    });
  });
}
