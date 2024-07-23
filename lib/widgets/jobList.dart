import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hr_app/classes/job.dart';
import 'package:hr_app/components/colors.dart';
import 'package:hr_app/managers/firebaseHelper.dart';
import 'package:hr_app/screens/jobDetailScreen.dart';

const List<Color> colorPalette = [
  Colors.lightBlue, // Light Blue
  Colors.lightGreen, // Light Green
  Colors.orangeAccent, // Orange
];

const Map<String, IconData> jobIcons = {
  "فني تنفيذي": Icons.build,
  "مدير الشركه": Icons.business,
  "مدير عمليات موقع": Icons.location_city,
  "مدير مشروع": Icons.assignment,
  "مراقب موقع": Icons.visibility,
  "مسؤول تخطيط و جدوله": Icons.schedule,
  "مسؤول مشتريات": Icons.shopping_cart,
  "مهندس برمجيات": Icons.code,
  "مهندس كهرباء": Icons.electrical_services,
  "مهندس مدني": Icons.location_on,
  "مهندس ميكانيكي": Icons.settings,
};

class JobList extends StatefulWidget {
  const JobList({super.key});

  @override
  State<JobList> createState() => _JobListState();
}

class _JobListState extends State<JobList> with TickerProviderStateMixin {
  List<Map<String, dynamic>> jobs = [];
  final FirestoreManager _firestoreManager = FirestoreManager();
  bool isOpen = false;
  int selectedIndex = -10;
  Job job = Job(name: "name", department: "department", employeeList: []);
  late List<AnimationController> _controllers;
  late List<Animation<double>> _opacityAnimations;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _firestoreManager.getAllDocuments("الوظائف").then((value) => setState(() {
          jobs = value;
          _initializeAnimations();
        }));
  }

  void _initializeAnimations() {
    _controllers = List<AnimationController>.generate(jobs.length, (index) {
      return AnimationController(
        duration: const Duration(seconds: 1),
        vsync: this,
      );
    });

    _opacityAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    _scaleAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 0.8, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    _startStaggeredAnimations();
  }

  void _startStaggeredAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (isOpen)
            Expanded(
              child: JobDetailScreen(job: job),
            )
          else
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  childAspectRatio: 1,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                padding: const EdgeInsets.all(8),
                itemCount: jobs.length,
                itemBuilder: (context, index) {
                  final Color color = colorPalette[index % colorPalette.length];
                  final IconData icon =
                      jobIcons[jobs[index]['name']] ?? Icons.work;
                  return _buildAnimatedGridItem(
                      jobs[index], color, icon, index);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnimatedGridItem(
      Map<String, dynamic> job, Color color, IconData icon, int index) {
    return AnimatedBuilder(
      animation: _controllers[index],
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimations[index].value,
          child: Transform.scale(
            scale: _scaleAnimations[index].value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            isOpen = true;
            selectedIndex = index;
            this.job = Job(
              name: job['name'],
              department: job['department'] ?? "",
              employeeList: [],
            );
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 36,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  job['name'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
