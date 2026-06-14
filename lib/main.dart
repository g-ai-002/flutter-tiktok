import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'pages/home_page.dart';
import 'providers/video_provider.dart';
import 'services/log_service.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows) {
    await windowManager.ensureInitialized();
    const opts = WindowOptions(
      size: Size(390, 844),
      minimumSize: Size(360, 640),
      center: true,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: AppConstants.appName,
    );
    windowManager.waitUntilReadyToShow(opts, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  final storage = await StorageService.instance;
  await LogService.init();
  LogService.info('应用启动: ${AppConstants.appName} v${AppConstants.version}');

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(TiktokApp(storage: storage));
}

class TiktokApp extends StatelessWidget {
  final StorageService storage;
  const TiktokApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    final fontFamily = Platform.isWindows ? 'Microsoft YaHei UI' : null;
    return ChangeNotifierProvider(
      create: (_) => VideoProvider(storage),
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: buildLightTheme(fontFamily: fontFamily),
        darkTheme: buildDarkTheme(fontFamily: fontFamily),
        themeMode: ThemeMode.dark,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('zh', 'CN')],
        locale: const Locale('zh', 'CN'),
        home: const HomePage(),
      ),
    );
  }
}
