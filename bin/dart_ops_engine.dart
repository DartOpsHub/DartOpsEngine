import 'package:args/command_runner.dart';

Future<void> main(List<String> arguments) async {
  final commandRunner = CommandRunner('dart_ops_engine', 'dart流程引擎工具');

  commandRunner.argParser.addOption(
    'root',
    abbr: 'r',
    help: '项目目录',
    callback: (p0) {
      print("->>>>>>>$p0");
    },
  );

  await commandRunner.run(arguments);
}
