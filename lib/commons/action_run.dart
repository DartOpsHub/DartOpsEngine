import 'package:dart_ops_engine/commons/env.dart';

abstract class ActionRun {
  Future<Map> run(Env env, Map request);
}
