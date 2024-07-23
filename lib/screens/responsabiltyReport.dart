import 'package:flutter/material.dart';
import 'package:hr_app/screens/reportMainWidget.dart';

class ResponsabilityReports extends StatefulWidget {
  const ResponsabilityReports({super.key});

  @override
  State<ResponsabilityReports> createState() => _ResponsabilityReportsState();
}

class _ResponsabilityReportsState extends State<ResponsabilityReports> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ReportMainWidget(
        collectionName: "تقارير الاصول",
        reportTitle: "طلب تقرير الاصول للموظف",
      ),
    );
  }
}
