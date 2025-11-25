import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/product.dart';

class ManualAddScreen extends StatefulWidget {
  final Function(ProductItem) onAddComplete;
  final Map<String, dynamic>? prefillData; // 预填充数据

  const ManualAddScreen({
    Key? key,
    required this.onAddComplete,
    this.prefillData,
  }) : super(key: key);

  @override
  State<ManualAddScreen> createState() => _ManualAddScreenState();
}

class _ManualAddScreenState extends State<ManualAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _brandController = TextEditingController();
  final _daysLeftController = TextEditingController();
  final _totalDaysController = TextEditingController();
  final _emojiController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 预填充表单数据
    if (widget.prefillData != null) {
      _nameController.text = widget.prefillData!['name'] ?? '';
      _categoryController.text = widget.prefillData!['category'] ?? '';
      _brandController.text = widget.prefillData!['brand'] ?? '';
      _daysLeftController.text = (widget.prefillData!['daysLeft'] ?? 7).toString();
      _totalDaysController.text = (widget.prefillData!['totalDays'] ?? 14).toString();
      _emojiController.text = widget.prefillData!['emoji'] ?? '';
      _descriptionController.text = widget.prefillData!['description'] ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _brandController.dispose();
    _daysLeftController.dispose();
    _totalDaysController.dispose();
    _emojiController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final item = ProductItem.create(
        name: _nameController.text.trim(),
        category: _categoryController.text.trim(),
        brand: _brandController.text.trim(),
        daysLeft: int.parse(_daysLeftController.text),
        totalDays: int.parse(_totalDaysController.text),
        emoji: _emojiController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      widget.onAddComplete(item);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text(
          widget.prefillData != null ? '确认商品信息' : '手动添加',
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildTextField(
              controller: _nameController,
              label: '商品名称',
              hint: '输入商品名称',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入商品名称';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _categoryController,
              label: '商品分类',
              hint: '如：乳制品、烘焙、生鲜等',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入商品分类';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _brandController,
              label: '品牌',
              hint: '输入品牌名称',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入品牌';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _daysLeftController,
                    label: '剩余天数',
                    hint: '剩余天数',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '必填';
                      }
                      if (int.tryParse(value) == null) {
                        return '请输入数字';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _totalDaysController,
                    label: '总保质期',
                    hint: '总天数',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '必填';
                      }
                      if (int.tryParse(value) == null) {
                        return '请输入数字';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emojiController,
              label: 'Emoji图标',
              hint: '选择一个Emoji',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入Emoji';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              label: '商品描述',
              hint: '可选',
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brand,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '添加商品',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
          color: AppColors.textLight,
          fontSize: 14,
        ),
        filled: true,
        fillColor: AppColors.cardBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.brand, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.urgent, width: 2),
        ),
      ),
    );
  }
}
