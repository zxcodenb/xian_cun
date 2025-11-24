import 'dart:ui';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

// --- 入口 ---
void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const ApplePantryApp());
}

// --- 配色常量 ---
class AppColors {
  static const Color bg = Color(0xFFF5F5F7);
  static const Color brand = Color(0xFF0A84FF);
  static const Color textDark = Color(0xFF1C1C1E);
  static const Color textLight = Color(0x993C3C43); // #3C3C4399
  static const Color safe = Color(0xFF30D158);
  static const Color warning = Color(0xFFFFD60A);
  static const Color urgent = Color(0xFFFF453A);
  static const Color cardBg = Color(0xD9FFFFFF); // rgba(255, 255, 255, 0.85)
}

// --- 数据模型 ---
class ProductItem {
  final int id;
  final String name;
  final String category;
  final int daysLeft;
  final int totalDays;
  final String emoji;

  ProductItem({
    required this.id,
    required this.name,
    required this.category,
    required this.daysLeft,
    required this.totalDays,
    required this.emoji,
  });
}

// --- 主应用 ---
class ApplePantryApp extends StatelessWidget {
  const ApplePantryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apple Pantry',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.bg,
        primaryColor: AppColors.brand,
        fontFamily: '.SF Pro Text', // iOS 默认字体，Android 上会回退到 Roboto
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

// --- 主屏幕 (Dashboard) ---
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  // 模拟初始数据
  List<ProductItem> items = [
    ProductItem(id: 1, name: '全脂牛奶', category: '乳制品', daysLeft: 2, totalDays: 14, emoji: '🥛'),
    ProductItem(id: 2, name: '法式软面包', category: '烘焙', daysLeft: 12, totalDays: 20, emoji: '🍞'),
    ProductItem(id: 3, name: '牛油果 (3个)', category: '生鲜', daysLeft: 4, totalDays: 10, emoji: '🥑'),
    ProductItem(id: 4, name: '草莓果酱', category: '调味', daysLeft: 45, totalDays: 180, emoji: '🍓'),
    ProductItem(id: 5, name: '三文鱼切片', category: '冷冻', daysLeft: 1, totalDays: 7, emoji: '🐟'),
  ];

  String filter = 'all'; // all, warning, urgent

  // 添加物品
  void _addItem(ProductItem item) {
    setState(() {
      items.insert(0, item);
    });
  }

  // 消耗物品
  void _consumeItem(int id) {
    setState(() {
      items.removeWhere((item) => item.id == id);
    });
  }

  // 获取筛选后的列表
  List<ProductItem> get filteredItems {
    if (filter == 'urgent') return items.where((i) => i.daysLeft <= 3).toList();
    if (filter == 'warning') return items.where((i) => i.daysLeft > 3 && i.daysLeft <= 15).toList();
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // 让内容延伸到顶部，实现磨砂 Header
      body: Stack(
        children: [
          // 滚动内容区域
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 顶部留白，为了避开 Header
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
              
              // 筛选 Tab
              if (items.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Row(
                      children: [
                        _FilterChip(
                          label: '全部',
                          isSelected: filter == 'all',
                          onTap: () => setState(() => filter = 'all'),
                        ),
                        const SizedBox(width: 10),
                        _FilterChip(
                          label: '临期',
                          isSelected: filter == 'warning',
                          onTap: () => setState(() => filter = 'warning'),
                        ),
                        const SizedBox(width: 10),
                        _FilterChip(
                          label: '紧急',
                          isSelected: filter == 'urgent',
                          onTap: () => setState(() => filter = 'urgent'),
                        ),
                      ],
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // 列表或空状态
              items.isEmpty
                  ? const SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75, // 卡片比例
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = filteredItems[index];
                            return ProductCard(
                              key: ValueKey(item.id),
                              item: item,
                              onConsume: () => _consumeItem(item.id),
                            );
                          },
                          childCount: filteredItems.length,
                        ),
                      ),
                    ),
            ],
          ),

          // 悬浮 Header (Glassmorphism)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _GlassHeader(items: items),
          ),
          
          // 悬浮扫码按钮 (FAB)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: _ScanButton(onTap: () {
                Navigator.of(context).push(PageRouteBuilder(
                  opaque: false, // 透明背景
                  pageBuilder: (_, __, ___) => ScannerScreen(onScanComplete: _addItem),
                  transitionsBuilder: (ctx, anim, secAnim, child) {
                    return FadeTransition(opacity: anim, child: child);
                  },
                ));
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// --- 组件: 玻璃拟态 Header ---
class _GlassHeader extends StatelessWidget {
  final List<ProductItem> items;

  const _GlassHeader({required this.items});

