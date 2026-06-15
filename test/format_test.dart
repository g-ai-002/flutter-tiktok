import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tiktok/utils/format.dart';

void main() {
  group('formatDuration', () {
    test('formats seconds only', () {
      expect(formatDuration(const Duration(seconds: 5)), '00:05');
      expect(formatDuration(const Duration(seconds: 59)), '00:59');
    });

    test('formats minutes and seconds', () {
      expect(formatDuration(const Duration(minutes: 3, seconds: 15)), '03:15');
      expect(formatDuration(const Duration(minutes: 59, seconds: 59)), '59:59');
    });

    test('formats hours, minutes and seconds', () {
      expect(formatDuration(const Duration(hours: 1, minutes: 5, seconds: 30)), '01:05:30');
      expect(formatDuration(const Duration(hours: 10, minutes: 0, seconds: 0)), '10:00:00');
    });

    test('formats zero duration', () {
      expect(formatDuration(Duration.zero), '00:00');
    });
  });
}
