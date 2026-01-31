import 'dart:math';
import 'package:flutter/material.dart';

class MonthlyBalancePage extends StatefulWidget {
  const MonthlyBalancePage({super.key});

  @override
  State<MonthlyBalancePage> createState() => _MonthlyBalancePageState();
}

class _MonthlyBalancePageState extends State<MonthlyBalancePage> with SingleTickerProviderStateMixin {
  late List<Map<String, dynamic>> _dailyData;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  double _totalNet = 0;
  DateTime _currentMonth = DateTime.now();

  final List<String> _monthNames = [
    "一月", "二月", "三月", "四月", "五月", "六月",
    "七月", "八月", "九月", "十月", "十一月", "十二月"
  ];

  final List<String> _aiTagsPool = [
    "奶茶小达人", "疯狂干饭人", "游戏重度玩家", "铲屎官",
    "养生达人", "出行特种兵", "买买买", "深夜食堂",
    "学习狂魔", "社交牛逼症"
  ];

  final List<String> _diaryTemplates = [
    "今天又是努力搬砖的一天！虽然花了点钱，但快乐是无价的。{tag}这个称号非我莫属了。",
    "有些东西说不清哪里好，但就是谁都替代不了，比如...今天的消费。看着{tag}的标签，我陷入了沉思。",
    "生活需要仪式感，今天的账单就是最好的证明。虽然余额在减少，但幸福感在增加呀！",
    "今日份的快乐已送达！不管是盈余还是赤字，都是认真生活的痕迹。{tag}，听起来还不错？",
  ];

