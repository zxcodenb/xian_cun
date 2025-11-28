import 'dart:ui';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/product.dart';
import '../common/status_dot.dart';

/// 玻璃拟态Header组件 - 增强版
class GlassHeader extends StatefulWidget {
  final List<ProductItem> items;
  final int selectedFilterIndex;

  const GlassHeader({
    Key? key,
    required this.items,
    required this.selectedFilterIndex,
  }) : super(key: key);

  @override
  State<GlassHeader> createState() => _GlassHeaderState();
}

class _GlassHeaderState extends State<GlassHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _floatAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
    for (final item in widget.items) {
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
    if (widget.items.isEmpty) return 160;
    return 200;
  }

  @override
  Widget build(BuildContext context) {
    final counts = _getCounts();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          height: headerHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.brand.withOpacity(0.15),
                AppColors.brand.withOpacity(0.08),
                AppColors.brand.withOpacity(0.05),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // 背景装饰圆圈 - 动态浮动效果
              Positioned(
                top: -50 + _floatAnimation.value,
                right: -50,
                child: Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.brand.withOpacity(0.15),
                          AppColors.brand.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 20 - _floatAnimation.value,
                left: -30,
                child: Transform.scale(
                  scale: _pulseAnimation.value * 0.9,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.brandLight.withOpacity(0.12),
                          AppColors.brandLight.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // 额外的小圆圈装饰
              Positioned(
                top: 100,
                left: 80 + _floatAnimation.value * 0.5,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.brandLight.withOpacity(0.08),
                        AppColors.brandLight.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
              // 毛玻璃效果层
              ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // 内容层
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // 动态渐变条
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeInOut,
                            width: 4,
                            height: 32,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: counts.urgent > 0
                                    ? AppColors.urgentGradient
                                    : counts.warning > 0
                                        ? AppColors.warningGradient
                                        : AppColors.brandGradient,
                              ),
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: [
                                BoxShadow(
                                  color: (counts.urgent > 0
                                          ? AppColors.urgent
                                          : counts.warning > 0
                                              ? AppColors.warning
                                              : AppColors.brand)
                                      .withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // 问候语 - 添加淡入动画
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Text(
                                '${_getGreeting()}!',
                                key: ValueKey(_getGreeting()),
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                  letterSpacing: -1,
                                  shadows: [
                                    Shadow(
                                      color: Colors.white.withOpacity(0.8),
                                      offset: const Offset(0, 1),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatusOverview(
                                counts.urgent, counts.warning),
                          ),
                        ],
                      ),
                      if (widget.items.isEmpty) ...{
                        const SizedBox(height: 12),
                        // 空状态提示卡片 - 添加脉冲动画
                        Transform.scale(
                          scale: 1.0 + (_pulseAnimation.value - 1.0) * 0.02,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.brand.withOpacity(0.2),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.brand.withOpacity(0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.add_circle_outline,
                                  color: AppColors.brand,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  '添加你的第一个商品吧!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      },
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusOverview(int urgentCount, int warningCount) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brand.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 4,
            offset: const Offset(-2, -2),
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
