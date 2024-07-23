import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';

class UpgradeSalary extends StatefulWidget {
  const UpgradeSalary({super.key});

  @override
  State<UpgradeSalary> createState() => _UpgradeSalaryState();
}

class _UpgradeSalaryState extends State<UpgradeSalary> {
  final _formKey = GlobalKey<FormState>();
  final _mainSalaryController = TextEditingController();
  final _housingAllowanceController = TextEditingController();
  final _livingAllowanceController = TextEditingController();
  final _transportAllowanceController = TextEditingController();
  final _extraAllowanceController = TextEditingController();

  String? _selectedEmployeeId;
  String? _selectedEmployeeName;
  String? _selectedEmployeeImage;
  double _totalSalary = 0.0;

  @override
  void dispose() {
    _mainSalaryController.dispose();
    _housingAllowanceController.dispose();
    _livingAllowanceController.dispose();
    _transportAllowanceController.dispose();
    _extraAllowanceController.dispose();
    super.dispose();
  }

  Future<void> _fetchSalaryDetails(String employeeId) async {
    final doc = await FirebaseFirestore.instance
        .collection('الموظفين')
        .doc(employeeId)
        .get();

    if (doc.exists) {
      setState(() {
        _mainSalaryController.text = doc['mainSalary']?.toString() ?? '';
        _housingAllowanceController.text =
            doc['housingAllowance']?.toString() ?? '';
        _livingAllowanceController.text =
            doc['livingAllowance']?.toString() ?? '';
        _transportAllowanceController.text =
            doc['transportAllowance']?.toString() ?? '';
        _extraAllowanceController.text =
            doc['extraAllowance']?.toString() ?? '';
        _updateTotalSalary();
      });
    }
  }

  void _updateTotalSalary() {
    setState(() {
      _totalSalary = (_parseDouble(_mainSalaryController.text) +
          _parseDouble(_housingAllowanceController.text) +
          _parseDouble(_livingAllowanceController.text) +
          _parseDouble(_transportAllowanceController.text) +
          _parseDouble(_extraAllowanceController.text));
    });
  }

  double _parseDouble(String value) {
    return double.tryParse(value) ?? 0.0;
  }

  Future<void> _updateSalaryDetails() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('الموظفين')
            .doc(_selectedEmployeeId)
            .update({
          'mainSalary': double.parse(_mainSalaryController.text),
          'housingAllowance': double.parse(_housingAllowanceController.text),
          'livingAllowance': double.parse(_livingAllowanceController.text),
          'transportAllowance':
              double.parse(_transportAllowanceController.text),
          'extraAllowance': double.parse(_extraAllowanceController.text),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم تحديث بيانات المرتب بنجاح')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء تحديث البيانات: $e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Initial fetch if needed, otherwise employee selection will trigger the fetch
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
                  'ترقيه راتب موظف',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('الموظفين')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return CircularProgressIndicator();
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
                          _selectedEmployeeId = item!['id'];
                          _selectedEmployeeName = item['name'];
                          _selectedEmployeeImage = item['imageUrl'];
                          _fetchSalaryDetails(_selectedEmployeeId!);
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
                          contentPadding: EdgeInsets.symmetric(
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
                            contentPadding: EdgeInsets.symmetric(
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
                if (_selectedEmployeeId != null) ...[
                  SizedBox(height: 20),
                  _buildSalaryField('الراتب الأساسي', _mainSalaryController),
                  _buildSalaryField('بدل السكن', _housingAllowanceController),
                  _buildSalaryField('بدل المعيشة', _livingAllowanceController),
                  _buildSalaryField(
                      'بدل المواصلات', _transportAllowanceController),
                  _buildSalaryField(
                      'بدل إضافي مقطوع', _extraAllowanceController),
                  SizedBox(height: 20),
                  Text(
                    'إجمالي الراتب: ${_totalSalary.toStringAsFixed(2)}',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _updateSalaryDetails,
                      child: Text('تحديث الراتب'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSalaryField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        ),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'الرجاء إدخال $label';
          }
          if (double.tryParse(value) == null) {
            return 'الرجاء إدخال رقم صحيح';
          }
          return null;
        },
        onChanged: (value) {
          _updateTotalSalary();
        },
      ),
    );
  }
}
