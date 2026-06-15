import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tiktok/utils/constants.dart';

void main() {
  test('AppConstants has correct values', () {
    expect(AppConstants.appName, '抖视频');
    expect(AppConstants.version, '0.6.1');
  });
}
