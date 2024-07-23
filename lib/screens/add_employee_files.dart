import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';

class AddEmployeeFiles extends StatefulWidget {
  const AddEmployeeFiles({super.key});

  @override
  _AddEmployeeFilesState createState() => _AddEmployeeFilesState();
}

class _AddEmployeeFilesState extends State<AddEmployeeFiles> {
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String? _selectedEmployeeName;
  String? _selectedEmployeeImage;
  List<PlatformFile> _pickedFiles = [];

  Future<void> _pickDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<List<Map<String, dynamic>>> _getEmployees() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('الموظفين').get();
    return querySnapshot.docs
        .map((doc) => {
              'id': doc.id,
              'name': doc['name'],
              'imageUrl': doc['imageUrl'],
            })
        .toList();
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(allowMultiple: true);
      if (result != null) {
        setState(() {
          _pickedFiles = result.files;
        });
      } else {
        // User canceled the picker
        print('File picking was canceled');
      }
    } catch (error) {
      print('Error picking files: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking files: $error')),
      );
    }
  }

  Future<void> _uploadFiles(String folder) async {
    if (_selectedEmployeeName == null || _pickedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار موظف وملفات للتحميل')),
      );
      return;
    }

    try {
      for (PlatformFile file in _pickedFiles) {
        String fileName = file.name;
        String filePath = file.path!;

        // Upload file to Firebase Storage
        File fileToUpload = File(filePath);
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('employees/${_selectedEmployeeName}/$folder/$fileName');
        UploadTask uploadTask = storageRef.putFile(fileToUpload);

        TaskSnapshot taskSnapshot = await uploadTask;
        String fileUrl = await taskSnapshot.ref.getDownloadURL();

        // Update Firestore with file details
        await FirebaseFirestore.instance
            .collection('الموظفين')
            .doc(_selectedEmployeeName)
            .update({
          'fileUrls': FieldValue.arrayUnion([
            {
              'name': fileName,
              'url': fileUrl,
              'folder': folder,
            }
          ])
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحميل الملفات بنجاح')),
      );

      Navigator.pop(context);
    } catch (error) {
      print('Error uploading files: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء تحميل الملفات: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/logo.png',
                  height: 40,
                ),
                const SizedBox(width: 10),
                const Text(
                  'إضافة ملفات للموظف',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _getEmployees(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                var employees = snapshot.data ?? [];
                return DropdownSearch<Map<String, dynamic>>(
                  items: employees,
                  itemAsString: (employee) => employee!['name'],
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    itemBuilder: (context, employee, isSelected) {
                      return ListTile(
                        leading: employee['imageUrl'] != null
                            ? Image.network(employee['imageUrl'],
                                width: 30, height: 30)
                            : Container(width: 30, height: 30),
                        title: Text(employee['name']),
                      );
                    },
                  ),
                  onChanged: (employee) {
                    setState(() {
                      _selectedEmployeeName = employee!['name'];
                      _selectedEmployeeImage = employee['imageUrl'];
                    });
                  },
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: "اختر الموظف",
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            FolderWidget(
              title: 'ملفات الاصول',
              onFilesPicked: (files) {
                setState(() {
                  _pickedFiles = files;
                });
                _uploadFiles('ملفات الاصول');
              },
            ),
            FolderWidget(
              title: 'ملفات الماليات',
              onFilesPicked: (files) {
                setState(() {
                  _pickedFiles = files;
                });
                _uploadFiles('ملفات الماليات');
              },
            ),
            FolderWidget(
              title: 'العقود',
              onFilesPicked: (files) {
                setState(() {
                  _pickedFiles = files;
                });
                _uploadFiles('العقود');
              },
            ),
            FolderWidget(
              title: 'الهويه',
              onFilesPicked: (files) {
                setState(() {
                  _pickedFiles = files;
                });
                _uploadFiles('الهويه');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class FolderWidget extends StatefulWidget {
  final String title;
  final ValueChanged<List<PlatformFile>> onFilesPicked;

  const FolderWidget({
    Key? key,
    required this.title,
    required this.onFilesPicked,
  }) : super(key: key);

  @override
  _FolderWidgetState createState() => _FolderWidgetState();
}

class _FolderWidgetState extends State<FolderWidget> {
  bool _isOpen = false;
  List<PlatformFile> _pickedFiles = [];

  void _toggleFolder() {
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(allowMultiple: true);
      if (result != null) {
        setState(() {
          _pickedFiles = result.files;
        });
        widget.onFilesPicked(_pickedFiles);
      } else {
        // User canceled the picker
        print('File picking was canceled');
      }
    } catch (error) {
      print('Error picking files: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking files: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(widget.title),
          trailing: Icon(_isOpen ? Icons.expand_less : Icons.expand_more),
          onTap: _toggleFolder,
        ),
        if (_isOpen)
          Column(
            children: [
              ElevatedButton(
                onPressed: _pickFiles,
                child: const Text('اختر الملفات'),
              ),
              const SizedBox(height: 20),
              if (_pickedFiles.isNotEmpty)
                Text(
                  'الملفات المختارة:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              for (var file in _pickedFiles)
                ListTile(
                  title: Text(file.name),
                ),
            ],
          ),
      ],
    );
  }
}
