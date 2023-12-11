import 'dart:io';

import 'package:dart_ops_engine/commons/cache_manager.dart';
import 'package:dart_ops_engine/commons/env.dart';

/// 一个流程一个执行器
class Execute {
  final int id;
  final CacheManager cacheManager;
  final Env memoryEnv;

  Execute(String cacheDir)
      : id = DateTime.now().millisecondsSinceEpoch,
        cacheManager = CacheManager(cacheDir: cacheDir),
        memoryEnv = Env(env: {});

  /// 获取环境变量
  Future<Env> loadEnv() async {
    final envFilePath = cacheManager.envFilePath(this);
    final envContents = await File(envFilePath).readAsLines();
    final envMap = <String, String>{};
    for (var content in envContents) {
      final value = content.split('=');
      envMap[value[0]] = value[1];
    }
    return Env(env: envMap);
  }
}
