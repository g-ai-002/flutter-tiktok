import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileSystemService {
  FileSystemService._();
  static final FileSystemService instance = FileSystemService._();

  Directory? _logRoot;
  Directory? _userRoot;

  Future<Directory> getUserRoot() async {
    if (_userRoot != null) return _userRoot!;
    Directory base;
    if (Platform.isAndroid) {
      final ext = await getExternalStorageDirectory();
      base = ext ?? await getApplicationDocumentsDirectory();
    } else {
      base = await getApplicationDocumentsDirectory();
    }
    final root = Directory('${base.path}${Platform.pathSeparator}FlutterTiktok');
    if (!await root.exists()) {
      await root.create(recursive: true);
    }
    _userRoot = root;
    return root;
  }

  Future<Directory> getLogRoot() async {
    if (_logRoot != null) return _logRoot!;
    final user = await getUserRoot();
    final logDir = Directory('${user.path}${Platform.pathSeparator}logs');
    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }
    _logRoot = logDir;
    return logDir;
  }

  Future<File> getUserFile(String filename) async {
    final dir = await getUserRoot();
    return File('${dir.path}${Platform.pathSeparator}$filename');
  }
}
