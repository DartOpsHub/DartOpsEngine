import 'package:dart_ops_engine/commons/execute.dart';
import 'package:path/path.dart';

/// 缓存管理
class CacheManager {
  /// 缓存的主目录
  final String cacheDir;

  CacheManager({required this.cacheDir});

  /// 执行目录
  String get executeDir => join(cacheDir, 'execute');

  /// 获取环境变量文件路径
  String envFilePath(Execute execute) =>
      join(executeDir, "${execute.id}", '.env');

  /// 单个Action请求内容文件
  String actionRequestFilePath(Execute execute, String actionId) =>
      join(executeDir, "${execute.id}", actionId, 'request.json');

  /// 请求Action的返回内容文件
  String actionResponseFilePath(Execute execute, String actionId) =>
      join(executeDir, "${execute.id}", actionId, 'response.json');

  String configFilePath(Execute execute) =>
      join(executeDir, "${execute.id}", "config.json");
}
