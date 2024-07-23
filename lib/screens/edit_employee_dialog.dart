import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:hr_app/classes/employee.dart';
import 'package:hr_app/components/colors.dart';
import 'package:hr_app/managers/firebaseHelper.dart';

class EditEmployeeDialog extends StatefulWidget {
  final Employee employee;
  final Map<String, dynamic> doc;

  const EditEmployeeDialog(
      {super.key, required this.employee, required this.doc});

  @override
  _EditEmployeeDialogState createState() => _EditEmployeeDialogState();
}

class _EditEmployeeDialogState extends State<EditEmployeeDialog> {
  final FirestoreManager _firestoreManager = FirestoreManager();
  TextEditingController numberController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController departmentTextEditingController =
      TextEditingController();
  TextEditingController locationTextEditingController = TextEditingController();
  TextEditingController workEndDateController = TextEditingController();
  TextEditingController vacationStatusController = TextEditingController();
  TextEditingController vacationTimeController = TextEditingController();
  TextEditingController mainSalaryController = TextEditingController();
  TextEditingController homeAlternativeSalaryController =
      TextEditingController();
  TextEditingController transportaionAlternativeSalaryController =
      TextEditingController();
  TextEditingController livingAlternativeSalaryController =
      TextEditingController();
  TextEditingController responsabilityAlternativeController =
      TextEditingController();
  TextEditingController plusAlternativeSalaryController =
      TextEditingController();
  TextEditingController totalSalaryController = TextEditingController();
  TextEditingController idNumberController = TextEditingController();
  String? selectedLicenseType;
  String? selectedCarType;

  final List<String> licenseTypes = [
    'خاصه',
    'نقل ثقيل',
    'عمومي',
    'لا يوجد',
  ];

  final List<String> carTypes = [
    'خاصه',
    'تابعه للشركه',
    'لا يوجد',
  ];

  @override
  void initState() {
    super.initState();
    numberController.text = widget.employee.number;
    startDateController.text = widget.employee.enterDate;
    departmentTextEditingController.text = widget.employee.department;
    locationTextEditingController.text = widget.employee.workLocation;
    workEndDateController.text = widget.employee.endDate;
    vacationStatusController.text = widget.employee.vacations;
    vacationTimeController.text = widget.employee.vacationsTime;
    mainSalaryController.text = widget.employee.salary.toString();
    homeAlternativeSalaryController.text =
        widget.doc['homeAltSalary']?.toString() ?? '';
    transportaionAlternativeSalaryController.text =
        widget.doc['transportAlt']?.toString() ?? '';
    livingAlternativeSalaryController.text =
        widget.doc['livingAltSalary']?.toString() ?? '';
    responsabilityAlternativeController.text =
        widget.doc['responsabilityAlt']?.toString() ?? '';
    plusAlternativeSalaryController.text =
        widget.doc['plusAltSalary']?.toString() ?? '';
    totalSalaryController.text = (widget.employee.salary +
            (int.tryParse(widget.doc['homeAltSalary']?.toString() ?? '0') ??
                0) +
            (int.tryParse(widget.doc['transportAlt']?.toString() ?? '0') ?? 0) +
            (int.tryParse(widget.doc['livingAltSalary']?.toString() ?? '0') ??
                0) +
            (int.tryParse(widget.doc['responsabilityAlt']?.toString() ?? '0') ??
                0) +
            (int.tryParse(widget.doc['plusAltSalary']?.toString() ?? '0') ?? 0))
        .toString();
    idNumberController.text = widget.doc['idNumber'] ?? 'لا يوجد';
    selectedLicenseType = widget.doc['licenseType'] ?? 'لا يوجد';
    selectedCarType = widget.doc['carType'] ?? 'لا يوجد';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "تعديل بيانات الموظف",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryColor),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    textEditingController: numberController,
                    isobsecureText: false,
                    hintText: "رقم الموظف",
                    isValidate: true,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    textEditingController: startDateController,
                    isobsecureText: false,
                    hintText: "التاريخ",
                    isValidate: true,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    textEditingController: departmentTextEditingController,
                    isobsecureText: false,
                    hintText: "القسم",
                    isValidate: true,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    textEditingController: locationTextEditingController,
                    isobsecureText: false,
                    hintText: "موقع العمل",
                    isValidate: true,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    textEditingController: workEndDateController,
                    isobsecureText: false,
                    hintText: "تاريخ انتهاء العقد",
                    isValidate: true,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    textEditingController: vacationStatusController,
                    isobsecureText: false,
                    hintText: "يملك اجازه بعد كم شهر من مباشرة العمل",
                    isValidate: true,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    textEditingController: vacationTimeController,
                    isobsecureText: false,
                    hintText: "مده الاجازه السنويه",
                    isValidate: true,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    textEditingController: mainSalaryController,
                    isobsecureText: false,
                    hintText: "الراتب الاساسي",
                    isValidate: true,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    textEditingController: homeAlternativeSalaryController,
                    isobsecureText: false,
                    hintText: "بدل السكن",
                    isValidate: false,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    textEditingController:
                        transportaionAlternativeSalaryController,
                    isobsecureText: false,
                    hintText: "بدل النقل",
                    isValidate: false,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    textEditingController: livingAlternativeSalaryController,
                    isobsecureText: false,
                    hintText: "بدل الاعاشه",
                    isValidate: false,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    textEditingController: responsabilityAlternativeController,
                    isobsecureText: false,
                    hintText: "بدل المسئوليه",
                    isValidate: false,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    textEditingController: plusAlternativeSalaryController,
                    isobsecureText: false,
                    hintText: "بدل اضافي مقطوع",
                    isValidate: false,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    textEditingController: idNumberController,
                    isobsecureText: false,
                    hintText: "رقم الهويه",
                    isValidate: true,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "نوع الرخصه",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    items: licenseTypes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedLicenseType = newValue;
                      });
                    },
                    value: selectedLicenseType,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "سياره",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    items: carTypes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedCarType = newValue;
                      });
                    },
                    value: selectedCarType,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      final updatedEmployee = <String, dynamic>{
                        "number": numberController.text,
                        "date": startDateController.text,
                        "department": departmentTextEditingController.text,
                        "location": locationTextEditingController.text,
                        "endDate": workEndDateController.text,
                        "vacationStatus": vacationStatusController.text,
                        "vacationTime": vacationTimeController.text,
                        "mainSalary": mainSalaryController.text,
                        "homeAltSalary": homeAlternativeSalaryController.text,
                        "transportAlt":
                            transportaionAlternativeSalaryController.text,
                        "livingAltSalary":
                            livingAlternativeSalaryController.text,
                        "responsabilityAlt":
                            responsabilityAlternativeController.text,
                        "plusAltSalary": plusAlternativeSalaryController.text,
                        "idNumber": idNumberController.text,
                        "licenseType": selectedLicenseType,
                        "carType": selectedCarType,
                      };
                      _firestoreManager.updateDocument(
                          "الموظفين", widget.employee.name, updatedEmployee);
                      Navigator.of(context).pop();
                    },
                    child: const Text("حفظ"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isobsecureText;
  final String hintText;
  final bool isValidate;

  const CustomTextField({
    super.key,
    required this.textEditingController,
    required this.isobsecureText,
    required this.hintText,
    required this.isValidate,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textEditingController,
      obscureText: isobsecureText,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
