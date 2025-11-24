import 'package:flutter/material.dart';
import 'dart:async';
import '../../constants/app_colors.dart';
import '../../models/product.dart';

class ScannerScreen extends StatefulWidget {
  final Function(ProductItem) onScanComplete;

  const ScannerScreen({
    Key? key,
    required this.onScanComplete,
  }) : super(key: key);

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _isScanning = false;
  bool _showResult = false;
  String _scannedCode = '';

  @override
  void initState() {
    super.initState();
    _startScanning();
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
    });

    // 模拟扫码延迟
    Timer(const Duration(seconds: 2), () {
      _simulateScan();
    });
  }

  void _simulateScan() {
    setState(() {
      _isScanning = false;
      _showResult = true;
      _scannedCode = '6901234567890';
    });

    // 自动确认
    Timer(const Duration(seconds: 1), () {
      _confirmScan();
    });
  }

  void _confirmScan() {
    // 根据扫码结果创建商品（模拟数据）
    final item = ProductItem.create(
      name: '扫码识别的商品',
      category: '生鲜',
      brand: '扫码品牌',
      daysLeft: 7,
      totalDays: 30,
      emoji: '📦',
      description: '通过扫码识别的商品信息',
    );

    widget.onScanComplete(item);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 相机预览区域（模拟）
          Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
              child: Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.brand,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),

          // 扫描线动画
          if (_isScanning)
            AnimatedPositioned(
              left: 50,
              right: 50,
              top: MediaQuery.of(context).size.height / 2 - 125,
              duration: const Duration(milliseconds: 500),
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.brand,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brand.withOpacity(0.8),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),

          // 结果显示
          if (_showResult)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.safe,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '识别成功，正在添加...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 顶部控制栏
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      '扫描商品条码',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),

          // 底部提示
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Text(
              _isScanning
                  ? '请将条码对准扫描框'
                  : _scannedCode.isNotEmpty
                      ? '识别到条码：$_scannedCode'
                      : '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
