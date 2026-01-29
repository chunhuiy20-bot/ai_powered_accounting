import 'package:flutter/material.dart';
import 'package:my_first_app/pages/profile/profile_page.dart';
import 'package:my_first_app/pages/profile/components/profile_app_bar.dart';
import 'package:my_first_app/pages/record/record_page.dart';

import '../components/floating_nav_bar.dart';
import 'daily/components/daily_bill_app_bar.dart';
import 'daily/daily_bill_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DailyBillPage(),
    const RecordPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 修改返回值类型为可空 (PreferredSizeWidget?)
  PreferredSizeWidget? _buildAppBar() {
    switch (_selectedIndex) {
      case 0: // 今日账单
        return const DailyBillAppBar();
      case 1: // 记账
        // 🟢 关键修改：返回 null
        // 因为 RecordPage 自己内部已经有了 Scaffold 和 RecordAppBar
        // 如果这里再返回 AppBar，界面上会出现两个头部
        return null;
      case 2: // 个人中心
        return const ProfileAppBar();
      default:
        return AppBar(backgroundColor: Colors.transparent, elevation: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 只有在个人中心页时，允许 body 延伸到 AppBar 后面
      extendBodyBehindAppBar: _selectedIndex == 2,
      // 允许 body 延伸到最底部 (配合悬浮导航栏)
      extendBody: true,

      appBar: _buildAppBar(),

      body: IndexedStack(index: _selectedIndex, children: _pages),

      bottomNavigationBar: FloatingNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
