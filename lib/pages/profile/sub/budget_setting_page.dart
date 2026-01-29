import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BudgetSettingPage extends StatefulWidget {
  const BudgetSettingPage({super.key});

  @override
  State<BudgetSettingPage> createState() => _BudgetSettingPageState();
}

class _BudgetSettingPageState extends State<BudgetSettingPage> {
  // 模拟数据：当前的预算和已支出
  double _currentBudget = 5000.0;
  final double _alreadySpent = 2480.50; // 这个通常从数据库查

  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _currentBudget.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 计算百分比
  double get _percent => (_alreadySpent / _currentBudget).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text("预算设置", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 预算进度预览卡片
            _buildStatusCard(),

            const SizedBox(height: 30),
            const Text("修改月度预算", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 16),

            // 2. 输入框区域
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      const Text("¥", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "0",
                          ),
                          onChanged: (val) {
                            setState(() {
                              _currentBudget = double.tryParse(val) ?? 0;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 40),
                  // 快捷增加按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuickAddButton(500),
                      _buildQuickAddButton(1000),
                      _buildQuickAddButton(2000),
                      _buildQuickAddButton(5000),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 3. 保存按钮
            ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                // TODO: 保存到本地或服务器
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("预算设置成功！"), behavior: SnackBarBehavior.floating)
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 5,
                shadowColor: Colors.black.withOpacity(0.3),
              ),
              child: const Text("保 存", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // 状态卡片组件
  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2B2E33), Color(0xFF1A1A1A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("本月支出进度", style: TextStyle(color: Colors.white70, fontSize: 14)),
              Text("${(_percent * 100).toStringAsFixed(1)}%",
                  style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 20),
          // 进度条
          Stack(
            children: [
              Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(5)),
              ),
              FractionallySizedBox(
                widthFactor: _percent,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFC107)]),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildMiniInfo("已用", "¥${_alreadySpent.toStringAsFixed(0)}"),
              const SizedBox(width: 40),
              _buildMiniInfo("剩余", "¥${(_currentBudget - _alreadySpent).clamp(0, double.infinity).toStringAsFixed(0)}"),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMiniInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }

  Widget _buildQuickAddButton(int amount) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _currentBudget = amount.toDouble();
          _controller.text = amount.toString();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text("¥$amount", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
