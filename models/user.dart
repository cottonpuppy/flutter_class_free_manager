enum UserRole { Teacher, Monitor, Student }

class User {
  final String name;
  final UserRole role;

  User({required this.name, required this.role});
}
