import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 引入系统服务(震动+声音)

class DailyBillPage extends StatefulWidget {
  const DailyBillPage({super.key});

  @override
  State<DailyBillPage> createState() => _DailyBillPageState();
}

class _DailyBillPageState extends State<DailyBillPage> {
  // 模拟数据源
  final List<Map<String, dynamic>> _dailyData = [
    {
      "date": "11月27日 今天",
      "summary": "支出 37.00",
      "items": [
        {"id": 1, "icon": Icons.coffee, "color": Colors.orange, "title": "星巴克咖啡", "time": "14:30", "amount": "-32.00"},
        {"id": 2, "icon": Icons.directions_subway, "color": Colors.blue, "title": "地铁通勤", "time": "08:15", "amount": "-5.00"},
      ]
    },
    {
      "date": "11月26日 昨天",
      "summary": "支出 173.50",
      "items": [
        {"id": 3, "icon": Icons.shopping_bag, "color": Colors.pink, "title": "沃尔玛超市", "time": "18:30", "amount": "-128.50"},
        {"id": 4, "icon": Icons.local_dining, "color": Colors.redAccent, "title": "麦当劳", "time": "12:00", "amount": "-45.00"},
      ]
    },
    {
      "date": "11月24日 周日",
      "summary": "支出 80.00",
      "items": [
        {"id": 5, "icon": Icons.movie, "color": Colors.purple, "title": "万达影城", "time": "20:00", "amount": "-80.00"},
      ]
    },
    {
      "date": "11月20日 周三",
      "summary": "收入 5000.00",
      "items": [
        {"id": 6, "icon": Icons.account_balance_wallet, "color": Colors.green, "title": "工资入账", "time": "09:00", "amount": "+5000.00", "isIncome": true},
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: const _OverviewCard(),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 110),
              itemCount: _dailyData.length,
              itemBuilder: (context, groupIndex) {
                final group = _dailyData[groupIndex];
                final List<Map<String, dynamic>> items = group['items'];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateHeader(group['date'], group['summary']),
                    ...items.map((item) {
                      return _InteractiveBillItem(
                        item: item,
                        onLongPress: () {
                          _showBeautifulDeleteDialog(groupIndex, item);
                        },
                      );
                    }).toList(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- 灵动简约的删除弹窗 ---
  void _showBeautifulDeleteDialog(int groupIndex, Map<String, dynamic> item) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
      pageBuilder: (ctx, anim1, anim2) {
        return Center(
          child: Container(
            width: 280,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 32),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "确认删除",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "记录删除后将无法恢复，确定要继续吗？",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            backgroundColor: const Color(0xFFF2F2F7),
                          ),
                          child: const Text("取消", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            // 删除确认时的轻微震动
                            HapticFeedback.lightImpact();
                            _deleteItem(groupIndex, item);
                            Navigator.pop(ctx);
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            backgroundColor: Colors.black,
                          ),
                          child: const Text("删除", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _deleteItem(int groupIndex, Map<String, dynamic> item) {
    setState(() {
      final List items = _dailyData[groupIndex]['items'];
      items.remove(item);
      if (items.isEmpty) {
        _dailyData.removeAt(groupIndex);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text("删除成功"),
          ],
        ),
        backgroundColor: Colors.black.withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Widget _buildDateHeader(String date, String summary) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12, left: 4, right: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            date,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          Text(
            summary,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// =======================================================
// 1. 带按压动画 + 震动 + 声音反馈 的 Item 组件
// =======================================================
class _InteractiveBillItem extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback onLongPress;

  const _InteractiveBillItem({
    required this.item,
    required this.onLongPress,
  });

  @override
  State<_InteractiveBillItem> createState() => _InteractiveBillItemState();
}

class _InteractiveBillItemState extends State<_InteractiveBillItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final bool isIncome = item['isIncome'] ?? false;

    return GestureDetector(
      // 按下时
      onTapDown: (_) => _controller.forward(),
      // 松开/取消时
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),

      // 2. 长按逻辑：强震动 + 系统短音 + 恢复动画 + 触发事件
      onLongPress: () async {
        // --- 触觉反馈 ---
        // 使用 vibrate() 获得最强烈的系统震动
        HapticFeedback.vibrate();

        // --- 听觉反馈 (无需额外文件) ---
        // 播放系统默认的“点击/交互”音效 (iOS是键盘声，Android是点击声)
        // 这是一个非常清脆的短音
        SystemSound.play(SystemSoundType.click);

        // --- 视觉反馈 ---
        _controller.reverse(); // 恢复卡片大小
        widget.onLongPress(); // 触发回调
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: item['color'].withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(item['icon'], color: item['color'], size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(item['time'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Text(
                item['amount'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isIncome ? const Color(0xFFE02020) : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '本月支出 (元)',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 8),
          const Text(
            '2,480.50',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              fontFamily: "Roboto",
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('预算剩余 1,500', style: TextStyle(color: Colors.white54, fontSize: 11)),
                        Text('62%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 6,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.62,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text('本月收入', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  SizedBox(height: 4),
                  Text(
                    '+8,500.00',
                    style: TextStyle(
                        color: Color(0xFFFFD700),
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                    ),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
