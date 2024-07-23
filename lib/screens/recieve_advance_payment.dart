import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:intl/intl.dart';

class ReceiveAdvancePayment extends StatefulWidget {
  const ReceiveAdvancePayment({super.key});

  @override
  State<ReceiveAdvancePayment> createState() => _ReceiveAdvancePaymentState();
}

class _ReceiveAdvancePaymentState extends State<ReceiveAdvancePayment> {
  String? _selectedEmployeeId;
  String? _selectedEmployeeName;
  String? _selectedAdvancePaymentId;
  Map<String, dynamic>? _selectedAdvancePaymentData;

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
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAdvancePayments() async {
    if (_selectedEmployeeId == null) {
      return [];
    }
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('الموظفين')
        .doc(_selectedEmployeeId)
        .collection('سلف')
        .where('status', isEqualTo: 'pending')
        .get();
    return result.docs
        .map((doc) => {
              'id': doc.id,
              'data': doc.data() as Map<String, dynamic>,
            })
        .toList();
  }

  Future<void> _confirmAdvancePaymentReceipt() async {
    if (_selectedEmployeeId != null && _selectedAdvancePaymentId != null) {
      try {
        final advancePayment = _selectedAdvancePaymentData!;
        final totalAmount = advancePayment['advancePayment'];
        final remainingAmount =
            advancePayment['remainingAmount'] ?? totalAmount;
        final paymentMethod = advancePayment['paymentMethod'];
        final numberOfInstallments = advancePayment['numberOfInstallments'];
        final installmentAmount = totalAmount / numberOfInstallments;
        final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

        if (paymentMethod == 'أكثر من دفعه') {
          final newRemainingAmount = remainingAmount - installmentAmount;
          await FirebaseFirestore.instance
              .collection('الموظفين')
              .doc(_selectedEmployeeId)
              .collection('سلف')
              .doc(_selectedAdvancePaymentId)
              .update({
            'remainingAmount': newRemainingAmount,
            'status': newRemainingAmount <= 0 ? 'مدفوعة' : 'pending',
          });

          await FirebaseFirestore.instance
              .collection('تقارير الماليات')
              .doc(_selectedEmployeeId)
              .collection('التقارير')
              .add({
            "job":
                "تم دفع قسط قدره ${installmentAmount.toStringAsFixed(2)} من سلفة قدرها ${totalAmount.toStringAsFixed(2)} في ${currentDate}. المتبقي ${newRemainingAmount.toStringAsFixed(2)}.",
            "date": currentDate,
          });
        } else {
          await FirebaseFirestore.instance
              .collection('الموظفين')
              .doc(_selectedEmployeeId)
              .collection('سلف')
              .doc(_selectedAdvancePaymentId)
              .update({
            'status': 'مدفوعة',
            'remainingAmount': 0,
          });

          await FirebaseFirestore.instance
              .collection('تقارير الماليات')
              .doc(_selectedEmployeeId)
              .collection('التقارير')
              .add({
            "job":
                "تم دفع السلفة بالكامل بقيمة ${totalAmount.toStringAsFixed(2)} في ${currentDate}.",
            "date": currentDate,
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم استلام السلفة بنجاح')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء استلام السلفة: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار موظف وسلفة')),
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
                  'استلام السلفة',
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
              if (_selectedEmployeeId != null)
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchAdvancePayments(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return const CircularProgressIndicator();
                    var advancePaymentList = snapshot.data!;
                    return DropdownSearch<Map<String, dynamic>>(
                      items: advancePaymentList,
                      itemAsString: (item) {
                        return "";
                      },
                      onChanged: (item) {
                        setState(() {
                          _selectedAdvancePaymentId = item!['id'];
                          _selectedAdvancePaymentData = item['data'];
                        });
                      },
                      selectedItem: _selectedAdvancePaymentId == null
                          ? null
                          : {
                              'id': _selectedAdvancePaymentId,
                            },
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          hintText: 'اختر السلفة',
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
                              title: Text(
                                  "سلفة بقيمة ${item['data']['advancePayment']} بتاريخ ${item['data']['requestSubmissionDate']}"),
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
              if (_selectedAdvancePaymentData != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "قيمة السلفة: ${_selectedAdvancePaymentData?['advancePayment'] ?? 'غير متوفر'}",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "تاريخ تقديم الطلب: ${_selectedAdvancePaymentData?['requestSubmissionDate'] ?? 'غير متوفر'}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "تاريخ موافقة الطلب: ${_selectedAdvancePaymentData?['approvalDate'] ?? 'غير متوفر'}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "طريقة السداد: ${_selectedAdvancePaymentData?['paymentMethod'] ?? 'غير متوفر'}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (_selectedAdvancePaymentData!['paymentMethod'] ==
                        'أكثر من دفعه')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            "عدد الدفعات: ${_selectedAdvancePaymentData!['numberOfInstallments'] ?? 'غير متوفر'}",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "المدة بين الدفعات: ${_selectedAdvancePaymentData!['installmentDuration'] ?? 'غير متوفر'}",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "قيمة كل دفعة: ${(double.parse(_selectedAdvancePaymentData!['advancePayment'].toString()) / _selectedAdvancePaymentData!['numberOfInstallments']).toStringAsFixed(2)}",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: _confirmAdvancePaymentReceipt,
                        child: const Text('تأكيد استلام السلفة'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
