import 'dart:convert';
import 'package:dio/dio.dart';
import '../constants/api_config.dart';

/// 统计数据模型
class StatsData {
  final int total;
  final int urgent;
  final int warning;
  final int safe;
  final Map<String, int> byCategory;

  const StatsData({
    required this.total,
    required this.urgent,
    required this.warning,
    required this.safe,
    required this.byCategory,
  });

  factory StatsData.fromJson(Map<String, dynamic> json) {
    return StatsData(
      total: json['total'] ?? 0,
      urgent: json['urgent'] ?? 0,
      warning: json['warning'] ?? 0,
      safe: json['safe'] ?? 0,
      byCategory: Map<String, int>.from(json['byCategory'] ?? {}),
    );
  }
}

/// 统计API服务
class StatsService {
  final Dio _dio;

  StatsService() : _dio = Dio() {
    _dio.options.baseUrl = ApiConfig.fullBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: ApiConfig.connectTimeout);
    _dio.options.receiveTimeout = const Duration(seconds: ApiConfig.receiveTimeout);
    _dio.options.headers = ApiConfig.headers;
  }

  /// 获取统计数据
  Future<StatsData> getStats() async {
    try {
      final response = await _dio.get(
        ApiConfig.statsEndpoint,
      );

      if (response.statusCode == 200) {
        return StatsData.fromJson(response.data);
      } else {
        throw Exception('获取统计数据失败');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      throw Exception('获取统计数据失败: $e');
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
