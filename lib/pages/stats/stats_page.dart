import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 记录当前选中的索引 (-1表示未选中)
  int _touchedIndex = -1;

  final Map<String, List<Map<String, dynamic>>> _mockData = {
    '周': [
      {'label': '餐饮', 'amount': 450.0, 'color': Colors.orange},
      {'label': '交通', 'amount': 120.0, 'color': Colors.blue},
      {'label': '购物', 'amount': 80.0, 'color': Colors.pink},
    ],
    '月': [
      {'label': '餐饮', 'amount': 2480.0, 'color': Colors.orange},
      {'label': '房租', 'amount': 3500.0, 'color': Colors.brown},
      {'label': '购物', 'amount': 1200.0, 'color': Colors.pink},
      {'label': '交通', 'amount': 400.0, 'color': Colors.blue},
      {'label': '娱乐', 'amount': 300.0, 'color': Colors.purple},
      {'label': '医疗', 'amount': 200.0, 'color': Colors.green},
      {'label': '人情', 'amount': 500.0, 'color': Colors.red},
    ],
    '年': [
      {'label': '房租', 'amount': 42000.0, 'color': Colors.brown},
      {'label': '餐饮', 'amount': 28000.0, 'color': Colors.orange},
      {'label': '购物', 'amount': 15000.0, 'color': Colors.pink},
      {'label': '交通', 'amount': 5000.0, 'color': Colors.blue},
      {'label': '旅游', 'amount': 8000.0, 'color': Colors.teal},
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _touchedIndex = -1;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "收支统计",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          // 1. 顶部 Tab
          Container(
            width: 300,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: "周"),
                Tab(text: "月"),
                Tab(text: "年"),
              ],
              onTap: (index) => setState(() {}),
            ),
          ),

          const SizedBox(height: 30),

          // 2. 核心内容：图表 + 网格列表
          Expanded(child: _buildStatsContent()),
        ],
      ),
    );
  }

  Widget _buildStatsContent() {
    String currentKey = ['周', '月', '年'][_tabController.index];
    List<Map<String, dynamic>> data = _mockData[currentKey]!;
    double totalAmount = data.fold(0, (sum, item) => sum + item['amount']);

    // 计算中间显示的内容
    String centerLabel = "总支出";
    String centerAmount = totalAmount.toStringAsFixed(0);
    String centerPercent = "";
    Color centerColor = Colors.black;

    // 如果有选中项，显示选中项的数据
    if (_touchedIndex != -1 && _touchedIndex < data.length) {
      final item = data[_touchedIndex];
      centerLabel = item['label'];
      centerAmount = item['amount'].toStringAsFixed(2);
      double percent = item['amount'] / totalAmount;
      centerPercent = "${(percent * 100).toStringAsFixed(1)}%";
      centerColor = item['color'];
    }

    return Column(
      children: [
        // --- A. 环形图表区域 ---
        SizedBox(
          height: 240,
          child: Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onPanUpdate: (details) =>
                    _handleTouch(details.localPosition, 220, data, totalAmount),
                onTapDown: (details) =>
                    _handleTouch(details.localPosition, 220, data, totalAmount),
                onPanEnd: (_) => setState(() => _touchedIndex = -1),
                onTapUp: (_) => setState(() => _touchedIndex = -1),

                child: CustomPaint(
                  size: const Size(220, 220),
                  painter: _PieChartPainter(
                    data,
                    totalAmount,
                    touchedIndex: _touchedIndex,
                  ),
                ),
              ),

              // 中间文字 (透传点击事件)
              IgnorePointer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      centerLabel,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      centerAmount,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: centerColor,
                      ),
                    ),
                    if (centerPercent.isNotEmpty)
                      Text(
                        centerPercent,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: centerColor.withOpacity(0.8),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // --- B. 分类网格列表 (省空间版) ---
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: const BoxDecoration(
              color: Color(0xFFF9F9F9), // 浅灰底色区分区域
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "分类详情",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // 一行3个
                          childAspectRatio: 2.2, // 扁长条形状
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final item = data[index];
                      // 判断是否被高亮
                      final bool isSelected = _touchedIndex == index;
                      // 如果有选中项但不是自己，则变淡
                      final bool isDimmed = _touchedIndex != -1 && !isSelected;

                      return GestureDetector(
                        // 1. 按下时高亮图表
                        onTapDown: (_) {
                          HapticFeedback.lightImpact(); // 震动反馈
                          setState(() => _touchedIndex = index);
                        },
                        // 2. 松开时恢复
                        onTapUp: (_) => setState(() => _touchedIndex = -1),
                        onTapCancel: () => setState(() => _touchedIndex = -1),

                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: isDimmed ? 0.3 : 1.0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              // 选中时加边框和阴影
                              border: isSelected
                                  ? Border.all(color: item['color'], width: 1.5)
                                  : Border.all(color: Colors.transparent),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // 小圆点颜色指示
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: item['color'],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // 只有图标和名称
                                Icon(
                                  Icons.category,
                                  size: 16,
                                  color: Colors.grey[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item['label'],
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? item['color']
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 计算触摸逻辑
  void _handleTouch(
    Offset localPosition,
    double size,
    List<Map<String, dynamic>> data,
    double total,
  ) {
    final centerX = size / 2;
    final centerY = size / 2;
    final dx = localPosition.dx - centerX;
    final dy = localPosition.dy - centerY;
    final distance = sqrt(dx * dx + dy * dy);

    // 增加触摸容错范围
    if (distance < 50 || distance > 130) {
      if (_touchedIndex != -1) setState(() => _touchedIndex = -1);
      return;
    }

    double angle = atan2(dy, dx);
    angle += pi / 2;
    if (angle < 0) angle += 2 * pi;

    double currentAngle = 0;
    int newIndex = -1;
    for (int i = 0; i < data.length; i++) {
      double sweep = (data[i]['amount'] / total) * 2 * pi;
      if (angle >= currentAngle && angle < currentAngle + sweep) {
        newIndex = i;
        break;
      }
      currentAngle += sweep;
    }

    if (newIndex != _touchedIndex) {
      HapticFeedback.selectionClick(); // 触摸到不同区域时震动
      setState(() {
        _touchedIndex = newIndex;
      });
    }
  }
}

// 画笔保持之前的完美版本 (平头 + 间隙)
class _PieChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final double total;
  final int touchedIndex;

  _PieChartPainter(this.data, this.total, {this.touchedIndex = -1});

  @override
  void paint(Canvas canvas, Size size) {
    double startAngle = -pi / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth =
          30 // 稍微加粗一点点
      ..strokeCap = StrokeCap.butt;

    for (int i = 0; i < data.length; i++) {
      var item = data[i];
      double percent = item['amount'] / total;
      double sweepAngle = percent * 2 * pi;

      // 视觉反馈
      if (touchedIndex != -1 && touchedIndex != i) {
        paint.color = (item['color'] as Color).withOpacity(0.15); // 未选中的变得更淡
      } else {
        paint.color = item['color'];
      }

      double drawAngle = sweepAngle;
      if (percent > 0.01) drawAngle = sweepAngle - 0.01; // 缝隙

      // 选中的那一段稍微放大一点点 (视觉弹出效果)
      double currentRadius = radius;
      double currentWidth = 30;

      if (i == touchedIndex) {
        currentRadius = radius + 2; // 半径变大
        currentWidth = 38; // 变粗

        // 绘制阴影
        final shadowPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 38
          ..color = item['color'].withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: currentRadius),
          startAngle,
          drawAngle,
          false,
          shadowPaint,
        );
      }

      paint.strokeWidth = currentWidth;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: currentRadius),
        startAngle,
        drawAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) =>
      oldDelegate.touchedIndex != touchedIndex;
}
