import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _currentTheme = lightTheme;
  String _currentThemeName = "默认白";

  ThemeData get currentTheme => _currentTheme;
  String get themeName => _currentThemeName;

  // // 1. 默认白
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Colors.blue,                // 主色（蓝色）
      secondary: Colors.blueAccent,        // 次色
      tertiary: Colors.lightBlue,          // 第三色
      surface: Colors.white,               // 卡片背景（白色）
      background: Color(0xFFF2F2F7),       // 页面背景（浅灰）
      onPrimary: Colors.white,             // 主色上的文字
      onSecondary: Colors.white,           // 次色上的文字
      onSurface: Colors.black87,           // 卡片上的文字（深色）
      onBackground: Colors.black87,        // 背景上的文字
      outline: Colors.grey,                // 边框颜色
      error: Colors.red,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFFF2F2F7),
    cardColor: Colors.white,
    appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent),
  );

  // 推荐配色方案：典雅孔雀绿 (以 #37a4bb 为主色)
  static final peacockTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,

    // --- 核心色彩方案 ---
    colorScheme: const ColorScheme(
      brightness: Brightness.light,

      // 主要颜色 (Primary)
      primary: Color(0xFF37A4BB),         // 主色 (您提供的孔雀绿)
      onPrimary: Colors.white,            // 主色上的文字/图标 (白色，对比度完美)

      // 次要/强调色 (Secondary) - 采用温暖的对比色
      secondary: Color(0xFFE5B673),       // 次色 (温暖的赭石色/柔和的金色)
      onSecondary: Color(0xFF41321C),     // 次色上的文字 (深棕色，确保清晰)

      // 第三色 (Tertiary) - 主色的柔和变体
      tertiary: Color(0xFFD1EAEF),         // 第三色 (非常浅的孔雀绿，用于背景或点缀)
      onTertiary: Color(0xFF1E4B56),       // 第三色上的文字 (深青色)

      // 界面背景/表面 (Surface & Background)
      surface: Colors.white,              // 卡片、对话框背景 (纯白)
      background: Color(0xFFF6F9FA),      // 页面背景 (非常浅的冷灰色，与主色调和谐)
      onSurface: Color(0xFF1A1C1D),       // 卡片上的文字 (标准的深色正文)
      onBackground: Color(0xFF1A1C1D),    // 页面背景上的文字

      // 其他
      outline: Color(0xFFDDE3E5),         // 边框/分割线颜色 (中性浅灰)
      error: Color(0xFFBA1A1A),           // 错误颜色 (M3 标准红色)
      onError: Colors.white,              // 错误颜色上的文字
    ),

    // --- 其他 UI 组件的快捷设置 ---
    scaffoldBackgroundColor: const Color(0xFFF6F9FA), // 页面背景
    cardColor: Colors.white,                         // 卡片背景
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,         // 保持 AppBar 透明
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF1A1C1D)), // AppBar 图标颜色
      titleTextStyle: TextStyle(
        color: Color(0xFF1A1C1D), // AppBar 标题颜色
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  // 天青
  static final ceruleanTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,

    // --- 核心色彩方案 ---
    colorScheme: const ColorScheme(
      brightness: Brightness.light,

      // 主要颜色 (Primary)
      primary: Color(0xFFC3E0E7),         // 主色 (您提供的天青色)
      onPrimary: Color(0xFF2E4047),       // 主色上的文字 (深蓝灰色，保证清晰可读)

      // 次要/强调色 (Secondary) - 采用温暖的辅助色进行平衡
      secondary: Color(0xFFE6C5A9),       // 次色 (柔和的沙滩色)
      onSecondary: Color(0xFF514335),     // 次色上的文字 (深棕色)

      // 第三色 (Tertiary) - 主色的变体，用于细节点缀
      tertiary: Color(0xFFB9D4DC),         // 第三色 (比主色稍深，增加层次)
      onTertiary: Color(0xFF22353A),       // 第三色上的文字 (深蓝灰色)

      // 界面背景/表面 (Surface & Background)
      surface: Colors.white,              // 卡片、对话框背景 (纯白)
      background: Color(0xFFF7F9FA),      // 页面背景 (极浅的冷灰色，与主色调和谐)
      onSurface: Color(0xFF1A1C1D),       // 卡片上的文字 (标准的深色正文)
      onBackground: Color(0xFF1A1C1D),    // 页面背景上的文字

      // 其他
      outline: Color(0xFFDDE2E5),         // 边框/分割线颜色 (中性浅灰)
      error: Color(0xFFBA1A1A),           // 错误颜色 (M3 标准红色)
      onError: Colors.white,              // 错误颜色上的文字
    ),

    // --- 其他 UI 组件的快捷设置 ---
    scaffoldBackgroundColor: const Color(0xFFF7F9FA), // 页面背景
    cardColor: Colors.white,                         // 卡片背景
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,         // 保持 AppBar 透明
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF1A1C1D)), // AppBar 图标颜色
      titleTextStyle: TextStyle(
        color: Color(0xFF1A1C1D), // AppBar 标题颜色
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  // 推荐配色方案：温暖活力（以 #f4a135 为主色）
  static final warmTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,

    // --- 核心色彩方案 ---
    colorScheme: const ColorScheme(
      brightness: Brightness.light,

      // 主要颜色 (Primary)
      primary: Color(0xFFF4A135),         // 主色 (您提供的橙金色)
      onPrimary: Colors.white,            // 主色上的文字/图标 (白色，对比度高)

      // 次要/强调色 (Secondary) - 采用互补色，增加视觉层次
      secondary: Color(0xFF5C7E9A),       // 次色 (沉稳的蓝灰色)
      onSecondary: Colors.white,          // 次色上的文字/图标 (白色)

      // 第三色 (Tertiary) - 通常是主色的柔和变体
      tertiary: Color(0xFFFDECDA),         // 第三色 (非常浅的橙色，用于高亮或背景)
      onTertiary: Color(0xFF614A2E),       // 第三色上的文字 (深棕色)

      // 界面背景/表面 (Surface & Background)
      surface: Colors.white,              // 卡片、对话框背景 (纯白)
      background: Color(0xFFF8F8FA),      // 页面背景 (一个更中性的浅灰)
      onSurface: Color(0xFF212121),       // 卡片上的文字 (近乎纯黑，确保可读性)
      onBackground: Color(0xFF212121),    // 页面背景上的文字

      // 其他
      outline: Color(0xFFE0E0E0),         // 边框/分割线颜色 (浅灰色)
      error: Color(0xFFD32F2F),           // 错误颜色 (标准的深红色)
      onError: Colors.white,              // 错误颜色上的文字
    ),

    // --- 其他 UI 组件的快捷设置 ---
    scaffoldBackgroundColor: const Color(0xFFF8F8FA), // 页面背景
    cardColor: Colors.white,                         // 卡片背景
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,         // 保持 AppBar 透明
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF212121)), // AppBar 图标颜色
      titleTextStyle: TextStyle(
        color: Color(0xFF212121),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  // 2. 极夜黑
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: Colors.blueAccent,          // 主色（亮蓝色）
      secondary: Colors.lightBlueAccent,   // 次色
      tertiary: Colors.blue,               // 第三色
      surface: Color(0xFF1C1C1E),          // 卡片背景（深灰）
      background: Color(0xFF000000),       // 页面背景（纯黑）
      onPrimary: Colors.black,             // 主色上的文字
      onSecondary: Colors.black,           // 次色上的文字
      onSurface: Colors.white,             // 卡片上的文字（白色）
      onBackground: Colors.white,          // 背景上的文字
      outline: Colors.grey,                // 边框颜色
      error: Colors.redAccent,
      onError: Colors.black,
    ),
    scaffoldBackgroundColor: const Color(0xFF000000),
    cardColor: const Color(0xFF1C1C1E),
    appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
  );

  // 3. 景泰蓝
  static final cloisonneTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF004ea2),        // 主蓝色
      secondary: Color(0xFF2b2680),      // 紫蓝色
      tertiary: Color(0xFF4659a7),       // 浅蓝色
      surface: Color(0xFFf5f9fc),        // 卡片背景（近白蓝）
      background: Color(0xFFe8f1f8),     // 页面背景（浅蓝）
      onPrimary: Colors.white,           // 主色上的文字
      onSecondary: Colors.white,         // 次色上的文字
      onSurface: Color(0xFF1a3a5c),      // 卡片上的文字（深蓝）
      onBackground: Color(0xFF1a3a5c),   // 背景上的文字
      outline: Color(0xFF8fa3c4),        // 边框颜色
      error: Colors.red,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFFe8f1f8),
    cardColor: const Color(0xFFf5f9fc),
    appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent),
  );

  void setTheme(String name) {
    _currentThemeName = name;
    if (name == "极夜黑") {
      _currentTheme = darkTheme;
    } else if (name == "景泰蓝") {
      _currentTheme = cloisonneTheme;
    } else if(name=="孔雀绿"){
      _currentTheme = peacockTheme;
    }else if(name=="天青色"){
      _currentTheme = ceruleanTheme;
    }else if(name=="暖黄色"){
      _currentTheme = warmTheme;
    }
    else {
      _currentTheme = lightTheme;
    }
    notifyListeners();
  }
}
