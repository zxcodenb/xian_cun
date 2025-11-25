import 'dart:convert';
import 'package:dio/dio.dart';
import '../constants/api_config.dart';

/// 分类数据模型
class CategoryItem {
  final int id;
  final String name;
  final String emoji;
  final int defaultShelfLife;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.defaultShelfLife,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      emoji: json['emoji'] ?? '📦',
      defaultShelfLife: json['defaultShelfLife'] ?? 14,
    );
  }
}

/// 分类API服务
class CategoryService {
  final Dio _dio;

  CategoryService() : _dio = Dio() {
    _dio.options.baseUrl = ApiConfig.fullBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: ApiConfig.connectTimeout);
    _dio.options.receiveTimeout = const Duration(seconds: ApiConfig.receiveTimeout);
    _dio.options.headers = ApiConfig.headers;
  }

  /// 获取所有分类
  Future<List<CategoryItem>> getCategories() async {
    try {
      final response = await _dio.get(
        ApiConfig.categoriesEndpoint,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final items = data['items'] as List;
        return items.map((item) => CategoryItem.fromJson(item)).toList();
      } else {
        throw Exception('获取分类列表失败');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      throw Exception('获取分类列表失败: $e');
    }
  }

  /// 获取单个分类
  Future<CategoryItem> getCategory(int id) async {
    try {
      final response = await _dio.get(
        ApiConfig.categoriesWithIdUrl(id),
      );

      if (response.statusCode == 200) {
        return CategoryItem.fromJson(response.data);
      } else {
        throw Exception('获取分类详情失败');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      throw Exception('获取分类详情失败: $e');
    }
  }

  /// 处理Dio错误
  void _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw Exception('请求超时，请检查网络连接');
    }
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final message = e.response!.data?['detail'] ?? e.message;
      throw Exception('请求失败 ($statusCode): $message');
    }
    throw Exception('网络错误: ${e.message}');
  }

  void dispose() {
    _dio.close();
  }
}
