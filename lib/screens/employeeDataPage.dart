import 'package:flutter/cupertino.dart';
import 'package:hr_app/widgets/employeeList.dart';

class EmployeeDataPage extends StatefulWidget {
  const EmployeeDataPage({super.key});

  @override
  State<EmployeeDataPage> createState() => _EmployeeDataPageState();
}

class _EmployeeDataPageState extends State<EmployeeDataPage> {
  @override
  Widget build(BuildContext context) {
    return const Expanded(child: EmployeeList());
  }
}
