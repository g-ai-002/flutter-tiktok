import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class StorageService {
  static Future<StorageService>? _initFuture;

  SharedPreferences? _prefs;
  bool _initialized = false;

  StorageService._();

  static Future<StorageService> get instance {
    final cached = _initFuture;
    if (cached != null) return cached;
    final f = _bootstrap();
    _initFuture = f;
    return f;
  }

  static Future<StorageService> _bootstrap() async {
    final s = StorageService._();
    await s._init();
    return s;
  }

  Future<void> _init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  SharedPreferences get _p {
    final p = _prefs;
    if (p == null) throw StateError('StorageService 尚未初始化');
    return p;
  }

  bool get darkMode => _p.getBool(AppConstants.prefKeyDarkMode) ?? false;
  Future<void> setDarkMode(bool v) => _p.setBool(AppConstants.prefKeyDarkMode, v);

  List<String> get likedVideos => _p.getStringList(AppConstants.prefKeyLikedVideos) ?? const [];
  Future<void> setLikedVideos(List<String> ids) => _p.setStringList(AppConstants.prefKeyLikedVideos, ids);
}
