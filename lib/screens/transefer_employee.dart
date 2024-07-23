import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';

class TransferEmployee extends StatefulWidget {
  const TransferEmployee({super.key});

  @override
  State<TransferEmployee> createState() => _TransferEmployeeState();
}

class _TransferEmployeeState extends State<TransferEmployee> {
  String? _selectedEmployeeId;
  String? _selectedEmployeeName;
  String? _selectedEmployeeImage;

  String? _selectedDepartment;
  String? _selectedLocation;
  String? _selectedJob;
  String? _selectedProject;

  Future<void> _fetchEmployeeDetails(String employeeName) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('الموظفين')
        .where('name', isEqualTo: employeeName)
        .get();
    if (result.docs.isNotEmpty) {
      final data = result.docs.first.data() as Map<String, dynamic>;
      setState(() {
        _selectedEmployeeId = result.docs.first.id;
        _selectedEmployeeName = data['name'];
        _selectedEmployeeImage = data['imageUrl'];
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCollectionData(
      String collection) async {
    final QuerySnapshot result =
        await FirebaseFirestore.instance.collection(collection).get();
    return result.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<List<Map<String, dynamic>>> _fetchSubCollectionData(
      String collection, String documentId, String subCollection) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection(collection)
        .doc(documentId)
        .collection(subCollection)
        .get();
    return result.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<void> _transferEmployee() async {
    try {
      await FirebaseFirestore.instance
          .collection('الموظفين')
          .doc(_selectedEmployeeId)
          .update({
        'department': _selectedDepartment,
        'location': _selectedLocation,
        'job': _selectedJob,
        'project': _selectedProject,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم نقل الموظف  بنجاح')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء تحديث البيانات: $e')),
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
                // ignore: prefer_const_constructors
                Text('نقل الموظف')
              ],
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('الموظفين')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const CircularProgressIndicator();
                  var employeeList = snapshot.data!.docs.map((doc) {
                    return {
                      'id': doc.id,
                      'name': doc['name'],
                      'imageUrl': doc['imageUrl'],
                    };
                  }).toList();
                  return DropdownSearch<Map<String, dynamic>>(
                    items: employeeList,
                    itemAsString: (item) => item!['name'],
                    onChanged: (item) {
                      setState(() {
                        _selectedEmployeeName = item!['name'];
                        _selectedEmployeeImage = item['imageUrl'];
                        _fetchEmployeeDetails(_selectedEmployeeName!);
                      });
                    },
                    selectedItem: _selectedEmployeeName == null
                        ? null
                        : {
                            'name': _selectedEmployeeName,
                          },
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        hintText: 'اختر الموظف',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    popupProps: PopupProps.dialog(
                      showSearchBox: true,
                      itemBuilder: (context, item, isSelected) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: item['imageUrl'] != null
                                ? Image.network(item['imageUrl'],
                                    width: 50, height: 50, fit: BoxFit.cover)
                                : Image.asset('assets/profile.jpeg',
                                    width: 50, height: 50, fit: BoxFit.cover),
                            title: Text(item['name']),
                          ),
                        );
                      },
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          hintText: 'بحث',
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchCollectionData('إدارات'),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const CircularProgressIndicator();
                  return DropdownSearch<Map<String, dynamic>>(
                    items: snapshot.data!,
                    itemAsString: (item) => item!['name'],
                    onChanged: (item) {
                      setState(() {
                        _selectedDepartment = item!['name'];
                      });
                    },
                    selectedItem: _selectedDepartment == null
                        ? null
                        : {
                            'name': _selectedDepartment,
                          },
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        hintText: 'اختر الإدارة',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchCollectionData('ألمواقع'),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const CircularProgressIndicator();
                  return DropdownSearch<Map<String, dynamic>>(
                    items: snapshot.data!,
                    itemAsString: (item) => item!['name'],
                    onChanged: (item) {
                      setState(() {
                        _selectedLocation = item!['name'];
                      });
                    },
                    selectedItem: _selectedLocation == null
                        ? null
                        : {
                            'name': _selectedLocation,
                          },
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        hintText: 'اختر الموقع',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchCollectionData('الوظائف'),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const CircularProgressIndicator();
                  return DropdownSearch<Map<String, dynamic>>(
                    items: snapshot.data!,
                    itemAsString: (item) => item!['name'],
                    onChanged: (item) {
                      setState(() {
                        _selectedJob = item!['name'];
                      });
                    },
                    selectedItem: _selectedJob == null
                        ? null
                        : {
                            'name': _selectedJob,
                          },
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        hintText: 'اختر الوظيفة',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              if (_selectedDepartment != null)
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchSubCollectionData(
                      'إدارات', _selectedDepartment!, 'مشاريع'),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return const CircularProgressIndicator();
                    return DropdownSearch<Map<String, dynamic>>(
                      items: snapshot.data!,
                      itemAsString: (item) => item!['name'],
                      onChanged: (item) {
                        setState(() {
                          _selectedProject = item!['name'];
                        });
                      },
                      selectedItem: _selectedProject == null
                          ? null
                          : {
                              'name': _selectedProject,
                            },
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          hintText: 'اختر المشروع',
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _transferEmployee,
                  child: const Text('نقل الموظف'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
