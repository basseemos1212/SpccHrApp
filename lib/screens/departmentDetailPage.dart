import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hr_app/classes/departments.dart';
import 'package:hr_app/components/colors.dart';
import 'package:hr_app/managers/firebaseHelper.dart';

class DepartmentDetailPage extends StatefulWidget {
  final Departments department;

  const DepartmentDetailPage({super.key, required this.department});

  @override
  State<DepartmentDetailPage> createState() => _DepartmentDetailPageState();
}

class _DepartmentDetailPageState extends State<DepartmentDetailPage> {
  List<Map<String, dynamic>> projects = [];
  List<Map<String, dynamic>> employees = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDepartmentDetails();
  }

  Future<void> fetchDepartmentDetails() async {
    try {
      // Fetch projects
      List<Map<String, dynamic>> projectData = await FirebaseFirestore.instance
          .collection('إدارات')
          .doc(widget.department.name)
          .collection('مشاريع')
          .get()
          .then((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());

      // Fetch employees
      List<Map<String, dynamic>> employeeData = await FirebaseFirestore.instance
          .collection('الموظفين')
          .where('department', isEqualTo: widget.department.name)
          .get()
          .then((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());

      setState(() {
        projects = projectData;
        employees = employeeData;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching department details: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addProject(String projectName) async {
    try {
      await FirebaseFirestore.instance
          .collection('إدارات')
          .doc(widget.department.name)
          .collection('مشاريع')
          .add({'name': projectName});
      setState(() {
        projects.add({'name': projectName});
      });
    } catch (e) {
      print("Error adding project: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(),
      ),
    );
  }

  void _showAddProjectDialog() {
    String projectName = "";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة مشروع جديد'),
        content: TextField(
          decoration: const InputDecoration(hintText: 'اسم المشروع'),
          onChanged: (value) {
            projectName = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              if (projectName.isNotEmpty) {
                addProject(projectName);
              }
              Navigator.of(context).pop();
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  Widget _buildManagerImage() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.2,
      width: MediaQuery.of(context).size.height * 0.2,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage("assets/logo.png"),
          fit: BoxFit.contain,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }

  Padding customTile({
    required BuildContext context,
    required String headLine,
    required String line,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headLine,
                  style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  line,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Padding employeeTile(Map<String, dynamic> employee) {
    final profileUrl = employee['profile_url'] ?? '';
    final imageProvider = profileUrl.isNotEmpty
        ? NetworkImage(profileUrl)
        : AssetImage('assets/profile.jpeg') as ImageProvider;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: imageProvider,
            radius: MediaQuery.of(context).size.height * 0.025,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                employee['name'],
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                employee['number'],
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Text headLine(String headLine) {
    return Text(
      headLine,
      style: const TextStyle(
          fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 18),
    );
  }
}
