import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../constants/api_config.dart';

/// AI识别服务 - 调用后端LLM API识别商品信息
class AIRecognitionService {
  final Dio _dio;

  AIRecognitionService() : _dio = Dio() {
    _dio.options.baseUrl = ApiConfig.fullBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: ApiConfig.connectTimeout);
    _dio.options.receiveTimeout = const Duration(seconds: ApiConfig.receiveTimeout);
    _dio.options.headers = {
      'Content-Type': 'multipart/form-data',
    };
  }

  /// 上传图片并识别商品信息
  ///
  /// [imageFile] 商品图片
  /// 返回识别结果，包含商品名称、分类、品牌、保质期等信息
  Future<Map<String, dynamic>> recognizeProduct(File imageFile) async {
    try {
      // 创建form-data
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'product_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      final response = await _dio.post(
        ApiConfig.recognizeEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // 解析返回的JSON数据
        return _parseRecognitionResult(data);
      } else {
        throw Exception('识别失败: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('请求超时，请检查网络连接');
      }
      throw Exception('识别失败: ${e.message}');
    } catch (e) {
      throw Exception('识别失败: $e');
    }
  }

  /// 解析识别结果
  Map<String, dynamic> _parseRecognitionResult(Map<String, dynamic> data) {
    try {
      // 根据实际API返回格式调整解析逻辑
      // 后端API直接返回识别结果，不需要result包装
      final result = data;

      return {
        'name': result['name'] ?? '',
        'category': result['category'] ?? '',
        'brand': result['brand'] ?? '',
        'daysLeft': _parseDaysLeft(result),
        'totalDays': _parseTotalDays(result),
        'emoji': _getEmojiFromCategory(result['category'] ?? ''),
        'description': result['description'] ?? '',
        'confidence': result['confidence'] ?? 0.0,
      };
    } catch (e) {
      throw Exception('解析识别结果失败: $e');
    }
  }

  /// 解析剩余天数
  int _parseDaysLeft(Map<String, dynamic> result) {
    // 优先从API获取
    if (result.containsKey('days_left')) {
      return result['days_left'] ?? 7;
    }

    // 如果有生产日期和保质期，计算剩余天数
    if (result.containsKey('production_date') &&
        result.containsKey('shelf_life_days')) {
      final productionDate = DateTime.parse(result['production_date']);
      final shelfLifeDays = result['shelf_life_days'] as int;
      final expirationDate =
          productionDate.add(Duration(days: shelfLifeDays));
      final remaining = expirationDate.difference(DateTime.now()).inDays;
      return remaining > 0 ? remaining : 0;
    }

    // 默认值
    return 7;
  }

  /// 解析总保质期天数
  int _parseTotalDays(Map<String, dynamic> result) {
    if (result.containsKey('shelf_life_days')) {
      return result['shelf_life_days'] as int? ?? 14;
    }
    return 14;
  }

  /// 根据分类获取Emoji
  String _getEmojiFromCategory(String category) {
    const categoryEmojis = {
      '乳制品': '🥛',
      '烘焙': '🍞',
      '生鲜': '🥬',
      '水果': '🍎',
      '蔬菜': '🥕',
      '肉类': '🥩',
      '海鲜': '🐟',
      '冷冻': '🧊',
      '调味': '🧂',
      '零食': '🍪',
      '饮料': '🥤',
      '酒类': '🍷',
    };

    for (final entry in categoryEmojis.entries) {
      if (category.contains(entry.key)) {
        return entry.value;
      }
    }

    return '📦'; // 默认
  }

  /// 测试用的模拟识别（开发阶段使用）
  Future<Map<String, dynamic>> simulateRecognition(File imageFile) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 2));

    // 返回模拟数据
    return {
      'name': '全脂牛奶',
      'category': '乳制品',
      'brand': '蒙牛',
      'daysLeft': 7,
      'totalDays': 14,
      'emoji': '🥛',
      'description': '通过AI识别的商品信息（模拟数据）',
      'confidence': 0.95,
    };
  }

  void dispose() {
    _dio.close();
  }
}
