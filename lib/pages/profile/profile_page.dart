import 'package:flutter/material.dart';
import 'sub/category_management_page.dart';
import 'sub/budget_setting_page.dart';
import 'package:provider/provider.dart';
import '../../theme/theme_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用 ListView 确保小屏幕可以滚动
    return Scaffold(
      backgroundColor: Colors.transparent, // 设为透明，透出底层的浅灰色
      body: ListView(
        // 关键点：设置 Padding
        // top: 290 是为了避开我们那个巨大的 ProfileAppBar (高度280左右)
        // bottom: 110 是为了避开底部的悬浮 TabBar 岛
        padding: const EdgeInsets.only(top: 290, left: 16, right: 16, bottom: 110),
        children: [

          // 1. 资产概览小卡片 (放在 VIP 卡片下面)
          Row(
            children: [
              Expanded(
                child: _buildAssetCard(
                  title: '总资产',
                  amount: '12,048.00',
                  icon: Icons.account_balance_wallet_outlined,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAssetCard(
                  title: '本月结余',
                  amount: '+3,204.50',
                  icon: Icons.savings_outlined,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 2. 常用功能组
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              "常用功能",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildMenuItem(Icons.category_outlined, "分类管理", onTap: () {
                  // 🟢 添加跳转逻辑
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CategoryManagementPage()),
                  );
                }),
                _buildDivider(),
                _buildMenuItem(Icons.receipt_long_outlined, "账单导出", suffix: "Excel/PDF", onTap: () {}),
                _buildDivider(),
                _buildMenuItem(Icons.alarm_on_outlined, "定时记账", onTap: () {}),
                _buildDivider(),
                _buildMenuItem(Icons.pie_chart_outline, "预算设置", onTap: () {
                  // 🟢 跳转到预算设置页
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BudgetSettingPage()),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 3. 系统设置组 (已合并退出登录)
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              "系统设置",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildMenuItem(
                    Icons.color_lens_outlined,
                    "主题皮肤",
                    suffix: Provider.of<ThemeProvider>(context).themeName,
                    onTap: () {
                      // 🟢 改为弹出底部层
                      _showThemeSelector(context);
                    }
                ),
                _buildDivider(),
                _buildMenuItem(Icons.feedback_outlined, "意见反馈", onTap: () {}),
                _buildDivider(),
                _buildMenuItem(Icons.info_outline, "关于我们", suffix: "v1.0.0", onTap: () {}),
                _buildDivider(),
                // 🟢 退出登录已移至此处
                _buildMenuItem(
                    Icons.logout_rounded,
                    "退出登录",
                    titleColor: Colors.redAccent, // 设置为红色警告色
                    onTap: () {
                      // TODO: 执行退出登录逻辑
                    }
                ),
              ],
            ),
          ),

          // 底部占位，确保滚动体验
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- 封装的小组件 ---

  // 顶部资产小卡片
  Widget _buildAssetCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Text(
            amount,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // 菜单项 (优化：增加 titleColor 参数)
  Widget _buildMenuItem(
      IconData icon,
      String title, {
        String? suffix,
        VoidCallback? onTap,
        Color titleColor = Colors.black87, // 默认黑色
      }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F7), // 图标背景色
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
            icon,
            size: 20,
            color: titleColor == Colors.redAccent ? Colors.redAccent : Colors.black87
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: titleColor, // 使用传入的颜色
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

  // 分割线 (缩进样式，不切断左侧图标)
  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 0.5,
      indent: 60, // 左侧缩进
      endIndent: 16,
      color: Color(0xFFEEEEEE),
    );
  }
}

// --- 新增：弹出层方法 ---
void _showThemeSelector(BuildContext context) {
  final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent, // 设为透明以使用自定义圆角
    builder: (context) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor, // 跟随当前主题卡片色
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // 高度自适应
          children: [
            const Text(
              "选择皮肤",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildThemeOption(context, "默认白", const Color(0xFFF2F2F7), themeProvider),
                _buildThemeOption(context, "极夜黑", const Color(0xFF121212), themeProvider),
                _buildThemeOption(context, "黑金尊享", const Color(0xFFFDFCF0), themeProvider),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}

// 辅助方法：构建主题预览按钮
Widget _buildThemeOption(BuildContext context, String name, Color previewColor, ThemeProvider provider) {
  bool isSelected = provider.themeName == name;

  return GestureDetector(
    onTap: () {
      provider.setTheme(name);
      Navigator.pop(context); // 切换后自动关闭弹窗
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
              color: isSelected ? Colors.black : Colors.grey.withOpacity(0.2),
              width: isSelected ? 3 : 1,
            ),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)] : [],
          ),
          child: isSelected ? const Icon(Icons.check, color: Colors.black) : null,
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