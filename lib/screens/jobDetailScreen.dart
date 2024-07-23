import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hr_app/classes/job.dart';
import 'package:hr_app/components/colors.dart';
import 'package:hr_app/screens/jobsScreen.dart';

class JobDetailScreen extends StatefulWidget {
  final Job job;
  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  List<Map<String, dynamic>> employees = [];
  bool isLoading = true;
  bool isBack = false;

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    try {
      List<Map<String, dynamic>> employeeData = await FirebaseFirestore.instance
          .collection('الموظفين')
          .where('job', isEqualTo: widget.job.name)
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
    return isBack
        ? const JobsScreen()
        : Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              appBar: AppBar(
                title: Text(widget.job.name),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      isBack = true;
                    });
                  },
                ),
              ),
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
                                var employee = employees[index];
                                return employeeTile(employee);
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
        : AssetImage('assets/logo.png') as ImageProvider;

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