  @override
  Widget build(BuildContext context) {
    final urgentCount = items.where((i) => i.daysLeft <= 3).length;
    final warningCount = items.where((i) => i.daysLeft > 3 && i.daysLeft <= 15).length;
    final hasStatus = items.isNotEmpty;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: AppColors.bg.withOpacity(0.7),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 10,
            bottom: 20,
            left: 24,
            right: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DASHBOARD',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items.isNotEmpty ? 'Hi, 库存良好' : '准备囤点什么？',
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: const Icon(CupertinoIcons.person_solid, color: Colors.grey),
                  )
                ],
              ),
              
              if (hasStatus) ...[
                const SizedBox(height: 16),
                // 状态概览条
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _StatusDot(color: AppColors.urgent, count: urgentCount, label: '急需'),
                      Container(
                        height: 16,
                        width: 1,
                        color: Colors.grey.withOpacity(0.3),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      _StatusDot(color: AppColors.warning, count: warningCount, label: '临期'),
                      const Spacer(),
                      const Icon(CupertinoIcons.chevron_right, size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final Color color;
  final int count;
  final String label;

  const _StatusDot({required this.color, required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          '$count $label',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}

// --- 组件: 筛选芯片 ---
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.textDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.2)),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// --- 组件: 商品卡片 ---
class ProductCard extends StatefulWidget {
  final ProductItem item;
  final VoidCallback onConsume;

  const ProductCard({super.key, required this.item, required this.onConsume});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getStatusColor(int days) {
    if (days <= 3) return AppColors.urgent;
    if (days <= 15) return AppColors.warning;
    return AppColors.safe;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(widget.item.daysLeft);
    final progress = (widget.item.daysLeft / widget.item.totalDays).clamp(0.05, 1.0);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Stack(
              children: [
                // 呼吸光晕 (仅紧急状态)
                if (widget.item.daysLeft <= 3)
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.urgent.withOpacity(0.1),
                          boxShadow: [BoxShadow(color: AppColors.urgent.withOpacity(0.2), blurRadius: 30)],
                        ),
                      ),
                    ),
                  ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 天数徽章
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${widget.item.daysLeft}天',
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Emoji
                    Text(
                      widget.item.emoji,
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 8),

                    // 名称 & 分类
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        widget.item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    Text(
                      widget.item.category,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textLight,
                      ),
                    ),

                    const Spacer(),

                    // 进度条 & 按钮区域
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          // 进度条
                          Container(
                            height: 6,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: progress,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          
                          // 消耗按钮
                          InkWell(
                            onTap: widget.onConsume,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F2F7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(CupertinoIcons.checkmark_alt, size: 14, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    '使用',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- 组件: 空状态 ---
class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: const Icon(CupertinoIcons.cube_box, size: 48, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          const Text(
            '储物间空空如也',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          const Text(
            '你的数字货架很干净。\n点击下方按钮开始扫码囤货吧。',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textLight, height: 1.5),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// --- 组件: 扫码按钮 FAB ---
class _ScanButton extends StatefulWidget {
  final VoidCallback onTap;

  const _ScanButton({required this.onTap});

  @override
  State<_ScanButton> createState() => _ScanButtonState();
}

class _ScanButtonState extends State<_ScanButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 呼吸光环
          FadeTransition(
            opacity: Tween(begin: 0.0, end: 0.5).animate(_controller),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brand.withOpacity(0.3),
              ),
            ),
          ),
          // 实体按钮
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.brand,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.brand.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(CupertinoIcons.viewfinder, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}

// --- 屏幕: 模拟扫码界面 ---
class ScannerScreen extends StatefulWidget {
  final Function(ProductItem) onScanComplete;

  const ScannerScreen({super.key, required this.onScanComplete});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with SingleTickerProviderStateMixin {
  bool _found = false;
  late AnimationController _scanLineController;

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    
    // 模拟2秒后识别成功
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _found = true;
          _scanLineController.stop();
        });
      }
    });
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    super.dispose();
  }

  void _confirmAdd() {
    widget.onScanComplete(ProductItem(
      id: DateTime.now().millisecondsSinceEpoch,
      name: '红富士苹果',
      category: '生鲜',
      daysLeft: 7,
      totalDays: 7,
      emoji: '🍎',
    ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 背景：模拟相机画面 (深色背景+模糊)
          Container(
            color: Colors.black,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // 模拟景深
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          ),
          
          // 关闭按钮
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(CupertinoIcons.xmark, color: Colors.white, size: 24),
              ),
            ),
          ),

          // 扫描框
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: _found ? AppColors.safe : Colors.white.withOpacity(0.3),
                      width: 4,
                    ),
                    color: _found ? AppColors.safe.withOpacity(0.1) : Colors.transparent,
                  ),
                ),
                // 扫描光线
                if (!_found)
                  SizedBox(
                    width: 240,
                    height: 240,
                    child: AnimatedBuilder(
                      animation: _scanLineController,
                      builder: (context, child) {
                        return Stack(
                          children: [
                            Positioned(
                              top: 240 * _scanLineController.value,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 2,
                                color: AppColors.brand,
                                boxShadow: [BoxShadow(color: AppColors.brand, blurRadius: 10)],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                // 成功图标
                if (_found)
                  const Icon(CupertinoIcons.checkmark_alt, color: AppColors.safe, size: 64),
                
                // 提示文字
                if (!_found)
                  const Positioned(
                    bottom: -40,
                    child: Text(
                      'SEARCHING...',
                      style: TextStyle(color: Colors.white70, letterSpacing: 2, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),

          // 底部结果面板 (Found State)
          if (_found)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.all(0),
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                decoration: const BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text('🍎', style: TextStyle(fontSize: 32)),
                        ),
                        const SizedBox(width: 16),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '红富士苹果',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '生鲜水果 • 建议7天内食用',
                              style: TextStyle(fontSize: 14, color: AppColors.textLight),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _confirmAdd,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brand,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text('确认入库', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}