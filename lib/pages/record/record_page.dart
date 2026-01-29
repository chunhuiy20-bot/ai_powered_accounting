import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 必须引入系统服务
import 'components/record_app_bar.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> with TickerProviderStateMixin {
  late TabController _tabController;

  // --- 脉冲动画相关 ---
  late AnimationController _pulseController;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startRecording() {
    if (!_isRecording) {
      setState(() {
        _isRecording = true;
      });
      _pulseController.repeat();
    }
  }

  void _stopRecording() {
    if (_isRecording) {
      setState(() {
        _isRecording = false;
      });
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
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
  // Tab 1: AI 智能语音记账页面
  // ==========================================
  Widget _buildAIVoicePage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),
        Text(
          _isRecording ? "正在倾听..." : "长按说话，AI 自动识别",
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 10),
        const Text(
          "“ 刚才打车花了 35 元 ”",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const Spacer(flex: 1),

        // 🟢 关键修复：使用固定高度的容器包裹动画区域，防止上下文字跳动
        SizedBox(
          height: 280,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 脉冲波动画
              if (_isRecording)
                ...List.generate(3, (index) {
                  return AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      double progress = (_pulseController.value + (index * 0.33)) % 1.0;
                      return Container(
                        width: 100 + (progress * 180), // 扩散范围
                        height: 100 + (progress * 180),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFFD700).withOpacity(1 - progress),
                            width: 2,
                          ),
                        ),
                      );
                    },
                  );
                }),

              // 基础静态背景圆
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFD700).withOpacity(0.05),
                ),
              ),

              // 核心麦克风按钮
              GestureDetector(
                onLongPressStart: (_) => _startRecording(),
                onLongPressEnd: (_) async {
                  // 长按松手时的强震动反馈
                  await HapticFeedback.heavyImpact();
                },
                onTap: () {
                  if (_isRecording) _stopRecording();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _isRecording ? 95 : 80,
                  height: _isRecording ? 95 : 80,
                  decoration: BoxDecoration(
                    color: Colors.black, // 🟢 始终黑色背景
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.mic_rounded, // 🟢 始终是麦克风图标，不再变方块
                    color: _isRecording ? const Color(0xFFFFD700) : Colors.white, // 🟢 录音变金色
                    size: 38,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),
        Text(
          _isRecording ? "点击按钮 结束" : "长按 录音",
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const Spacer(flex: 3),
      ],
    );
  }

  // ==========================================
  // Tab 2: 手动记账页面
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

  Widget _buildCategoryItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
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

class _RecordInputModal extends StatefulWidget {
  final Map<String, dynamic> category;
  const _RecordInputModal({required this.category});
  @override
  State<_RecordInputModal> createState() => _RecordInputModalState();
}

class _RecordInputModalState extends State<_RecordInputModal> {
  String _amount = "0";
  String _remark = "";

  void _onKeyTap(String value) {
    setState(() {
      if (value == "delete") {
        if (_amount.length > 1) {
          _amount = _amount.substring(0, _amount.length - 1);
        } else {
          _amount = "0";
        }
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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: widget.category['color'].withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(widget.category['icon'], color: widget.category['color'], size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.category['label'], style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      Text(_amount == "0" ? "0.00" : "¥ $_amount", style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
            child: TextField(
              onChanged: (val) => _remark = val,
              decoration: const InputDecoration(icon: Icon(Icons.edit_note, color: Colors.grey), hintText: "写点备注...", border: InputBorder.none),
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
      color: const Color(0xFFF9F9F9),
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
                Expanded(
                  flex: 3,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("记账成功！")));
                    },
                    child: Container(margin: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)), child: const Center(child: Text("完\n成", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)))),
                  ),
                ),
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
