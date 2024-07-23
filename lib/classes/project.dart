import 'package:hr_app/classes/employee.dart';

class Project {
  final String name;
  final String department;
  final List<Employee> employees;

  Project(
      {required this.name, required this.department, required this.employees});
}
