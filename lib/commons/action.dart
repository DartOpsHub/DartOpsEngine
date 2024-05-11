import 'package:darty_json_safe/darty_json_safe.dart';

/// 单个执行的方法
class Action {
  /// 方法的名称
  final String name;

  /// 方法的唯一ID
  final String id;

  /// 方法传递的参数
  final List<String> argument;

  /// 方法名称 默认为dart
  final String actionType;

  final String? commandName;

  Action({
    required this.name,
    required this.argument,
    required int index,
    this.actionType = 'dart',
    this.commandName,
  }) : id = actionId(name, index, commandName);

  factory Action.fromJson(Map data) {
    final json = JSON(data);
    return Action(
      name: json['name'].stringValue,
      argument: json['argument'].listValue.map((e) => e.toString()).toList(),
      index: json['index'].int ?? 0,
      commandName: json['commandName'].string,
      actionType: json['actionType'].string ?? 'dart',
    );
  }

  Map toJson() {
    return {
      'name': name,
      'argument': argument,
      'index': id,
      'actionType': actionType,
      'commandName': commandName,
    };
  }

  static String actionId(String name, int index, [String? commandName]) =>
      '${name}_${commandName ?? "@"}_$index';
}
