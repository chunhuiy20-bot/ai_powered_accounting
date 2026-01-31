import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class AssetProvider with ChangeNotifier {
  Timer? _timer;

  // 1. 全局汇率 (基准 CNY)
  final Map<String, double> exchangeRates = {
    'CNY': 1.0,
    'USD': 7.23,
    'HKD': 0.92,
    'JPY': 0.048,
  };

  // 2. 模拟行情价格 (私有，通过方法获取)
  final Map<String, double> _marketPrices = {
    'BTC': 480000.0,
    'USDT': 7.25,
    'KO': 430.0,   // 可口可乐
    'NVDA': 6500.0, // 英伟达
    'AAPL': 1300.0, // 苹果
  };

  // 3. 资产数据源
  final List<Map<String, dynamic>> assets = [
    {
      'type': 'cash',
      'name': '现金钱包',
      'icon': Icons.account_balance_wallet,
      'color': Colors.teal,
      'details': <Map<String, dynamic>>[
        {'name': '人民币 (CNY)', 'amount': 2500.00, 'currency': 'CNY'},
        {'name': '美元 (USD)', 'amount': 800.00, 'currency': 'USD'},
      ]
    },
    {
      'type': 'bank',
      'name': '银行卡',
      'icon': Icons.credit_card,
      'color': Colors.blue,
      'details': <Map<String, dynamic>>[
        {'name': '招商银行', 'amount': 58000.00, 'cardNumber': '6225 **** 8888'},
      ]
    },
    {
      'type': 'market',
      'name': '股票账户',
      'icon': Icons.show_chart,
      'color': Colors.purple,
      'details': <Map<String, dynamic>>[
        {'name': 'NVIDIA', 'symbol': 'NVDA', 'quantity': 10.0, 'isAuto': true, 'manualAmount': 0.0},
        {'name': 'Apple', 'symbol': 'AAPL', 'quantity': 25.0, 'isAuto': true, 'manualAmount': 0.0},
      ]
    },
    {
      'type': 'market',
      'name': '加密货币',
      'icon': Icons.currency_bitcoin,
      'color': Colors.orange,
      'details': <Map<String, dynamic>>[
        {'name': 'Bitcoin', 'symbol': 'BTC', 'quantity': 0.25, 'isAuto': true, 'manualAmount': 0.0},
      ]
    },
  ];

  AssetProvider() {
    _startMarketSimulation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // 启动行情模拟：每3秒随机波动
  void _startMarketSimulation() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _marketPrices.updateAll((symbol, price) {
        // 随机波动 ±1.5%
        double fluctuation = 1.0 + (Random().nextDouble() * 0.03 - 0.015);
        return price * fluctuation;
      });
      notifyListeners(); // 通知 UI 刷新
    });
  }

  // 获取当前市价
  double getMarketPrice(String symbol) => _marketPrices[symbol] ?? 0.0;

  // 计算单个资产 CNY 价值
  double calculateCNYValue(Map<String, dynamic> detail, String type) {
    if (type == 'cash') {
      double amount = detail['amount'] ?? 0.0;
      String currency = detail['currency'] ?? 'CNY';
      return amount * (exchangeRates[currency] ?? 1.0);
    } else if (type == 'market') {
      if (detail['isAuto'] == true) {
        String symbol = detail['symbol'] ?? '';
        double qty = detail['quantity'] ?? 0.0;
        double price = _marketPrices[symbol] ?? 0.0;
        return qty * price;
      } else {
        return detail['manualAmount'] ?? 0.0;
      }
    } else {
      return detail['amount'] ?? 0.0;
    }
  }

  // 获取总资产 (CNY)
  double get totalAssetCNY {
    double total = 0;
    for (var category in assets) {
      for (var detail in category['details']) {
        total += calculateCNYValue(detail, category['type']);
      }
    }
    return total;
  }

  // --- 增删改查操作 ---
  void addAsset(int categoryIndex, Map<String, dynamic> newDetail) {
    assets[categoryIndex]['details'].add(newDetail);
    notifyListeners();
  }

  void updateAsset(int categoryIndex, int detailIndex, Map<String, dynamic> newDetail) {
    assets[categoryIndex]['details'][detailIndex] = newDetail;
    notifyListeners();
  }

  void deleteAsset(int categoryIndex, int detailIndex) {
    assets[categoryIndex]['details'].removeAt(detailIndex);
    notifyListeners();
  }
}
