import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:color_logger/color_logger.dart';
import 'package:process_run/shell.dart';

String engineDir = join(platformEnvironment['HOME']!, '.dart_ops_engine');
ColorLogger logger = ColorLogger();

Future<dynamic> jsonFromPath(String path) async {
  if (!path.endsWith('.json')) return null;
  final file = File(path);
  if (!await file.exists()) return null;
  return json.decode(await file.readAsString());
}

Future<void> saveJsonFromPath(String path, dynamic data) async {
  final file = File(path);
  if (!await file.exists()) {
    await file.create(recursive: true);
  }
  await file.writeAsString(json.encode(data));
}