  @override
  void initState() {
    super.initState();
    _generateMockData();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _generateMockData() {
    _dailyData = [];
    _totalNet = 0;

    final random = Random();
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;

    for (int i = 1; i <= daysInMonth; i++) {
      DateTime date = DateTime(_currentMonth.year, _currentMonth.month, i);

      double income = random.nextDouble() > 0.6 ? random.nextDouble() * 1500 : 0.0;
      double expense = random.nextDouble() * 400 + 50;
      double net = income - expense;

      int tagCount = random.nextInt(3) + 1;
      List<String> tags = [];
      for(int k=0; k<tagCount; k++) {
        tags.add(_aiTagsPool[random.nextInt(_aiTagsPool.length)]);
      }
      tags = tags.toSet().toList();

      String imageUrl = "https://api.dicebear.com/7.x/notionists/png?seed=${i}_${random.nextInt(100)}&backgroundColor=e6e6e6";

      String template = _diaryTemplates[random.nextInt(_diaryTemplates.length)];
      String mainTag = tags.isNotEmpty ? "“${tags[0]}”" : "“理财小能手”";
      String diaryContent = template.replaceAll("{tag}", mainTag);

      _dailyData.add({
        'date': date,
        'day': i,
        'weekday': date.weekday,
        'income': income,
        'expense': expense,
        'net': net,
        'tags': tags,
        'image': imageUrl,
        'diary': diaryContent,
      });
      _totalNet += net;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgGradientStart = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F7FA);
    final bgGradientEnd = isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
    final accentColor = isDark ? const Color(0xFFFFD700) : Colors.black;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgGradientStart, bgGradientEnd],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildCalendarHeatmapCard(isDark, accentColor),
                      const SizedBox(height: 30),
                      _buildSummaryCapsules(isDark),
                      const SizedBox(height: 40),
                      _buildTimelineList(isDark),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Theme.of(context).cardColor.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.arrow_back_ios_new, size: 18),
            ),
          ),
          const Text("账单统计", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1)),
          GestureDetector(
            onTap: () => _showDiaryBook(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Theme.of(context).cardColor.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.menu_book_rounded, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  void _showDiaryBook(BuildContext context) {
    List<Map<String, dynamic>> diaryPages = _dailyData.reversed.toList();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Diary",
      barrierColor: Colors.black.withOpacity(0.8),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: SizedBox(
            height: 600,
            width: double.infinity,
            child: _BookFlipPageView(pagesData: diaryPages),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  Widget _buildCalendarHeatmapCard(bool isDark, Color accentColor) {
    String monthTitle = "${_monthNames[_currentMonth.month - 1]}结余";
    int firstWeekday = (_dailyData.first['date'] as DateTime).weekday;
    int emptySlots = firstWeekday - 1;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: accentColor.withOpacity(0.05), blurRadius: 30, offset: const Offset(0, 10))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(monthTitle, style: TextStyle(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("${_totalNet >= 0 ? '+' : ''}${_totalNet.toStringAsFixed(0)}", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: accentColor, height: 1)),
                  ],
                ),
                Row(children: [_buildLegend(Colors.green, "盈"), const SizedBox(width: 8), _buildLegend(Colors.redAccent, "亏")])
              ],
            ),
            const SizedBox(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: ["M", "T", "W", "T", "F", "S", "S"].map((day) => SizedBox(width: 30, child: Center(child: Text(day, style: TextStyle(color: Colors.grey[400], fontSize: 10, fontWeight: FontWeight.bold))))).toList()),
            const SizedBox(height: 12),
            LayoutBuilder(
                builder: (context, constraints) {
                  double itemSize = (constraints.maxWidth - (6 * 8)) / 7;
                  return Wrap(
                    spacing: 8, runSpacing: 8,
                    children: [
                      ...List.generate(emptySlots, (index) => SizedBox(width: itemSize, height: itemSize)),
                      ..._dailyData.map((data) => _buildGridCell(data, itemSize, isDark)).toList(),
                    ],
                  );
                }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCell(Map<String, dynamic> data, double size, bool isDark) {
    double net = data['net'];
    bool isPositive = net >= 0;
    Color cellColor = isPositive ? Colors.green.withOpacity(0.85) : Colors.redAccent.withOpacity(0.85);
    String text = "${isPositive ? '+' : ''}${net.toInt()}";
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: cellColor, borderRadius: BorderRadius.circular(6)),
      child: Center(child: FittedBox(fit: BoxFit.scaleDown, child: Padding(padding: const EdgeInsets.all(2.0), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text("${data['day']}", style: TextStyle(fontSize: 8, color: Colors.white.withOpacity(0.8))), Text(text, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold))])))),
    );
  }

  Widget _buildLegend(Color color, String text) => Row(children: [Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 4), Text(text, style: const TextStyle(fontSize: 10, color: Colors.grey))]);

  Widget _buildSummaryCapsules(bool isDark) {
    double totalIn = _dailyData.fold(0, (p, c) => p + c['income']);
    double totalOut = _dailyData.fold(0, (p, c) => p + c['expense']);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [_buildCapsule(isDark, "本月收入", totalIn.toStringAsFixed(0), Colors.green, Icons.arrow_downward), const SizedBox(width: 15), _buildCapsule(isDark, "本月支出", totalOut.toStringAsFixed(0), Colors.redAccent, Icons.arrow_upward), const SizedBox(width: 15), _buildCapsule(isDark, "日均消费", (totalOut / _dailyData.length).toStringAsFixed(0), Colors.blue, Icons.speed)]),
    );
  }

  Widget _buildCapsule(bool isDark, String label, String amount, Color color, IconData icon) => Container(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20), decoration: BoxDecoration(color: isDark ? const Color(0xFF2C2C2E) : Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.withOpacity(0.05))), child: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 16)), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 11)), const SizedBox(height: 2), Text(amount, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87))])]));

  Widget _buildTimelineList(bool isDark) {
    final reversedData = _dailyData.reversed.toList();
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("近期流水", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 20), ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: 10, itemBuilder: (context, index) => _buildTimelineItem(isDark, index, reversedData[index]))]));
  }

  Widget _buildTimelineItem(bool isDark, int index, Map<String, dynamic> item) {
    bool isFirst = index == 0; bool isLast = index == 9; double net = item['net']; bool isPositive = net >= 0; List<String> tags = item['tags']; String imageUrl = item['image'];
    return IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [SizedBox(width: 50, child: Column(children: [Text("${item['day']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text(_getWeekdayText(item['weekday']), style: const TextStyle(fontSize: 10, color: Colors.grey))])), Column(children: [Expanded(child: Container(width: 2, color: isFirst ? Colors.transparent : Colors.grey.withOpacity(0.2))), Container(margin: const EdgeInsets.symmetric(vertical: 4), width: 10, height: 10, decoration: BoxDecoration(color: isPositive ? Colors.green : Colors.redAccent, shape: BoxShape.circle, border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2), boxShadow: [BoxShadow(color: (isPositive ? Colors.green : Colors.redAccent).withOpacity(0.4), blurRadius: 6)])), Expanded(child: Container(width: 2, color: isLast ? Colors.transparent : Colors.grey.withOpacity(0.2)))]), const SizedBox(width: 20), Expanded(child: Container(margin: const EdgeInsets.only(bottom: 24), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: isDark ? const Color(0xFF2C2C2E) : Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(isPositive ? "盈余" : "赤字", style: TextStyle(fontWeight: FontWeight.bold, color: isPositive ? Colors.green : Colors.redAccent)), Text("${isPositive ? '+' : ''}${net.toStringAsFixed(0)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87))]), const SizedBox(height: 4), Text("收 ${item['income'].toStringAsFixed(0)} / 支 ${item['expense'].toStringAsFixed(0)}", style: const TextStyle(fontSize: 11, color: Colors.grey)), Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: Colors.grey.withOpacity(0.1))), Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Wrap(spacing: 6, runSpacing: 6, children: tags.map((tag) => _buildTag(tag, isDark)).toList())), const SizedBox(width: 12), Container(width: 60, height: 60, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey[200], image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)))])]))) ]));
  }

  Widget _buildTag(String text, bool isDark) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: isDark ? Colors.grey.withOpacity(0.2) : const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(6)), child: Text(text, style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[300] : Colors.grey[800], fontWeight: FontWeight.bold)));
  String _getWeekdayText(int weekday) { const map = {1: 'MON', 2: 'TUE', 3: 'WED', 4: 'THU', 5: 'FRI', 6: 'SAT', 7: 'SUN'}; return map[weekday] ?? ''; }
}

