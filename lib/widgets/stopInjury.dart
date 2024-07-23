import 'package:flutter/material.dart';
import 'package:hr_app/components/colors.dart';
import 'package:hr_app/managers/firebaseHelper.dart';

class StopInjuryDialog extends StatefulWidget {
  final Map<String, dynamic> docs;

  const StopInjuryDialog({super.key, required this.docs});
  @override
  _StopInjuryDialogState createState() => _StopInjuryDialogState();
}

class _StopInjuryDialogState extends State<StopInjuryDialog> {
  final FirestoreManager _firestoreManager = FirestoreManager();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('إيقاف الإصابة في العمل'),
        content: const Text('هل ترغب في إيقاف الإصابة في العمل لهذا الموظف؟'),
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
                {"status": "نشط"},
              );
              Navigator.of(context).pop(); // Close the dialog after saving
            },
            child: const Text('إيقاف الإصابة في العمل'),
          ),
        ],
      ),
    );
  }
}
