import 'package:flutter/material.dart';

/// 应用颜色系统 - 参考iOS设计规范
class AppColors {
  AppColors._();

  // 背景色
  static const Color bg = Color(0xFFF2F2F7);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color secondaryBg = Color(0xFFE5E5EA);

  // 品牌色 - 现代化iOS蓝色
  static const Color brand = Color(0xFF007AFF);
  static const Color brandLight = Color(0xFF5AC8FA);
  static const Color brandDark = Color(0xFF0051D5);

  // 文字色 - 更清晰的层次
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF3C3C43);
  static const Color textTertiary = Color(0xFF8E8E93);
  static const Color textQuaternary = Color(0xFFC7C7CC);

  // 保持兼容
  static const Color textDark = textPrimary;
  static const Color textLight = textTertiary;

  // 状态色 - 更鲜艳生动
  static const Color safe = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color urgent = Color(0xFFFF3B30);
  static const Color info = Color(0xFF5856D6);

  // 分隔线和边框
  static const Color separator = Color(0xFFE5E5EA);
  static const Color border = Color(0xFFD1D1D6);

  // 遮罩
  static const Color overlay = Color(0x4D000000);
  static const Color overlayLight = Color(0x1A000000);

  // 渐变色组
  static const List<Color> brandGradient = [
    Color(0xFF007AFF),
    Color(0xFF5AC8FA),
  ];

  static const List<Color> safeGradient = [
    Color(0xFF34C759),
    Color(0xFF30D158),
  ];

  static const List<Color> warningGradient = [
    Color(0xFFFF9500),
    Color(0xFFFFCC00),
  ];

  static const List<Color> urgentGradient = [
    Color(0xFFFF3B30),
    Color(0xFFFF6961),
  ];

  // 卡片阴影色
  static Color get cardShadow => Colors.black.withOpacity(0.08);
  static Color get cardShadowHeavy => Colors.black.withOpacity(0.15);
}
