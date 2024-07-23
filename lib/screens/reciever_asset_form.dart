import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:intl/intl.dart';

class ReceiveAssetForm extends StatefulWidget {
  const ReceiveAssetForm({super.key});

  @override
  _ReceiveAssetFormState createState() => _ReceiveAssetFormState();
}

class _ReceiveAssetFormState extends State<ReceiveAssetForm> {
  String? _selectedEmployeeName;
  String? _selectedEmployeeId;
  String? _selectedEmployeeImage;
  Map<String, dynamic>? _selectedAsset;

  Future<List<Map<String, dynamic>>> _getEmployees() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('الموظفين').get();
    return querySnapshot.docs
        .map((doc) => {
              'id': doc.id,
              'name': doc['name'],
              'imageUrl': doc['imageUrl'],
            })
        .toList();
  }

  Future<void> _fetchEmployeeDetails(String employeeName) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('الموظفين')
        .where('name', isEqualTo: employeeName)
        .get();
    if (result.docs.isNotEmpty) {
      final data = result.docs.first.data() as Map<String, dynamic>;
      setState(() {
        _selectedEmployeeId = result.docs.first.id;
        _selectedEmployeeName = data['name'];
        _selectedEmployeeImage = data['imageUrl'];
      });
    }
  }

  Future<List<Map<String, dynamic>>> _getEmployeeAssets(
      String employeeId) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('الموظفين')
        .doc(employeeId)
        .get();
    List<dynamic> assets = doc['assets'] ?? [];
    return assets.map((asset) => asset as Map<String, dynamic>).toList();
  }

  Future<void> _receiveAsset() async {
    if (_selectedEmployeeId == null || _selectedAsset == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار الموظف والعهدة')),
      );
      return;
    }

    DocumentReference employeeDoc = FirebaseFirestore.instance
        .collection('الموظفين')
        .doc(_selectedEmployeeId);

    try {
      // Update the employee document to remove the asset
      await employeeDoc.update({
        'assets': FieldValue.arrayRemove([_selectedAsset]),
      });

      // Add a report to the asset reports collection
      await FirebaseFirestore.instance
          .collection('تقارير الاصول')
          .doc(_selectedEmployeeName)
          .collection('التقارير')
          .add({
        'job':
            'تم استلام العهدة ${_selectedAsset!['item_name']} من الموظف $_selectedEmployeeName بتاريخ ${DateFormat('yyyy-MM-dd').format(DateTime.now())}'
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم استلام العهدة بنجاح')),
      );

      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء استلام العهدة: $error')),
      );
    }
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
                  'استلام العهدة',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _getEmployees(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                var employees = snapshot.data ?? [];
                return DropdownSearch<Map<String, dynamic>>(
                  items: employees,
                  itemAsString: (employee) => employee!['name'],
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    itemBuilder: (context, employee, isSelected) {
                      return ListTile(
                        leading: employee['imageUrl'] != null
                            ? Image.network(employee['imageUrl'],
                                width: 30, height: 30)
                            : Container(width: 30, height: 30),
                        title: Text(employee['name']),
                      );
                    },
                  ),
                  onChanged: (employee) {
                    setState(() {
                      _selectedEmployeeName = employee!['name'];
                      _fetchEmployeeDetails(_selectedEmployeeName!);
                    });
                  },
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: "اختر الموظف",
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            if (_selectedEmployeeId != null)
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _getEmployeeAssets(_selectedEmployeeId!),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  var assets = snapshot.data ?? [];
                  return DropdownSearch<Map<String, dynamic>>(
                    items: assets,
                    itemAsString: (asset) => asset!['item_name'],
                    onChanged: (asset) {
                      setState(() {
                        _selectedAsset = asset;
                      });
                    },
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: "اختر العهدة",
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _receiveAsset,
              child: const Text('تسليم العهدة'),
            ),
          ],
        ),
      ),
    );
  }
}
