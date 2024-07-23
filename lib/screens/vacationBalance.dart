import 'package:flutter/material.dart';
import 'package:hr_app/managers/firebaseHelper.dart';

class VacationBalanceTable extends StatefulWidget {
  @override
  _VacationBalanceTableState createState() => _VacationBalanceTableState();
}

class _VacationBalanceTableState extends State<VacationBalanceTable> {
  List<Map<String, dynamic>>? vacationData;
  final FirestoreManager _firestoreManager = FirestoreManager();

  @override
  void initState() {
    super.initState();
    fetchVacationData();
  }

  Future<void> fetchVacationData() async {
    try {
      List<Map<String, dynamic>> data =
          await _firestoreManager.getAllDocuments('رصيد الاجازات');
      setState(() {
        vacationData = data;
      });
    } catch (e) {
      print("Error fetching vacation data: $e");
      // Handle error accordingly
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('رصيد الاجازات'),
      ),
      body: vacationData == null
          ? const Center(
              child: CircularProgressIndicator(), // Loading indicator
            )
          : Align(
              alignment: Alignment.topRight,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('اسم الموظف')),
                      DataColumn(label: Text('المتبقي من رصيد الاجازات')),
                      DataColumn(label: Text('تاريخ اخر اجازه')),
                      DataColumn(label: Text('قدرها')),
                    ],
                    rows: vacationData!.map((data) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              data['name'].toString(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${data['balance'].toString()} ايام',
                              style: TextStyle(color: Colors.green),
                            ),
                          ),
                          DataCell(
                            Text(
                              data['date'].toString(),
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${data['amount'].toString()} يوم',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
    );
  }
}
