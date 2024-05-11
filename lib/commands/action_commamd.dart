import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dart_ops_engine/commons/action.dart';
import 'package:dart_ops_engine/commons/action_run.dart';
import 'package:dart_ops_engine/commons/dart_ops_engine.dart';
import 'package:dart_ops_engine/commons/execute.dart';
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
  });

  @override
  FutureOr? run() async {
    final id = JSON(globalResults?['id']).intValue;
    final index = JSON(globalResults?['index']).intValue;
    final execute = Execute.cache(id);
    final data = await DartOpsEngine.getRequestData(id).then((value) =>
        value.map((key, value) => MapEntry(key.toString(), value.toString())));
    requestArgs.addAll(data);
    final actionId = Action.actionId(runnerName, index, name);
    await execute.saveRequestData(data, actionId);
    final response = await actionRun.run(execute.memoryEnv, requestArgs);
    await execute.saveResponseData(response, actionId);
  }
}
