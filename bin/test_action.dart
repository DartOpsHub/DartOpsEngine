import 'package:dart_ops_engine/commons/action_run.dart';
import 'package:dart_ops_engine/commons/env.dart';
import 'package:dart_ops_engine/defines/define.dart';

class TestAction extends ActionRun {
  @override
  Future<Map> run(Env env, Map request) async {
    logger.log('env: ${env.env}');
    logger.log('request: $request');
    return {};
  }
}
