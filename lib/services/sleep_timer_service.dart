import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/log_service.dart';

class SleepTimerService extends ChangeNotifier {
  static final SleepTimerService instance = SleepTimerService._();
  SleepTimerService._();

  Timer? _timer;
  DateTime? _endTime;
  int _totalMinutes = 0;

  bool get isActive => _timer != null && _timer!.isActive;
  DateTime? get endTime => _endTime;
  int get totalMinutes => _totalMinutes;

  Duration get remaining {
    if (_endTime == null) return Duration.zero;
    final diff = _endTime!.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  void start(int minutes) {
    cancel();
    _totalMinutes = minutes;
    _endTime = DateTime.now().add(Duration(minutes: minutes));
    _timer = Timer(Duration(minutes: minutes), () {
      cancel();
    });
    notifyListeners();
    LogService.info('定时关闭已启动: $minutes分钟');
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
    _endTime = null;
    _totalMinutes = 0;
    notifyListeners();
    LogService.info('定时关闭已取消');
  }
}
