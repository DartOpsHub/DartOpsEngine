/// 环境变量
class Env {
  /// 环境变量
  final Map<String, String> env;
  Env({required this.env});

  /// 设置环境变量
  void operator []=(String name, String value) {
    env[name] = value;
  }

  /// 获取环境变量
  String? operator [](String name) => env[name];
}
