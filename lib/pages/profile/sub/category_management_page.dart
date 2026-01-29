import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CategoryManagementPage extends StatefulWidget {
  const CategoryManagementPage({super.key});

  @override
  State<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // --- 预设的图标库 ---
  final List<IconData> _availableIcons = [
    Icons.category_rounded,
    Icons.shopping_cart_rounded,
    Icons.fastfood_rounded,
    Icons.directions_car_rounded,
    Icons.movie_rounded,
    Icons.fitness_center_rounded,
    Icons.book_rounded,
    Icons.pets_rounded,
    Icons.home_rounded,
    Icons.work_rounded,
    Icons.medical_services_rounded,
    Icons.card_giftcard_rounded,
    Icons.local_cafe_rounded,
    Icons.gamepad_rounded,
    Icons.brush_rounded,
    Icons.airplanemode_active_rounded,
  ];

  // 模拟数据
  final List<Map<String, dynamic>> _expenseCategories = [
    {'icon': Icons.restaurant, 'label': '餐饮', 'color': Colors.orange, 'isDefault': true},
    {'icon': Icons.directions_bus, 'label': '交通', 'color': Colors.blue, 'isDefault': true},
    {'icon': Icons.shopping_bag, 'label': '购物', 'color': Colors.pink, 'isDefault': true},
    {'icon': Icons.house, 'label': '居住', 'color': Colors.brown, 'isDefault': true},
    {'icon': Icons.movie, 'label': '娱乐', 'color': Colors.purple, 'isDefault': true},
  ];

  final List<Map<String, dynamic>> _incomeCategories = [
    {'icon': Icons.account_balance_wallet, 'label': '工资', 'color': Colors.green, 'isDefault': true},
    {'icon': Icons.trending_up, 'label': '理财', 'color': Colors.red, 'isDefault': true},
    {'icon': Icons.card_giftcard, 'label': '礼金', 'color': Colors.orange, 'isDefault': true},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text("分类管理", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          indicatorWeight: 3,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [Tab(text: "支出"), Tab(text: "收入")],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryList(_expenseCategories),
          _buildCategoryList(_incomeCategories),
        ],
      ),
      bottomNavigationBar: _buildAddButton(),
    );
  }

  Widget _buildCategoryList(List<Map<String, dynamic>> categories) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final item = categories[index];
        final bool isDefault = item['isDefault'] ?? false;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (item['color'] as Color).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(item['icon'], color: item['color'], size: 20),
            ),
            title: Text(item['label'], style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: isDefault
                ? const Text("默认", style: TextStyle(color: Colors.grey, fontSize: 12))
                : IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
              onPressed: () => _showDeleteConfirm(categories, index),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddButton() {
    return Container(
      padding: EdgeInsets.only(
          left: 24, right: 24, bottom: MediaQuery.of(context).padding.bottom + 20, top: 10
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: ElevatedButton(
        onPressed: _showAddDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          elevation: 0,
        ),
        child: const Text("添加新分类", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showDeleteConfirm(List<Map<String, dynamic>> list, int index) {
    HapticFeedback.vibrate();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("删除分类"),
        content: Text("确定要删除自定义分类“${list[index]['label']}”吗？"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("取消", style: TextStyle(color: Colors.grey))),
          TextButton(
              onPressed: () {
                setState(() => list.removeAt(index));
                Navigator.pop(ctx);
              },
              child: const Text("确定删除", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  // --- 核心修改：带图标选择的添加弹窗 ---
  void _showAddDialog() {
    final TextEditingController nameController = TextEditingController();
    IconData selectedIcon = Icons.category_rounded; // 默认选中第一个图标

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder( // 使用 StatefulBuilder 处理弹窗内部状态
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                  left: 24, right: 24, top: 24,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 40
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("新增自定义分类", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  // 1. 名称输入
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: nameController,
                      autofocus: true,
                      maxLength: 4,
                      decoration: const InputDecoration(
                        hintText: "分类名称",
                        border: InputBorder.none,
                        counterText: "",
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text("选择图标", style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  // 2. 图标选择网格
                  SizedBox(
                    height: 180, // 固定高度防止溢出
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                      ),
                      itemCount: _availableIcons.length,
                      itemBuilder: (context, index) {
                        final icon = _availableIcons[index];
                        final bool isPicked = selectedIcon == icon;

                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setModalState(() => selectedIcon = icon);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isPicked ? Colors.black : const Color(0xFFF2F2F7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              icon,
                              color: isPicked ? Colors.white : Colors.black54,
                              size: 24,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 3. 完成按钮
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isNotEmpty) {
                        setState(() {
                          final newCategory = {
                            'icon': selectedIcon,
                            'label': nameController.text,
                            'color': Colors.blueGrey, // 实际开发可再加颜色选择
                            'isDefault': false,
                          };

                          if (_tabController.index == 0) {
                            _expenseCategories.add(newCategory);
                          } else {
                            _incomeCategories.add(newCategory);
                          }
                        });
                        Navigator.pop(ctx);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                    ),
                    child: const Text("完成", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          }
      ),
    );
  }
}
