import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:hr_app/managers/firebaseHelper.dart';

class StartWorkTransaction extends StatefulWidget {
  final String transaction;
  const StartWorkTransaction({super.key, required this.transaction});

  @override
  State<StartWorkTransaction> createState() => _StartWorkTransactionState();
}

class _StartWorkTransactionState extends State<StartWorkTransaction>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  FirestoreManager firestoreManager = FirestoreManager();
  DateTime? _selectedDate;
  String? _selectedEmployeeId;
  String? _selectedEmployeeName;
  String? _selectedEmployeeImage;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _updateEmployee() async {
    if (_selectedEmployeeId == null || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار الموظف وتاريخ مباشره العمل')),
      );
      return;
    }

    try {
      await firestoreManager
          .updateDocument("الموظفين", _selectedEmployeeName!, {
        "status": "نشط",
        "projectStartWork": DateFormat('yyyy-MM-dd').format(_selectedDate!)
      });
      await firestoreManager.updateDocumentInCollection(
          "التقرير العام", _selectedEmployeeName!, "تقارير", "", {
        "report":
            "${DateFormat('yyyy-MM-dd').format(_selectedDate!)} تمت مباشره عمل الموظف في يوم ",
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث بيانات الموظف بنجاح')),
      );
      Navigator.pop(context);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء تحديث البيانات')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

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
                  'مباشره خدمه',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'تاريخ مباشره العمل',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _pickDate(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _selectedDate == null
                      ? 'اختر التاريخ'
                      : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'اختيار الموظف',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('الموظفين').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                var employeeList = snapshot.data!.docs.map((doc) {
                  return {
                    'id': doc.id,
                    'name': doc['name'],
                    'imageUrl': doc['imageUrl'],
                  };
                }).toList();
                return DropdownSearch<Map<String, dynamic>>(
                  items: employeeList,
                  itemAsString: (item) => item!['name'],
                  onChanged: (item) {
                    setState(() {
                      _selectedEmployeeId = item!['name'];
                      _selectedEmployeeName = item['name'];
                      _selectedEmployeeImage = item['imageUrl'];
                    });
                  },
                  selectedItem: _selectedEmployeeName == null
                      ? null
                      : {
                          'id': _selectedEmployeeId,
                          'name': _selectedEmployeeName
                        },
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      hintText: 'اختر الموظف',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  popupProps: PopupProps.dialog(
                    showSearchBox: true,
                    itemBuilder: (context, item, isSelected) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: item['imageUrl'] != null
                              ? Image.network(item['imageUrl'],
                                  width: 50, height: 50, fit: BoxFit.cover)
                              : Image.asset('assets/profile.jpeg',
                                  width: 50, height: 50, fit: BoxFit.cover),
                          title: Text(item['name']),
                        ),
                      );
                    },
                    searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(
                        hintText: 'بحث',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _updateEmployee,
                child: const Text('مباشره الخدمه'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
