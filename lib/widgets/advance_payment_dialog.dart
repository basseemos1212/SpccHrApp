import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:hr_app/components/colors.dart';
import 'package:hr_app/managers/firebaseHelper.dart';
import 'package:hr_app/screens/paySalary.dart';
import 'package:hr_app/widgets/saveToDB.dart';

class AdvancePaymentDialog extends StatefulWidget {
  final dynamic doc;
  const AdvancePaymentDialog({super.key, this.doc});

  @override
  State<AdvancePaymentDialog> createState() => _AdvancePaymentDialogState();
}

class _AdvancePaymentDialogState extends State<AdvancePaymentDialog> {
  final FirestoreManager _firestoreManager = FirestoreManager();
  DateTime pickedDate = DateTime.now();
  String applyDate = '';
  String approveDate = '';
  String transferDate = '';
  TextEditingController advancePaymentController = TextEditingController();
  XFile? pickedFile;
  ParseFileBase? empl;
  ParseObject emplyeeGallery = ParseObject("s");

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text(
          'تسليم سلفه لموظف',
          style: TextStyle(
            color: primaryColor,
          ),
        ),
        content: SizedBox(
          // width: MediaQuery.of(context).size.width * 0.2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDateButton('تاريخ تقديم الطلب', applyDate, (date) {
                setState(() {
                  applyDate = date;
                });
              }),
              const SizedBox(height: 20),
              _buildDateButton('تاريخ اعتماد الطلب', approveDate, (date) {
                setState(() {
                  approveDate = date;
                });
              }),
              const SizedBox(height: 20),
              _buildDateButton('تاريخ صرف السلفه', transferDate, (date) {
                setState(() {
                  transferDate = date;
                });
              }),
              const SizedBox(height: 20),
              _buildAdvancePaymentField(),
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
                "object_id": PaySalaryDialog.object_id,
                "job":
                    "تم صرف للموظف ${widget.doc['name']} يوم $transferDate مبلغ و قدره ${advancePaymentController.text} ريال حيث تم تقديم الطلب من قبل الموظف يوم $applyDate و تمت الموافقه عليه من قبل اداره الشركه يوم $approveDate"
              });
              Navigator.pop(context);
            },
            child: const Text('تسليم السلفه للموظف'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('غلق'),
          ),
        ],
      ),
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
          String formattedDate = "${picked.day}/${picked.month}/${picked.year}";
          onDateSelected(formattedDate);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Text(
          '$label: $date',
          style: const TextStyle(fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildAdvancePaymentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'مبلغ السلفه',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.1,
          child: TextField(
            controller: advancePaymentController,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              hintText: 'أدخل المبلغ هنا',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            ),
          ),
        ),
      ],
    );
  }
}
