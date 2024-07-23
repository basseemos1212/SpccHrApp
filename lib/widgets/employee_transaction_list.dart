import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:hr_app/classes/employee.dart';
import 'package:hr_app/components/colors.dart';
import 'package:hr_app/components/lists.dart';
import 'package:hr_app/managers/firebaseHelper.dart';
import 'package:intl/intl.dart';
import 'package:hr_app/screens/paySalary.dart';
import 'package:hr_app/widgets/advance_payment_dialog.dart';
import 'package:hr_app/widgets/editable_dialog.dart';
import 'package:hr_app/widgets/end_vacation_dialog.dart';
import 'package:hr_app/widgets/outAndNotReturnedDialog.dart';
import 'package:hr_app/widgets/rating_dialog.dart';
import 'package:hr_app/widgets/reActivateEmployee.dart';
import 'package:hr_app/widgets/request_vacation_dialog.dart';
import 'package:hr_app/widgets/runDatepicker.dart';
import 'package:hr_app/widgets/saveToDB.dart';
import 'package:hr_app/widgets/stopEmployeeDialog.dart';
import 'package:hr_app/widgets/stopInjury.dart';
import 'package:hr_app/widgets/transport_employee.dart';
import 'package:hr_app/widgets/work_injury_dialog.dart';

class EmployeeTransactionList extends StatefulWidget {
  final String transaction;
  const EmployeeTransactionList({super.key, required this.transaction});

  @override
  State<EmployeeTransactionList> createState() =>
      _EmployeeTransactionListState();
}

class _EmployeeTransactionListState extends State<EmployeeTransactionList> {
  XFile? pickedFile;
  ParseFileBase? empl;
  dynamic emplyeeGallery = ParseObject("s");
  List<Map<String, dynamic>> docs = [];
  bool loading = true;
  final FirestoreManager _firestoreManager = FirestoreManager();

  @override
  void initState() {
    super.initState();
    _firestoreManager.getAllDocuments("الموظفين").then((value) {
      setState(() {
        docs = value;
      });
    });
    Future.delayed(const Duration(seconds: 4), () {
      setState(() {
        loading = false;
      });
    });
  }

  Future<void> saveToDB(
      String className, ParseFileBase? parseFile, dynamic gallery) async {
    final result = await FilePicker.platform.pickFiles(
      type: className == "profileImages" ? FileType.image : FileType.any,
    );

    if (result != null) {
      final file = result.files.first;
      setState(() {
        pickedFile = XFile(file.path.toString());
      });
    }

    if (kIsWeb) {
      parseFile =
          ParseWebFile(await pickedFile!.readAsBytes(), name: pickedFile!.name);
    } else {
      parseFile = ParseFile(File(pickedFile!.path));
    }

    await parseFile.save();
    empl = parseFile;

    gallery = ParseObject(className)..set('file', parseFile, forceUpdate: true);
    await gallery.save();
    emplyeeGallery = gallery;
  }

  bool isOpen = false;
  int selectedIndex = -10;
  Employee employee = Employee(
    name: "",
    department: "",
    endDate: "",
    enterDate: "",
    vacationsTime: "",
    number: "",
    image: "",
    job: "",
    status: "",
    rate: 0,
    salary: 0,
    nationality: "",
    relegion: "",
    vacations: "",
    salaryAlternatives: {},
    workStatus: "",
    finalJobPrize: "",
    workLocation: "",
  );

