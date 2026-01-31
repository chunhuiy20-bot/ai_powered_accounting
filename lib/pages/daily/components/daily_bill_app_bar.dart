import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_first_app/pages/stats/stats_page.dart';

class DailyBillAppBar extends StatefulWidget implements PreferredSizeWidget {
  // 添加一个回调，当日期改变时通知父页面（方便以后联动账单列表）
  final Function(DateTime)? onDateChanged;

  const DailyBillAppBar({super.key, this.onDateChanged});

  @override
  State<DailyBillAppBar> createState() => _DailyBillAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _DailyBillAppBarState extends State<DailyBillAppBar> {
  // 当前选中的日期，默认为今天
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: 16,

      // --- 核心交互区域 ---
      title: GestureDetector(
        onTap: () {
          // 点击弹出自定义年月选择器
          _showMonthPicker(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 动态显示月份
              Text(
                '${_selectedDate.month}月',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.2,
                ),
              ),
              const SizedBox(width: 6),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 动态显示年份
                  Text(
                    '${_selectedDate.year}',
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.grey,
                      height: 1.0,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 10,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Row(
            children: [
              _buildActionButton(Icons.search_rounded, () {}),
              const SizedBox(width: 12),
              _buildActionButton(Icons.pie_chart_outline_rounded, () {
                // 跳转到统计页
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StatsPage()),
                );
              }),
            ],
          ),
        ),
      ],
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    );
  }

  // --- 自定义底部年月选择器 ---
  void _showMonthPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        // 使用 StatefulBuilder 是为了在弹窗内部刷新年份
        return StatefulBuilder(
          builder: (context, setModalState) {
            // 弹窗内部的临时年份变量，用于左右切换，确认后才更新主页面
            int pickerYear = _selectedDate.year;

            // 定义一个内部函数来处理年份变化
            void changeYear(int delta) {
              setModalState(() {
                // 这里有一个逻辑陷阱：直接改 pickerYear 并不会生效，
                // 因为 _selectedDate.year 是外部状态。
                // 我们需要把 _selectedDate 临时更新一下，或者引入一个临时变量。
                // 为了简单，我们这里直接创建一个新的临时日期对象给 UI 用
                _selectedDate = DateTime(
                  _selectedDate.year + delta,
                  _selectedDate.month,
                );
              });
            }

            return Container(
              height: 320,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // 1. 顶部年份切换栏
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => changeYear(-1),
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Text(
                        "${_selectedDate.year}年",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => changeYear(1),
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 2. 月份网格
                  Expanded(
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(), // 禁止网格滚动
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4, // 一行4个月
                            childAspectRatio: 1.5, // 宽高比
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                          ),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        final int month = index + 1;
                        // 判断是否是当前选中的月份
                        final bool isSelected = month == _selectedDate.month;

                        return GestureDetector(
                          onTap: () {
                            // 更新主状态
                            setState(() {
                              _selectedDate = DateTime(
                                _selectedDate.year,
                                month,
                              );
                            });
                            // 如果有父级回调，通知父级
                            if (widget.onDateChanged != null) {
                              widget.onDateChanged!(_selectedDate);
                            }
                            // 关闭弹窗
                            Navigator.pop(context);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              // 选中使用主题色，未选中透明
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              // 未选中时加个淡边框
                              border: isSelected
                                  ? null
                                  : Border.all(
                                      color: Colors.grey.withOpacity(0.2),
                                    ),
                            ),
                            child: Text(
                              "$month月",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.onSurface, size: 20),
      ),
    );
  }
}
