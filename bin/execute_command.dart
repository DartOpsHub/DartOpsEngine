import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dart_ops_engine/dart_ops_engine.dart';
import 'package:darty_json_safe/darty_json_safe.dart';

class ExecuteCommand extends Command {
  ExecuteCommand() {
    argParser.addOption('path', help: '执行路径', mandatory: true);
  }

  @override
  String get description => '执行Execute';

  @override
  String get name => 'execute';

  @override
  FutureOr? run() async {
    final path = JSON(argResults?['path']).stringValue;
    final configData = await jsonFromPath(path);
    final execute = Execute(
        configs: JSON(configData)
            .listValue
            .map((e) => e as Map<dynamic, dynamic>)
            .toList());
    await execute.init();
    await execute.run();
    await execute.close();
  }
}
