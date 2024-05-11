/// 环境变量
class Env {
  /// 环境变量
  Map<String, String> env = {};
  Env({Map<String, String> environment = const {}}) {
    env.addAll(environment);
  }

  /// 设置环境变量
  void operator []=(String name, String value) {
    env[name] = value;
  }

  /// 获取环境变量
  String? operator [](String name) => env[name];

  void operator +(Env environment) {
    env.addAll(environment.env);
  }
}
