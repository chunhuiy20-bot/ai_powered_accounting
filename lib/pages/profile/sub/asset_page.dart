import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../providers/asset_provider.dart';

class AssetPage extends StatefulWidget {
  const AssetPage({super.key});

  @override
  State<AssetPage> createState() => _AssetPageState();
}

class _AssetPageState extends State<AssetPage> {
  String _displayCurrency = 'CNY';

  @override
  Widget build(BuildContext context) {
    // 🟢 通过 Provider 获取数据，无需本地状态
    final assetProvider = Provider.of<AssetProvider>(context);
    final assets = assetProvider.assets;
    final exchangeRates = assetProvider.exchangeRates;

    // 计算总资产
    double totalDisplayAsset = assetProvider.totalAssetCNY / (exchangeRates[_displayCurrency] ?? 1.0);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text("我的资产", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTotalCard(totalDisplayAsset, exchangeRates),
            const SizedBox(height: 30),
            Text("资产明细 (折合 CNY)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onBackground)),
            const SizedBox(height: 16),
            ...assets.asMap().entries.map((entry) {
              return _buildExpansionCard(context, entry.key, entry.value, assetProvider);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard(double totalAmount, Map<String, double> rates) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF2B2E33), Color(0xFF1A1A1A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("净资产估值", style: TextStyle(color: Colors.white54, fontSize: 14)),
              Container(
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                child: DropdownButton<String>(
                  value: _displayCurrency,
                  dropdownColor: const Color(0xFF2B2E33),
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 18),
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  items: rates.keys.map((String value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                  onChanged: (val) => setState(() => _displayCurrency = val!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Text(
              "${_getCurrencySymbol(_displayCurrency)} ${totalAmount.toStringAsFixed(2)}",
              key: ValueKey<double>(totalAmount),
              style: const TextStyle(color: Color(0xFFFFD700), fontSize: 32, fontWeight: FontWeight.w900, fontFamily: "Roboto"),
            ),
          ),
          const SizedBox(height: 20),
          Row(children: [_buildTag("实时汇率换算"), const SizedBox(width: 10), _buildTag("行情自动同步")]),
        ],
      ),
    );
  }

  Widget _buildTag(String text) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)));
  String _getCurrencySymbol(String currency) => currency == 'USD' || currency == 'HKD' ? '\$' : '¥';

  Widget _buildExpansionCard(BuildContext context, int categoryIndex, Map<String, dynamic> category, AssetProvider provider) {
    double categoryTotalCNY = 0;
    for (var detail in category['details']) {
      categoryTotalCNY += provider.calculateCNYValue(detail, category['type']);
    }
    double percent = provider.totalAssetCNY == 0 ? 0 : categoryTotalCNY / provider.totalAssetCNY;
    List<Map<String, dynamic>> details = List<Map<String, dynamic>>.from(category['details']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
          title: Row(
            children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: (category['color'] as Color).withOpacity(0.1), shape: BoxShape.circle), child: Icon(category['icon'], color: category['color'], size: 24)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(category['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), Text("¥${categoryTotalCNY.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))]),
                    const SizedBox(height: 6),
                    Stack(children: [Container(height: 4, width: double.infinity, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(2))), FractionallySizedBox(widthFactor: percent.clamp(0.0, 1.0), child: Container(height: 4, decoration: BoxDecoration(color: category['color'], borderRadius: BorderRadius.circular(2))))])
                  ],
                ),
              ),
            ],
          ),
          children: [
            Container(height: 1, color: Theme.of(context).dividerColor.withOpacity(0.05), margin: const EdgeInsets.only(bottom: 12)),
            ...List.generate((category['details'] as List).length, (detailIndex) => _buildSubAssetCard(context, category, categoryIndex, category['details'][detailIndex], detailIndex, provider)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _showAddOrEditDialog(context, categoryIndex, null, provider),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.withOpacity(0.3)), borderRadius: BorderRadius.circular(12)),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.add, size: 18, color: Colors.grey), SizedBox(width: 4), Text("添加资产", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13))]),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSubAssetCard(BuildContext context, Map<String, dynamic> category, int categoryIndex, Map<String, dynamic> detail, int detailIndex, AssetProvider provider) {
    String type = category['type'];
    double cnyValue = provider.calculateCNYValue(detail, type);
    String subtitle = type == 'cash' ? "${detail['amount']} ${detail['currency']}" : (type == 'bank' ? (detail['cardNumber'] ?? "") : (detail['isAuto'] == true ? "持仓: ${detail['quantity']} | 市价: ¥${provider.getMarketPrice(detail['symbol'] ?? '').toStringAsFixed(0)}" : "手动估值"));

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: UniqueKey(),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) async => await showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text("确认删除"), content: Text("确定要删除“${detail['name']}”吗？"), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("取消")), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("删除", style: TextStyle(color: Colors.red)))])),
        onDismissed: (_) => provider.deleteAsset(categoryIndex, detailIndex),
        background: Container(decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(12)), alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
        child: InkWell(
          onTap: () => _showAddOrEditDialog(context, categoryIndex, detailIndex, provider),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withOpacity(0.1)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))]),
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: (category['color'] as Color).withOpacity(0.05), borderRadius: BorderRadius.circular(8)), child: Icon(category['icon'], color: category['color'], size: 18)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(detail['name'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)), const SizedBox(height: 2), Text(subtitle, style: TextStyle(color: Colors.grey[400], fontSize: 11))])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: Text(cnyValue.toStringAsFixed(2), key: ValueKey(cnyValue), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface, fontFamily: "Roboto"))),
                  if (type == 'cash' && detail['currency'] != 'CNY') const Text("≈ CNY", style: TextStyle(fontSize: 10, color: Colors.grey)),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddOrEditDialog(BuildContext context, int categoryIndex, int? detailIndex, AssetProvider provider) {
    final bool isEdit = detailIndex != null;
    final Map<String, dynamic> category = provider.assets[categoryIndex];
    final String type = category['type'];
    final Map<String, dynamic> currentData = isEdit ? category['details'][detailIndex] : {};

    final nameCtrl = TextEditingController(text: currentData['name']);
    final cardNumCtrl = TextEditingController(text: currentData['cardNumber']);
    final amountCtrl = TextEditingController(text: currentData['amount']?.toString());

    String selectedCurrency = currentData['currency'] ?? 'CNY';
    bool isAuto = currentData['isAuto'] ?? true;
    final symbolCtrl = TextEditingController(text: currentData['symbol']);
    final qtyCtrl = TextEditingController(text: currentData['quantity']?.toString());
    final manualAmountCtrl = TextEditingController(text: currentData['manualAmount']?.toString());

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(isEdit ? "修改资产" : "添加新资产", style: const TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "名称")),
                  const SizedBox(height: 10),
                  if (type == 'bank') ...[TextField(controller: amountCtrl, decoration: const InputDecoration(labelText: "余额", prefixText: "¥ "), keyboardType: TextInputType.number), const SizedBox(height: 10), TextField(controller: cardNumCtrl, decoration: const InputDecoration(labelText: "卡号 (选填)"))],
                  if (type == 'cash') ...[TextField(controller: amountCtrl, decoration: const InputDecoration(labelText: "金额"), keyboardType: TextInputType.number), const SizedBox(height: 10), DropdownButtonFormField<String>(value: selectedCurrency, decoration: const InputDecoration(labelText: "币种"), items: provider.exchangeRates.keys.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (val) => setDialogState(() => selectedCurrency = val!))],
                  if (type == 'market') ...[SwitchListTile(title: const Text("自动跟随行情"), value: isAuto, onChanged: (val) => setDialogState(() => isAuto = val)), if (isAuto) ...[TextField(controller: symbolCtrl, decoration: const InputDecoration(labelText: "代码 (如 BTC, NVDA)")), const SizedBox(height: 10), TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: "持仓数量"), keyboardType: TextInputType.number)] else ...[TextField(controller: manualAmountCtrl, decoration: const InputDecoration(labelText: "当前总市值 (CNY)"), keyboardType: TextInputType.number)]],
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("取消")),
              TextButton(
                onPressed: () {
                  if (nameCtrl.text.isNotEmpty) {
                    final Map<String, dynamic> newData = {'name': nameCtrl.text};

                    if (type == 'bank') {
                      newData['amount'] = double.tryParse(amountCtrl.text) ?? 0.0;
                      newData['cardNumber'] = cardNumCtrl.text;
                    } else if (type == 'cash') {
                      newData['amount'] = double.tryParse(amountCtrl.text) ?? 0.0;
                      newData['currency'] = selectedCurrency;
                    } else if (type == 'market') {
                      newData['isAuto'] = isAuto;
                      if (isAuto) {
                        newData['symbol'] = symbolCtrl.text.toUpperCase();
                        newData['quantity'] = double.tryParse(qtyCtrl.text) ?? 0.0;
                      } else {
                        newData['manualAmount'] = double.tryParse(manualAmountCtrl.text) ?? 0.0;
                      }
                    }

                    if (isEdit) provider.updateAsset(categoryIndex, detailIndex!, newData);
                    else provider.addAsset(categoryIndex, newData);
                    Navigator.pop(context);
                  }
                },
                child: const Text("保存", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        });
      },
    );
  }
}
