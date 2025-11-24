import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/settings/settings_item.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: const Text(
          '设置',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          const SizedBox(height: 20),
          SettingsItem(
            icon: Icons.notifications_outlined,
            title: '提醒设置',
            subtitle: '管理保质期提醒',
            onTap: () => _showMessage(context, '提醒设置'),
          ),
          SettingsItem(
            icon: Icons.category_outlined,
            title: '分类管理',
            subtitle: '编辑商品分类',
            onTap: () => _showMessage(context, '分类管理'),
          ),
          SettingsItem(
            icon: Icons.analytics_outlined,
            title: '统计报告',
            subtitle: '查看消耗统计',
            onTap: () => _showMessage(context, '统计报告'),
          ),
          SettingsItem(
            icon: Icons.help_outline,
            title: '关于和帮助',
            subtitle: 'v1.0.0',
            onTap: () => _showMessage(context, '关于和帮助'),
          ),
        ],
      ),
    );
  }

  void _showMessage(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('功能开发中：$feature'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
