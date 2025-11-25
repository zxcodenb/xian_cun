import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

// --- Models ---
import 'models/product.dart';

// --- Constants ---
import 'constants/app_colors.dart';
import 'constants/api_config.dart';

// --- Services ---
import 'services/product_service.dart';
import 'services/category_service.dart';
import 'services/stats_service.dart';
import 'services/ai_recognition_service.dart';

// --- Widgets (Common) ---
import 'widgets/common/product_filter_chip.dart';
import 'widgets/common/status_dot.dart';
import 'widgets/common/nav_item.dart';

// --- Widgets (Dashboard) ---
import 'widgets/dashboard/glass_header.dart';
import 'widgets/dashboard/product_card.dart';
import 'widgets/dashboard/empty_state.dart';

// --- Widgets (Settings) ---
import 'widgets/settings/settings_item.dart';

// --- Widgets (Product Detail) ---
import 'widgets/product_detail/detail_row.dart';
import 'screens/product_detail/product_detail_sheet.dart';

// --- Screens ---
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/add/add_select_screen.dart';
import 'screens/add/manual_add_screen.dart';
import 'screens/add/camera_capture_screen.dart';
import 'screens/settings/settings_screen.dart';

// --- 入口 ---
void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const ApplePantryApp());
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
        fontFamily: '.SF Pro Text',
        useMaterial3: true,
      ),
      home: const MainShell(),
    );
  }
}

// --- 主 Shell (包含底部导航) ---
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;

  // API服务实例
  late final ProductService _productService;
  late final CategoryService _categoryService;
  late final StatsService _statsService;

  // 维护商品列表状态
  List<ProductItem> _items = [];

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadData();
  }

  void _initializeServices() {
    _productService = ProductService();
    _categoryService = CategoryService();
    _statsService = StatsService();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // 从API加载商品列表
      final products = await _productService.getProducts();
      setState(() {
        _items = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      // 显示错误提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('加载失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 处理添加商品
  void _handleAddItem(ProductItem item) async {
    try {
      // 调用API创建商品
      final newProduct = await _productService.createProduct(
        name: item.name,
        category: item.category,
        brand: item.brand,
        daysLeft: item.daysLeft,
        totalDays: item.totalDays,
        emoji: item.emoji,
        description: item.description,
      );

      setState(() {
        _items.insert(0, newProduct);
        _currentIndex = 0; // 返回首页
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已添加: ${newProduct.name}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('添加失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 处理删除商品
  void _handleDeleteItem(int id) async {
    try {
      await _productService.deleteProduct(id);
      setState(() {
        _items.removeWhere((item) => item.id == id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('商品已删除'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('删除失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _productService.dispose();
    _categoryService.dispose();
    _statsService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      DashboardScreen(
        items: _items,
        onShowDetail: (item) {
          // 打开详情页（由DashboardScreen内部处理）
        },
      ),
      AddSelectScreen(
        onScanComplete: _handleAddItem,
        onManualAddComplete: _handleAddItem,
      ),
      SettingsScreen(
        onRefreshData: _loadData,
      ),
    ];

    // 如果正在加载，显示加载指示器
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 如果有错误，显示错误页面
    if (_errorMessage != null && _items.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.exclamationmark_triangle,
                size: 64,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              Text(
                '加载失败',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        height: 84,
        padding: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            NavItem(
              icon: CupertinoIcons.home,
              label: '首页',
              isActive: _currentIndex == 0,
              onTap: () => setState(() => _currentIndex = 0),
            ),
            NavItem(
              icon: CupertinoIcons.add,
              label: '新增',
              isActive: _currentIndex == 1,
              onTap: () => setState(() => _currentIndex = 1),
            ),
            NavItem(
              icon: CupertinoIcons.settings,
              label: '设置',
              isActive: _currentIndex == 2,
              onTap: () => setState(() => _currentIndex = 2),
            ),
          ],
        ),
      ),
    );
  }
}
