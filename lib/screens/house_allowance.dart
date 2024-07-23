import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HousingAllowanceScreen extends StatefulWidget {
  @override
  _HousingAllowanceScreenState createState() => _HousingAllowanceScreenState();
}

class _HousingAllowanceScreenState extends State<HousingAllowanceScreen> {
  List<Map<String, dynamic>> employees = [];
  double totalMonthlyAllowance = 0.0;
  double totalYearlyAllowance = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchEmployeeData();
  }

  Future<void> _fetchEmployeeData() async {
    final QuerySnapshot result =
        await FirebaseFirestore.instance.collection('الموظفين').get();

    setState(() {
      employees = result.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final housingAllowance =
            double.parse(data['housingAllowance'].toString());
        final allowanceType =
            data['housingAllowancePaymentType']?.toString() ?? 'شهري';

        if (allowanceType == 'شهري') {
          totalMonthlyAllowance += housingAllowance;
        } else {
          totalYearlyAllowance += housingAllowance;
        }

        return {
          'name': data['name']?.toString() ?? 'غير متوفر',
          'housingAllowance': housingAllowance,
          'allowanceType': allowanceType,
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/logo.png',
                  height: 40,
                ),
                const SizedBox(width: 10),
                const Text(
                  'بدلات السكن',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                const Text(
                  'الموظفين و بدلات السكن',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildEmployeeTable(),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                const Text(
                  'مجموع البدلات',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildTotalsTable(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeTable() {
    return DataTable(
      columns: const [
        DataColumn(label: Text('اسم الموظف')),
        DataColumn(label: Text('بدل السكن')),
        DataColumn(label: Text('نوع البدلة')),
      ],
      rows: employees
          .map(
            (employee) => DataRow(cells: [
              DataCell(Text(employee['name'])),
              DataCell(Text(employee['housingAllowance'].toString())),
              DataCell(Text(employee['allowanceType'])),
            ]),
          )
          .toList(),
    );
  }

  Widget _buildTotalsTable() {
    return DataTable(
      columns: const [
        DataColumn(label: Text('نوع البدلة')),
        DataColumn(label: Text('المجموع')),
      ],
      rows: [
        DataRow(cells: [
          const DataCell(Text('شهري')),
          DataCell(Text(totalMonthlyAllowance.toString())),
        ]),
        DataRow(cells: [
          const DataCell(Text('سنوي')),
          DataCell(Text(totalYearlyAllowance.toString())),
        ]),
      ],
    );
  }
}
