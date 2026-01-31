import 'package:flutter/material.dart';

class FloatingNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const FloatingNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    // 1. 计算导航栏的实际宽度（屏幕宽度 - 两边边距）
    final double barWidth = MediaQuery.of(context).size.width - 80.0;
    // 2. 计算每个导航项应该占据的“槽位”宽度
    final double itemSlotWidth = barWidth / 3;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(left: 40, right: 40, bottom: 30),
        height: 64, // 悬浮岛的高度
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface, // 使用主题卡片背景色
          borderRadius: BorderRadius.circular(32), // 全圆角
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        // 3. 使用 Stack 布局来堆叠滑动块和图标
        child: Stack(
          children: [
            // --- 背景层的滑动块 ---
            AnimatedPositioned(
              // 4. 动画的核心：根据 selectedIndex 计算 left 位置
              left: itemSlotWidth * selectedIndex,
              top: 0,
              bottom: 0,
              duration: const Duration(milliseconds: 350), // 动画时长
              curve: Curves.fastOutSlowIn, // 动画曲线，体验更佳
              child: Container(
                // 滑动块的宽度等于一个槽位的宽度
                width: itemSlotWidth,
                // 使用一些内边距来让黑色块看起来像个“药丸”
                padding: const EdgeInsets.all(4),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
              ),
            ),
            // --- 前景层的图标和文字 ---
            Row(
              children: [
                _buildNavItem(context, 0, Icons.grid_view_rounded, "账单"),
                _buildNavItem(context, 1, Icons.add_rounded, "记账"),
                _buildNavItem(context, 2, Icons.person_rounded, "我的"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 5. _buildNavItem 现在只负责显示内容和处理点击，不再有自己的背景
  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label) {
    final bool isSelected = selectedIndex == index;

    // 每个 Item 使用 Expanded 来占据 1/3 的空间
    return Expanded(
      child: GestureDetector(
        onTap: () => onItemTapped(index),
        behavior: HitTestBehavior.opaque, // 保证整个区域可点击
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                // 选中的图标使用主题的 onPrimary 颜色；未选中的使用 onSurface
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                size: 24,
              ),
              // 使用 AnimatedSize 让文字出现/消失时有平滑的宽度动画
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.fastOutSlowIn,
                child: isSelected
                    ? Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                )
                // 未选中时，用一个空的 SizedBox 占位
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
