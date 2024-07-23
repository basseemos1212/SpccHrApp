import 'package:flutter/material.dart';
import 'package:hr_app/managers/firebaseHelper.dart';

class StopEmployeeDialog extends StatefulWidget {
  final Map<String, dynamic> docs;

  const StopEmployeeDialog({super.key, required this.docs});

  @override
  _StopEmployeeDialogState createState() => _StopEmployeeDialogState();
}

class _StopEmployeeDialogState extends State<StopEmployeeDialog> {
  final FirestoreManager _firestoreManager = FirestoreManager();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('إيقاف موظف عن العمل'),
        content: const Text('هل ترغب في إيقاف الموظف عن العمل؟'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog without saving
            },
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              _firestoreManager.updateDocument(
                "الموظفين",
                widget.docs['name'],
                {"status": "موقوف"},
              );
              Navigator.of(context).pop(); // Close the dialog after saving
            },
            child: const Text('إيقاف الموظف عن العمل'),
          ),
        ],
      ),
    );
  }
}
