import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:hr_app/components/colors.dart';
import 'package:hr_app/managers/firebaseHelper.dart';
import 'package:hr_app/widgets/departmentDropDown.dart';
import 'package:hr_app/widgets/jobsDropDownMenu.dart';
import 'package:hr_app/widgets/locationDropDown.dart';

class TransportEmployee extends StatefulWidget {
  final dynamic doc;

  const TransportEmployee({
    super.key,
    required this.doc,
  });

  @override
  // ignore: library_private_types_in_public_api
  _TransportEmployeeState createState() => _TransportEmployeeState();
}

class _TransportEmployeeState extends State<TransportEmployee> {
  String job = "";
  String department = "";
  String location = "";
  String oldJob = "";
  String oldDepartment = "";
  String oldLocation = "";
  String transferDate = ""; // New field for transfer date
  final FirestoreManager _firestoreManager = FirestoreManager();
  DateTime pickedDate = DateTime.now();
  String formattedDate = "";
  TextEditingController jobController = TextEditingController();
  TextEditingController departmentTextEditingController =
      TextEditingController();
  TextEditingController locationTextEditingController = TextEditingController();
  XFile? pickedFile;
  ParseFileBase? empl;

  ParseObject emplyeeGallery = ParseObject("s");
  Future<void> saveToDB(
      String className, ParseFileBase? parseFile, dynamic gallery) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: className == "profileImages" ? FileType.image : FileType.any);

    if (result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        pickedFile = XFile(file.path.toString());
      });
    }

    if (kIsWeb) {
      //Flutter Web
      parseFile = ParseWebFile(await pickedFile!.readAsBytes(),
          name: pickedFile!.name); //Name for file is required
    } else {
      //Flutter Mobile/Desktop

      parseFile = ParseFile(File(pickedFile!.path));
    }
    print(parseFile.name);
    await parseFile.save();
    empl = parseFile;
    print(parseFile.saved);

    gallery = ParseObject(className)..set('file', parseFile, forceUpdate: true);

    await gallery.save();
    emplyeeGallery = gallery;
    print(gallery.objectId);
  }

  @override
  void initState() {
    super.initState();
    // Initialize controllers with initial text
    setState(() {
      oldJob = widget.doc['job'];
      oldLocation = widget.doc['location'];
      oldDepartment = widget.doc['department'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'نقل الموظف',
        style: TextStyle(
          color: primaryColor,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          JobsDropdown(
            textEditingController: jobController,
          ),
          DepartmentsDropdown(
              textEditingController: departmentTextEditingController),
          LocationsDropdown(
              textEditingController: locationTextEditingController),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                saveToDB("transportDoc", empl, emplyeeGallery);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(primaryColor),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.all(16)),
              ),
              icon: const Icon(
                Icons.upload,
                color: Colors.white,
              ), // Upload icon
              label: const Text(
                "ارفاق المستند",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
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
            },
            child: Text(
              'تاريخ النقل : $formattedDate ',
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            String dateString2 = formattedDate;
            String dateString1 = widget.doc['projectStartWork'];

            DateFormat dateFormat = DateFormat('d/M/yyyy');

            DateTime date1 = dateFormat.parse(dateString1);
            DateTime date2 = dateFormat.parse(dateString2);

            Duration difference = date2.difference(date1);
            int differenceInDays = difference.inDays;

            print("Difference in days: $differenceInDays");
            _firestoreManager.updateDocumentInCollection(
                "تقارير التحركات", widget.doc['name'], "التقارير", "", {
              "object_id": emplyeeGallery.objectId,
              "job":
                  "تم في تاريخ يوم $formattedDate نقل الموظف ${widget.doc['name']} من وظيفته $oldJob الي ${jobController.text} و من الموقع $oldLocation الي ${locationTextEditingController.text} و من اداره $oldDepartment الي ${departmentTextEditingController.text}  بعد مده $differenceInDays يوم و ذلك من تاريخ ${widget.doc['projectStartWork']} حتي تاريخ $formattedDate  ",
            }).then((value) {
              _firestoreManager.updateDocument("الموظفين", widget.doc['name'], {
                "department": departmentTextEditingController.text,
                "job": jobController.text,
                "location": locationTextEditingController.text,
                "projectStartWork": formattedDate,
                "transferDate": transferDate,
              });
            });

            Navigator.pop(context);
          },
          child: const Text('نقل الموظف'),
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
      job = newJob;
    });
  }

  void onDepartmentChange(String newDep) {
    setState(() {
      department = newDep;
    });
  }

  void onLocationChange(String newLoc) {
    setState(() {
      location = newLoc;
    });
  }

  void onTransferDateChanged(String newDate) {
    setState(() {
      transferDate = newDate;
    });
  }

  Widget _buildEditableField(
    String header,
    String value,
    Function(String) onChanged,
  ) {
    return Row(
      children: [
        Text(header), // Header
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2101),
                locale: const Locale("ar", "AE"), // Change locale to Arabic
              );
              if (picked != null) {
                final formattedDate =
                    "${picked.day}/${picked.month}/${picked.year}";
                onChanged(formattedDate);
              }
            },
            child: AbsorbPointer(
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: value,
                ),
                controller: TextEditingController(text: value),
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableDropdown(
    String header,
    List<String> options,
    String selectedOption,
    Function(String) onOptionChanged,
  ) {
    return Row(
      children: [
        Text(header), // Header
        SizedBox(width: 10), // Spacer
        DropdownButton<String>(
          value: selectedOption,
          onChanged: (newValue) {
            onOptionChanged(newValue!);
          },
          items: options.map<DropdownMenuItem<String>>((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
        ),
        SizedBox(width: 10), // Spacer
      ],
    );
  }
}
