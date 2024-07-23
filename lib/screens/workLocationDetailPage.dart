import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hr_app/classes/workLocation.dart';
import 'package:hr_app/components/colors.dart';

class WorkLocationDetailScreen extends StatefulWidget {
  final WorkLocation workLocation;
  const WorkLocationDetailScreen({super.key, required this.workLocation});

  @override
  State<WorkLocationDetailScreen> createState() =>
      _WorkLocationDetailScreenState();
}

class _WorkLocationDetailScreenState extends State<WorkLocationDetailScreen> {
  List<Map<String, dynamic>> employees = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    try {
      List<Map<String, dynamic>> employeeData = await FirebaseFirestore.instance
          .collection('الموظفين')
          .where('location', isEqualTo: widget.workLocation.name)
          .get()
          .then((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());

      setState(() {
        employees = employeeData;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching employees: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headLine("الموظفين"),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: employees.length,
                        itemBuilder: (context, index) {
                          return employeeTile(employees[index]);
                        },
                      ),
                    ),
                  ],
                ),
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
            radius: MediaQuery.of(context).size.height * 0.03,
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
