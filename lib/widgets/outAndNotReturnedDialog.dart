import 'package:flutter/material.dart';
import 'package:hr_app/managers/firebaseHelper.dart';

class OutAndNotReturnedDialog extends StatelessWidget {
  final Map<String, dynamic> docs;

  const OutAndNotReturnedDialog({super.key, required this.docs});

  @override
  Widget build(BuildContext context) {
    final FirestoreManager _firestoreManager = FirestoreManager();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('خروج و لم يعد'),
        content: const Text('هل ترغب في تسجيل الموظف كـ "خرج و لم يعد"؟'),
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
                {"status": "خرج و لم يعد"},
              );
              Navigator.of(context).pop(); // Close the dialog after saving
            },
            child: const Text('تسجيل'),
          ),
        ],
      ),
    );
  }
}
