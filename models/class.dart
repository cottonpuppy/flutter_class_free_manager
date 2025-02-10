// models/class.dart
import 'fee_manager.dart';

class Class {
  final String name; // 班级名称
  final FeeManager feeManager; // 班级的 FeeManager 实例

  Class({required this.name, required this.feeManager});
}