import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hr_app/classes/employee.dart';
import 'package:hr_app/components/lists.dart';
import 'package:hr_app/managers/firebaseHelper.dart';
import 'package:hr_app/widgets/end_vacation_dialog.dart';

class EndVacationScreen extends StatefulWidget {
  const EndVacationScreen({super.key});

  @override
  State<EndVacationScreen> createState() => _EndVacationScreenState();
}

class _EndVacationScreenState extends State<EndVacationScreen> {
  List<Map<String, dynamic>> docs = [];
  dynamic rate = 0;
  int selectedNumber = 0;
  final FirestoreManager _firestoreManager =
      FirestoreManager(); // Instantiate FirestoreManager
  CollectionReference users = FirebaseFirestore.instance.collection('الموظفين');
  @override
  void initState() {
    _firestoreManager
        .getAllDocuments("الموظفين")
        .then((value) => setState(() {
              docs = value;
            }))
        .then((value) => print(docs));

    super.initState();
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
      workLocation: "");
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: headLine("انهاء اجازه موظف"),
        ),
        generateEmployeeList(docs)
      ]),
    );
  }

  Text headLine(String headLine) {
    return Text(
      headLine,
      style: const TextStyle(
          fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 20),
    );
  }

  Widget generateEmployeeList(List<dynamic> docs) {
    List<Widget> employeeWidgets = [];

    for (var doc in docs) {
      employeeWidgets.add(
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Directionality(
                    textDirection: TextDirection.rtl,
                    child: EndVacationDialog(
                      doc: doc,
                    ));
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(employees[0].image),
                  radius: MediaQuery.of(context).size.height * 0.055,
                ),
                const SizedBox(
                  width: 10,
                ),
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
        ),
      );
    }

    return Column(
      children: employeeWidgets,
    );
  }
}
