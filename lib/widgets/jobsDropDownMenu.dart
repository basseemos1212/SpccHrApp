import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hr_app/classes/job.dart';

class JobsDropdown extends StatefulWidget {
  final TextEditingController textEditingController;

  final void Function(Job selectedJob)? onChanged;

  const JobsDropdown({
    super.key,
    required this.textEditingController,
    this.onChanged,
  });

  @override
  // ignore: library_private_types_in_public_api
  _JobsDropdownState createState() => _JobsDropdownState();
}

class _JobsDropdownState extends State<JobsDropdown> {
  Job? _selectedJob;
  List<Job> jobList = [];

  @override
  void initState() {
    super.initState();
    _fetchJobs();
  }

  Future<void> _fetchJobs() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('الوظائف').get();
    setState(() {
      jobList = querySnapshot.docs
          .map(
              (doc) => Job(name: doc['name'], department: "", employeeList: []))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              height: 50, // Set the height as per your requirement
              width: MediaQuery.of(context).size.width * 0.21,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(15), // Set the border radius
                border: Border.all(
                  width: 0.5, // Set the border width
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: DropdownButton<Job>(
                  value: _selectedJob,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedJob = newValue;
                      widget.textEditingController.text =
                          _selectedJob?.name ?? '';

                      if (widget.onChanged != null) {
                        widget.onChanged!(newValue!);
                      }
                    });
                  },
                  items: jobList.map((job) {
                    return DropdownMenuItem<Job>(
                      value: job,
                      child: Text(job.name),
                    );
                  }).toList(),
                  hint: const Text('اختيار الوظيفه'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
