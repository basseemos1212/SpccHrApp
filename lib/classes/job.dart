import 'package:hr_app/classes/employee.dart';

class Job {
  final String name;
  final String department;
  final List<Employee> employeeList;

  Job(
      {required this.name,
      required this.department,
      required this.employeeList});
}
