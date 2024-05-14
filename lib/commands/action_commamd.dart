import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dart_ops_engine/dart_ops_engine.dart';
import 'package:darty_json_safe/darty_json_safe.dart';

class ActionCommand extends Command {
  @override
  final String name;
  @override
  final String description;

  final ActionRun actionRun;
  final Map<String, String> requestArgs;
  final String runnerName;

  ActionCommand({
    required this.name,
    required this.description,
    required this.actionRun,
    required this.requestArgs,
    required this.runnerName,
  }) {
    argParser.addOption('id', help: '执行ID');
    argParser.addOption('index', help: '执行的索引，默认为0');
  }

  @override
  FutureOr? run() async {
    final id = JSON(argResults?['id']).int;
    final index = JSON(argResults?['index']).stringValue;
    final execute = Unwrap(id).map((e) => Execute.cache(e)).value;
    final data = await DartOpsEngine.getRequestData(id).then((value) =>
        value.map((key, value) => MapEntry(key.toString(), value.toString())));
    requestArgs.addAll(data);
    if (execute != null) {
      await execute.saveRequestData(data, index);
    }

    final response = await actionRun.run(
      execute?.memoryEnv ?? Env(),
      requestArgs,
    );
    if (execute != null) {
      await execute.saveResponseData(response, index);
    } else {
      print(JSON(response).stringValue);
    }
  }
}
