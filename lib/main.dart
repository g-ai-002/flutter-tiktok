import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'pages/home_page.dart';
import 'pages/search_page.dart';
import 'pages/profile_page.dart';
import 'providers/video_provider.dart';
import 'providers/theme_provider.dart';
import 'services/interaction_service.dart';
import 'services/log_service.dart';
import 'services/storage_service.dart';
import 'services/category_service.dart';
import 'theme/app_theme.dart';
import 'utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

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
  await InteractionService.instance.init();
  await CategoryService.instance.init();
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VideoProvider(storage)),
        ChangeNotifierProvider(create: (_) => ThemeProvider(storage)),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          final isDark = themeProvider.isDarkMode;
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          ));
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: buildLightTheme(fontFamily: fontFamily),
            darkTheme: buildDarkTheme(fontFamily: fontFamily),
            themeMode: themeProvider.themeMode,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('zh', 'CN')],
            locale: const Locale('zh', 'CN'),
            home: const MainShell(),
          );
        },
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentTab = 0;
  final PageController _homePageController = PageController();

  void _switchToHome(int videoIndex) {
    setState(() => _currentTab = 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_homePageController.hasClients) {
        _homePageController.jumpToPage(videoIndex);
      }
    });
  }

  @override
  void dispose() {
    _homePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : Colors.white;
    final navBg = isDark ? Colors.black : Colors.white;
    final borderColor = isDark ? Colors.white12 : Colors.black12;

    return Scaffold(
      backgroundColor: bgColor,
      body: IndexedStack(
        index: _currentTab,
        children: [
          HomePage(pageController: _homePageController),
          SearchPage(onVideoSelected: _switchToHome),
          ProfilePage(onVideoSelected: _switchToHome),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: borderColor, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentTab,
          onTap: (i) => setState(() => _currentTab = i),
          backgroundColor: navBg,
          selectedItemColor: isDark ? Colors.white : Colors.black87,
          unselectedItemColor: isDark ? Colors.white38 : Colors.black38,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home, size: 24), label: '首页'),
            BottomNavigationBarItem(icon: Icon(Icons.search, size: 24), label: '搜索'),
            BottomNavigationBarItem(icon: Icon(Icons.person, size: 24), label: '我的'),
          ],
        ),
      ),
    );
  }
}
