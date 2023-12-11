/// 单个执行的方法
class Action {
  /// 方法的名称
  final String name;

  Action({required this.name});

  /// 获取当前执行方法的ID
  ///
  /// [index]  当前执行的索引 防止因为一次执行多次导致ID重复
  String id([int index = 0]) => "${name}_$index";
}
