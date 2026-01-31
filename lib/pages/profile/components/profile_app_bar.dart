import 'package:flutter/material.dart';
// 1. 引入登录页面 (确保路径正确)
import '../../login/login_page.dart';

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ProfileAppBar({super.key});

  static const double _totalHeight = 280.0;
  static const double _whiteBackgroundHeight = 240.0;
  static const double _cardHeight = 80.0;

  @override
  Size get preferredSize => const Size.fromHeight(_totalHeight);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _totalHeight,
      child: Stack(
        children: [
          // 第一层：白色弧形背景
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: _whiteBackgroundHeight,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
          ),

          // 第二层：右上角按钮
          Positioned(
            top: MediaQuery.of(context).padding.top,
            right: 16,
            child: Row(
              children: [
                _buildIconButton(Icons.headset_mic_outlined),
                const SizedBox(width: 8),
                _buildIconButton(Icons.settings_outlined),
              ],
            ),
          ),

          // ==========================================
          // 2. 第三层：用户信息 (点击区域) -> 修改了这里
          // ==========================================
          Positioned(
            top: MediaQuery.of(context).padding.top + 50,
            left: 24,
            right: 24,
            child: GestureDetector(
              // 添加点击事件
              onTap: () {
                // 跳转到登录页面
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              // 确保点击空白处也能触发（如果Row没填满）
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  // 头像
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      image: const DecorationImage(
                        // 建议还是改回 AssetImage 用本地图片比较稳定
                        // 如果还没放本地图片，这里继续用 NetworkImage
                        image: NetworkImage('https://avatar.iran.liara.run/public/35'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 文字信息
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '点击登录',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Text(
                            '登录同步数据',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.grey),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),

          // 第四层：悬浮的 VIP 黑金卡片 (保持不变)
          Positioned(
            bottom: 0,
            left: 20,
            right: 20,
            height: _cardHeight,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2B2E33), Color(0xFF1A1A1A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -10,
                    top: -10,
                    child: Icon(Icons.diamond_outlined, size: 100, color: Colors.white.withOpacity(0.05)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    child: Row(
                      children: [
                        const Icon(Icons.diamond_rounded, color: Color(0xFFFFD700), size: 24),
                        const SizedBox(width: 12),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              '永久 VIP 会员',
                              style: TextStyle(
                                color: Color(0xFFFFD700),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '限时特惠，解锁所有功能',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFFC107)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '立即查看',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Builder(
      builder: (context) => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.onSurface, size: 22),
      ),
    );
  }
}
