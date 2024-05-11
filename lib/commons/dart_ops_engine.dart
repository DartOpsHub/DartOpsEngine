import 'package:args/command_runner.dart';
import 'package:dart_ops_engine/commands/action_commamd.dart';
import 'package:dart_ops_engine/commons/action_run.dart';
import 'package:dart_ops_engine/commons/execute.dart';
import 'package:darty_json_safe/darty_json_safe.dart';

class DartOpsEngine {
  final List<String> args;
  final CommandRunner runner;
  final Map<String, String> requestArgs = {};
  String? id;
  int? index;

  DartOpsEngine(String runnerName, this.args, {String? description})
      : runner = CommandRunner(runnerName, description ?? runnerName);

  void addAction(String actionName, ActionRun run, {String? description}) {
    runner.addCommand(ActionCommand(
      name: actionName,
      description: description ?? actionName,
      actionRun: run,
      requestArgs: requestArgs,
      runnerName: runner.executableName,
    ));
  }

  Future<void> run() async {
    runner.argParser.addOption('id', help: '执行ID', mandatory: true);
    runner.argParser.addOption('index', help: '执行的索引，默认为0');

    var arguments0 = [...args];
    requestArgument.clear();
    for (var arg in args) {
      final prefixs = ['--args=', '--env=', '--res='];
      if (prefixs.any((element) => arg.startsWith(element))) {
        requestArgument.add(arg);
        arguments0.remove(arg);
      }
    }
    return runner.run(arguments0);
  }

  static List<String> requestArgument = [];

  static Future<Map> getRequestData(int id) async {
    Map data = {};
    final execute = Execute.cache(id);
    await execute.init();
    for (var arg in requestArgument) {
      if (arg.startsWith('--args=')) {
        // --args=name=value
        final values = arg.substring(7).split('=');
        data[values[0]] = values[1];
      } else if (arg.startsWith('--env=')) {
        // --env=name
        final name = arg.substring(6);
        final value = execute.memoryEnv.env[name];
        if (value != null) {
          data[name] = value;
        }
      } else if (arg.startsWith('--res=')) {
        // --res=a|index|name,1,2,3
        final contents = arg.substring(6).split('|');
        if (contents.length != 3) continue;
        final argName = JSON(contents)[0].string;
        final index = JSON(contents)[1].intValue;
        final action = execute.actions[index];
        final responseMap = await execute.responseData(action);
        final keys = JSON(contents)[2].stringValue.split(',');
        final value = JSON(responseMap)[keys].string;
        if (value != null && argName != null) {
          data[argName] = value;
        }
      }
    }
    return data;
  }
}
