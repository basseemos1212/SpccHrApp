import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';

class AssetDeliveryForm extends StatefulWidget {
  const AssetDeliveryForm({super.key});

  @override
  _AssetDeliveryFormState createState() => _AssetDeliveryFormState();
}

class _AssetDeliveryFormState extends State<AssetDeliveryForm> {
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String? _selectedEmployeeName;
  String? _selectedEmployeeImage;

  Future<void> _pickDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

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

  Future<void> _submitData() async {
    if (_itemNameController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _selectedEmployeeName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء ملء جميع الحقول')),
      );
      return;
    }

    DocumentReference employeeDoc = FirebaseFirestore.instance
        .collection('الموظفين')
        .doc(_selectedEmployeeName);

    try {
      await employeeDoc.update({
        'assets': FieldValue.arrayUnion([
          {
            'item_name': _itemNameController.text,
            'date_received': _dateController.text,
          }
        ])
      });

      await FirebaseFirestore.instance
          .collection('تقارير الاصول')
          .doc(_selectedEmployeeName)
          .collection('التقارير')
          .add({
        'job':
            'تم تسليم العهدة ${_itemNameController.text} للموظف ${_selectedEmployeeName} بتاريخ ${_dateController.text}'
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال البيانات بنجاح')),
      );

      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء إرسال البيانات')),
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
                  'تسليم العهدة',
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
                      _selectedEmployeeImage = employee['imageUrl'];
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
            TextField(
              controller: _itemNameController,
              decoration: const InputDecoration(
                labelText: 'اسم العهدة',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _pickDate(context),
              child: AbsorbPointer(
                child: TextField(
                  controller: _dateController,
                  decoration: const InputDecoration(
                    labelText: 'اختر التاريخ',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitData,
              child: const Text('إرسال'),
            ),
          ],
        ),
      ),
    );
  }
}
