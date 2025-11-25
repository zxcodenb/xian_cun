import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/product.dart';
import '../common/status_dot.dart';

/// 玻璃拟态Header组件
class GlassHeader extends StatelessWidget {
  final List<ProductItem> items;
  final int selectedFilterIndex;

  const GlassHeader({
    Key? key,
    required this.items,
    required this.selectedFilterIndex,
  }) : super(key: key);

  /// 获取动态问候语
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '早上好';
    if (hour < 18) return '下午好';
    return '晚上好';
  }

  /// 统计紧急和临期商品
  ({int urgent, int warning}) _getCounts() {
    int urgent = 0;
    int warning = 0;
    for (final item in items) {
      if (item.daysLeft <= 1) {
        urgent++;
      } else if (item.daysLeft <= 3) {
        warning++;
      }
    }
    return (urgent: urgent, warning: warning);
  }

  /// 计算Header高度
  double get headerHeight {
    if (items.isEmpty) return 160;
    return 200;
  }

  @override
  Widget build(BuildContext context) {
    final counts = _getCounts();

    return Container(
      height: headerHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.brand.withOpacity(0.1),
            AppColors.brand.withOpacity(0.05),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_getGreeting()}!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatusOverview(counts.urgent, counts.warning),
                  ),
                ],
              ),
              if (items.isEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  '添加你的第一个商品吧!',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusOverview(int urgentCount, int warningCount) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (urgentCount > 0)
            Flexible(
              child: StatusDot(
                count: urgentCount,
                label: '紧急',
                color: 'urgent',
              ),
            ),
          if (warningCount > 0)
            Flexible(
              child: StatusDot(
                count: warningCount,
                label: '临期',
                color: 'warning',
              ),
            ),
          if (urgentCount == 0 && warningCount == 0)
            const Flexible(
              child: StatusDot(
                count: 0,
                label: '全部新鲜',
                color: 'safe',
              ),
            ),
        ],
      ),
    );
  }
}
