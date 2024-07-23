import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:hr_app/components/colors.dart';
import 'package:hr_app/managers/firebaseHelper.dart';
import 'package:hr_app/screens/paySalary.dart';
import 'package:hr_app/widgets/saveToDB.dart';
import 'package:intl/intl.dart';

class RequestVacationDialog extends StatefulWidget {
  final dynamic doc;

  const RequestVacationDialog({Key? key, required this.doc}) : super(key: key);

  @override
  State<RequestVacationDialog> createState() => _RequestVacationDialogState();
}

class _RequestVacationDialogState extends State<RequestVacationDialog> {
  String leaveType = 'اجازة سنويه';
  String? reason;
  DateTime pickedDate = DateTime.now();
  String formattedDate = '';
  int? specifiedDays;
  XFile? pickedFile;
  ParseFileBase? empl;
  ParseObject emplyeeGallery = ParseObject("s");
  final FirestoreManager _firestoreManager = FirestoreManager();
  TextEditingController specifiedDaysController = TextEditingController();

  late int availableVacationDays;

  @override
  void initState() {
    super.initState();
    formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
    availableVacationDays = _calculateAvailableVacationDays();
  }

  int _calculateAvailableVacationDays() {
    String startWorkDateString = widget.doc['projectStartWork'];
    DateTime startWorkDate =
        DateFormat('dd/MM/yyyy').parse(startWorkDateString);
    DateTime today = DateTime.now();

    int totalDays = today.difference(startWorkDate).inDays;
    int totalMonths =
        (totalDays / 30).ceil(); // Convert days to months and round up
    if ((totalMonths * 1.75).ceil() > int.parse(widget.doc['vacationTime'])) {
      return int.parse(widget.doc['vacationTime']);
    } else {
      return (totalMonths * 1.75)
          .ceil(); // Convert months to years and round down
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'طلب اجازة للموظف',
        style: TextStyle(
          color: primaryColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDateButton('تاريخ الاجازة', formattedDate, (date) {
                setState(() {
                  formattedDate = date;
                });
              }),
              const SizedBox(height: 16),
              _buildDropdownButton('نوع الاجازة', leaveType, (newValue) {
                setState(() {
                  leaveType = newValue!;
                });
              }, <String>['اجازة مرضية', 'اجازة سنويه', 'اجازة استثنائية']),
              if (leaveType == 'اجازة سنويه') ...[
                const SizedBox(height: 16),
                Text(
                  'الايام المتاحه من الاجازه السنويه: $availableVacationDays',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: specifiedDaysController,
                  label: 'الايام المحدده من الاجازه السنويه المستحقه',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    specifiedDays = int.tryParse(value);
                  },
                ),
              ],
              if (leaveType == 'اجازة استثنائية') ...[
                const SizedBox(height: 16),
                _buildDropdownButton('عذر/بدون عذر', reason, (newValue) {
                  setState(() {
                    reason = newValue!;
                  });
                }, <String>['عذر', 'بدون عذر']),
              ],
              const SizedBox(height: 20),
              SaveToDB(
                buttonText: "vacation",
                emplyeeGallery: emplyeeGallery,
                empl: empl,
                pickedFile: pickedFile,
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            _submitRequest();
          },
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

  Widget _buildDropdownButton(String label, String? value,
      ValueChanged<String?> onChanged, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        DropdownButton<String>(
          value: value,
          hint: Text(label),
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onChanged: onChanged,
    );
  }

  void _submitRequest() {
    if (leaveType == "اجازة سنويه") {
      _firestoreManager.updateDocumentInCollection(
        "تقارير الاجازات",
        widget.doc['name'],
        "التقارير",
        "",
        {
          "object_id": PaySalaryDialog.object_id,
          "job":
              "تم نزول ${widget.doc['name']} اجازه بتاريخ $formattedDate علما بان له عدد ${widget.doc['vacationTime']}  من الايام المستحقه للاجازه السنويه و تم احتساب عدد $specifiedDays يوم منها "
        },
      );
      _firestoreManager.updateDocumentInCollection(
        "طلبات الاجازات",
        widget.doc['name'],
        "الطلبات",
        widget.doc['name'],
        {
          "leave_type": leaveType,
          "leave_date": formattedDate,
          "specified_days": specifiedDays,
          "reason": leaveType == 'اجازة استثنائية' ? reason : null,
        },
      );
      _firestoreManager.updateDocument(
        "الموظفين",
        widget.doc['name'],
        {
          "status": "اجازه",
          "vacationTime":
              (int.parse(widget.doc['vacationTime']) - specifiedDays!)
                  .toString(),
        },
      );
    }
    Navigator.pop(context);
  }
}
