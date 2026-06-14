class AppConstants {
  AppConstants._();

  static const String appName = '抖视频';
  static const String version = '0.3.1';

  static const String prefKeyLikedVideos = 'liked_videos_v1';

  static const List<Map<String, dynamic>> sampleVideos = [
    {
      'id': '1',
      'title': '美丽的日落',
      'author': '@旅行者小明',
      'description': '今天的日落太美了 #日落 #旅行',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      'thumbnail': '',
      'likes': '1.2万',
      'comments': '356',
      'shares': '128',
    },
    {
      'id': '2',
      'title': '城市夜景',
      'author': '@城市探索者',
      'description': '夜幕降临，城市灯火辉煌 #夜景 #城市',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      'thumbnail': '',
      'likes': '2.5万',
      'comments': '892',
      'shares': '456',
    },
    {
      'id': '3',
      'title': '美食制作',
      'author': '@厨房达人',
      'description': '今天教大家做一道美味佳肴 #美食 #烹饪',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
      'thumbnail': '',
      'likes': '3.8万',
      'comments': '1205',
      'shares': '678',
    },
    {
      'id': '4',
      'title': '萌宠日常',
      'author': '@宠物乐园',
      'description': '我家猫咪的可爱瞬间 #萌宠 #猫咪',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
      'thumbnail': '',
      'likes': '5.1万',
      'comments': '2340',
      'shares': '1024',
    },
    {
      'id': '5',
      'title': '舞蹈教学',
      'author': '@舞蹈老师',
      'description': '零基础学舞蹈，跟我一起跳 #舞蹈 #教学',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
      'thumbnail': '',
      'likes': '4.2万',
      'comments': '1567',
      'shares': '890',
    },
  ];
}
