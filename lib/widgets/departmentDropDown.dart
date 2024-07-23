import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DepartmentsDropdown extends StatefulWidget {
  final TextEditingController textEditingController;
  final void Function(String selectedDepartment)? onChanged;

  const DepartmentsDropdown({
    Key? key,
    required this.textEditingController,
    this.onChanged,
  }) : super(key: key);

  @override
  _DepartmentsDropdownState createState() => _DepartmentsDropdownState();
}

class _DepartmentsDropdownState extends State<DepartmentsDropdown> {
  String? _selectedDepartment;
  List<String> departmentList = [];

  @override
  void initState() {
    super.initState();
    _fetchDepartments();
  }

  Future<void> _fetchDepartments() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('إدارات').get();
    setState(() {
      departmentList =
          querySnapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              height: 50, // Set the height as per your requirement
              width: MediaQuery.of(context).size.width * 0.21,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(15), // Set the border radius
                border: Border.all(
                  width: 0.5, // Set the border width
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: DropdownButton<String>(
                  value: _selectedDepartment,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedDepartment = newValue;
                      widget.textEditingController.text =
                          _selectedDepartment ?? '';

                      if (widget.onChanged != null) {
                        widget.onChanged!(newValue!);
                      }
                    });
                  },
                  items: departmentList.map((department) {
                    return DropdownMenuItem<String>(
                      value: department,
                      child: Text(department),
                    );
                  }).toList(),
                  hint: const Text('اختيار الإدارة'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
