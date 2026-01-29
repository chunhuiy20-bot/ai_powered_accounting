import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _currentTheme = lightTheme;
  String _currentThemeName = "默认白";

  ThemeData get currentTheme => _currentTheme;
  String get themeName => _currentThemeName;

  // 1. 默认白
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF2F2F7), // 浅灰背景
    cardColor: Colors.white, // 白色卡片
    appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent),
    useMaterial3: true,
  );

  // 2. 极夜黑
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF000000), // 纯黑背景
    cardColor: const Color(0xFF1C1C1E), // 深灰卡片色（iOS 风格）
    appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent),
    // 定义文字颜色方案，确保深色模式下文字自动变白
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    useMaterial3: true,
  );

  void setTheme(String name) {
    _currentThemeName = name;
    _currentTheme = (name == "极夜黑") ? darkTheme : lightTheme;
    notifyListeners();
  }
}
