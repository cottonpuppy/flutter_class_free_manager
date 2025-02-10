import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/user.dart';
import 'models/class.dart';
import 'models/class_manager.dart';
import 'models/fee_manager.dart';
import 'pages/record_list_page.dart';

void main() {
  runApp(ClassFeeApp());
}

class ClassFeeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ClassManager>(
          create: (context) {
            final classManager = ClassManager();

            // 初始化多个班级
            classManager.addClass(Class(name: "Class A", feeManager: FeeManager()));
            classManager.addClass(Class(name: "Class B", feeManager: FeeManager()));
            classManager.addClass(Class(name: "Class C", feeManager: FeeManager()));

            return classManager;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Class Fee Manager',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: RecordListPage(),
      ),
    );
  }
}

// 当前登录用户（可以动态切换）
User currentUser = User(name: "Monitor 1", role: UserRole.Monitor);

// 默认的用户列表
final List<User> allUsers = [
  ...List.generate(82, (index) => User(name: "Student ${index + 1}", role: UserRole.Student)),
  ...List.generate(8, (index) => User(name: "Monitor ${index + 1}", role: UserRole.Monitor)),
  ...List.generate(3, (index) => User(name: "Teacher ${index + 1}", role: UserRole.Teacher)),
];
