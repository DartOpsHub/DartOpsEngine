import 'package:dart_ops_engine/commons/dart_ops_engine.dart';

import 'test_action.dart';

Future<void> main(List<String> arguments) async {
  final engine = DartOpsEngine('dart_ops', arguments);
  engine.addAction('test', TestAction());
  await engine.run();
}
