import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hr_app/classes/departments.dart';
import 'package:hr_app/components/colors.dart';
import 'package:hr_app/screens/departmentDetailPage.dart';
import 'package:hr_app/managers/firebaseHelper.dart';

const List<Color> colorPalette = [
  Colors.lightBlue, // Light Blue
  Colors.lightGreen, // Light Green
  Colors.orangeAccent, // Orange
];

const List<IconData> departmentIcons = [
  Icons.people, // for "إدارة الموارد البشريه"
  Icons.business, // for "إداره الشركه"
  Icons.money, // for "إدارة الموارد الماليه"
  Icons.handshake, // for "إدارة الموارد الماليه"
  Icons.file_copy, // for "إدارة الموارد الماليه"
  Icons.payment_rounded, // for "إدارة الموارد الماليه"
  Icons.build, // for "إدارة الموارد الماليه"
  Icons.architecture, // for "إدارة الموارد الماليه"

  // Add other icons as needed
];

class DepartmentsList extends StatefulWidget {
  const DepartmentsList({Key? key}) : super(key: key);

  @override
  State<DepartmentsList> createState() => _DepartmentsListState();
}

class _DepartmentsListState extends State<DepartmentsList>
    with TickerProviderStateMixin {
  final FirestoreManager _firestoreManager = FirestoreManager();
  List<Departments> departments = [];
  bool isLoading = true;
  bool isOpen = false;
  int selectedIndex = -10;
  String searchQuery = '';
  late List<AnimationController> _controllers;
  late List<Animation<double>> _opacityAnimations;
  late List<Animation<double>> _scaleAnimations;
  Departments? selectedDepartment;

  @override
  void initState() {
    super.initState();
    fetchDepartments();
    _controllers = List<AnimationController>.generate(8, (index) {
      // Adjusted for 7 departments
      return AnimationController(
        duration: const Duration(seconds: 1),
        vsync: this,
      )..forward();
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

  void fetchDepartments() async {
    try {
      List<Map<String, dynamic>> depsData =
          await _firestoreManager.getAllDocuments("إدارات");
      setState(() {
        departments = depsData
            .map((dep) => Departments(
                  name: dep['name'],
                  manager: dep['manager'],
                  location: dep['location'] ?? "",
                  projects: [],
                ))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching departments: $e");
      setState(() {
        isLoading = false;
      });
    }
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
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredList = departments
        .where((department) =>
            department.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isOpen)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'بحث...',
                    border: InputBorder.none,
                    icon: Icon(Icons.search),
                  ),
                ),
              ),
            ),
          if (isOpen && selectedDepartment != null)
            DepartmentDetailPage(department: selectedDepartment!)
          else if (filteredList.isEmpty)
            const Expanded(
              child: Center(
                child: Text('لا توجد نتائج'),
              ),
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
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  return _buildAnimatedGridItem(filteredList[index],
                      departmentIcons[index % departmentIcons.length], index);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnimatedGridItem(
      Departments department, IconData icon, int index) {
    final Color color = colorPalette[index % colorPalette.length];
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
            selectedDepartment = department;
            selectedIndex = index;
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
                  department.name,
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
