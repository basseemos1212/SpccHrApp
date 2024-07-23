import 'package:flutter/material.dart';
import 'package:hr_app/managers/firebaseHelper.dart';

class CustomDatePickerDialog extends StatefulWidget {
  final Map<String, dynamic> doc;

  const CustomDatePickerDialog({Key? key, required this.doc}) : super(key: key);

  @override
  _CustomDatePickerDialogState createState() => _CustomDatePickerDialogState();
}

class _CustomDatePickerDialogState extends State<CustomDatePickerDialog> {
  late String selectedDate;
  FirestoreManager _firestoreManager = FirestoreManager();

  @override
  void initState() {
    super.initState();
    selectedDate = ''; // Initialize with the current date or an empty string
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: Text('اختر تاريخ الهروب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(selectedDate),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _selectDate(context);
              },
              child: Text('أختر التاريخ'),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Return the selected date
            },
            child: Text(' غلق'),
          ),
          TextButton(
            onPressed: () {
              _firestoreManager.updateDocument("الموظفين", widget.doc['name'],
                  {"status": "هروب", "runDate": selectedDate});
              Navigator.of(context)
                  .pop(selectedDate); // Return the selected date
            },
            child: Text('تسجيل الهروب'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate =
            "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
      });
    }
  }
}
