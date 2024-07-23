import 'package:flutter/material.dart';
import 'package:hr_app/widgets/workLocationsList.dart';

class WorkLocationsScreen extends StatefulWidget {
  const WorkLocationsScreen({super.key});

  @override
  State<WorkLocationsScreen> createState() => _WorkLocationsScreenState();
}

class _WorkLocationsScreenState extends State<WorkLocationsScreen> {
  @override
  Widget build(BuildContext context) {
    return const Expanded(child: WorkLocationsList());
  }
}
