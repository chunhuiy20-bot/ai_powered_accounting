import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'components/record_app_bar.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> with TickerProviderStateMixin {
  late TabController _tabController;

  // --- 状态变量 ---
  late AnimationController _pulseController;
  bool _isRecording = false;
  bool _isProcessing = false;
  List<Map<String, dynamic>> _aiBills = [];

  // --- 引导文案轮播 ---
  int _hintIndex = 0;
  Timer? _hintTimer;
  final List<String> _exampleSentences = [
    "“ 刚才打车花了 35 元 ”",
    "“ 昨天发工资 8000 元 ”",
    "“ 早餐面包 5 元，咖啡 15 元 ”",
    "“ 晚上请客吃饭 200 元 ”",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // 启动文案轮播
    _hintTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && _aiBills.isEmpty && !_isRecording && !_isProcessing) {
        setState(() {
          _hintIndex = (_hintIndex + 1) % _exampleSentences.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pulseController.dispose();
    _hintTimer?.cancel();
    super.dispose();
  }

  // --- 核心逻辑 ---

  void _startRecording() {
    if (!_isRecording) {
      setState(() {
        _isRecording = true;
        _aiBills = []; // 清空旧数据
      });
      _pulseController.repeat();
      HapticFeedback.lightImpact();
    }
  }

  void _stopRecordingAndProcess() async {
    if (!_isRecording) return;

    setState(() {
      _isRecording = false;
      _isProcessing = true;
    });
    _pulseController.stop();
    _pulseController.reset();

    // 松手时强震动反馈
    await HapticFeedback.heavyImpact();

    // 模拟后端延迟和返回数据
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isProcessing = false;
        _aiBills = [
          {"id": 1, "title": "午饭肉夹馍", "amount": "25.00", "icon": Icons.restaurant, "color": Colors.orange},
          {"id": 2, "title": "地铁出行", "amount": "5.00", "icon": Icons.directions_subway, "color": Colors.blue},
          {"id": 3, "title": "瑞幸咖啡", "amount": "9.90", "icon": Icons.local_cafe, "color": Colors.brown},
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: RecordAppBar(tabController: _tabController),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAIVoicePage(),
          _buildManualPage(),
        ],
      ),
    );
  }

  // ==========================================
  // Tab 1: AI 智能语音记账页面 (位置微调版)
  // ==========================================
  Widget _buildAIVoicePage() {
    // 场景 A：还没有结果 (闲置 / 录音中 / 解析中)
    if (_aiBills.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2), // 🟢 增加顶部 Spacer，把内容向下压一点点，保持垂直居中感

          // 状态提示
          _buildStatusText(),
          const SizedBox(height: 20),

          // 轮播文案
          if (!_isProcessing && !_isRecording) ...[
            Text("您可以这样说：", style: TextStyle(fontSize: 12, color: Colors.grey[400])),
            const SizedBox(height: 8),
            SizedBox(
              height: 30,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  _exampleSentences[_hintIndex],
                  key: ValueKey<int>(_hintIndex),
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground
                  ),
                ),
              ),
            ),
          ] else
            const SizedBox(height: 52), // 占位保持高度

          const SizedBox(height: 40), // 🟢 增加文案和麦克风之间的间距

          // 核心圆环区域 (高度减小，更紧凑)
          SizedBox(
            height: 320,
            width: double.infinity,
            child: _buildMicOrLoading(),
          ),

          const Spacer(flex: 3), // 🟢 底部留白增加，将整体内容顶上去
        ],
      );
    }

    // 场景 B：已有结果
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          "AI 已为您智能拆分账单 ✨",
          style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 15),

        // 操作按钮
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _aiBills = []),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: const Text("取消重录", style: TextStyle(color: Colors.grey)),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    setState(() => _aiBills = []);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("已全部存入账本 🚀")));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text("确认记入", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 15),

        // 账单列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 110),
            itemCount: _aiBills.length,
            itemBuilder: (context, index) => _buildEditableBillCard(index),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusText() {
    if (_isRecording) return const Text("正在倾听...", style: TextStyle(fontSize: 16, color: Colors.grey));
    if (_isProcessing) return const Text("AI 正在解析您的语音...", style: TextStyle(fontSize: 16, color: Colors.grey));
    return const SizedBox.shrink();
  }

  // 构建麦克风或Loading动画
  Widget _buildMicOrLoading() {
    if (_isProcessing) {
      return const Center(
        child: SizedBox(
          width: 60, height: 60,
          child: CircularProgressIndicator(color: Color(0xFFFFD700), strokeWidth: 3),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // 🟢 底部提示文字 (贴近麦克风)
        Positioned(
          bottom: 60, // 距离 Stack 底部 60px (让文字紧贴麦克风下方)
          child: Text(
            _isRecording ? "点击按钮 结束" : (_isProcessing ? "" : "长按 录音"),
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),

        if (_isRecording)
          ...List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                double progress = (_pulseController.value + (index * 0.33)) % 1.0;
                return Container(
                  width: 100 + (progress * 180),
                  height: 100 + (progress * 180),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFFD700).withOpacity(1 - progress), width: 2),
                  ),
                );
              },
            );
          }),
        Container(
          width: 160, height: 160,
          decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFFFD700).withOpacity(0.05)),
        ),
        GestureDetector(
          onLongPressStart: (_) => _startRecording(),
          onTap: () {
            if (_isRecording) _stopRecordingAndProcess();
          },
          child: Container(
            width: 95, height: 95,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary, // 适配主题色
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Icon(
              Icons.mic_rounded,
              color: _isRecording ? const Color(0xFFFFD700) : Theme.of(context).colorScheme.onPrimary,
              size: 42,
            ),
          ),
        ),
      ],
    );
  }

  // --- 每一条 AI 账单的编辑卡片 ---
  Widget _buildEditableBillCard(int index) {
    final bill = _aiBills[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bill['color'].withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(bill['icon'], color: bill['color'], size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                TextField(
                  controller: TextEditingController(text: bill['title']),
                  onChanged: (v) => bill['title'] = v,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: TextEditingController(text: bill['amount']),
                  onChanged: (v) => bill['amount'] = v,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onBackground),
                  decoration: const InputDecoration(border: InputBorder.none, prefixText: "¥ ", isDense: true, contentPadding: EdgeInsets.zero),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
            onPressed: () {
              setState(() {
                _aiBills.removeAt(index);
              });
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Tab 2: 手动记账页面 (保持原样)
  // ==========================================
  Widget _buildManualPage() {
    final List<Map<String, dynamic>> categories = [
      {'icon': Icons.restaurant, 'label': '餐饮', 'color': Colors.orange},
      {'icon': Icons.directions_bus, 'label': '交通', 'color': Colors.blue},
      {'icon': Icons.shopping_bag, 'label': '购物', 'color': Colors.pink},
      {'icon': Icons.house, 'label': '居住', 'color': Colors.brown},
      {'icon': Icons.movie, 'label': '娱乐', 'color': Colors.purple},
      {'icon': Icons.medical_services, 'label': '医疗', 'color': Colors.green},
      {'icon': Icons.school, 'label': '教育', 'color': Colors.indigo},
      {'icon': Icons.sports_esports, 'label': '游戏', 'color': Colors.deepPurple},
      {'icon': Icons.pets, 'label': '宠物', 'color': Colors.teal},
      {'icon': Icons.card_giftcard, 'label': '人情', 'color': Colors.red},
      {'icon': Icons.more_horiz, 'label': '其他', 'color': Colors.grey},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: GridView.builder(
        padding: const EdgeInsets.only(bottom: 110),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 24,
          crossAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final item = categories[index];
          return _buildCategoryItem(
            icon: item['icon'],
            label: item['label'],
            color: item['color'],
            onTap: () {
              _showRecordModal(context, item);
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryItem({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showRecordModal(BuildContext context, Map<String, dynamic> category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RecordInputModal(category: category),
    );
  }
}

// ---------------------------------------------------------
// 独立的弹窗组件
// ---------------------------------------------------------
class _RecordInputModal extends StatefulWidget {
  final Map<String, dynamic> category;
  const _RecordInputModal({required this.category});
  @override
  State<_RecordInputModal> createState() => _RecordInputModalState();
}

class _RecordInputModalState extends State<_RecordInputModal> {
  String _amount = "0";
  void _onKeyTap(String value) {
    setState(() {
      if (value == "delete") {
        if (_amount.length > 1) _amount = _amount.substring(0, _amount.length - 1);
        else _amount = "0";
      } else if (value == ".") {
        if (!_amount.contains(".")) _amount += ".";
      } else {
        if (_amount == "0") _amount = value;
        else if (_amount.length < 9) _amount += value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 480 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: widget.category['color'].withOpacity(0.1), shape: BoxShape.circle), child: Icon(widget.category['icon'], color: widget.category['color'], size: 28)),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.category['label'], style: const TextStyle(fontSize: 14, color: Colors.grey)), Text(_amount == "0" ? "0.00" : "¥ $_amount", style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold))])),
              ],
            ),
          ),
          const Spacer(),
          const Divider(height: 1),
          _buildKeyboardLayout(),
        ],
      ),
    );
  }

  Widget _buildKeyboardLayout() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      height: 280,
      child: Row(
        children: [
          Expanded(flex: 3, child: Column(children: [_buildKeyRow(["1", "2", "3"]), _buildKeyRow(["4", "5", "6"]), _buildKeyRow(["7", "8", "9"]), _buildKeyRow([".", "0", "delete"])])),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(child: Container(margin: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)), child: const Center(child: Icon(Icons.calendar_today, size: 20)))),
                Expanded(flex: 3, child: GestureDetector(onTap: () { Navigator.pop(context); }, child: Container(margin: const EdgeInsets.all(6), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(8)), child: Center(child: Text("完\n成", style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 18, fontWeight: FontWeight.bold)))))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyRow(List<dynamic> keys) {
    return Expanded(
      child: Row(
        children: keys.map((k) => Expanded(child: GestureDetector(onTap: () => _onKeyTap(k == "delete" ? "delete" : k), child: Container(margin: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 2))]), child: Center(child: k == "delete" ? const Icon(Icons.backspace_outlined) : Text(k, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))))))).toList(),
      ),
    );
  }
}