  @override
  Widget build(BuildContext context) {
    return loading
        ? Center(
            child: Lottie.asset(
              'assets/lottie/loading.json',
              height: 1200,
              width: 1200,
              fit: BoxFit.contain,
              repeat: false,
            ),
          )
        : docs.isEmpty
            ? Center(
                child: Lottie.asset(
                  'assets/lottie/empty.json',
                  height: 1200,
                  width: 1200,
                  fit: BoxFit.contain,
                  repeat: true,
                ),
              )
            : ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: headLine(getTransactionHeadline(widget.transaction)),
                  ),
                  generateEmployeeList(docs)
                ],
              );
  }

  String getTransactionHeadline(String transaction) {
    switch (transaction) {
      case "startWork":
        return "اختر الموظف لتقوم بعمل مباشرة عمل له";
      case "upgradeSalary":
        return "ترقيه موظف";
      case "advancePayment":
        return "سلفه موظف";
      case "transportEmployee":
        return "نقل الموظف";
      case "run":
        return "تسجيل هروب موظف";
      case "workInjury":
        return "تسجيل اصابه عمل";
      case "stopWorkInjury":
        return "ايقاف اصابه عمل";
      case "stopEmployee":
        return "ايقاف موظف";
      case "activate":
        return "تنشيط موظف";
      case "out":
        return "تسجيل خروج موظف بلا عوده";
      case "endVacation":
        return "تسجيل عوده اجازه موظف";
      case "requestVacation":
        return "تسجيل اجازه موظف";
      default:
        return "تعديل تقيم الموظف";
    }
  }

  Text headLine(String headLine) {
    return Text(
      headLine,
      style: const TextStyle(
          fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 20),
    );
  }

  Widget generateEmployeeList(List<dynamic> docs) {
    List<Map<String, dynamic>>? filteredDocs =
        docs.cast<Map<String, dynamic>>();
    if (widget.transaction == "startWork") {
      filteredDocs = docs
          .where((doc) => doc['workStatus'] == "لم تتم مباشره العمل بعد")
          .cast<Map<String, dynamic>>()
          .toList();
    }
    return Column(
      children: filteredDocs!.map((doc) {
        final profileUrl = doc['profile_url'] ?? '';
        final imageProvider = profileUrl.isNotEmpty
            ? NetworkImage(profileUrl)
            : AssetImage('assets/logo.png') as ImageProvider;

        final employee = Employee(
          name: doc['name'],
          department: doc['department'],
          endDate: doc['endDate'],
          enterDate: doc['date'],
          vacationsTime: doc['vacationTime'],
          number: doc['number'],
          image: profileUrl,
          job: doc['job'],
          status: "حالته",
          rate: 0,
          salary: double.parse(doc['mainSalary']),
          nationality: doc['name'],
          relegion: doc['name'],
          vacations: doc['vacationStatus'],
          salaryAlternatives: {
            "homeAltSalary": doc['homeAltSalary'],
            "livingAltSalary": doc['homeAltSalary'],
            "responsabilityAlt": doc['responsabilityAlt'],
            "transportAlt": doc['transportAlt'],
            "plusAltSalary": doc['plusAltSalary'],
          },
          workStatus: doc['workStatus'],
          finalJobPrize: "لم يتم حسابها بعد",
          workLocation: doc['location'],
        );

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => handleEmployeeTap(doc, employee),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: imageProvider,
                  backgroundColor: Colors.white,
                  radius: MediaQuery.of(context).size.height * 0.04,
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${doc['job']} :  ${doc['name']}",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      doc['number'],
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void handleEmployeeTap(dynamic doc, Employee employee) {
    setState(() {
      isOpen = true;
      selectedIndex = docs.indexOf(doc);
      this.employee = employee;

      final dialog = getTransactionDialog(widget.transaction, doc);
      if (dialog != null) {
        showDialog(context: context, builder: (context) => dialog);
      }
    });
  }

  Widget? getTransactionDialog(String transaction, dynamic doc) {
    switch (transaction) {
      case "upgradeSalary":
        return PromoteEmployee(
          homeAlt: doc['homeAltSalary'],
          resAlt: doc['responsabilityAlt'],
          salary: doc['mainSalary'],
          transAlt: doc['transportAlt'],
          job: doc['job'],
          location: doc['location'],
          doc: doc,
        );
      case "transportEmployee":
        return TransportEmployee(doc: doc);
      case "run":
        return CustomDatePickerDialog(doc: doc);
      case "stopWorkInjury":
        return StopInjuryDialog(docs: doc);
      case "editRate":
        return RatingDialog(doc: doc);
      case "workInjury":
        return InjuryDialog(docs: doc);
      case "stopEmployee":
        return StopEmployeeDialog(docs: doc);
      case "paySalary":
        return PaySalaryDialog(doc: doc);
      case "advancePayment":
        return AdvancePaymentDialog(doc: doc);
      case "requestVacation":
        return RequestVacationDialog(doc: doc);
      case "endVacation":
        return EndVacationDialog(doc: doc);
      case "activate":
        return ReActivateDialog(docs: doc);
      case "out":
        return OutAndNotReturnedDialog(docs: doc);
      default:
        return getStartWorkDialog(doc);
    }
  }

  Widget getStartWorkDialog(dynamic doc) {
    DateTime selectedDate = DateTime.now();
    final formatter = DateFormat('dd/MM/yyyy');

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return AlertDialog(
          title: headLine("اختر تاريخ مباشره الخدمه"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null && pickedDate != selectedDate) {
                    setState(() {
                      selectedDate = pickedDate;
                    });
                  }
                },
                child: Text('التاريخ: ${formatter.format(selectedDate)}'),
              ),
              SaveToDB(
                buttonText: "startWorkDoc ",
                emplyeeGallery: emplyeeGallery,
                empl: empl,
                pickedFile: pickedFile,
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _firestoreManager.updateDocument(
                  "الموظفين",
                  doc['name'],
                  {
                    "status": "نشط",
                    "workStatus":
                        "تمت مباشرة الخدمة يوم ${formatter.format(selectedDate)}",
                    "projectStartWork": formatter.format(selectedDate),
                    "work_start_file": PaySalaryDialog.object_id,
                  },
                );
                Navigator.of(context).pop(formatter.format(selectedDate));
              },
              child: const Text('اضافه مباشره الخدمه'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('غلق'),
            ),
          ],
        );
      },
    );
  }
}
