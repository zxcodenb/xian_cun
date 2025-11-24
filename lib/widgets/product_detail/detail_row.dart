import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// 详情行组件
class DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? colorName; // 'safe', 'warning', 'urgent'

  const DetailRow({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    this.colorName,
  }) : super(key: key);

  Color? get _valueColor {
    if (colorName == null) return null;
    switch (colorName) {
      case 'safe':
        return AppColors.safe;
      case 'warning':
        return AppColors.warning;
      case 'urgent':
        return AppColors.urgent;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.textLight,
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textLight,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: _valueColor ?? AppColors.textDark,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
