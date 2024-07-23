import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:intl/intl.dart';

class DeliverSalary extends StatefulWidget {
  const DeliverSalary({super.key});

  @override
  State<DeliverSalary> createState() => _DeliverSalaryState();
}

class _DeliverSalaryState extends State<DeliverSalary> {
  String? _selectedEmployeeId;
  String? _selectedEmployeeName;
  String? _selectedEmployeeImage;
  String? _selectedMonth;
  double _totalSalary = 0.0;

  Future<void> _fetchEmployeeDetails(String employeeName) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('الموظفين')
        .where('name', isEqualTo: employeeName)
        .get();
    if (result.docs.isNotEmpty) {
      final data = result.docs.first.data() as Map<String, dynamic>;
      setState(() {
        _selectedEmployeeId = data['name'];
        _selectedEmployeeName = data['name'];
        _selectedEmployeeImage = data['imageUrl'];
        _calculateTotalSalary(data);
      });
    }
  }

  void _calculateTotalSalary(Map<String, dynamic> data) {
    setState(() {
      _totalSalary = (data['mainSalary'] ?? 0.0) +
          (data['housingAllowance'] ?? 0.0) +
          (data['livingAllowance'] ?? 0.0) +
          (data['transportAllowance'] ?? 0.0) +
          (data['extraAllowance'] ?? 0.0);
    });
  }

  Future<void> _deliverSalary() async {
    if (_selectedEmployeeId != null && _selectedMonth != null) {
      try {
        await FirebaseFirestore.instance
            .collection('الموظفين')
            .doc(_selectedEmployeeId)
            .collection('رواتب')
            .doc(_selectedMonth)
            .set({
          'totalSalary': _totalSalary,
          'month': _selectedMonth,
          'dateDelivered': DateTime.now(),
        });
        await FirebaseFirestore.instance
            .collection('تقارير الماليات')
            .doc(_selectedEmployeeId)
            .collection('التقارير')
            .doc()
            .set({
          'job':
              "تم تسليم كامل مستحقات شهر $_selectedMonth و قدرها $_totalSalary ريال سعودي فقط لا غير",
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: const Text('تم تسليم راتب الموظف بنجاح')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء تسليم الراتب: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تحديد الموظف والشهر')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];

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
                  'تسليم راتب موظف',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('الموظفين')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const CircularProgressIndicator();
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
                        _selectedEmployeeName = item!['name'];
                        _selectedEmployeeImage = item['imageUrl'];
                        _fetchEmployeeDetails(_selectedEmployeeName!);
                      });
                    },
                    selectedItem: _selectedEmployeeName == null
                        ? null
                        : {
                            'name': _selectedEmployeeName,
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
              DropdownButton<String>(
                isExpanded: true,
                value: _selectedMonth,
                items: months.map((String month) {
                  return DropdownMenuItem<String>(
                    value: month,
                    child: Text(month),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedMonth = newValue;
                  });
                },
                hint: const Text('اختر الشهر'),
              ),
              const SizedBox(height: 20),
              Text(
                'إجمالي الراتب: ${_totalSalary.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _deliverSalary,
                  child: const Text('تسليم الراتب'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
