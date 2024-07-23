import 'package:flutter/material.dart';
import 'package:hr_app/screens/reportMainWidget.dart';

class TransportationReport extends StatefulWidget {
  const TransportationReport({super.key});

  @override
  State<TransportationReport> createState() => _TransportationReportState();
}

class _TransportationReportState extends State<TransportationReport> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ReportMainWidget(
        collectionName: "تقارير التحركات",
        reportTitle: "طلب تقرير تحركات للموظف",
      ),
    );
  }
}
