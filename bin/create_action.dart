import 'dart:io';

import 'package:color_logger/color_logger.dart';
import 'package:dart_ops_engine/dart_ops_engine.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:path/path.dart';
import 'package:process_run/shell.dart';

class CreateAction extends ActionRun {
  @override
  Future<Map> run(Env env, Map request) async {
    final name = JSON(request)['name'].string;
    if (name == null) {
      throw ArgumentError('name must not be null');
    }
    final description = JSON(request)['description'].string;
    final current = Directory.current.path;
    final root = join(current, name);
    if (await File(root).exists()) {
      throw ArgumentError('$root already exists');
    }
    final items = <_NeedCreateItem>[
      _NeedCreateItem('''
import 'package:dart_ops_engine/dart_ops_engine.dart';
import 'package:$name/$name.dart';

void main(List<String> arguments) {
  DartOpsEngine('sample', arguments)
    ..addAction('calculate', CalculateAction())
    ..run();
}
''', File(join(root, 'bin', '$name.dart'))),
      _NeedCreateItem('''
import 'package:dart_ops_engine/dart_ops_engine.dart';
import 'package:darty_json_safe/darty_json_safe.dart';

class CalculateAction extends ActionRun {
  @override
  Future<Map> run(Env env, Map request) {
    final a = JSON(request)['a'].intValue;
    final b = JSON(request)['b'].intValue;
    return Future.value({'result': calculate(a, b)});
  }

  int calculate(int a, int b) {
    return a * b;
  }
}

''', File(join(root, 'lib', '$name.dart'))),
      _NeedCreateItem('''
import 'package:dart_ops_engine/dart_ops_engine.dart';
import 'package:$name/$name.dart';
import 'package:test/test.dart';

void main() {
  test('calculate', () async {
    final rep = await CalculateAction().run(Env(), {'a': 21, 'b': 21});
    expect(rep['result'], 441);
  });
}

''', File(join(root, 'test', '${name}_test.dart'))),
      _NeedCreateItem('''
# https://dart.dev/guides/libraries/private-files
# Created by `dart pub`
.dart_tool/
''', File(join(root, '.gitignore'))),
      _NeedCreateItem('''
# This file configures the static analysis results for your project (errors,
# warnings, and lints).
#
# This enables the 'recommended' set of lints from `package:lints`.
# This set helps identify many issues that may lead to problems when running
# or consuming Dart code, and enforces writing Dart using a single, idiomatic
# style and format.
#
# If you want a smaller set of lints you can change this to specify
# 'package:lints/core.yaml'. These are just the most critical lints
# (the recommended set includes the core lints).
# The core lints are also what is used by pub.dev for scoring packages.

include: package:lints/recommended.yaml

# Uncomment the following section to specify additional rules.

# linter:
#   rules:
#     - camel_case_types

# analyzer:
#   exclude:
#     - path/to/excluded/files/**

# For more information about the core and recommended set of lints, see
# https://dart.dev/go/core-lints

# For additional information about configuring this file, see
# https://dart.dev/guides/language/analysis-options

''', File(join(root, 'analysis_options.yaml'))),
      _NeedCreateItem('''
## 1.0.0

- Initial version.

''', File(join(root, 'CHANGELOG.md'))),
      _NeedCreateItem('''
name: $name
description: ${description ?? "A sample command-line application."}
version: 1.0.0
publish_to: none
# repository: https://github.com/my_org/my_repo

environment:
  sdk: ^3.1.3

# Add regular dependencies here.
dependencies:
  dart_ops_engine: ^$version
  darty_json_safe: ^1.0.3

dev_dependencies:
  lints: ^2.0.0
  test: ^1.21.0

''', File(join(root, 'pubspec.yaml'))),
      _NeedCreateItem('''
A sample command-line application with an entrypoint in `bin/`, library code
in `lib/`, and example unit test in `test/`.

''', File(join(root, 'README.md'))),
    ];

    await Future.wait(items.map((e) => createFileContent(e.content, e.file)));
    Shell(workingDirectory: root).run('git init');
    logger.log('创建插件成功!', status: LogStatus.success);
    return {};
  }

  Future<void> createFileContent(String content, File file) async {
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    await file.writeAsString(content);
  }
}

class _NeedCreateItem {
  final String content;
  final File file;
  _NeedCreateItem(this.content, this.file);
}
