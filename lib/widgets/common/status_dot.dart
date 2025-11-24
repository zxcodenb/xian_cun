import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// 状态指示器组件
class StatusDot extends StatelessWidget {
  final int count;
  final String label;
  final String color; // 'safe', 'warning', 'urgent'

  const StatusDot({
    Key? key,
    required this.count,
    required this.label,
    required this.color,
  }) : super(key: key);

  Color get _colorValue {
    switch (color) {
      case 'safe':
        return AppColors.safe;
      case 'warning':
        return AppColors.warning;
      case 'urgent':
        return AppColors.urgent;
      default:
        return AppColors.safe;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _colorValue,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$count $label',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}
