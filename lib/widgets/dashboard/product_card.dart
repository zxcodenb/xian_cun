import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/product.dart';

/// 商品卡片组件
class ProductCard extends StatefulWidget {
  final ProductItem item;
  final VoidCallback onTap;

  const ProductCard({
    Key? key,
    required this.item,
    required this.onTap,
  }) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.97,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // 临期商品（1-3天）呼吸效果
    if (widget.item.daysLeft <= 3 && widget.item.daysLeft > 0) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUrgent = widget.item.daysLeft <= 1;
    final isWarning = widget.item.daysLeft > 1 && widget.item.daysLeft <= 3;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: isUrgent || isWarning ? _animation.value : 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isUrgent ? 0.15 : 0.08),
                    blurRadius: isUrgent ? 12 : 8,
                    offset: Offset(0, isUrgent ? 6 : 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.item.emoji,
                                style: const TextStyle(fontSize: 32),
                              ),
                              _buildStatusBadge(),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.item.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.item.category,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildProgressBar(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color badgeColor;
    String badgeText;

    if (widget.item.daysLeft <= 1) {
      badgeColor = AppColors.urgent;
      badgeText = '${widget.item.daysLeft}天';
    } else if (widget.item.daysLeft <= 3) {
      badgeColor = AppColors.warning;
      badgeText = '${widget.item.daysLeft}天';
    } else {
      badgeColor = AppColors.safe;
      badgeText = '${widget.item.daysLeft}天';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withOpacity(0.5)),
      ),
      child: Text(
        badgeText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: badgeColor,
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = widget.item.progress;
    Color progressColor;

    if (widget.item.daysLeft <= 1) {
      progressColor = AppColors.urgent;
    } else if (widget.item.daysLeft <= 3) {
      progressColor = AppColors.warning;
    } else {
      progressColor = AppColors.safe;
    }

    return Container(
      height: 4,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: progressColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
