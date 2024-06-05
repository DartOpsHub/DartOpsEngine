import 'package:dart_ops_engine/commons/env.dart';

abstract class ActionRun {
  Future<Map> run(Env env, Map request);
}

extension EnvGet on Env {
  String read(String name) {
    final value = this[name];
    if (value == null) {
      throw Exception('环境变量:$name 不存在!');
    }
    return value;
  }
}

extension MapGet on Map {
  T read<T>(String name) {
    final value = this[name];
    if (value == null) {
      throw Exception('没有设置$name 参数!');
    }
    return value as T;
  }
}
