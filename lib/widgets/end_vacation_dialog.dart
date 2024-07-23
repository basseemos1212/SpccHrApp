import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:hr_app/components/colors.dart';
import 'package:hr_app/managers/firebaseHelper.dart';
import 'package:hr_app/screens/paySalary.dart';
import 'package:hr_app/widgets/saveToDB.dart';
import 'package:intl/intl.dart';

class EndVacationDialog extends StatefulWidget {
  final dynamic doc;

  const EndVacationDialog({Key? key, required this.doc}) : super(key: key);

  @override
  State<EndVacationDialog> createState() => _EndVacationDialogState();
}

class _EndVacationDialogState extends State<EndVacationDialog> {
  DateTime pickedDate = DateTime.now();
  String formattedDate = '';
  String vacationDate = '';
  XFile? pickedFile;
  ParseFileBase? empl;
  ParseObject emplyeeGallery = ParseObject("s");

  final FirestoreManager _firestoreManager = FirestoreManager();
  TextEditingController reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
    _fetchVacationDate();
  }

  Future<void> _fetchVacationDate() async {
    vacationDate = await _firestoreManager.getFieldInSubcollection(
      "طلبات الاجازات",
      widget.doc['name'],
      "الطلبات",
      widget.doc['name'],
      'leave_date',
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'انهاء اجازة للموظف',
        style: TextStyle(
          color: primaryColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDateButton('تاريخ العوده', formattedDate, (date) {
            setState(() {
              formattedDate = date;
            });
          }),
          const SizedBox(height: 16),
          SaveToDB(
            buttonText: "vacation",
            emplyeeGallery: emplyeeGallery,
            empl: empl,
            pickedFile: pickedFile,
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _submitRequest,
          child: const Text('ارسال الطلب'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('الغاء'),
        ),
      ],
    );
  }

  Widget _buildDateButton(
      String label, String date, Function(String) onDateSelected) {
    return ElevatedButton(
      onPressed: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );

        if (picked != null) {
          String formattedDate = DateFormat('dd/MM/yyyy').format(picked);
          onDateSelected(formattedDate);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          '$label: $date',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  void _submitRequest() {
    int vacationDuration = calculateDateDifference(vacationDate, formattedDate);

    _firestoreManager.updateDocumentInCollection(
      "تقارير الاجازات",
      widget.doc['name'],
      "التقارير",
      "",
      {
        "object_id": PaySalaryDialog.object_id,
        "job":
            "تم عوده ${widget.doc['name']} بعد قضاء اجازه مدتها $vacationDuration يوم و عاد في تاريخ $formattedDate",
      },
    );

    _firestoreManager.updateDocument(
      "الموظفين",
      widget.doc['name'],
      {"status": "نشط"},
    );

    Navigator.pop(context);
  }

  int calculateDateDifference(String startDate, String endDate) {
    DateTime startDateObj = DateFormat('dd/MM/yyyy').parse(startDate);
    DateTime endDateObj = DateFormat('dd/MM/yyyy').parse(endDate);
    Duration difference = endDateObj.difference(startDateObj);

    return difference.inDays >= 0 ? difference.inDays : 0;
  }
}
