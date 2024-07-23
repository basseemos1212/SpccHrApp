import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:intl/intl.dart';

class DeliverAdvancePayment extends StatefulWidget {
  const DeliverAdvancePayment({super.key});

  @override
  State<DeliverAdvancePayment> createState() => _DeliverAdvancePaymentState();
}

class _DeliverAdvancePaymentState extends State<DeliverAdvancePayment> {
  String? _selectedEmployeeId;
  String? _selectedEmployeeName;
  String? _selectedEmployeeImage;

  final _advancePaymentController = TextEditingController();
  DateTime? _requestSubmissionDate;
  DateTime? _approvalDate;
  String? _paymentMethod;
  int? _numberOfInstallments;
  String? _installmentDuration;

  final List<String> paymentMethods = ['دفعه واحدة', 'أكثر من دفعه'];
  final List<String> installmentDurations = ['شهر', 'شهرين'];

  @override
  void dispose() {
    _advancePaymentController.dispose();
    super.dispose();
  }

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
      });
    }
  }

  Future<void> _pickDate(BuildContext context, bool isSubmissionDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isSubmissionDate) {
          _requestSubmissionDate = picked;
        } else {
          _approvalDate = picked;
        }
      });
    }
  }

  Future<void> _deliverAdvancePayment() async {
    if (_selectedEmployeeId != null &&
        _advancePaymentController.text.isNotEmpty &&
        _requestSubmissionDate != null &&
        _approvalDate != null &&
        _paymentMethod != null) {
      try {
        double advancePayment = double.parse(_advancePaymentController.text);
        Map<String, dynamic> paymentData = {
          'advancePayment': advancePayment,
          'requestSubmissionDate':
              DateFormat('yyyy-MM-dd').format(_requestSubmissionDate!),
          'approvalDate': DateFormat('yyyy-MM-dd').format(_approvalDate!),
          'paymentMethod': _paymentMethod,
        };

        String report =
            "تم اعطاء الموظف سلفه قدرها ${_advancePaymentController.text} و ذلك بعد ان تم تقديم الطلب في ${DateFormat('yyyy-MM-dd').format(_requestSubmissionDate!)} و تم الموافقه عليه من قبل مجلس الاداره في ${DateFormat('yyyy-MM-dd').format(_approvalDate!)}.";

        if (_paymentMethod == 'أكثر من دفعه') {
          paymentData['numberOfInstallments'] = _numberOfInstallments;
          paymentData['installmentDuration'] = _installmentDuration;
          double installmentAmount =
              advancePayment / (_numberOfInstallments ?? 1);

          report +=
              " سيتم تسليم السلفة على ${_numberOfInstallments} دفعات، والمدة بين كل دفعة هي ${_installmentDuration} ، وثمن كل دفعة هو ${installmentAmount.toStringAsFixed(2)} ريال سعودي لا غير.";
        } else {
          report += " سيتم تسليم السلفة على دفعة واحدة.";
        }

        await FirebaseFirestore.instance
            .collection('تقارير الماليات')
            .doc(_selectedEmployeeId)
            .collection('التقارير')
            .add({
          'job': report,
        });

        await FirebaseFirestore.instance
            .collection('الموظفين')
            .doc(_selectedEmployeeId)
            .collection('سلف')
            .add(paymentData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم تسليم السلفه بنجاح')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء تسليم السلفه: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى إدخال جميع الحقول المطلوبة')),
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
                  'تسليم سلفه للموظف',
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
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              SizedBox(height: 20),
              TextFormField(
                controller: _advancePaymentController,
                decoration: InputDecoration(
                  labelText: 'قيمه السلفه',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () => _pickDate(context, true),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _requestSubmissionDate == null
                        ? 'تاريخ تقديم الطلب'
                        : DateFormat('yyyy-MM-dd')
                            .format(_requestSubmissionDate!),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () => _pickDate(context, false),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _approvalDate == null
                        ? 'تاريخ موافقه الطلب'
                        : DateFormat('yyyy-MM-dd').format(_approvalDate!),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 20),
              DropdownButton<String>(
                isExpanded: true,
                value: _paymentMethod,
                items: paymentMethods.map((String method) {
                  return DropdownMenuItem<String>(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _paymentMethod = newValue;
                  });
                },
                hint: Text('اختر طريقه السداد'),
              ),
              if (_paymentMethod == 'أكثر من دفعه') ...[
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'عدد الدفعات',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _numberOfInstallments = int.tryParse(value);
                  },
                ),
                SizedBox(height: 20),
                DropdownButton<String>(
                  isExpanded: true,
                  value: _installmentDuration,
                  items: installmentDurations.map((String duration) {
                    return DropdownMenuItem<String>(
                      value: duration,
                      child: Text(duration),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _installmentDuration = newValue;
                    });
                  },
                  hint: Text('اختر المدة بين الدفعات'),
                ),
              ],
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _deliverAdvancePayment,
                  child: Text('تسليم السلفه'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
