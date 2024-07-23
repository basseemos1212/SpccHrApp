import 'package:hr_app/classes/project.dart';

class Departments {
  final String name;
  final String manager;
  final String location;
  final List<Project> projects;

  Departments(
      {required this.name,
      required this.manager,
      required this.location,
      required this.projects});
}
