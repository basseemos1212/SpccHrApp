import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';

class VacationRequestForm extends StatefulWidget {
  const VacationRequestForm({super.key});

  @override
  _VacationRequestFormState createState() => _VacationRequestFormState();
}

class _VacationRequestFormState extends State<VacationRequestForm> {
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
  DateTime? _startDate;
  DateTime? _endDate;
  int _totalVacationDays = 0;
  int _entitledPaidVacationDays = 0;

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
        if (controller == _startDateController) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
        }
        if (_startDate != null && _endDate != null) {
          _totalVacationDays = _endDate!.difference(_startDate!).inDays + 1;
          _totalDaysController.text = _totalVacationDays.toString();
          _calculateEntitledPaidVacationDays();
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
    if (_startDate != null && employeeData != null) {
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

  Future<void> _submitVacationRequest() async {
    if (_selectedEmployeeId == null ||
        _startDate == null ||
        _endDate == null ||
        _paidDaysController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء ملء جميع الحقول')),
      );
      return;
    }

    try {
      int requestedPaidDays = int.parse(_paidDaysController.text);
      int remainingPaidDays = yearlyVacationDays - requestedPaidDays;

      await FirebaseFirestore.instance
          .collection('الموظفين')
          .doc(_selectedEmployeeId)
          .update({
        'vacationDuration': remainingPaidDays,
      });

      await FirebaseFirestore.instance
          .collection('الموظفين')
          .doc(_selectedEmployeeId)
          .collection('اجازات')
          .add({
        'startDate': _startDateController.text,
        'endDate': _endDateController.text,
        'totalVacationDays': _totalVacationDays,
        'paidDays': _paidDaysController.text,
        'status': 'قيد الانتظار',
      });

      await FirebaseFirestore.instance
          .collection('تقارير الاجازات')
          .doc(_selectedEmployeeId)
          .collection('التقارير')
          .add({
        'job':
            "تم تقديم طلب إجازة بواسطة ${_selectedEmployeeName}، بتاريخ بدء الإجازة ${_startDateController.text} وتاريخ العودة ${_endDateController.text}. إجمالي عدد أيام الإجازة هو ${_totalVacationDays} يومًا، منها ${_paidDaysController.text} يومًا مدفوعًا. تبقى لدى الموظف ${_entitledPaidVacationDays - int.parse(_paidDaysController.text)} يومًا مدفوعًا مستحقًا بعد هذه الإجازة.",
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال الطلب بنجاح')),
      );

      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء إرسال الطلب: $error')),
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
                  'طلب إجازة',
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
            GestureDetector(
              onTap: () => _pickDate(context, _startDateController),
              child: AbsorbPointer(
                child: TextField(
                  controller: _startDateController,
                  decoration: const InputDecoration(
                    labelText: 'اختر تاريخ الذهاب',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _pickDate(context, _endDateController),
              child: AbsorbPointer(
                child: TextField(
                  controller: _endDateController,
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
              controller: _totalDaysController,
              decoration: const InputDecoration(
                labelText: 'عدد أيام الإجازة',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _entitledPaidDaysController,
              decoration: const InputDecoration(
                labelText: 'عدد الأيام المدفوعة المستحقة',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _paidDaysController,
              decoration: const InputDecoration(
                labelText: 'عدد الأيام المدفوعة المطلوبة',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  // Handle any required actions on value change
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitVacationRequest,
              child: const Text('تسجيل الطلب'),
            ),
          ],
        ),
      ),
    );
  }
}
