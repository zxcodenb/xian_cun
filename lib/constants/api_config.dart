/// API配置常量
class ApiConfig {
  /// 基础API地址
  /// 开发环境：使用本机地址
  /// 生产环境：替换为实际服务器地址
  static const String baseUrl = 'http://10.0.2.2:8000'; // Android模拟器特殊地址

  /// API前缀
  static const String apiPrefix = '/api/v1';

  /// 完整的API基础URL
  static String get fullBaseUrl => '$baseUrl$apiPrefix';

  /// 连接超时时间（秒）
  static const int connectTimeout = 30;

  /// 接收超时时间（秒）
  static const int receiveTimeout = 30;

  /// 请求头
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// API端点路径
  static const String productsEndpoint = '/products';
  static const String categoriesEndpoint = '/categories';
  static const String settingsEndpoint = '/settings';
  static const String statsEndpoint = '/stats';
  static const String recognizeEndpoint = '/recognize';

  /// 完整的API URL
  static String get productsUrl => '$fullBaseUrl$productsEndpoint';
  static String get categoriesUrl => '$fullBaseUrl$categoriesEndpoint';
  static String get settingsUrl => '$fullBaseUrl$settingsEndpoint';
  static String get statsUrl => '$fullBaseUrl$statsEndpoint';
  static String get recognizeUrl => '$fullBaseUrl$recognizeEndpoint';

  /// 生成带ID的URL
  static String productsWithIdUrl(int id) => '$productsUrl/$id';
  static String settingsWithKeyUrl(String key) => '$settingsUrl/$key';
  static String categoriesWithIdUrl(int id) => '$categoriesUrl/$id';
}
