/// 商品数据模型
class ProductItem {
  final int id;                    // 唯一标识
  final String name;               // 商品名称
  final String category;           // 商品分类
  final int daysLeft;              // 剩余天数
  final int totalDays;             // 总保质期天数
  final String emoji;              // Emoji图标
  final DateTime purchaseDate;     // 购买日期
  final String? description;       // 商品描述
  final String brand;              // 品牌

  const ProductItem({
    required this.id,
    required this.name,
    required this.category,
    required this.daysLeft,
    required this.totalDays,
    required this.emoji,
    required this.purchaseDate,
    this.description,
    required this.brand,
  });

  /// 获取状态标签
  String get status {
    if (daysLeft <= 1) return '紧急';
    if (daysLeft <= 3) return '临期';
    return '新鲜';
  }

  /// 获取状态颜色
  String get statusColor {
    if (daysLeft <= 1) return 'urgent';
    if (daysLeft <= 3) return 'warning';
    return 'safe';
  }

  /// 获取进度百分比
  double get progress {
    if (totalDays == 0) return 0.0;
    return ((totalDays - daysLeft) / totalDays).clamp(0.0, 1.0);
  }

  /// 创建新商品（用于添加）
  factory ProductItem.create({
    required String name,
    required String category,
    required String brand,
    required int daysLeft,
    required int totalDays,
    required String emoji,
    String? description,
  }) {
    return ProductItem(
      id: DateTime.now().millisecondsSinceEpoch,
      name: name,
      category: category,
      brand: brand,
      daysLeft: daysLeft,
      totalDays: totalDays,
      emoji: emoji,
      description: description,
      purchaseDate: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'ProductItem(name: $name, category: $category, daysLeft: $daysLeft)';
  }
}
