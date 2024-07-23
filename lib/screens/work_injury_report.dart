import 'package:flutter/material.dart';
import 'package:hr_app/screens/reportMainWidget.dart';

class WorkInjuryReports extends StatefulWidget {
  const WorkInjuryReports({super.key});

  @override
  State<WorkInjuryReports> createState() => _WorkInjuryReportsState();
}

class _WorkInjuryReportsState extends State<WorkInjuryReports> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ReportMainWidget(
        collectionName: "تقارير اصابه العمل",
        reportTitle: "طلب تقرير اصابات العمل للموظف",
      ),
    );
  }
}
