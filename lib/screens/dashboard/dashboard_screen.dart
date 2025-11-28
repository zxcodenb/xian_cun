import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../constants/app_colors.dart';
import '../../widgets/dashboard/glass_header.dart';
import '../../widgets/dashboard/product_card.dart';
import '../../widgets/dashboard/empty_state.dart';
import '../../widgets/common/product_filter_chip.dart';
import '../product_detail/product_detail_sheet.dart';

class DashboardScreen extends StatefulWidget {
  final List<ProductItem> items;
  final Function(ProductItem) onShowDetail;

  const DashboardScreen({
    Key? key,
    required this.items,
    required this.onShowDetail,
  }) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedFilterIndex = 0;

  /// 筛选商品
  List<ProductItem> _getFilteredItems() {
    switch (_selectedFilterIndex) {
      case 0: // 全部
        return widget.items;
      case 1: // 紧急
        return widget.items.where((item) => item.daysLeft <= 1).toList();
      case 2: // 临期
        return widget.items
            .where((item) => item.daysLeft > 1 && item.daysLeft <= 3)
            .toList();
      default:
        return widget.items;
    }
  }

  /// 获取筛选标签
  List<String> _getFilterLabels() {
    if (widget.items.isEmpty) return ['全部'];

    final urgentCount =
        widget.items.where((item) => item.daysLeft <= 1).length;
    final warningCount = widget.items
        .where((item) => item.daysLeft > 1 && item.daysLeft <= 3)
        .length;

    final labels = ['全部'];
    if (urgentCount > 0) labels.add('紧急($urgentCount)');
    if (warningCount > 0) labels.add('临期($warningCount)');

    return labels;
  }

  /// 计算Header高度（动态）
  double _calculateHeaderHeight(int itemCount) {
    if (itemCount == 0) return 160;
    return 200;
  }

  void _showProductDetail(ProductItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      builder: (context) => ProductDetailSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _getFilteredItems();
    final filterLabels = _getFilterLabels();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: _calculateHeaderHeight(filteredItems.length),
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.bg,
            flexibleSpace: FlexibleSpaceBar(
              background: GlassHeader(
                items: filteredItems,
                selectedFilterIndex: _selectedFilterIndex,
              ),
            ),
          ),
          if (filteredItems.isEmpty)
            SliverToBoxAdapter(
              child: EmptyState(
                onAddItem: () {
                  // 触发添加操作（在MainShell中处理）
                },
              ),
            )
          else ...[
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    for (int i = 0; i < filterLabels.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: ProductFilterChip(
                          label: filterLabels[i],
                          isSelected: _selectedFilterIndex == i,
                          onTap: () {
                            setState(() {
                              _selectedFilterIndex = i;
                            });
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = filteredItems[index];
                    return ProductCard(
                      item: item,
                      onTap: () => _showProductDetail(item),
                    );
                  },
                  childCount: filteredItems.length,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
