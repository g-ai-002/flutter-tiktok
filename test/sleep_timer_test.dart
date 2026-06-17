import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tiktok/services/sleep_timer_service.dart';

void main() {
  group('SleepTimerService', () {
    test('initial state is inactive', () {
      final service = SleepTimerService.instance;
      expect(service.isActive, false);
      expect(service.remaining, Duration.zero);
      expect(service.totalMinutes, 0);
    });

    test('start activates timer', () {
      final service = SleepTimerService.instance;
      service.start(15);
      expect(service.isActive, true);
      expect(service.totalMinutes, 15);
      expect(service.endTime, isNotNull);
    });

    test('cancel deactivates timer', () {
      final service = SleepTimerService.instance;
      service.start(30);
      expect(service.isActive, true);
      service.cancel();
      expect(service.isActive, false);
      expect(service.totalMinutes, 0);
      expect(service.endTime, isNull);
    });

    test('start replaces existing timer', () {
      final service = SleepTimerService.instance;
      service.start(15);
      service.start(60);
      expect(service.totalMinutes, 60);
    });

    test('remaining is positive after start', () {
      final service = SleepTimerService.instance;
      service.start(60);
      expect(service.remaining.inMinutes, greaterThan(0));
    });

    test('cancel when inactive does not throw', () {
      final service = SleepTimerService.instance;
      expect(() => service.cancel(), returnsNormally);
    });
  });
}
