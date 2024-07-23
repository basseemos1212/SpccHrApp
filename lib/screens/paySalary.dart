import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:hr_app/components/colors.dart';
import 'package:hr_app/managers/firebaseHelper.dart';
import 'package:hr_app/widgets/saveToDB.dart';

class PaySalaryDialog extends StatefulWidget {
  final dynamic doc;
  static String object_id = "";
  const PaySalaryDialog({super.key, this.doc});

  @override
  State<PaySalaryDialog> createState() => _PaySalaryDialogState();
}

class _PaySalaryDialogState extends State<PaySalaryDialog> {
  final FirestoreManager _firestoreManager = FirestoreManager();
  DateTime pickedDate = DateTime.now();
  String formattedDate = "";
  XFile? pickedFile;
  ParseFileBase? empl;
  ParseObject emplyeeGallery = ParseObject("s");

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text(
          'تسليم راتب لموظف',
          style: TextStyle(
            color: primaryColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );

                  if (selectedDate != null) {
                    setState(() {
                      pickedDate = selectedDate;
                      formattedDate =
                          "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                    });
                  }
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    'تاريخ تسليم الراتب: $formattedDate',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'المستحقات الشهريه: ${widget.doc['totalSalary']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              SaveToDB(
                buttonText: "finance",
                empl: empl,
                emplyeeGallery: emplyeeGallery,
                pickedFile: pickedFile,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              _firestoreManager.updateDocumentInCollection(
                  "تقارير الماليات", widget.doc['name'], "التقارير", "", {
                "job":
                    "تم تسليم كامل المستحقات لشهر ${pickedDate.month} يوم $formattedDate",
                "object_id": PaySalaryDialog.object_id
              });
              Navigator.of(context).pop();
            },
            child: const Text(
              'تم تسليم الراتب للموظف',
              style: TextStyle(fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'غلق',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
