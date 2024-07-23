import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hr_app/components/colors.dart';
import 'package:hr_app/managers/firebaseHelper.dart';

class HomeUltListScreem extends StatefulWidget {
  const HomeUltListScreem({super.key});

  @override
  State<HomeUltListScreem> createState() => _HomeUltListScreemState();
}

class _HomeUltListScreemState extends State<HomeUltListScreem> {
  List<Map<String, dynamic>> docs = [];
  int totalMounthPrice = 0;
  int totalYearPrice = 0;
  final FirestoreManager _firestoreManager =
      FirestoreManager(); // Instantiate FirestoreManager
  CollectionReference users =
      FirebaseFirestore.instance.collection('بدلات السكن');

  @override
  void initState() {
    super.initState();
    _firestoreManager
        .getAllDocuments('بدلات السكن')
        .then((value) => setState(() {
              docs = value;
              for (int i = 0; i < docs.length; i++) {
                if (docs[i]['سنوي']) {
                  totalYearPrice += docs[i]['المبلغ'] as int;
                } else {
                  totalMounthPrice += docs[i]['المبلغ'] as int;
                }
              }
            }))
        .then((value) => print(docs));
  }

  void _deleteMember(Map<String, dynamic> member) async {
    setState(() {
      docs.remove(member);
      if (member['سنوي']) {
        totalYearPrice -= member['المبلغ'] as int;
      } else {
        totalMounthPrice -= member['المبلغ'] as int;
      }
    });
    await _firestoreManager.deleteDocument('بدلات السكن', member['name']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomTable(
        data: docs,
        totalMounthPrice: totalMounthPrice,
        totalYearPrice: totalYearPrice,
        onDelete: _deleteMember,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddMemberDialog(
              onAdd: (newMember) {
                setState(() {
                  docs.add(newMember);
                  if (newMember['سنوي']) {
                    totalYearPrice += newMember['المبلغ'] as int;
                  } else {
                    totalMounthPrice += newMember['المبلغ'] as int;
                  }
                });
                _firestoreManager.addDocument('بدلات السكن', newMember);
              },
            ),
          );
        },
        backgroundColor: primaryColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

class AddMemberDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdd;

  const AddMemberDialog({super.key, required this.onAdd});

  @override
  _AddMemberDialogState createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<AddMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool isYearly = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('اضافه بدل سكن جديد'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'الاسم'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ادخل الاسم';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'المبلغ'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ادخل المبلغ';
                  }
                  return null;
                },
              ),
              CheckboxListTile(
                title: const Text('سنوي'),
                value: isYearly,
                onChanged: (value) {
                  setState(() {
                    isYearly = value!;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('غلق'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final newMember = {
                  'name': _nameController.text,
                  'المبلغ': int.parse(_amountController.text),
                  'سنوي': isYearly,
                };
                widget.onAdd(newMember);
                Navigator.of(context).pop();
              }
            },
            child: const Text('اضافه'),
          ),
        ],
      ),
    );
  }
}

class CustomTable extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final int totalMounthPrice;
  final int totalYearPrice;
  final Function(Map<String, dynamic>) onDelete;

  const CustomTable(
      {super.key,
      required this.data,
      required this.totalMounthPrice,
      required this.totalYearPrice,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DataTable(
              columns: const [
                DataColumn(
                    label: Text(
                  'الاسم',
                  style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                )),
                DataColumn(
                    label: Text(
                  'بدل السكن',
                  style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                )),
                DataColumn(
                    label: Text(
                  'شهريا/سنويا',
                  style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                )),
                DataColumn(
                    label: Text(
                  'حذف',
                  style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                )),
              ],
              rows: data.map((map) {
                return DataRow(
                  cells: [
                    DataCell(Text(
                      map['name'] ?? '',
                      style: const TextStyle(fontSize: 18),
                    )), // Display data in Text widget
                    DataCell(Text(
                      map['المبلغ'].toString(),
                      style: const TextStyle(fontSize: 18),
                    )), // Display data in Text widget
                    DataCell(Text(
                      map["سنوي"] ? "سنويا" : "شهريا",
                      style: const TextStyle(fontSize: 18),
                    )), // Display data in Text widget
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => onDelete(map),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            DataTable(
              columns: const [
                DataColumn(
                    label: Text(
                  'اجمالي المبلغ',
                  style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                )),
                DataColumn(
                    label: Text(
                  'شهريا/سنويا',
                  style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                )),
              ],
              rows: [
                DataRow(cells: [
                  DataCell(Text(
                    totalMounthPrice.toString(),
                    style: const TextStyle(fontSize: 18),
                  )),
                  const DataCell(Text(
                    "شهريا",
                    style: TextStyle(fontSize: 18),
                  )), ////
                ]),
                DataRow(cells: [
                  DataCell(Text(
                    totalYearPrice.toString(),
                    style: const TextStyle(fontSize: 18),
                  )),
                  const DataCell(Text(
                    "سنويا",
                    style: TextStyle(fontSize: 18),
                  )), ////
                ])
              ],
            ),
          ],
        ),
      ],
    );
  }
}
