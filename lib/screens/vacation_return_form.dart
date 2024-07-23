import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';

class VacationReturnForm extends StatefulWidget {
  const VacationReturnForm({super.key});

  @override
  _VacationReturnFormState createState() => _VacationReturnFormState();
}

class _VacationReturnFormState extends State<VacationReturnForm> {
  final TextEditingController _returnDateController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _totalDaysController = TextEditingController();
  final TextEditingController _paidDaysController = TextEditingController();
  final TextEditingController _entitledPaidDaysController =
      TextEditingController();

  String? _selectedEmployeeId;
  String? _selectedEmployeeName;
  String? _selectedEmployeeImage;
  int yearlyVacationDays = 0;
  DateTime? _returnDate;
  DateTime? _startDate;
  DateTime? _endDate;
  int _totalVacationDays = 0;
  int _entitledPaidVacationDays = 0;
  Map<String, dynamic>? _selectedVacationData;

  Future<void> _pickDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
        if (controller == _returnDateController) {
          _returnDate = pickedDate;
        }
      });
    }
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
        _calculateEntitledPaidVacationDays(employeeData: data);
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

  Future<List<Map<String, dynamic>>> _fetchVacations() async {
    if (_selectedEmployeeId == null) {
      return [];
    }
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('الموظفين')
        .doc(_selectedEmployeeId)
        .collection('اجازات')
        .where('status', isEqualTo: 'قيد الانتظار')
        .get();
    return result.docs
        .map((doc) => {
              'id': doc.id,
              'data': doc.data() as Map<String, dynamic>,
            })
        .toList();
  }

  void _calculateEntitledPaidVacationDays(
      {Map<String, dynamic>? employeeData}) {
    if (employeeData == null && _selectedEmployeeId != null) {
      FirebaseFirestore.instance
          .collection('الموظفين')
          .doc(_selectedEmployeeId)
          .get()
          .then((doc) {
        if (doc.exists) {
          employeeData = doc.data() as Map<String, dynamic>;
          _calculateEntitledPaidVacationDays(employeeData: employeeData);
        }
      });
      return;
    }
    if (employeeData != null) {
      DateTime projectStartDate =
          DateFormat('yyyy-MM-dd').parse(employeeData['projectStartWork']);
      DateTime today = DateTime.now();
      int totalDays = today.difference(projectStartDate).inDays;
      int totalMonths = (totalDays / 30).ceil();
      yearlyVacationDays = employeeData['vacationDuration'] is int
          ? employeeData['vacationDuration']
          : int.tryParse(employeeData['vacationDuration']) ?? 0;
      _entitledPaidVacationDays =
          ((yearlyVacationDays * totalMonths) / 12).round();
      _entitledPaidDaysController.text = _entitledPaidVacationDays.toString();
    }
  }

  Future<void> _confirmVacationReturn() async {
    if (_selectedEmployeeId == null || _returnDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء ملء جميع الحقول')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('الموظفين')
          .doc(_selectedEmployeeId)
          .collection('اجازات')
          .doc(_selectedVacationData!['id'])
          .update({
        'status': 'مكتملة',
        'returnDate': _returnDateController.text,
      });

      await FirebaseFirestore.instance
          .collection('تقارير الاجازات')
          .doc(_selectedEmployeeId)
          .collection('التقارير')
          .add({
        'job':
            "تم تسجيل عودة الموظف ${_selectedEmployeeName} من إجازته التي بدأت في ${_selectedVacationData!['startDate']} وانتهت في ${_selectedVacationData!['endDate']}. تاريخ العودة هو ${_returnDateController.text}.",
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تسجيل العودة بنجاح')),
      );

      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء تسجيل العودة: $error')),
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
                  'تسجيل العودة من الإجازة',
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
                future: _fetchVacations(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const CircularProgressIndicator();
                  var vacationList = snapshot.data!;
                  return DropdownSearch<Map<String, dynamic>>(
                    items: vacationList,
                    itemAsString: (item) {
                      return "إجازة من ${item['data']['startDate']} إلى ${item['data']['endDate']}";
                    },
                    onChanged: (item) {
                      setState(() {
                        _selectedVacationData = item!['data'];
                        _selectedVacationData!['id'] = item['id'];
                        _startDateController.text =
                            item['data']['startDate'] ?? '';
                        _endDateController.text = item['data']['endDate'] ?? '';
                        _totalDaysController.text =
                            item['data']['totalVacationDays'].toString();
                        _paidDaysController.text =
                            item['data']['paidDays'].toString();
                      });
                    },
                    selectedItem: _selectedVacationData == null
                        ? null
                        : {
                            'id': _selectedVacationData!['id'],
                            'data': _selectedVacationData,
                          },
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: "اختر الإجازة",
                      ),
                    ),
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      itemBuilder: (context, item, isSelected) {
                        return ListTile(
                          title: Text(
                              "إجازة من ${item['data']['startDate']} إلى ${item['data']['endDate']}"),
                        );
                      },
                    ),
                  );
                },
              ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _pickDate(context, _returnDateController),
              child: AbsorbPointer(
                child: TextField(
                  controller: _returnDateController,
                  decoration: const InputDecoration(
                    labelText: 'اختر تاريخ العودة',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _startDateController,
              decoration: const InputDecoration(
                labelText: 'تاريخ بدء الإجازة',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _endDateController,
              decoration: const InputDecoration(
                labelText: 'تاريخ انتهاء الإجازة',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _totalDaysController,
              decoration: const InputDecoration(
                labelText: 'عدد أيام الإجازة',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _paidDaysController,
              decoration: const InputDecoration(
                labelText: 'عدد الأيام المدفوعة',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _confirmVacationReturn,
              child: const Text('تسجيل العودة'),
            ),
          ],
        ),
      ),
    );
  }
}
