import 'dart:convert';
import 'package:dio/dio.dart';
import '../constants/api_config.dart';
import '../models/product.dart';

/// 商品API服务
class ProductService {
  final Dio _dio;

  ProductService() : _dio = Dio() {
    _dio.options.baseUrl = ApiConfig.fullBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: ApiConfig.connectTimeout);
    _dio.options.receiveTimeout = const Duration(seconds: ApiConfig.receiveTimeout);
    _dio.options.headers = ApiConfig.headers;
  }

  /// 获取商品列表
  Future<List<ProductItem>> getProducts({
    int page = 1,
    int size = 20,
    String? category,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _dio.get(
        ApiConfig.productsEndpoint,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final items = data['items'] as List;
        return items.map((item) => _parseProduct(item)).toList();
      } else {
        throw Exception('获取商品列表失败');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      throw Exception('获取商品列表失败: $e');
    }
  }

  /// 获取单个商品详情
  Future<ProductItem> getProduct(int id) async {
    try {
      final response = await _dio.get(
        ApiConfig.productsWithIdUrl(id),
      );

      if (response.statusCode == 200) {
        return _parseProduct(response.data);
      } else {
        throw Exception('获取商品详情失败');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      throw Exception('获取商品详情失败: $e');
    }
  }

  /// 创建商品
  Future<ProductItem> createProduct({
    required String name,
    required String category,
    required String brand,
    required int daysLeft,
    required int totalDays,
    required String emoji,
    String? description,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.productsEndpoint,
        data: {
          'name': name,
          'category': category,
          'brand': brand,
          'daysLeft': daysLeft,
          'totalDays': totalDays,
          'emoji': emoji,
          'description': description,
        },
      );

      if (response.statusCode == 200) {
        return _parseProduct(response.data);
      } else {
        throw Exception('创建商品失败');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      throw Exception('创建商品失败: $e');
    }
  }

  /// 更新商品
  Future<ProductItem> updateProduct({
    required int id,
    required String name,
    required String category,
    required String brand,
    required int daysLeft,
    required int totalDays,
    required String emoji,
    String? description,
  }) async {
    try {
      final response = await _dio.put(
        ApiConfig.productsWithIdUrl(id),
        data: {
          'name': name,
          'category': category,
          'brand': brand,
          'daysLeft': daysLeft,
          'totalDays': totalDays,
          'emoji': emoji,
          'description': description,
        },
      );

      if (response.statusCode == 200) {
        return _parseProduct(response.data);
      } else {
        throw Exception('更新商品失败');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      throw Exception('更新商品失败: $e');
    }
  }

  /// 删除商品
  Future<bool> deleteProduct(int id) async {
    try {
      final response = await _dio.delete(
        ApiConfig.productsWithIdUrl(id),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      throw Exception('删除商品失败: $e');
    }
  }

  /// 解析API响应为ProductItem对象
  ProductItem _parseProduct(Map<String, dynamic> item) {
    return ProductItem(
      id: item['id'] ?? 0,
      name: item['name'] ?? '',
      category: item['category'] ?? '',
      brand: item['brand'] ?? '',
      daysLeft: item['daysLeft'] ?? 0,
      totalDays: item['totalDays'] ?? 0,
      emoji: item['emoji'] ?? '📦',
      description: item['description'],
      purchaseDate: item['purchaseDate'] != null
          ? DateTime.parse(item['purchaseDate'])
          : DateTime.now(),
    );
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
