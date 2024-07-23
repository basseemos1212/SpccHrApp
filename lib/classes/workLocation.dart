import 'package:hr_app/classes/employee.dart';

class WorkLocation {
  final String name;
  final String department;
  final List<Employee> employeeList;

  WorkLocation(
      {required this.name,
      required this.department,
      required this.employeeList});
}
