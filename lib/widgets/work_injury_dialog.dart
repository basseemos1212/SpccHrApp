import 'package:flutter/material.dart';
import 'package:hr_app/components/colors.dart';
import 'package:hr_app/managers/firebaseHelper.dart';

class InjuryDialog extends StatefulWidget {
  final Map<String, dynamic> docs;

  const InjuryDialog({super.key, required this.docs});
  @override
  _InjuryDialogState createState() => _InjuryDialogState();
}

class _InjuryDialogState extends State<InjuryDialog> {
  final FirestoreManager _firestoreManager = FirestoreManager();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('تسجيل اصابة عمل'),
        content: const Text('هل تريد تسجيل إصابة عمل لهذا الموظف؟'),
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
                {"status": "اصابه عمل"},
              );
              Navigator.of(context).pop(); // Close the dialog after saving
            },
            child: const Text('تسجيل اصابه عمل موظف'),
          ),
        ],
      ),
    );
  }
}
