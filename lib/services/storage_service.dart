import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class StorageService {
  static StorageService? _instance;

  final SharedPreferences _prefs;

  StorageService._(this._prefs);

  static Future<StorageService> get instance async {
    if (_instance != null) return _instance!;
    final prefs = await SharedPreferences.getInstance();
    _instance = StorageService._(prefs);
    return _instance!;
  }

  List<String> get likedVideos => _prefs.getStringList(AppConstants.prefKeyLikedVideos) ?? const [];
  Future<void> setLikedVideos(List<String> ids) => _prefs.setStringList(AppConstants.prefKeyLikedVideos, ids);

  bool get isDarkMode => _prefs.getBool(AppConstants.prefKeyDarkMode) ?? true;
  Future<void> setDarkMode(bool value) => _prefs.setBool(AppConstants.prefKeyDarkMode, value);
}
