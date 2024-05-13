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
    runner.argParser.addOption('id', help: '执行ID');
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

  static Future<Map> getRequestData(int? id) async {
    Map data = {};
    Execute? execute;
    if (id != null) {
      execute = Execute.cache(id);
      await execute.init();
    }

    for (var arg in requestArgument) {
      if (arg.startsWith('--args=')) {
        // --args=name=value
        final values = arg.substring(7).split('=');
        data[values[0]] = values[1];
      } else if (arg.startsWith('--env=') && execute != null) {
        // --env=name
        final name = arg.substring(6);
        final value = execute.memoryEnv.env[name];
        if (value != null) {
          data[name] = value;
        }
      } else if (arg.startsWith('--res=') && execute != null) {
        // --res=a|index|name,1,2,3
        final argName = execute.key(arg);
        final value = await execute.repValue(arg);
        if (value != null && argName != null) {
          data[argName] = value;
        }
      } else if (arg.startsWith('--req=') && execute != null) {
        // --req=a|index|name,1,2,3
        final argName = execute.key(arg);
        final value = await execute.reqValue(arg);
        if (value != null && argName != null) {
          data[argName] = value;
        }
      }
    }
    return data;
  }
}

extension _JSONData on Execute {
  String? key(String arg) {
    return JSON(contents(arg))[0].string;
  }

  List<String> contents(String arg) {
    final values = arg.substring(6).split('|');
    return values.length == 3 ? values : [];
  }

  Future<String?> reqValue(String arg) async {
    final index = JSON(contents)[1].intValue;
    final action = actions[index];
    final responseMap = await requestData(action);
    final keys = JSON(contents)[2].stringValue.split(',');
    return JSON(responseMap)[keys].string;
  }

  Future<String?> repValue(String arg) async {
    final index = JSON(contents)[1].intValue;
    final action = actions[index];
    final responseMap = await responseData(action);
    final keys = JSON(contents)[2].stringValue.split(',');
    return JSON(responseMap)[keys].string;
  }
}
