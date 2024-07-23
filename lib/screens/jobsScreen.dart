import 'package:flutter/material.dart';
import 'package:hr_app/widgets/jobList.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  @override
  Widget build(BuildContext context) {
    return Expanded(child: const JobList());
  }
}
