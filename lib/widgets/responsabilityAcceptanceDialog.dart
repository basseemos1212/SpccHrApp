import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hr_app/components/colors.dart';
import 'package:hr_app/managers/firebaseHelper.dart';
import 'package:hr_app/widgets/multilineTextField.dart';

class ResponsabilityAcceptanceDialog extends StatefulWidget {
  final dynamic doc;
  const ResponsabilityAcceptanceDialog({super.key, this.doc});

  @override
  State<ResponsabilityAcceptanceDialog> createState() =>
      _ResponsabilityAcceptanceDialogState();
}

class _ResponsabilityAcceptanceDialogState
    extends State<ResponsabilityAcceptanceDialog> {
  String transferDate = ""; // New field for transfer date
  FirestoreManager _firestoreManager = FirestoreManager();
  DateTime pickedDate = DateTime.now();
  TextEditingController advancePaymentController = TextEditingController();
  String formattedDate = "";

  @override
  void initState() {
    super.initState();
    // Initialize controllers with initial text
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'استلام عهده لموظف',
        style: TextStyle(
          color: primaryColor,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () async {
              pickedDate = (await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              ))!;

              // Update selectedDate if user picked a date
              setState(() {
                formattedDate =
                    "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
              });
              // setState(() {
              //   selectedDate = formattedDate; // Update state variable
              // });

              // You can save the formatted date here or use it as needed
              print("Selected Date: $formattedDate");
            },
            child: Text(
              'تاريخ استلام العهده : $formattedDate ',
            ),
          ),
          const SizedBox(
              height: 16), // Spacer between the button and the fields

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'استلام',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                  height: 8), // Spacer between the header and TextField
              MultilineTextField(controller: advancePaymentController)
            ],
          )
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            _firestoreManager.updateDocumentInCollection(
                "تقارير الاصول", widget.doc['name'], "التقارير", "", {
              "job":
                  "\nتم استلام عهده : \n${advancePaymentController.text} \n يوم $formattedDate"
            });
            Navigator.pop(context);
          },
          child: const Text(' استلام العهده للموظف'),
        ),
        TextButton(
          onPressed: () {
            // Close the dialog without saving
            Navigator.pop(context);
          },
          child: const Text('غلق'),
        ),
      ],
    );
  }

  void onJobChanged(String newJob) {
    setState(() {
      // job = newJob;
    });
  }

  void onDepartmentChange(String newDep) {
    setState(() {
      // department = newDep;
    });
  }

  void onLocationChange(String newLoc) {
    setState(() {
      // location = newLoc;
    });
  }

  void onTransferDateChanged(String newDate) {
    setState(() {
      transferDate = newDate;
    });
  }
}
