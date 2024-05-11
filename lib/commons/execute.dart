import 'dart:io';

import 'package:color_logger/color_logger.dart';
import 'package:dart_ops_engine/commons/action.dart';
import 'package:dart_ops_engine/commons/cache_manager.dart';
import 'package:dart_ops_engine/commons/env.dart';
import 'package:dart_ops_engine/defines/define.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:path/path.dart';
import 'package:process_run/process_run.dart';
import 'package:dcm/dcm.dart';
import 'package:process_run/shell.dart';

/// 一个流程一个执行器
class Execute {
  final int id;
  final CacheManager cacheManager;
  final Env memoryEnv;
  final List<Action> actions = [];
  final bool useCache;
  List<Map> configs = [];

  Execute({int? id, this.useCache = false, List<Map> configs = const []})
      : id = id ?? DateTime.now().millisecondsSinceEpoch,
        cacheManager = CacheManager(cacheDir: join(engineDir, 'execute')),
        memoryEnv = Env(environment: platformEnvironment) {
    this.configs.addAll(configs);
  }

  factory Execute.cache(int id) => Execute(id: id, useCache: true);

  Future<void> init() async {
    memoryEnv + await _loadEnv();
    if (useCache) {
      final data = await jsonFromPath(cacheManager.configFilePath(this));
      if (data != null) {
        configs.clear();
        configs.addAll(JSON(data).listValue.map((e) => e as Map).toList());
      }
    }
    for (var config in JSON(configs).listValue) {
      final name = JSON(config)['name'].stringValue;
      final action = Action(
        name: JSON(config)['name'].stringValue,
        argument: JSON(config)['argument']
            .listValue
            .map((e) => e.toString())
            .toList(),
        actionType: JSON(config)['actionType'].stringValue,
        index: actions.where((element) => element.name == name).toList().length,
        commandName: JSON(config)['commandName'].string,
      );
      actions.add(action);
    }
  }

  Future<void> close() async {
    await _saveEnv(memoryEnv);
  }

  Future<void> run() async {
    await saveJsonFromPath(cacheManager.configFilePath(this), configs);
    for (var i = 0; i < actions.length; i++) {
      final action = actions[i];
      final shellText = action.argument.join(' ');
      var shellName = action.name;
      final name = action.name.split('@').first;
      final ref = action.name.split('@').last;
      if (action.actionType == 'dart' && action.commandName != null) {
        shellName =
            '${exePath(name, ref)} ${action.commandName} --id $id --index ${action.id}';
      }
      final shell = Shell(workingDirectory: memoryEnv['PWD']);
      final results = await shell.run('$shellName $shellText');
      for (var result in results) {
        if (result.errText.isNotEmpty) {
          logger.log(
            '[${result.exitCode}]${result.errText}',
            status: LogStatus.error,
          );
        }
      }
      if (results.any((element) => element.errText.isNotEmpty)) {
        exit(2);
      }
    }
  }

  /// 获取环境变量
  Future<Env> _loadEnv() async {
    final envFilePath = cacheManager.envFilePath(this);
    if (!await File(envFilePath).exists()) {
      return Env(environment: {});
    }
    final envContents = await File(envFilePath).readAsLines();
    final envMap = <String, String>{};
    for (var content in envContents) {
      final value = content.split('=');
      envMap[value[0]] = value[1];
    }
    return Env(environment: envMap);
  }

  Future<void> _saveEnv(Env env) async {
    final envFile = File(cacheManager.envFilePath(this));
    final envContents = <String>[];
    env.env.forEach((key, value) {
      envContents.add('$key=$value');
    });
    if (!await envFile.exists()) {
      await envFile.create(recursive: true);
    }
    await envFile.writeAsString(envContents.join('\n'));
  }

  Future<Map?> requestData(String actionName, int index) async {
    final action =
        JSON(actions.where((element) => element.name == actionName).toList())[
                index]
            .rawValue;
    if (action == null) return null;
    final path = cacheManager.actionRequestFilePath(this, action);
    return jsonFromPath(path).then((value) => value as Map);
  }

  Future<void> saveRequestData(Map data, String actionId) async {
    final path = cacheManager.actionRequestFilePath(this, actionId);
    await saveJsonFromPath(path, data);
  }

  Future<Map?> responseData(Action action) async {
    final path = cacheManager.actionResponseFilePath(this, action.id);
    return jsonFromPath(path).then((value) => JSON(value).map);
  }

  Future<void> saveResponseData(Map data, String actionId) async {
    final path = cacheManager.actionResponseFilePath(this, actionId);
    await saveJsonFromPath(path, data);
  }
}
