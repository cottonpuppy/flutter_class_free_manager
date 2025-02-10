// models/class_manager.dart
import 'class.dart';

class ClassManager {
  final List<Class> _classes = []; // 所有班级列表
  int _currentClassIndex = 0; // 当前选中的班级索引

  // 获取所有班级
  List<Class> get classes => List.unmodifiable(_classes);

  // 获取当前班级
  Class get currentClass => _classes[_currentClassIndex];

  // 添加新班级
  void addClass(Class newClass) {
    _classes.add(newClass);
  }

  // 切换班级
  void switchClass(int index) {
    if (index >= 0 && index < _classes.length) {
      _currentClassIndex = index;
    }
  }
}