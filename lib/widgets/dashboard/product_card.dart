import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/product.dart';

/// 商品卡片组件 - 参考App Store设计
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
  late Animation<double> _scaleAnimation;
  late Animation<double> _breathingAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _breathingAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // 临期商品呼吸动画
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
    final isSafe = widget.item.daysLeft > 3;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: AnimatedBuilder(
          animation: _breathingAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: (isUrgent || isWarning) ? _breathingAnimation.value : 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: isUrgent
                          ? AppColors.urgent.withOpacity(0.2)
                          : isWarning
                              ? AppColors.warning.withOpacity(0.15)
                              : Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 顶部状态条
                      if (isUrgent || isWarning)
                        Container(
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isUrgent
                                  ? AppColors.urgentGradient
                                  : AppColors.warningGradient,
                            ),
                          ),
                        ),
                      // 内容区域
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Emoji和天数标签
                              Row(
                                children: [
                                  // Emoji容器 - 添加Hero动画
                                  Hero(
                                    tag: 'product_emoji_${widget.item.id}',
                                    child: Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: _getEmojiBackground(
                                            isUrgent, isWarning, isSafe),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        widget.item.emoji,
                                        style: const TextStyle(fontSize: 28),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  // 天数标签
                                  _buildDaysBadge(
                                      isUrgent, isWarning, isSafe),
                                ],
                              ),
                              const Spacer(),
                              // 商品名称
                              Text(
                                widget.item.name,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                  height: 1.2,
                                  letterSpacing: -0.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              // 分类标签
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.bg,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      widget.item.category,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textTertiary,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // 进度条
                              _buildProgressBar(isUrgent, isWarning, isSafe),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getEmojiBackground(bool isUrgent, bool isWarning, bool isSafe) {
    if (isUrgent) return AppColors.urgent.withOpacity(0.1);
    if (isWarning) return AppColors.warning.withOpacity(0.1);
    return AppColors.brandLight.withOpacity(0.08);
  }

  Widget _buildDaysBadge(bool isUrgent, bool isWarning, bool isSafe) {
    Color bgColor;
    Color textColor;
    String text;

    if (isUrgent) {
      bgColor = AppColors.urgent;
      textColor = Colors.white;
      text = '${widget.item.daysLeft}天';
    } else if (isWarning) {
      bgColor = AppColors.warning;
      textColor = Colors.white;
      text = '${widget.item.daysLeft}天';
    } else {
      bgColor = AppColors.safe.withOpacity(0.12);
      textColor = AppColors.safe;
      text = '${widget.item.daysLeft}天';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _buildProgressBar(bool isUrgent, bool isWarning, bool isSafe) {
    final progress = widget.item.progress;
    List<Color> colors;

    if (isUrgent) {
      colors = AppColors.urgentGradient;
    } else if (isWarning) {
      colors = AppColors.warningGradient;
    } else {
      colors = AppColors.safeGradient;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '新鲜度',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 5,
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(2.5),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
