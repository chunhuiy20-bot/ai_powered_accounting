import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/theme_provider.dart';
import '../../providers/asset_provider.dart';
import 'sub/category_management_page.dart';
import 'sub/budget_setting_page.dart';
import 'sub/asset_page.dart';
import 'sub/monthly_balance_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // 记录用户设置的定时提醒时间 (默认为空)
  TimeOfDay? _reminderTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.only(top: 290, left: 16, right: 16, bottom: 110),
        children: [
          // 1. 资产概览
          Row(
            children: [
              Expanded(
                child: Consumer<AssetProvider>(
                  builder: (context, assetProvider, child) {
                    return _buildAssetCard(
                      context,
                      title: '总资产',
                      amount: assetProvider.totalAssetCNY.toStringAsFixed(2),
                      icon: Icons.account_balance_wallet_outlined,
                      color: Colors.blueAccent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AssetPage()),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAssetCard(
                  context,
                  title: '本月结余',
                  amount: '+3,204.50',
                  icon: Icons.savings_outlined,
                  color: Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MonthlyBalancePage()),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 2. 常用功能
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              "常用功能",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildMenuItem(context, Icons.category_outlined, "分类管理", onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryManagementPage()));
                }),
                _buildDivider(),
                _buildMenuItem(context, Icons.receipt_long_outlined, "账单导出", suffix: "Excel/PDF", onTap: () {}),
                _buildDivider(),
                // 🟢 核心修改：定时记账逻辑
                _buildMenuItem(
                    context,
                    Icons.alarm_on_outlined,
                    "定时记账",
                    // 如果已设置，显示具体时间；否则为空
                    suffix: _reminderTime != null ? _reminderTime!.format(context) : null,
                    onTap: () {
                      _showTimePicker(context);
                    }
                ),
                _buildDivider(),
                _buildMenuItem(context, Icons.pie_chart_outline, "预算设置", onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const BudgetSettingPage()));
                }),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 3. 系统设置
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              "系统设置",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildMenuItem(
                    context,
                    Icons.color_lens_outlined,
                    "主题皮肤",
                    suffix: Provider.of<ThemeProvider>(context).themeName,
                    onTap: () {
                      _showThemeSelector(context);
                    }
                ),
                _buildDivider(),
                _buildMenuItem(context, Icons.feedback_outlined, "意见反馈", onTap: () {}),
                _buildDivider(),
                _buildMenuItem(context, Icons.info_outline, "关于我们", suffix: "v1.0.0", onTap: () {}),
                _buildDivider(),
                _buildMenuItem(
                    context,
                    Icons.logout_rounded,
                    "退出登录",
                    titleColor: Colors.redAccent,
                    onTap: () {}
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- 🟢 核心逻辑：显示时间选择器 ---
  Future<void> _showTimePicker(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
      builder: (context, child) {
        // 自定义 TimePicker 主题以适配深色模式
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).cardColor,
              dialHandColor: Theme.of(context).colorScheme.primary,
              dialBackgroundColor: Colors.grey.withOpacity(0.1),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // 弹出二次确认框
      if (!mounted) return;
      _showConfirmationDialog(context, picked);
    }
  }

  void _showConfirmationDialog(BuildContext context, TimeOfDay time) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("设置提醒", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text("我们将在每天的 ${time.format(context)} 提醒您记账，养成好习惯！"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("取消", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _reminderTime = time;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("已开启每日 ${time.format(context)} 提醒"),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text("确认开启", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // --- 封装组件 (保持不变) ---

  Widget _buildAssetCard(
      BuildContext context, {
        required String title,
        required String amount,
        required IconData icon,
        required Color color,
        VoidCallback? onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Icon(icon, size: 18, color: color),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Text(
                amount,
                key: ValueKey<String>(amount),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontFamily: "Roboto",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context,
      IconData icon,
      String title, {
        String? suffix,
        VoidCallback? onTap,
        Color? titleColor,
      }) {
    final defaultTitleColor = titleColor ?? Theme.of(context).colorScheme.onSurface;
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
            icon,
            size: 20,
            color: titleColor ?? Theme.of(context).colorScheme.onSurface
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: defaultTitleColor,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (suffix != null)
            Text(
              suffix,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          if (suffix != null) const SizedBox(width: 4),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 0.5, indent: 60, endIndent: 16, color: Color(0xFFEEEEEE));
  }

  void _showThemeSelector(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 40),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "选择皮肤",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 20,
                crossAxisSpacing: 10,
                childAspectRatio: 0.9,
                children: [
                  _buildThemeOption(context, "默认白", const Color(0xFFF2F2F7), themeProvider),
                  _buildThemeOption(context, "极夜黑", const Color(0xFF000000), themeProvider),
                  _buildThemeOption(context, "景泰蓝", const Color(0xFF004EA2), themeProvider),
                  _buildThemeOption(context, "孔雀绿", const Color(0xFF37A4BB), themeProvider),
                  _buildThemeOption(context, "天青色", const Color(0xFFC3E0E7), themeProvider),
                  _buildThemeOption(context, "暖黄色", const Color(0xFFF4A135), themeProvider),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(BuildContext context, String name, Color previewColor, ThemeProvider provider) {
    bool isSelected = provider.themeName == name;
    return GestureDetector(
      onTap: () {
        provider.setTheme(name);
        Navigator.pop(context);
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: previewColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.withOpacity(0.2),
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)] : [],
            ),
            child: isSelected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}
