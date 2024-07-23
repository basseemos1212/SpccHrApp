import 'package:flutter/material.dart';
import 'package:hr_app/screens/reportMainWidget.dart';

class VacationDetailReport extends StatefulWidget {
  const VacationDetailReport({super.key});

  @override
  State<VacationDetailReport> createState() => _VacationDetailReportState();
}

class _VacationDetailReportState extends State<VacationDetailReport> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ReportMainWidget(
        collectionName: "تقارير الاجازات",
        reportTitle: "طلب تقرير اجازات للموظف",
      ),
    );
  }
}
