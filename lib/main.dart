import 'package:flutter/material.dart';
import 'package:my_first_app/providers/asset_provider.dart';
import 'package:provider/provider.dart'; // 引入 provider
import 'package:my_first_app/pages/main_page.dart';
import 'theme/theme_provider.dart'; // 引入刚才创建的类

void main() {
  runApp(
    // 🟢 使用 MultiProvider 包裹，方便以后添加更多状态
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AssetProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 🟢 监听主题变化
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'AI 记账',
      // 🟢 绑定动态主题
      theme: themeProvider.currentTheme,
      debugShowCheckedModeBanner: false,
      home: const MainPage(),
    );
  }
}
