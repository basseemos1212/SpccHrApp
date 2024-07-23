import 'package:flutter/material.dart';
import 'package:hr_app/screens/reportMainWidget.dart';

class FinanceReportScreen extends StatefulWidget {
  const FinanceReportScreen({super.key});

  @override
  State<FinanceReportScreen> createState() => _FinanceReportScreenState();
}

class _FinanceReportScreenState extends State<FinanceReportScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ReportMainWidget(
        collectionName: "تقارير الماليات",
        reportTitle: "طلب تقرير ماليه للموظف",
      ),
    );
  }
}
