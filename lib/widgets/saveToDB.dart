import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:hr_app/components/colors.dart';
import 'package:hr_app/managers/firebaseHelper.dart';
import 'package:hr_app/screens/paySalary.dart';

// ignore: must_be_immutable
class SaveToDB extends StatefulWidget {
  final String buttonText;
  XFile? pickedFile;

  ParseFileBase? empl;

  ParseObject emplyeeGallery;

  SaveToDB({
    super.key,
    required this.buttonText,
    this.pickedFile,
    this.empl,
    required this.emplyeeGallery,
  });

  @override
  State<SaveToDB> createState() => _SaveToDBState();
}

class _SaveToDBState extends State<SaveToDB> {
  String status = "";
  bool isUploaded = false;
  FirestoreManager firestoreManager = FirestoreManager();
  Future<void> saveToDB(
      String className, ParseFileBase? parseFile, dynamic gallery) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: className == "profileImages" ? FileType.image : FileType.any);

    if (result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        widget.pickedFile = XFile(file.path.toString());
      });
    }

    //Flutter Mobile/Desktop

    if (widget.pickedFile != null) {
      parseFile = ParseFile(File(widget.pickedFile!.path));
      setState(() {
        isUploaded = true;
      });
      // Continue with your code that uses parseFile
    } else {
      // Handle the case where widget.pickedFile is null
    }

    print(parseFile?.name);
    await parseFile?.save();
    widget.empl = parseFile;
    print(parseFile?.saved);

    gallery = ParseObject(className)..set('file', parseFile, forceUpdate: true);

    await gallery.save();
    print("gal is ${gallery.objectId}");
    widget.emplyeeGallery = gallery;
    print(widget.emplyeeGallery.objectId);
    PaySalaryDialog.object_id = widget.emplyeeGallery.objectId.toString();
    setState(() {
      isUploaded = false;
      status = "done";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: !isUploaded
          ? ElevatedButton.icon(
              onPressed: () {
                if (status != "done") {
                  saveToDB(
                      widget.buttonText, widget.empl, widget.emplyeeGallery);
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.blue), // Change to your primary color
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  const EdgeInsets.all(16),
                ),
              ),
              icon: const Icon(
                Icons.upload,
                color: Colors.white,
              ),
              label: Text(
                status != "done" ? "ارفاق المستند" : "تم ارفاق المستند",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : const CircularProgressIndicator(
              color: primaryColor,
            ),
    );
  }
}
