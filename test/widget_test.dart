import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tiktok/utils/constants.dart';

void main() {
  test('AppConstants has correct values', () {
    expect(AppConstants.appName, '抖视频');
    expect(AppConstants.version, '0.4.0');
    expect(AppConstants.sampleVideos.length, 5);
  });

  test('sampleVideos have required fields', () {
    for (final video in AppConstants.sampleVideos) {
      expect(video.containsKey('id'), true);
      expect(video.containsKey('title'), true);
      expect(video.containsKey('url'), true);
      expect(video.containsKey('author'), true);
    }
  });
}
