import 'package:flutter/material.dart';
import 'package:hr_app/managers/firebaseHelper.dart';

class ReActivateDialog extends StatelessWidget {
  final Map<String, dynamic> docs;
  ReActivateDialog({super.key, required this.docs});
  FirestoreManager _firestoreManager = FirestoreManager();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('تنشيط موظف'),
        content: const Text('هل ترغب في تنشيط الموظف؟'),
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
                docs['name'],
                {"status": "نشط"},
              );
              Navigator.of(context).pop(); // Close the dialog after saving
            },
            child: const Text('تنشيط الموظف'),
          ),
        ],
      ),
    );
  }
}
