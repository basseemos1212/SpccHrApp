import 'package:flutter/material.dart';
import 'package:hr_app/components/colors.dart';
import 'package:hr_app/components/lists.dart';
import 'package:hr_app/screens/departments%D9%8DScreen.dart';
import 'package:hr_app/screens/employeeDataPage.dart';
import 'package:hr_app/screens/jobsScreen.dart';
import 'package:hr_app/screens/workLocationScreen.dart';

const List<Color> colorPalette = [
  Colors.lightBlue, // Light Blue
  Colors.lightGreen, // Light Green
  Colors.orangeAccent, // Orange
];

const List<IconData> fileIcons = [
  Icons.person, // for "الموظفين"
  Icons.account_balance, // for "الإدارات"
  Icons.location_city, // for "المواقع"
  Icons.work, // for "الوظائف"
];

class Files extends StatefulWidget {
  final String direction;
  const Files({Key? key, required this.direction}) : super(key: key);

  @override
  State<Files> createState() => _FilesState();
}

class _FilesState extends State<Files> with TickerProviderStateMixin {
  bool isOpen = false;
  int selectedIndex = -1;
  String searchQuery = '';
  late List<AnimationController> _controllers;
  late List<Animation<double>> _opacityAnimations;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _controllers =
        List<AnimationController>.generate(filesList.length, (index) {
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
    final filteredList = filesList
        .where((item) => item.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: widget.direction == 'homePage'
          ? AppBar(
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
                        'الملفات',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
              backgroundColor: Colors.white,
            )
          : null,
      body: Column(
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
          if (isOpen && selectedIndex == 0)
            const EmployeeDataPage()
          else if (isOpen && selectedIndex == 1)
            const DepartmentsScreen()
          else if (isOpen && selectedIndex == 2)
            const WorkLocationsScreen()
          else if (isOpen && selectedIndex == 3)
            const JobsScreen()
          else
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  childAspectRatio: 1.1,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                padding: const EdgeInsets.all(8),
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  return _buildAnimatedGridItem(
                      filteredList[index], fileIcons[index], index);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnimatedGridItem(String title, IconData icon, int index) {
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
            isOpen = true;
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
                  title,
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
