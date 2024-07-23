import 'package:flutter/material.dart';

import '../widgets/departmentsList.dart';

class DepartmentsScreen extends StatefulWidget {
  const DepartmentsScreen({super.key});

  @override
  State<DepartmentsScreen> createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends State<DepartmentsScreen> {
  @override
  Widget build(BuildContext context) {
    return const Expanded(child: DepartmentsList());
  }
}