// ==========================================
// 🟢 核心修改：3D 翻页组件 (书脊固定在左侧)
// ==========================================
class _BookFlipPageView extends StatefulWidget {
  final List<Map<String, dynamic>> pagesData;
  const _BookFlipPageView({required this.pagesData});
  @override
  State<_BookFlipPageView> createState() => _BookFlipPageViewState();
}

class _BookFlipPageViewState extends State<_BookFlipPageView> {
  late PageController _controller;
  double _currPageValue = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _controller.addListener(() {
      setState(() => _currPageValue = _controller.page!);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      itemCount: widget.pagesData.length,
      itemBuilder: (context, index) {
        // 计算旋转角度
        double rotation = 0;
        if (index == _currPageValue.floor()) {
          // 当前页 (向左翻走)：0 -> -90度
          double offset = _currPageValue - index;
          rotation = offset * -pi / 2;
        } else if (index == _currPageValue.floor() + 1) {
          // 下一页 (从左翻入)：90 -> 0度
          double offset = _currPageValue - (index - 1);
          rotation = (1 - offset) * pi / 2;
        }

        return _buildBookPage(index, rotation);
      },
    );
  }

  Widget _buildBookPage(int index, double rotation) {
    final data = widget.pagesData[index];
    final date = data['date'] as DateTime;

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(rotation),
      // 🟢 核心修改：所有页面都以左边缘为轴心旋转
      // 这样就像翻书皮一样，从右向左揭开
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 40, top: 40, bottom: 40), // 右侧多留点空隙，增加立体感
        decoration: BoxDecoration(
            color: const Color(0xFFFDFBF7),
            borderRadius: const BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
            boxShadow: [
              // 动态阴影：翻起来的时候阴影重一点
              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(5, 5))
            ]
        ),
        child: Stack(
          children: [
            // 🟢 左侧装订线 (这是书脊)
            Positioned(
              left: 0, top: 0, bottom: 0,
              child: Container(
                width: 15,
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Color(0xFFE0E0E0), Color(0xFFFDFBF7)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight
                    )
                ),
                child: Center(
                  child: Container(width: 1, color: Colors.red.withOpacity(0.2)),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(30, 40, 30, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("${date.year}.${date.month}.${date.day}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87, fontFamily: "Courier")), Text("星期${_getWeekdayNum(date.weekday)}", style: const TextStyle(fontSize: 14, color: Colors.grey))]),
                  const Divider(color: Colors.black12, thickness: 1),
                  const SizedBox(height: 20),
                  Center(child: Transform.rotate(angle: -0.05, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)]), child: Column(children: [Image.network(data['image'], height: 120, width: 120, fit: BoxFit.cover), const SizedBox(height: 4), Text("#今日心情", style: TextStyle(fontSize: 10, color: Colors.grey[400]))])))),
                  const SizedBox(height: 30),
                  Text(data['diary'] ?? "今天好像忘记写日记了...", style: const TextStyle(fontSize: 16, height: 1.8, color: Colors.black87, fontFamily: "FangSong")),
                  const Spacer(),
                  Align(alignment: Alignment.bottomRight, child: Text("By AI Assistant", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[400], fontSize: 12)))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getWeekdayNum(int weekday) { const map = {1: '一', 2: '二', 3: '三', 4: '四', 5: '五', 6: '六', 7: '日'}; return map[weekday] ?? ''; }
}
